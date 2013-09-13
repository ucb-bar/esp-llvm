//===-- RISCVISelLowering.cpp - RISCV DAG lowering implementation -----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the RISCVTargetLowering class.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "riscv-lower"

#include "RISCVISelLowering.h"
#include "RISCVCallingConv.h"
#include "RISCVConstantPoolValue.h"
#include "RISCVMachineFunctionInfo.h"
#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

// Classify VT as either 32 or 64 bit.
static bool is32Bit(EVT VT) {
  switch (VT.getSimpleVT().SimpleTy) {
  case MVT::i32:
    return true;
  case MVT::i64:
    return false;
  default:
    llvm_unreachable("Unsupported type");
  }
}

static const uint16_t RV32IntRegs[8] = {
  RISCV::a0, RISCV::a1, RISCV::a2, RISCV::a3,
  RISCV::a4, RISCV::a5, RISCV::a6, RISCV::a7
};

static const uint16_t RV64IntRegs[8] = {
  RISCV::a0_64, RISCV::a1_64, RISCV::a2_64, RISCV::a3_64,
  RISCV::a4_64, RISCV::a5_64, RISCV::a6_64, RISCV::a7_64
};

// Return a version of MachineOperand that can be safely used before the
// final use.
static MachineOperand earlyUseOperand(MachineOperand Op) {
  if (Op.isReg())
    Op.setIsKill(false);
  return Op;
}

RISCVTargetLowering::RISCVTargetLowering(RISCVTargetMachine &tm)
  : TargetLowering(tm, new TargetLoweringObjectFileELF()),
    Subtarget(*tm.getSubtargetImpl()), TM(tm), 
    IsRV32(Subtarget.isRV32()) {
  MVT PtrVT = getPointerTy();

  // Set up the register classes.
  if(Subtarget.isRV64())
    addRegisterClass(MVT::i64,  &RISCV::GR64BitRegClass);
  else
    addRegisterClass(MVT::i32,  &RISCV::GR32BitRegClass);
  if(Subtarget.hasD())
    addRegisterClass(MVT::f64,  &RISCV::FP64BitRegClass);
  else if(Subtarget.hasF())
    addRegisterClass(MVT::f32,  &RISCV::FP32BitRegClass);

  // Compute derived properties from the register classes
  computeRegisterProperties();

  // Set up special registers.
  // TODO: not all of these exist in RISCV
  setExceptionPointerRegister(RISCV::epc);
  setExceptionSelectorRegister(RISCV::evec);
  setStackPointerRegisterToSaveRestore(RISCV::sp);

  // TODO: It may be better to default to latency-oriented scheduling, however
  // LLVM's current latency-oriented scheduler can't handle physreg definitions
  // such as RISCV has with PSW, so set this to the register-pressure
  // scheduler, because it can.
  setSchedulingPreference(Sched::RegPressure);

  //For i1 types all bits are zero except bit 0
  setBooleanContents(ZeroOrOneBooleanContent);
  setBooleanVectorContents(ZeroOrOneBooleanContent); //vectors of i1s are the same

  // Instructions are strings of 2-byte aligned 2-byte values.
  // align by log2(2) bytes?
  setMinFunctionAlignment(2);

  // Handle operations that are handled in a similar way for all types.
  for (unsigned I = MVT::FIRST_INTEGER_VALUETYPE;
       I <= MVT::LAST_FP_VALUETYPE;
       ++I) {
    MVT VT = MVT::SimpleValueType(I);
    if (isTypeLegal(VT)) {
      // Expand SETCC(X, Y, COND) into SELECT_CC(X, Y, 1, 0, COND).
      setOperationAction(ISD::SETCC, VT, Legal);//folds into brcond

      // Expand SELECT(C, A, B) into SELECT_CC(X, 0, A, B, NE).
      //setOperationAction(ISD::SELECT, VT, Expand);

      // Lower SELECT_CC and BR_CC into separate comparisons and branches.
      setOperationAction(ISD::SELECT_CC, VT, Expand);
      setOperationAction(ISD::BR_CC,     VT, Expand);

    }
  }

  // Expand jump table branches as address arithmetic followed by an
  // indirect jump.
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);
  //RISCV also does not have indirect branch so expand them
  setOperationAction(ISD::BRIND, MVT::Other, Expand);

  //Expand build_pair i64 since we don't support i64
  setOperationAction(ISD::BUILD_PAIR, MVT::i64, Expand);

  //make BRCOND legal, its actually only legal for a subset of conds
  setOperationAction(ISD::BRCOND, MVT::Other, Legal);

  // Handle integer types.
  for (unsigned I = MVT::FIRST_INTEGER_VALUETYPE;
       I <= MVT::LAST_INTEGER_VALUETYPE;
       ++I) {
    MVT VT = MVT::SimpleValueType(I);
    if (isTypeLegal(VT)) {
      if(Subtarget.hasM()) {
        setOperationAction(ISD::MUL  , VT, Legal);
        setOperationAction(ISD::MULHS, VT, Legal);
        setOperationAction(ISD::MULHU, VT, Legal);
        setOperationAction(ISD::SDIV , VT, Legal);
        setOperationAction(ISD::UDIV , VT, Legal);
        setOperationAction(ISD::SREM , VT, Legal);
        setOperationAction(ISD::UREM , VT, Legal);
      }else{
        setOperationAction(ISD::MUL  , VT, Expand);
        setOperationAction(ISD::MULHS, VT, Expand);
        setOperationAction(ISD::MULHU, VT, Expand);
        setOperationAction(ISD::SDIV , VT, Expand);
        setOperationAction(ISD::UDIV , VT, Expand);
        setOperationAction(ISD::SREM , VT, Expand);
        setOperationAction(ISD::UREM , VT, Expand);
      }

      // Expand ATOMIC_LOAD and ATOMIC_STORE using ATOMIC_CMP_SWAP.
      // FIXME: probably much too conservative.
      setOperationAction(ISD::ATOMIC_LOAD,  VT, Expand);
      setOperationAction(ISD::ATOMIC_STORE, VT, Expand);

      // No special instructions for these.
      setOperationAction(ISD::CTPOP,           VT, Expand);
      setOperationAction(ISD::CTTZ,            VT, Expand);
      setOperationAction(ISD::CTTZ_ZERO_UNDEF, VT, Expand);
      setOperationAction(ISD::CTLZ_ZERO_UNDEF, VT, Expand);
      setOperationAction(ISD::ROTR,            VT, Expand);

      // We have instructions for signed but not unsigned FP conversion.
      setOperationAction(ISD::FP_TO_UINT, VT, Expand);
    }
  }

  // Type legalization will convert 8- and 16-bit atomic operations into
  // forms that operate on i32s (but still keeping the original memory VT).
  // Lower them into full i32 operations.
  setOperationAction(ISD::ATOMIC_SWAP,      MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_ADD,  MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_SUB,  MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_AND,  MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_OR,   MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_XOR,  MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_NAND, MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_MIN,  MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_MAX,  MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_UMIN, MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_LOAD_UMAX, MVT::i32, Custom);
  setOperationAction(ISD::ATOMIC_CMP_SWAP,  MVT::i32, Custom);

  // We have instructions for signed but not unsigned FP conversion.
  // Handle unsigned 32-bit types as signed 64-bit types.
  setOperationAction(ISD::UINT_TO_FP, MVT::i32, Promote);
  //setOperationAction(ISD::UINT_TO_FP, MVT::i64, Expand);

  // We have native support for a 64-bit CTLZ, via FLOGR.
  setOperationAction(ISD::CTLZ, MVT::i32, Promote);
  //setOperationAction(ISD::CTLZ, MVT::i64, Legal);

  // Give LowerOperation the chance to replace 64-bit ORs with subregs.
  //setOperationAction(ISD::OR, MVT::i64, Custom);

  // The architecture has 32-bit SMUL_LOHI and UMUL_LOHI (MR and MLR),
  // but they aren't really worth using.  There is no 64-bit SMUL_LOHI,
  // but there is a 64-bit UMUL_LOHI: MLGR.
  setOperationAction(ISD::SDIVREM, MVT::i32, Expand);
  setOperationAction(ISD::UDIVREM, MVT::i32, Expand);
  setOperationAction(ISD::SDIVREM, MVT::i64, Expand);
  setOperationAction(ISD::UDIVREM, MVT::i64, Expand);
  setOperationAction(ISD::SMUL_LOHI, MVT::i32, Expand);
  setOperationAction(ISD::SMUL_LOHI, MVT::i64, Expand);
  setOperationAction(ISD::UMUL_LOHI, MVT::i32, Expand);
  setOperationAction(ISD::UMUL_LOHI, MVT::i64, Custom);

  // FIXME: Can we support these natively?
  //setOperationAction(ISD::SRL_PARTS, MVT::i64, Expand);
  //setOperationAction(ISD::SHL_PARTS, MVT::i64, Expand);
  //setOperationAction(ISD::SRA_PARTS, MVT::i64, Expand);

  // We have native instructions for i8, i16 and i32 extensions, but not i1.
  setLoadExtAction(ISD::SEXTLOAD, MVT::i1, Promote);
  setLoadExtAction(ISD::ZEXTLOAD, MVT::i1, Promote);
  setLoadExtAction(ISD::EXTLOAD,  MVT::i1, Promote);
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i1, Expand);
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i8, Expand);
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i16, Expand);

  // Handle the various types of symbolic address.
  setOperationAction(ISD::ConstantPool,     PtrVT, Custom);
  setOperationAction(ISD::GlobalAddress,    PtrVT, Custom);
  setOperationAction(ISD::GlobalTLSAddress, PtrVT, Custom);
  setOperationAction(ISD::BlockAddress,     PtrVT, Custom);
  setOperationAction(ISD::JumpTable,        PtrVT, Custom);

  // We need to handle dynamic allocations specially because of the
  // 160-byte area at the bottom of the stack.
  setOperationAction(ISD::DYNAMIC_STACKALLOC, PtrVT, Expand);

  // Use custom expanders so that we can force the function to use
  // a frame pointer.
  setOperationAction(ISD::STACKSAVE,    MVT::Other, Custom);
  setOperationAction(ISD::STACKRESTORE, MVT::Other, Custom);

  // Expand these using getExceptionSelectorRegister() and
  // getExceptionPointerRegister().
  setOperationAction(ISD::EXCEPTIONADDR, PtrVT, Expand);
  setOperationAction(ISD::EHSELECTION,   PtrVT, Expand);

  // Handle floating-point types.
  for (unsigned I = MVT::FIRST_FP_VALUETYPE;
       I <= MVT::LAST_FP_VALUETYPE;
       ++I) {
    MVT VT = MVT::SimpleValueType(I);
    if (isTypeLegal(VT)) {
      // We can use FI for FRINT.
      setOperationAction(ISD::FRINT, VT, Legal);

      // No special instructions for these.
      setOperationAction(ISD::FSIN, VT, Expand);
      setOperationAction(ISD::FCOS, VT, Expand);
      setOperationAction(ISD::FREM, VT, Expand);
    }
  }

  // We have fused multiply-addition for f32 and f64 but not f128.
  setOperationAction(ISD::FMA, MVT::f32,  Legal);
  setOperationAction(ISD::FMA, MVT::f64,  Legal);
  setOperationAction(ISD::FMA, MVT::f128, Expand);

  // Needed so that we don't try to implement f128 constant loads using
  // a load-and-extend of a f80 constant (in cases where the constant
  // would fit in an f80).
  setLoadExtAction(ISD::EXTLOAD, MVT::f80, Expand);

  // Floating-point truncation and stores need to be done separately.
  setTruncStoreAction(MVT::f64,  MVT::f32, Expand);
  setTruncStoreAction(MVT::f128, MVT::f32, Expand);
  setTruncStoreAction(MVT::f128, MVT::f64, Expand);

  // We have 64-bit FPR<->GPR moves, but need special handling for
  // 32-bit forms.
  setOperationAction(ISD::BITCAST, MVT::i32, Custom);
  setOperationAction(ISD::BITCAST, MVT::f32, Custom);

  // VASTART and VACOPY need to deal with the RISCV-specific varargs
  // structure, but VAEND is a no-op.
  setOperationAction(ISD::VASTART, MVT::Other, Custom);
  setOperationAction(ISD::VACOPY,  MVT::Other, Custom);
  setOperationAction(ISD::VAEND,   MVT::Other, Expand);
}

bool RISCVTargetLowering::isFPImmLegal(const APFloat &Imm, EVT VT) const {
  // We can load zero using LZ?R and negative zero using LZ?R;LC?BR.
  return Imm.isZero() || Imm.isNegZero();
}

//===----------------------------------------------------------------------===//
// Inline asm support
//===----------------------------------------------------------------------===//

TargetLowering::ConstraintType
RISCVTargetLowering::getConstraintType(const std::string &Constraint) const {
  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
    case 'a': // Address register
    case 'd': // Data register (equivalent to 'r')
    case 'f': // Floating-point register
    case 'r': // General-purpose register
      return C_RegisterClass;

    case 'Q': // Memory with base and unsigned 12-bit displacement
    case 'R': // Likewise, plus an index
    case 'S': // Memory with base and signed 20-bit displacement
    case 'T': // Likewise, plus an index
    case 'm': // Equivalent to 'T'.
      return C_Memory;

    case 'I': // Unsigned 8-bit constant
    case 'J': // Unsigned 12-bit constant
    case 'K': // Signed 16-bit constant
    case 'L': // Signed 20-bit displacement (on all targets we support)
    case 'M': // 0x7fffffff
      return C_Other;

    default:
      break;
    }
  }
  return TargetLowering::getConstraintType(Constraint);
}

TargetLowering::ConstraintWeight RISCVTargetLowering::
getSingleConstraintMatchWeight(AsmOperandInfo &info,
                               const char *constraint) const {
  ConstraintWeight weight = CW_Invalid;
  Value *CallOperandVal = info.CallOperandVal;
  // If we don't have a value, we can't do a match,
  // but allow it at the lowest weight.
  if (CallOperandVal == NULL)
    return CW_Default;
  Type *type = CallOperandVal->getType();
  // Look at the constraint type.
  switch (*constraint) {
  default:
    weight = TargetLowering::getSingleConstraintMatchWeight(info, constraint);
    break;

  case 'a': // Address register
  case 'd': // Data register (equivalent to 'r')
  case 'r': // General-purpose register
    if (CallOperandVal->getType()->isIntegerTy())
      weight = CW_Register;
    break;

  case 'f': // Floating-point register
    if (type->isFloatingPointTy())
      weight = CW_Register;
    break;

  case 'I': // Unsigned 8-bit constant
    if (ConstantInt *C = dyn_cast<ConstantInt>(CallOperandVal))
      if (isUInt<8>(C->getZExtValue()))
        weight = CW_Constant;
    break;

  case 'J': // Unsigned 12-bit constant
    if (ConstantInt *C = dyn_cast<ConstantInt>(CallOperandVal))
      if (isUInt<12>(C->getZExtValue()))
        weight = CW_Constant;
    break;

  case 'K': // Signed 16-bit constant
    if (ConstantInt *C = dyn_cast<ConstantInt>(CallOperandVal))
      if (isInt<16>(C->getSExtValue()))
        weight = CW_Constant;
    break;

  case 'L': // Signed 20-bit displacement (on all targets we support)
    if (ConstantInt *C = dyn_cast<ConstantInt>(CallOperandVal))
      if (isInt<20>(C->getSExtValue()))
        weight = CW_Constant;
    break;

  case 'M': // 0x7fffffff
    if (ConstantInt *C = dyn_cast<ConstantInt>(CallOperandVal))
      if (C->getZExtValue() == 0x7fffffff)
        weight = CW_Constant;
    break;
  }
  return weight;
}

std::pair<unsigned, const TargetRegisterClass *> RISCVTargetLowering::
getRegForInlineAsmConstraint(const std::string &Constraint, EVT VT) const {
  if (Constraint.size() == 1) {
    // GCC Constraint Letters
    switch (Constraint[0]) {
    default: break;
    case 'd': // Data register (equivalent to 'r')
    case 'r': // General-purpose register
      return std::make_pair(0U, &RISCV::GR32BitRegClass);

    case 'a': // Address register
      return std::make_pair(0U, &RISCV::ADDR32BitRegClass);

    case 'f': // Floating-point register
      return std::make_pair(0U, &RISCV::FP32BitRegClass);
    }
  }
  return TargetLowering::getRegForInlineAsmConstraint(Constraint, VT);
}

void RISCVTargetLowering::
LowerAsmOperandForConstraint(SDValue Op, std::string &Constraint,
                             std::vector<SDValue> &Ops,
                             SelectionDAG &DAG) const {
  // Only support length 1 constraints for now.
  if (Constraint.length() == 1) {
    switch (Constraint[0]) {
    case 'I': // Unsigned 8-bit constant
      if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op))
        if (isUInt<8>(C->getZExtValue()))
          Ops.push_back(DAG.getTargetConstant(C->getZExtValue(),
                                              Op.getValueType()));
      return;

    case 'J': // Unsigned 12-bit constant
      if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op))
        if (isUInt<12>(C->getZExtValue()))
          Ops.push_back(DAG.getTargetConstant(C->getZExtValue(),
                                              Op.getValueType()));
      return;

    case 'K': // Signed 16-bit constant
      if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op))
        if (isInt<16>(C->getSExtValue()))
          Ops.push_back(DAG.getTargetConstant(C->getSExtValue(),
                                              Op.getValueType()));
      return;

    case 'L': // Signed 20-bit displacement (on all targets we support)
      if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op))
        if (isInt<20>(C->getSExtValue()))
          Ops.push_back(DAG.getTargetConstant(C->getSExtValue(),
                                              Op.getValueType()));
      return;

    case 'M': // 0x7fffffff
      if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op))
        if (C->getZExtValue() == 0x7fffffff)
          Ops.push_back(DAG.getTargetConstant(C->getZExtValue(),
                                              Op.getValueType()));
      return;
    }
  }
  TargetLowering::LowerAsmOperandForConstraint(Op, Constraint, Ops, DAG);
}

//===----------------------------------------------------------------------===//
//  Lower helper functions
//===----------------------------------------------------------------------===//

// addLiveIn - This helper function adds the specified physical register to the
// MachineFunction as a live in value.  It also creates a corresponding
// virtual register for it.
static unsigned
addLiveIn(MachineFunction &MF, unsigned PReg, const TargetRegisterClass *RC)
{
  unsigned VReg = MF.getRegInfo().createVirtualRegister(RC);
  MF.getRegInfo().addLiveIn(PReg, VReg);
  return VReg;
}

//Return the next register that can be paired with this one to pass doble word values
static unsigned getNextIntArgReg(unsigned Reg) {
  assert((Reg == RISCV::a0) || (Reg == RISCV::a2) || (Reg == RISCV::a4) || (Reg == RISCV::a6)); 
  return (Reg == RISCV::a0) ? RISCV::a1 :
         (Reg == RISCV::a2) ? RISCV::a3 :
         (Reg == RISCV::a4) ? RISCV::a5 :
                              RISCV::a7;
}

//===----------------------------------------------------------------------===//
// Calling conventions
//===----------------------------------------------------------------------===//

#include "RISCVGenCallingConv.inc"

// Value is a value that has been passed to us in the location described by VA
// (and so has type VA.getLocVT()).  Convert Value to VA.getValVT(), chaining
// any loads onto Chain.
static SDValue convertLocVTToValVT(SelectionDAG &DAG, DebugLoc DL,
                                   CCValAssign &VA, SDValue Chain,
                                   SDValue Value) {
  // If the argument has been promoted from a smaller type, insert an
  // assertion to capture this.
  if (VA.getLocInfo() == CCValAssign::SExt)
    Value = DAG.getNode(ISD::AssertSext, DL, VA.getLocVT(), Value,
                        DAG.getValueType(VA.getValVT()));
  else if (VA.getLocInfo() == CCValAssign::ZExt)
    Value = DAG.getNode(ISD::AssertZext, DL, VA.getLocVT(), Value,
                        DAG.getValueType(VA.getValVT()));

  if (VA.isExtInLoc())
    Value = DAG.getNode(ISD::TRUNCATE, DL, VA.getValVT(), Value);
  else if (VA.getLocInfo() == CCValAssign::Indirect)
    Value = DAG.getLoad(VA.getValVT(), DL, Chain, Value,
                        MachinePointerInfo(), false, false, false, 0);
  else
    assert(VA.getLocInfo() == CCValAssign::Full && "Unsupported getLocInfo");
  return Value;
}

// Value is a value of type VA.getValVT() that we need to copy into
// the location described by VA.  Return a copy of Value converted to
// VA.getValVT().  The caller is responsible for handling indirect values.
static SDValue convertValVTToLocVT(SelectionDAG &DAG, DebugLoc DL,
                                   CCValAssign &VA, SDValue Value) {
  switch (VA.getLocInfo()) {
  case CCValAssign::SExt:
    return DAG.getNode(ISD::SIGN_EXTEND, DL, VA.getLocVT(), Value);
  case CCValAssign::ZExt:
    return DAG.getNode(ISD::ZERO_EXTEND, DL, VA.getLocVT(), Value);
  case CCValAssign::AExt:
    return DAG.getNode(ISD::ANY_EXTEND, DL, VA.getLocVT(), Value);
  case CCValAssign::Full:
    return Value;
  default:
    llvm_unreachable("Unhandled getLocInfo()");
  }
}

/// This function returns true if CallSym is a long double emulation routine.
static bool isF128SoftLibCall(const char *CallSym) {
  const char *const LibCalls[] =
    {"__addtf3", "__divtf3", "__eqtf2", "__extenddftf2", "__extendsftf2",
     "__fixtfdi", "__fixtfsi", "__fixtfti", "__fixunstfdi", "__fixunstfsi",
     "__fixunstfti", "__floatditf", "__floatsitf", "__floattitf",
     "__floatunditf", "__floatunsitf", "__floatuntitf", "__getf2", "__gttf2",
     "__letf2", "__lttf2", "__multf3", "__netf2", "__powitf2", "__subtf3",
     "__trunctfdf2", "__trunctfsf2", "__unordtf2",
     "ceill", "copysignl", "cosl", "exp2l", "expl", "floorl", "fmal", "fmodl",
     "log10l", "log2l", "logl", "nearbyintl", "powl", "rintl", "sinl", "sqrtl",
     "truncl"};

  const char * const *End = LibCalls + array_lengthof(LibCalls);

  // Check that LibCalls is sorted alphabetically.
  RISCVTargetLowering::LTStr Comp;

#ifndef NDEBUG
  for (const char * const *I = LibCalls; I < End - 1; ++I)
    assert(Comp(*I, *(I + 1)));
#endif

  return std::binary_search(LibCalls, End, CallSym, Comp);
}

/// This function returns true if Ty is fp128 or i128 which was originally a
/// fp128.
static bool originalTypeIsF128(const Type *Ty, const SDNode *CallNode) {
  if (Ty->isFP128Ty())
    return true;

  const ExternalSymbolSDNode *ES =
    dyn_cast_or_null<const ExternalSymbolSDNode>(CallNode);

  // If the Ty is i128 and the function being called is a long double emulation
  // routine, then the original type is f128.
  return (ES && Ty->isIntegerTy(128) && isF128SoftLibCall(ES->getSymbol()));
}

//RISCVCC Implementation
RISCVTargetLowering::RISCVCC::RISCVCC(CallingConv::ID CC, bool IsRV32_,
                                   CCState &Info)
  : CCInfo(Info), CallConv(CC), IsRV32(IsRV32_) {
  // Pre-allocate reserved argument area.
  //TODO: is this entirely unused in RISCV
  CCInfo.AllocateStack(reservedArgArea(), 1);
}

void RISCVTargetLowering::RISCVCC::
analyzeFormalArguments(const SmallVectorImpl<ISD::InputArg> &Args,
                       bool IsSoftFloat, Function::const_arg_iterator FuncArg) {
  unsigned NumArgs = Args.size();
  llvm::CCAssignFn *FixedFn;
  if(!IsRV32)
    FixedFn = CC_RISCV64;
  else
    FixedFn = CC_RISCV32;
  unsigned CurArgIdx = 0;

  for (unsigned I = 0; I != NumArgs; ++I) {
    MVT ArgVT = Args[I].VT;
    ISD::ArgFlagsTy ArgFlags = Args[I].Flags;
    std::advance(FuncArg, Args[I].OrigArgIndex - CurArgIdx);
    CurArgIdx = Args[I].OrigArgIndex;

    if (ArgFlags.isByVal()) {
      handleByValArg(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags);
      continue;
    }

    MVT RegVT = getRegVT(ArgVT, FuncArg->getType(), 0, IsSoftFloat);

    if (!FixedFn(I, ArgVT, RegVT, CCValAssign::Full, ArgFlags, CCInfo))
      continue;

#ifndef NDEBUG
    dbgs() << "Formal Arg #" << I << " has unhandled type "
           << EVT(ArgVT).getEVTString();
#endif
    llvm_unreachable(0);
  }
}

MVT RISCVTargetLowering::RISCVCC::getRegVT(MVT VT, const Type *OrigTy,
                                         const SDNode *CallNode,
                                         bool IsSoftFloat) const {
  if (IsSoftFloat || IsRV32)
    return VT;

  // Check if the original type was fp128.
  if (originalTypeIsF128(OrigTy, CallNode)) {
    assert(VT == MVT::i64);
    return MVT::f64;
  }

  return VT;
}

void RISCVTargetLowering::
copyByValRegs(SDValue Chain, DebugLoc DL, std::vector<SDValue> &OutChains,
              SelectionDAG &DAG, const ISD::ArgFlagsTy &Flags,
              SmallVectorImpl<SDValue> &InVals, const Argument *FuncArg,
              const RISCVCC &CC, const ByValArgInfo &ByVal) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  unsigned RegAreaSize = ByVal.NumRegs * CC.regSize();
  unsigned FrameObjSize = std::max(Flags.getByValSize(), RegAreaSize);
  int FrameObjOffset;

  if (RegAreaSize)
    FrameObjOffset = (int)CC.reservedArgArea() -
      (int)((CC.numIntArgRegs() - ByVal.FirstIdx) * CC.regSize());
  else
    FrameObjOffset = ByVal.Address;

  // Create frame object.
  EVT PtrTy = getPointerTy();
  int FI = MFI->CreateFixedObject(FrameObjSize, FrameObjOffset, true);
  SDValue FIN = DAG.getFrameIndex(FI, PtrTy);
  InVals.push_back(FIN);

  if (!ByVal.NumRegs)
    return;

  // Copy arg registers.
  MVT RegTy = MVT::getIntegerVT(CC.regSize() * 8);
  const TargetRegisterClass *RC = getRegClassFor(RegTy);

  for (unsigned I = 0; I < ByVal.NumRegs; ++I) {
    unsigned ArgReg = CC.intArgRegs()[ByVal.FirstIdx + I];
    unsigned VReg = addLiveIn(MF, ArgReg, RC);
    unsigned Offset = I * CC.regSize();
    SDValue StorePtr = DAG.getNode(ISD::ADD, DL, PtrTy, FIN,
                                   DAG.getConstant(Offset, PtrTy));
    SDValue Store = DAG.getStore(Chain, DL, DAG.getRegister(VReg, RegTy),
                                 StorePtr, MachinePointerInfo(FuncArg, Offset),
                                 false, false, 0);
    OutChains.push_back(Store);
  }
}

void
RISCVTargetLowering::RISCVCC::handleByValArg(unsigned ValNo, MVT ValVT,
                                           MVT LocVT,
                                           CCValAssign::LocInfo LocInfo,
                                           ISD::ArgFlagsTy ArgFlags) {
  assert(ArgFlags.getByValSize() && "Byval argument's size shouldn't be 0.");

  struct ByValArgInfo ByVal;
  unsigned RegSize = regSize();
  unsigned ByValSize = RoundUpToAlignment(ArgFlags.getByValSize(), RegSize);
  unsigned Align = std::min(std::max(ArgFlags.getByValAlign(), RegSize),
                            RegSize * 2);

  /*TODO:do we need this
  if (useRegsForByval())
    allocateRegs(ByVal, ByValSize, Align);
  */

  // Allocate space on caller's stack.
  ByVal.Address = CCInfo.AllocateStack(ByValSize - RegSize * ByVal.NumRegs,
                                       Align);
  CCInfo.addLoc(CCValAssign::getMem(ValNo, ValVT, ByVal.Address, LocVT,
                                    LocInfo));
  ByValArgs.push_back(ByVal);
}

unsigned RISCVTargetLowering::RISCVCC::numIntArgRegs() const {
  return llvm::RISCV::NumArgGPRs;
}

unsigned RISCVTargetLowering::RISCVCC::reservedArgArea() const {
  return 0;
}

const uint16_t *RISCVTargetLowering::RISCVCC::intArgRegs() const {
  return IsRV32 ? RV32IntRegs : RV64IntRegs;
}
//End RISCVCC Implementation

SDValue RISCVTargetLowering::
LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
                     const SmallVectorImpl<ISD::InputArg> &Ins,
                     DebugLoc DL, SelectionDAG &DAG,
                     SmallVectorImpl<SDValue> &InVals) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  RISCVMachineFunctionInfo *RISCVFI = MF.getInfo<RISCVMachineFunctionInfo>();

  RISCVFI->setVarArgsFrameIndex(0);

  // Used with vargs to acumulate store chains.
  std::vector<SDValue> OutChains;

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(),
                 getTargetMachine(), ArgLocs, *DAG.getContext());
  RISCVCC RISCVCCInfo(CallConv, IsRV32, CCInfo);
  Function::const_arg_iterator FuncArg =
    DAG.getMachineFunction().getFunction()->arg_begin();
  bool UseSoftFloat = getTargetMachine().Options.UseSoftFloat;

  RISCVCCInfo.analyzeFormalArguments(Ins, UseSoftFloat, FuncArg);
  RISCVFI->setFormalArgInfo(CCInfo.getNextStackOffset(),
                           RISCVCCInfo.hasByValArg());

  unsigned CurArgIdx = 0;
  RISCVCC::byval_iterator ByValArg = RISCVCCInfo.byval_begin();

  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    std::advance(FuncArg, Ins[i].OrigArgIndex - CurArgIdx);
    CurArgIdx = Ins[i].OrigArgIndex;
    EVT ValVT = VA.getValVT();
    ISD::ArgFlagsTy Flags = Ins[i].Flags;
    bool IsRegLoc = VA.isRegLoc();

    if (Flags.isByVal()) {
      assert(Flags.getByValSize() &&
             "ByVal args of size 0 should have been ignored by front-end.");
      assert(ByValArg != RISCVCCInfo.byval_end());
      copyByValRegs(Chain, DL, OutChains, DAG, Flags, InVals, &*FuncArg,
                    RISCVCCInfo, *ByValArg);
      ++ByValArg;
      continue;
    }

    // Arguments stored on registers
    if (IsRegLoc) {
      EVT RegVT = VA.getLocVT();
      unsigned ArgReg = VA.getLocReg();
      const TargetRegisterClass *RC;

      if (RegVT == MVT::i32 || RegVT.getSizeInBits() < 32)//All word and subword values stored in GR32
        if(Subtarget.isRV64())
          RC = &RISCV::GR64BitRegClass;
        else
          RC = &RISCV::GR32BitRegClass;
      else if (RegVT == MVT::i64){
        if(Subtarget.isRV32()){
          //for RV32 store in pair of two GR32
          RC = &RISCV::PairGR64BitRegClass;
        }
      } else if (RegVT == MVT::f32) {
          if(Subtarget.hasF())
            RC = &RISCV::FP32BitRegClass;
          else if(Subtarget.hasD())
            RC = &RISCV::FP64BitRegClass;
          else
            RC = &RISCV::GR32BitRegClass;
      } else if (RegVT == MVT::f64) {
          if(Subtarget.hasF())
            RC = &RISCV::PairFP64BitRegClass;
          else if(Subtarget.hasD())
            RC = &RISCV::FP64BitRegClass;
          else if(Subtarget.isRV64())
            RC = &RISCV::GR64BitRegClass;
          else
            RC = &RISCV::PairGR64BitRegClass;
      } else
        llvm_unreachable("RegVT not supported by FormalArguments Lowering");

      // Transform the arguments stored on
      // physical registers into virtual ones
      unsigned Reg = addLiveIn(DAG.getMachineFunction(), ArgReg, RC);
      SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, Reg, RegVT);

      // If this is an 8 or 16-bit value, it has been passed promoted
      // to 32 bits.  Insert an assert[sz]ext to capture this, then
      // truncate to the right size.
      if (VA.getLocInfo() != CCValAssign::Full) {
        unsigned Opcode = 0;
        if (VA.getLocInfo() == CCValAssign::SExt)
          Opcode = ISD::AssertSext;
        else if (VA.getLocInfo() == CCValAssign::ZExt)
          Opcode = ISD::AssertZext;
        if (Opcode)
          ArgValue = DAG.getNode(Opcode, DL, RegVT, ArgValue,
                                 DAG.getValueType(ValVT));
        ArgValue = DAG.getNode(ISD::TRUNCATE, DL, ValVT, ArgValue);
      }

      /* This was handled in the previous assignment to Pairs
      // Handle floating point arguments passed in integer registers and
      // long double arguments passed in floating point registers.
      if ((RegVT == MVT::i32 && ValVT == MVT::f32) ||
          (RegVT == MVT::i64 && ValVT == MVT::f64) ||
          (RegVT == MVT::f64 && ValVT == MVT::i64))
        ArgValue = DAG.getNode(ISD::BITCAST, DL, ValVT, ArgValue);
      else if (IsO32 && RegVT == MVT::i32 && ValVT == MVT::f64) {
        unsigned Reg2 = addLiveIn(DAG.getMachineFunction(),
                                  getNextIntArgReg(ArgReg), RC);
        SDValue ArgValue2 = DAG.getCopyFromReg(Chain, DL, Reg2, RegVT);
        if (!Subtarget->isLittle())
          std::swap(ArgValue, ArgValue2);
        ArgValue = DAG.getNode(RISCVISD::BuildPairF64, DL, MVT::f64,
                               ArgValue, ArgValue2);
      }
      */

      InVals.push_back(ArgValue);
    } else { // VA.isRegLoc()

      // sanity check
      assert(VA.isMemLoc());

      // The stack pointer offset is relative to the caller stack frame.
      int FI = MFI->CreateFixedObject(ValVT.getSizeInBits()/8,
                                      VA.getLocMemOffset(), true);

      // Create load nodes to retrieve arguments from the stack
      SDValue FIN = DAG.getFrameIndex(FI, getPointerTy());
      InVals.push_back(DAG.getLoad(ValVT, DL, Chain, FIN,
                                   MachinePointerInfo::getFixedStack(FI),
                                   false, false, false, 0));
    }
  }

  // The RISCV ABIs for returning structs by value requires that we copy
  // the sret argument into $v0 for the return. Save the argument into
  // a virtual register so that we can access it from the return points.
  if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
    unsigned Reg = RISCVFI->getSRetReturnReg();
    if (!Reg) {
      Reg = MF.getRegInfo().
        createVirtualRegister(getRegClassFor(Subtarget.isRV64() ? MVT::i64 : MVT::i32));
      RISCVFI->setSRetReturnReg(Reg);
    }
    SDValue Copy = DAG.getCopyToReg(DAG.getEntryNode(), DL, Reg, InVals[0]);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, Copy, Chain);
  }

  if (IsVarArg)
    writeVarArgRegs(OutChains, RISCVCCInfo, Chain, DL, DAG);

  // All stores are grouped in one node to allow the matching between
  // the size of Ins and InVals. This only happens when on varg functions
  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other,
                        &OutChains[0], OutChains.size());
  }

  return Chain;
    /*
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  RISCVMachineFunctionInfo *FuncInfo =
    MF.getInfo<RISCVMachineFunctionInfo>();
  const RISCVFrameLowering *TFL =
    static_cast<const RISCVFrameLowering *>(TM.getFrameLowering());

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, MF, TM, ArgLocs, *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_RISCV);

  unsigned NumFixedGPRs = 0;
  unsigned NumFixedFPRs = 0;
  for (unsigned I = 0, E = ArgLocs.size(); I != E; ++I) {
    SDValue ArgValue;
    CCValAssign &VA = ArgLocs[I];
    EVT LocVT = VA.getLocVT();
    if (VA.isRegLoc()) {
      // Arguments passed in registers
      const TargetRegisterClass *RC;
      switch (LocVT.getSimpleVT().SimpleTy) {
      default:
        // Integers smaller than i64 should be promoted to i64.
        llvm_unreachable("Unexpected argument type");
      case MVT::i32:
        NumFixedGPRs += 1;
        RC = &RISCV::GR32BitRegClass;
        break;
      case MVT::f32:
        NumFixedFPRs += 1;
        RC = &RISCV::FP32BitRegClass;
        break;
      }

      unsigned VReg = MRI.createVirtualRegister(RC);
      MRI.addLiveIn(VA.getLocReg(), VReg);
      ArgValue = DAG.getCopyFromReg(Chain, DL, VReg, LocVT);
    } else {
      assert(VA.isMemLoc() && "Argument not register or memory");

      // Create the frame index object for this incoming parameter.
      int FI = MFI->CreateFixedObject(LocVT.getSizeInBits() / 8,
                                      VA.getLocMemOffset(), true);

      // Create the SelectionDAG nodes corresponding to a load
      // from this parameter.  Unpromoted ints and floats are
      // passed as right-justified 8-byte values.
      EVT PtrVT = getPointerTy();
      SDValue FIN = DAG.getFrameIndex(FI, PtrVT);
      if (VA.getLocVT() == MVT::i32 || VA.getLocVT() == MVT::f32)
        FIN = DAG.getNode(ISD::ADD, DL, PtrVT, FIN, DAG.getIntPtrConstant(4));
      ArgValue = DAG.getLoad(LocVT, DL, Chain, FIN,
                             MachinePointerInfo::getFixedStack(FI),
                             false, false, false, 0);
    }

    // Convert the value of the argument register into the value that's
    // being passed.
    InVals.push_back(convertLocVTToValVT(DAG, DL, VA, Chain, ArgValue));
  }

  if (IsVarArg) {
    // Save the number of non-varargs registers for later use by va_start, etc.
    FuncInfo->setVarArgsFirstGPR(NumFixedGPRs);
    FuncInfo->setVarArgsFirstFPR(NumFixedFPRs);

    // Likewise the address (in the form of a frame index) of where the
    // first stack vararg would be.  The 1-byte size here is arbitrary.
    int64_t StackSize = CCInfo.getNextStackOffset();
    FuncInfo->setVarArgsFrameIndex(MFI->CreateFixedObject(1, StackSize, true));

    // ...and a similar frame index for the caller-allocated save area
    // that will be used to store the incoming registers.
    int64_t RegSaveOffset = TFL->getOffsetOfLocalArea();
    unsigned RegSaveIndex = MFI->CreateFixedObject(1, RegSaveOffset, true);
    FuncInfo->setRegSaveFrameIndex(RegSaveIndex);

    // Store the FPR varargs in the reserved frame slots.  (We store the
    // GPRs as part of the prologue.)
    if (NumFixedFPRs < RISCV::NumArgFPRs) {
      SDValue MemOps[RISCV::NumArgFPRs];
      for (unsigned I = NumFixedFPRs; I < RISCV::NumArgFPRs; ++I) {
        unsigned Offset = TFL->getRegSpillOffset(RISCV::ArgFPRs[I]);
        int FI = MFI->CreateFixedObject(8, RegSaveOffset + Offset, true);
        SDValue FIN = DAG.getFrameIndex(FI, getPointerTy());
        unsigned VReg = MF.addLiveIn(RISCV::ArgFPRs[I],
                                     &RISCV::FP32BitRegClass);
        SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, VReg, MVT::f64);
        MemOps[I] = DAG.getStore(ArgValue.getValue(1), DL, ArgValue, FIN,
                                 MachinePointerInfo::getFixedStack(FI),
                                 false, false, 0);

      }
      // Join the stores, which are independent of one another.
      Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other,
                          &MemOps[NumFixedFPRs],
                          RISCV::NumArgFPRs - NumFixedFPRs);
    }
  }

  return Chain;
  */
}

SDValue
RISCVTargetLowering::LowerCall(CallLoweringInfo &CLI,
                                 SmallVectorImpl<SDValue> &InVals) const {
  SelectionDAG &DAG = CLI.DAG;
  DebugLoc &DL = CLI.DL;
  SmallVector<ISD::OutputArg, 32> &Outs = CLI.Outs;
  SmallVector<SDValue, 32> &OutVals = CLI.OutVals;
  SmallVector<ISD::InputArg, 32> &Ins = CLI.Ins;
  SDValue Chain = CLI.Chain;
  SDValue Callee = CLI.Callee;
  bool &isTailCall = CLI.IsTailCall;
  CallingConv::ID CallConv = CLI.CallConv;
  bool IsVarArg = CLI.IsVarArg;
  MachineFunction &MF = DAG.getMachineFunction();
  EVT PtrVT = getPointerTy();

  // RISCV target does not yet support tail call optimization.
  isTailCall = false;

  // Analyze the operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState ArgCCInfo(CallConv, IsVarArg, MF, TM, ArgLocs, *DAG.getContext());
  if(Subtarget.isRV64())
    ArgCCInfo.AnalyzeCallOperands(Outs, CC_RISCV64);
  else
    ArgCCInfo.AnalyzeCallOperands(Outs, CC_RISCV32);

  // Get a count of how many bytes are to be pushed on the stack.
  unsigned NumBytes = ArgCCInfo.getNextStackOffset();

  // Mark the start of the call.
  Chain = DAG.getCALLSEQ_START(Chain, DAG.getConstant(NumBytes, PtrVT, true));

  // Copy argument values to their designated locations.
  SmallVector<std::pair<unsigned, SDValue>, 9> RegsToPass;
  SmallVector<SDValue, 8> MemOpChains;
  SDValue StackPtr;
  for (unsigned I = 0, E = ArgLocs.size(); I != E; ++I) {
    CCValAssign &VA = ArgLocs[I];
    SDValue ArgValue = OutVals[I];

    if (VA.getLocInfo() == CCValAssign::Indirect) {
      // Store the argument in a stack slot and pass its address.
      SDValue SpillSlot = DAG.CreateStackTemporary(VA.getValVT());
      int FI = cast<FrameIndexSDNode>(SpillSlot)->getIndex();
      MemOpChains.push_back(DAG.getStore(Chain, DL, ArgValue, SpillSlot,
                                         MachinePointerInfo::getFixedStack(FI),
                                         false, false, 0));
      ArgValue = SpillSlot;
    } else
      ArgValue = convertValVTToLocVT(DAG, DL, VA, ArgValue);

    if (VA.isRegLoc())
      // Queue up the argument copies and emit them at the end.
      RegsToPass.push_back(std::make_pair(VA.getLocReg(), ArgValue));
    else {
      assert(VA.isMemLoc() && "Argument not register or memory");

      // Work out the address of the stack slot.  Unpromoted ints and
      // floats are passed as right-justified 8-byte values.
      if (!StackPtr.getNode())
        StackPtr = DAG.getCopyFromReg(Chain, DL, RISCV::sp, PtrVT);
      unsigned Offset = RISCVMC::CallFrameSize + VA.getLocMemOffset();
      if (VA.getLocVT() == MVT::i32 || VA.getLocVT() == MVT::f32)
        Offset += 4;
      SDValue Address = DAG.getNode(ISD::ADD, DL, PtrVT, StackPtr,
                                    DAG.getIntPtrConstant(Offset));

      // Emit the store.
      MemOpChains.push_back(DAG.getStore(Chain, DL, ArgValue, Address,
                                         MachinePointerInfo(),
                                         false, false, 0));
    }
  }

  // Join the stores, which are independent of one another.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other,
                        &MemOpChains[0], MemOpChains.size());

  // Build a sequence of copy-to-reg nodes, chained and glued together.
  SDValue Glue;
  for (unsigned I = 0, E = RegsToPass.size(); I != E; ++I) {
    Chain = DAG.getCopyToReg(Chain, DL, RegsToPass[I].first,
                             RegsToPass[I].second, Glue);
    Glue = Chain.getValue(1);
  }

  // Accept direct calls by converting symbolic call addresses to the
  // associated Target* opcodes.
  if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
    Callee = DAG.getTargetGlobalAddress(G->getGlobal(), DL, PtrVT);
    Callee = DAG.getNode(RISCVISD::PCREL_WRAPPER, DL, PtrVT, Callee);
  } else if (ExternalSymbolSDNode *E = dyn_cast<ExternalSymbolSDNode>(Callee)) {
    Callee = DAG.getTargetExternalSymbol(E->getSymbol(), PtrVT);
    Callee = DAG.getNode(RISCVISD::PCREL_WRAPPER, DL, PtrVT, Callee);
  }

  // The first call operand is the chain and the second is the target address.
  SmallVector<SDValue, 8> Ops;
  Ops.push_back(Chain);
  Ops.push_back(Callee);

  // Add argument registers to the end of the list so that they are
  // known live into the call.
  for (unsigned I = 0, E = RegsToPass.size(); I != E; ++I)
    Ops.push_back(DAG.getRegister(RegsToPass[I].first,
                                  RegsToPass[I].second.getValueType()));

  // Glue the call to the argument copies, if any.
  if (Glue.getNode())
    Ops.push_back(Glue);

  // Emit the call.
  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);
  Chain = DAG.getNode(RISCVISD::CALL, DL, NodeTys, &Ops[0], Ops.size());
  Glue = Chain.getValue(1);

  // Mark the end of the call, which is glued to the call itself.
  Chain = DAG.getCALLSEQ_END(Chain,
                             DAG.getConstant(NumBytes, PtrVT, true),
                             DAG.getConstant(0, PtrVT, true),
                             Glue);
  Glue = Chain.getValue(1);

  // Assign locations to each value returned by this call.
  SmallVector<CCValAssign, 16> RetLocs;
  CCState RetCCInfo(CallConv, IsVarArg, MF, TM, RetLocs, *DAG.getContext());
  if(Subtarget.isRV64())
    RetCCInfo.AnalyzeCallResult(Ins, RetCC_RISCV64);
  else
    RetCCInfo.AnalyzeCallResult(Ins, RetCC_RISCV32);

  // Copy all of the result registers out of their specified physreg.
  for (unsigned I = 0, E = RetLocs.size(); I != E; ++I) {
    CCValAssign &VA = RetLocs[I];

    // Copy the value out, gluing the copy to the end of the call sequence.
    SDValue RetValue = DAG.getCopyFromReg(Chain, DL, VA.getLocReg(),
                                          VA.getLocVT(), Glue);
    Chain = RetValue.getValue(1);
    Glue = RetValue.getValue(2);

    // Convert the value of the return register into the value that's
    // being returned.
    InVals.push_back(convertLocVTToValVT(DAG, DL, VA, Chain, RetValue));
  }

  return Chain;
}

SDValue
RISCVTargetLowering::LowerReturn(SDValue Chain,
                                   CallingConv::ID CallConv, bool IsVarArg,
                                   const SmallVectorImpl<ISD::OutputArg> &Outs,
                                   const SmallVectorImpl<SDValue> &OutVals,
                                   DebugLoc DL, SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();

  // Assign locations to each returned value.
  SmallVector<CCValAssign, 16> RetLocs;
  CCState RetCCInfo(CallConv, IsVarArg, MF, TM, RetLocs, *DAG.getContext());
  if(Subtarget.isRV64())
    RetCCInfo.AnalyzeReturn(Outs, RetCC_RISCV64);
  else
    RetCCInfo.AnalyzeReturn(Outs, RetCC_RISCV32);

  // Quick exit for void returns
  if (RetLocs.empty())
    return DAG.getNode(RISCVISD::RET_FLAG, DL, MVT::Other, Chain);

  // Copy the result values into the output registers.
  SDValue Glue;
  SmallVector<SDValue, 4> RetOps;
  RetOps.push_back(Chain);
  for (unsigned I = 0, E = RetLocs.size(); I != E; ++I) {
    CCValAssign &VA = RetLocs[I];
    SDValue RetValue = OutVals[I];

    // Make the return register live on exit.
    assert(VA.isRegLoc() && "Can only return in registers!");

    // Promote the value as required.
    RetValue = convertValVTToLocVT(DAG, DL, VA, RetValue);

    // Chain and glue the copies together.
    unsigned Reg = VA.getLocReg();
    Chain = DAG.getCopyToReg(Chain, DL, Reg, RetValue, Glue);
    Glue = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(Reg, VA.getLocVT()));
  }

  // Update chain and glue.
  RetOps[0] = Chain;
  if (Glue.getNode())
    RetOps.push_back(Glue);

  return DAG.getNode(RISCVISD::RET_FLAG, DL, MVT::Other,
                     RetOps.data(), RetOps.size());
}

// CC is a comparison that will be implemented using an integer or
// floating-point comparison.  Return the condition code mask for
// a branch on true.  In the integer case, CCMASK_CMP_UO is set for
// unsigned comparisons and clear for signed ones.  In the floating-point
// case, CCMASK_CMP_UO has its normal mask meaning (unordered).
static unsigned CCMaskForCondCode(ISD::CondCode CC) {
#define CONV(X) \
  case ISD::SET##X: return RISCV::CCMASK_CMP_##X; \
  case ISD::SETO##X: return RISCV::CCMASK_CMP_##X; \
  case ISD::SETU##X: return RISCV::CCMASK_CMP_UO | RISCV::CCMASK_CMP_##X

  switch (CC) {
  default:
    llvm_unreachable("Invalid integer condition!");

  CONV(EQ);
  CONV(NE);
  CONV(GT);
  CONV(GE);
  CONV(LT);
  CONV(LE);

  case ISD::SETO:  return RISCV::CCMASK_CMP_O;
  case ISD::SETUO: return RISCV::CCMASK_CMP_UO;
  }
#undef CONV
}

// If a comparison described by IsUnsigned, CCMask, CmpOp0 and CmpOp1
// is suitable for CLI(Y), CHHSI or CLHHSI, adjust the operands as necessary.
static void adjustSubwordCmp(SelectionDAG &DAG, bool &IsUnsigned,
                             SDValue &CmpOp0, SDValue &CmpOp1,
                             unsigned &CCMask) {
  // For us to make any changes, it must a comparison between a single-use
  // load and a constant.
  if (!CmpOp0.hasOneUse() ||
      CmpOp0.getOpcode() != ISD::LOAD ||
      CmpOp1.getOpcode() != ISD::Constant)
    return;

  // We must have an 8- or 16-bit load.
  LoadSDNode *Load = cast<LoadSDNode>(CmpOp0);
  unsigned NumBits = Load->getMemoryVT().getStoreSizeInBits();
  if (NumBits != 8 && NumBits != 16)
    return;

  // The load must be an extending one and the constant must be within the
  // range of the unextended value.
  ConstantSDNode *Constant = cast<ConstantSDNode>(CmpOp1);
  uint64_t Value = Constant->getZExtValue();
  uint64_t Mask = (1 << NumBits) - 1;
  if (Load->getExtensionType() == ISD::SEXTLOAD) {
    int64_t SignedValue = Constant->getSExtValue();
    if (uint64_t(SignedValue) + (1 << (NumBits - 1)) > Mask)
      return;
    // Unsigned comparison between two sign-extended values is equivalent
    // to unsigned comparison between two zero-extended values.
    if (IsUnsigned)
      Value &= Mask;
    else if (CCMask == RISCV::CCMASK_CMP_EQ ||
             CCMask == RISCV::CCMASK_CMP_NE)
      // Any choice of IsUnsigned is OK for equality comparisons.
      // We could use either CHHSI or CLHHSI for 16-bit comparisons,
      // but since we use CLHHSI for zero extensions, it seems better
      // to be consistent and do the same here.
      Value &= Mask, IsUnsigned = true;
    else if (NumBits == 8) {
      // Try to treat the comparison as unsigned, so that we can use CLI.
      // Adjust CCMask and Value as necessary.
      if (Value == 0 && CCMask == RISCV::CCMASK_CMP_LT)
        // Test whether the high bit of the byte is set.
        Value = 127, CCMask = RISCV::CCMASK_CMP_GT, IsUnsigned = true;
      else if (SignedValue == -1 && CCMask == RISCV::CCMASK_CMP_GT)
        // Test whether the high bit of the byte is clear.
        Value = 128, CCMask = RISCV::CCMASK_CMP_LT, IsUnsigned = true;
      else
        // No instruction exists for this combination.
        return;
    }
  } else if (Load->getExtensionType() == ISD::ZEXTLOAD) {
    if (Value > Mask)
      return;
    // Signed comparison between two zero-extended values is equivalent
    // to unsigned comparison.
    IsUnsigned = true;
  } else
    return;

  // Make sure that the first operand is an i32 of the right extension type.
  ISD::LoadExtType ExtType = IsUnsigned ? ISD::ZEXTLOAD : ISD::SEXTLOAD;
  if (CmpOp0.getValueType() != MVT::i32 ||
      Load->getExtensionType() != ExtType)
    CmpOp0 = DAG.getExtLoad(ExtType, Load->getDebugLoc(), MVT::i32,
                            Load->getChain(), Load->getBasePtr(),
                            Load->getPointerInfo(), Load->getMemoryVT(),
                            Load->isVolatile(), Load->isNonTemporal(),
                            Load->getAlignment());

  // Make sure that the second operand is an i32 with the right value.
  if (CmpOp1.getValueType() != MVT::i32 ||
      Value != Constant->getZExtValue())
    CmpOp1 = DAG.getConstant(Value, MVT::i32);
}

// Return true if a comparison described by CCMask, CmpOp0 and CmpOp1
// is an equality comparison that is better implemented using unsigned
// rather than signed comparison instructions.
static bool preferUnsignedComparison(SelectionDAG &DAG, SDValue CmpOp0,
                                     SDValue CmpOp1, unsigned CCMask) {
  // The test must be for equality or inequality.
  if (CCMask != RISCV::CCMASK_CMP_EQ && CCMask != RISCV::CCMASK_CMP_NE)
    return false;

  if (CmpOp1.getOpcode() == ISD::Constant) {
    uint64_t Value = cast<ConstantSDNode>(CmpOp1)->getSExtValue();

    // If we're comparing with memory, prefer unsigned comparisons for
    // values that are in the unsigned 16-bit range but not the signed
    // 16-bit range.  We want to use CLFHSI and CLGHSI.
    if (CmpOp0.hasOneUse() &&
        ISD::isNormalLoad(CmpOp0.getNode()) &&
        (Value >= 32768 && Value < 65536))
      return true;

    // Use unsigned comparisons for values that are in the CLGFI range
    // but not in the CGFI range.
    if (CmpOp0.getValueType() == MVT::i64 && (Value >> 31) == 1)
      return true;

    return false;
  }

  // Prefer CL for zero-extended loads.
  if (CmpOp1.getOpcode() == ISD::ZERO_EXTEND ||
      ISD::isZEXTLoad(CmpOp1.getNode()))
    return true;

  // ...and for "in-register" zero extensions.
  if (CmpOp1.getOpcode() == ISD::AND && CmpOp1.getValueType() == MVT::i64) {
    SDValue Mask = CmpOp1.getOperand(1);
    if (Mask.getOpcode() == ISD::Constant &&
        cast<ConstantSDNode>(Mask)->getZExtValue() == 0xffffffff)
      return true;
  }

  return false;
}

// Return a target node that compares CmpOp0 and CmpOp1.  Set CCMask to the
// 4-bit condition-code mask for CC.
static SDValue emitCmp(SelectionDAG &DAG, SDValue CmpOp0, SDValue CmpOp1,
                       ISD::CondCode CC, unsigned &CCMask) {
  bool IsUnsigned = false;
  CCMask = CCMaskForCondCode(CC);
  if (!CmpOp0.getValueType().isFloatingPoint()) {
    IsUnsigned = CCMask & RISCV::CCMASK_CMP_UO;
    CCMask &= ~RISCV::CCMASK_CMP_UO;
    adjustSubwordCmp(DAG, IsUnsigned, CmpOp0, CmpOp1, CCMask);
    if (preferUnsignedComparison(DAG, CmpOp0, CmpOp1, CCMask))
      IsUnsigned = true;
  }

  DebugLoc DL = CmpOp0.getDebugLoc();
  return DAG.getNode((IsUnsigned ? RISCVISD::UCMP : RISCVISD::CMP),
                     DL, MVT::Glue, CmpOp0, CmpOp1);
}

SDValue RISCVTargetLowering::
lowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const
{
  DebugLoc DL = Op.getDebugLoc();
  EVT Ty = Op.getOperand(0).getValueType();
  SDValue Cond = DAG.getNode(ISD::SETCC, DL, getSetCCResultType(Ty),
                             Op.getOperand(0), Op.getOperand(1),
                             Op.getOperand(4));

  return DAG.getNode(ISD::SELECT, DL, Op.getValueType(), Cond, Op.getOperand(2),
                     Op.getOperand(3));
}

SDValue RISCVTargetLowering::lowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const {
  // check the depth
  assert((cast<ConstantSDNode>(Op.getOperand(0))->getZExtValue() == 0) &&
    "Return address can be determined only for current frame.");
      
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  MVT VT = Op.getSimpleValueType();
  unsigned RA = Subtarget.isRV64() ? RISCV::ra_64 : RISCV::ra;
  MFI->setReturnAddressIsTaken(true);

  // Return RA, which contains the return address. Mark it an implicit live-in.
  unsigned Reg = MF.addLiveIn(RA, getRegClassFor(VT));
  return DAG.getCopyFromReg(DAG.getEntryNode(), Op.getDebugLoc(), Reg, VT);
}

SDValue RISCVTargetLowering::lowerGlobalAddress(GlobalAddressSDNode *Node,
                                                  SelectionDAG &DAG) const {
  DebugLoc DL = Node->getDebugLoc();
  const GlobalValue *GV = Node->getGlobal();
  int64_t Offset = Node->getOffset();
  EVT PtrVT = getPointerTy();
  Reloc::Model RM = TM.getRelocationModel();
  CodeModel::Model CM = TM.getCodeModel();

  SDValue Result;
  if (Subtarget.isPC32DBLSymbol(GV, RM, CM)) {
    // Make sure that the offset is aligned to a halfword.  If it isn't,
    // create an "anchor" at the previous 12-bit boundary.
    // FIXME check whether there is a better way of handling this.
    if (Offset & 1) {
      Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT,
                                          Offset & ~uint64_t(0xfff));
      Offset &= 0xfff;
    } else {
      Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT, Offset);
      Offset = 0;
    }
    Result = DAG.getNode(RISCVISD::PCREL_WRAPPER, DL, PtrVT, Result);
  } else {
    Result = DAG.getTargetGlobalAddress(GV, DL, PtrVT, 0, RISCVII::MO_GOT);
    Result = DAG.getNode(RISCVISD::PCREL_WRAPPER, DL, PtrVT, Result);
    Result = DAG.getLoad(PtrVT, DL, DAG.getEntryNode(), Result,
                         MachinePointerInfo::getGOT(), false, false, false, 0);
  }

  // If there was a non-zero offset that we didn't fold, create an explicit
  // addition for it.
  if (Offset != 0)
    Result = DAG.getNode(ISD::ADD, DL, PtrVT, Result,
                         DAG.getConstant(Offset, PtrVT));

  return Result;
}

SDValue RISCVTargetLowering::lowerGlobalTLSAddress(GlobalAddressSDNode *Node,
						     SelectionDAG &DAG) const {
  DebugLoc DL = Node->getDebugLoc();
  const GlobalValue *GV = Node->getGlobal();
  EVT PtrVT = getPointerTy();
  TLSModel::Model model = TM.getTLSModel(GV);

  if (model != TLSModel::LocalExec)
    llvm_unreachable("only local-exec TLS mode supported");

  // The high part of the thread pointer is in access register 0.
  SDValue TPHi = DAG.getNode(RISCVISD::EXTRACT_ACCESS, DL, MVT::i32,
                             DAG.getConstant(0, MVT::i32));
  TPHi = DAG.getNode(ISD::ANY_EXTEND, DL, PtrVT, TPHi);

  // The low part of the thread pointer is in access register 1.
  SDValue TPLo = DAG.getNode(RISCVISD::EXTRACT_ACCESS, DL, MVT::i32,
                             DAG.getConstant(1, MVT::i32));
  TPLo = DAG.getNode(ISD::ZERO_EXTEND, DL, PtrVT, TPLo);

  // Merge them into a single 64-bit address.
  SDValue TPHiShifted = DAG.getNode(ISD::SHL, DL, PtrVT, TPHi,
				    DAG.getConstant(32, PtrVT));
  SDValue TP = DAG.getNode(ISD::OR, DL, PtrVT, TPHiShifted, TPLo);

  // Get the offset of GA from the thread pointer.
  RISCVConstantPoolValue *CPV =
    RISCVConstantPoolValue::Create(GV, RISCVCP::NTPOFF);

  // Force the offset into the constant pool and load it from there.
  SDValue CPAddr = DAG.getConstantPool(CPV, PtrVT, 8);
  SDValue Offset = DAG.getLoad(PtrVT, DL, DAG.getEntryNode(),
			       CPAddr, MachinePointerInfo::getConstantPool(),
			       false, false, false, 0);

  // Add the base and offset together.
  return DAG.getNode(ISD::ADD, DL, PtrVT, TP, Offset);
}

SDValue RISCVTargetLowering::lowerBlockAddress(BlockAddressSDNode *Node,
                                                 SelectionDAG &DAG) const {
  DebugLoc DL = Node->getDebugLoc();
  const BlockAddress *BA = Node->getBlockAddress();
  int64_t Offset = Node->getOffset();
  EVT PtrVT = getPointerTy();

  SDValue Result = DAG.getTargetBlockAddress(BA, PtrVT, Offset);
  Result = DAG.getNode(RISCVISD::PCREL_WRAPPER, DL, PtrVT, Result);
  return Result;
}

SDValue RISCVTargetLowering::lowerJumpTable(JumpTableSDNode *JT,
                                              SelectionDAG &DAG) const {
  DebugLoc DL = JT->getDebugLoc();
  EVT PtrVT = getPointerTy();
  SDValue Result = DAG.getTargetJumpTable(JT->getIndex(), PtrVT);

  // Use LARL to load the address of the table.
  return DAG.getNode(RISCVISD::PCREL_WRAPPER, DL, PtrVT, Result);
}

SDValue RISCVTargetLowering::lowerConstantPool(ConstantPoolSDNode *CP,
                                                 SelectionDAG &DAG) const {
  DebugLoc DL = CP->getDebugLoc();
  EVT PtrVT = getPointerTy();

  SDValue Result;
  if (CP->isMachineConstantPoolEntry())
    Result = DAG.getTargetConstantPool(CP->getMachineCPVal(), PtrVT,
				       CP->getAlignment());
  else
    Result = DAG.getTargetConstantPool(CP->getConstVal(), PtrVT,
				       CP->getAlignment(), CP->getOffset());

  // Use LARL to load the address of the constant pool entry.
  return DAG.getNode(RISCVISD::PCREL_WRAPPER, DL, PtrVT, Result);
}

SDValue RISCVTargetLowering::lowerVASTART(SDValue Op,
                                            SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  RISCVMachineFunctionInfo *FuncInfo =
    MF.getInfo<RISCVMachineFunctionInfo>();
  EVT PtrVT = getPointerTy();

  SDValue Chain   = Op.getOperand(0);
  SDValue Addr    = Op.getOperand(1);
  const Value *SV = cast<SrcValueSDNode>(Op.getOperand(2))->getValue();
  DebugLoc DL     = Op.getDebugLoc();

  // The initial values of each field.
  const unsigned NumFields = 4;
  SDValue Fields[NumFields] = {
    DAG.getConstant(FuncInfo->getVarArgsFirstGPR(), PtrVT),
    DAG.getConstant(FuncInfo->getVarArgsFirstFPR(), PtrVT),
    DAG.getFrameIndex(FuncInfo->getVarArgsFrameIndex(), PtrVT),
    DAG.getFrameIndex(FuncInfo->getRegSaveFrameIndex(), PtrVT)
  };

  // Store each field into its respective slot.
  SDValue MemOps[NumFields];
  unsigned Offset = 0;
  for (unsigned I = 0; I < NumFields; ++I) {
    SDValue FieldAddr = Addr;
    if (Offset != 0)
      FieldAddr = DAG.getNode(ISD::ADD, DL, PtrVT, FieldAddr,
                              DAG.getIntPtrConstant(Offset));
    MemOps[I] = DAG.getStore(Chain, DL, Fields[I], FieldAddr,
                             MachinePointerInfo(SV, Offset),
                             false, false, 0);
    Offset += 8;
  }
  return DAG.getNode(ISD::TokenFactor, DL, MVT::Other, MemOps, NumFields);
}

SDValue RISCVTargetLowering::lowerVACOPY(SDValue Op,
                                           SelectionDAG &DAG) const {
  SDValue Chain      = Op.getOperand(0);
  SDValue DstPtr     = Op.getOperand(1);
  SDValue SrcPtr     = Op.getOperand(2);
  const Value *DstSV = cast<SrcValueSDNode>(Op.getOperand(3))->getValue();
  const Value *SrcSV = cast<SrcValueSDNode>(Op.getOperand(4))->getValue();
  DebugLoc DL        = Op.getDebugLoc();

  return DAG.getMemcpy(Chain, DL, DstPtr, SrcPtr, DAG.getIntPtrConstant(32),
                       /*Align*/8, /*isVolatile*/false, /*AlwaysInline*/false,
                       MachinePointerInfo(DstSV), MachinePointerInfo(SrcSV));
}

/*
SDValue RISCVTargetLowering::
lowerDYNAMIC_STACKALLOC(SDValue Op, SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);
  SDValue Size  = Op.getOperand(1);
  DebugLoc DL   = Op.getDebugLoc();

  unsigned SPReg = getStackPointerRegisterToSaveRestore();

  // Get a reference to the stack pointer.
  SDValue OldSP = DAG.getCopyFromReg(Chain, DL, SPReg, MVT::i64);

  // Get the new stack pointer value.
  SDValue NewSP = DAG.getNode(ISD::SUB, DL, MVT::i64, OldSP, Size);

  // Copy the new stack pointer back.
  Chain = DAG.getCopyToReg(Chain, DL, SPReg, NewSP);

  // The allocated data lives above the 160 bytes allocated for the standard
  // frame, plus any outgoing stack arguments.  We don't know how much that
  // amounts to yet, so emit a special ADJDYNALLOC placeholder.
  SDValue ArgAdjust = DAG.getNode(RISCVISD::ADJDYNALLOC, DL, MVT::i64);
  SDValue Result = DAG.getNode(ISD::ADD, DL, MVT::i64, NewSP, ArgAdjust);

  SDValue Ops[2] = { Result, Chain };
  return DAG.getMergeValues(Ops, 2, DL);
}
*/

SDValue RISCVTargetLowering::lowerUMUL_LOHI(SDValue Op,
                                              SelectionDAG &DAG) const {
  EVT VT = Op.getValueType();
  DebugLoc DL = Op.getDebugLoc();
  assert(!is32Bit(VT) && "Only support 64-bit UMUL_LOHI");

  // UMUL_LOHI64 returns the low result in the odd register and the high
  // result in the even register.  UMUL_LOHI is defined to return the
  // low half first, so the results are in reverse order.
  SDValue Ops[2];
  return DAG.getMergeValues(Ops, 2, DL);
}

SDValue RISCVTargetLowering::lowerSDIVREM(SDValue Op,
                                            SelectionDAG &DAG) const {
  SDValue Op0 = Op.getOperand(0);
  SDValue Op1 = Op.getOperand(1);
  EVT VT = Op.getValueType();
  DebugLoc DL = Op.getDebugLoc();

  // We use DSGF for 32-bit division.
  if (is32Bit(VT)) {
    Op0 = DAG.getNode(ISD::SIGN_EXTEND, DL, MVT::i64, Op0);
    Op1 = DAG.getNode(ISD::SIGN_EXTEND, DL, MVT::i64, Op1);
  }

  // DSG(F) takes a 64-bit dividend, so the even register in the GR128
  // input is "don't care".  The instruction returns the remainder in
  // the even register and the quotient in the odd register.
  SDValue Ops[2];
  return DAG.getMergeValues(Ops, 2, DL);
}

SDValue RISCVTargetLowering::lowerUDIVREM(SDValue Op,
                                            SelectionDAG &DAG) const {
  EVT VT = Op.getValueType();
  DebugLoc DL = Op.getDebugLoc();

  // DL(G) uses a double-width dividend, so we need to clear the even
  // register in the GR128 input.  The instruction returns the remainder
  // in the even register and the quotient in the odd register.
  SDValue Ops[2];
  return DAG.getMergeValues(Ops, 2, DL);
}

// Op is an 8-, 16-bit or 32-bit ATOMIC_LOAD_* operation.  Lower the first
// two into the fullword ATOMIC_LOADW_* operation given by Opcode.
SDValue RISCVTargetLowering::lowerATOMIC_LOAD(SDValue Op,
                                                SelectionDAG &DAG,
                                                unsigned Opcode) const {
  AtomicSDNode *Node = cast<AtomicSDNode>(Op.getNode());

  // 32-bit operations need no code outside the main loop.
  EVT NarrowVT = Node->getMemoryVT();
  EVT WideVT = MVT::i32;
  if (NarrowVT == WideVT)
    return Op;

  int64_t BitSize = NarrowVT.getSizeInBits();
  SDValue ChainIn = Node->getChain();
  SDValue Addr = Node->getBasePtr();
  SDValue Src2 = Node->getVal();
  MachineMemOperand *MMO = Node->getMemOperand();
  DebugLoc DL = Node->getDebugLoc();
  EVT PtrVT = Addr.getValueType();

  // Convert atomic subtracts of constants into additions.
  if (Opcode == RISCVISD::ATOMIC_LOADW_SUB)
    if (ConstantSDNode *Const = dyn_cast<ConstantSDNode>(Src2)) {
      Opcode = RISCVISD::ATOMIC_LOADW_ADD;
      Src2 = DAG.getConstant(-Const->getSExtValue(), Src2.getValueType());
    }

  // Get the address of the containing word.
  SDValue AlignedAddr = DAG.getNode(ISD::AND, DL, PtrVT, Addr,
                                    DAG.getConstant(-4, PtrVT));

  // Get the number of bits that the word must be rotated left in order
  // to bring the field to the top bits of a GR32.
  SDValue BitShift = DAG.getNode(ISD::SHL, DL, PtrVT, Addr,
                                 DAG.getConstant(3, PtrVT));
  BitShift = DAG.getNode(ISD::TRUNCATE, DL, WideVT, BitShift);

  // Get the complementing shift amount, for rotating a field in the top
  // bits back to its proper position.
  SDValue NegBitShift = DAG.getNode(ISD::SUB, DL, WideVT,
                                    DAG.getConstant(0, WideVT), BitShift);

  // Extend the source operand to 32 bits and prepare it for the inner loop.
  // ATOMIC_SWAPW uses RISBG to rotate the field left, but all other
  // operations require the source to be shifted in advance.  (This shift
  // can be folded if the source is constant.)  For AND and NAND, the lower
  // bits must be set, while for other opcodes they should be left clear.
  if (Opcode != RISCVISD::ATOMIC_SWAPW)
    Src2 = DAG.getNode(ISD::SHL, DL, WideVT, Src2,
                       DAG.getConstant(32 - BitSize, WideVT));
  if (Opcode == RISCVISD::ATOMIC_LOADW_AND ||
      Opcode == RISCVISD::ATOMIC_LOADW_NAND)
    Src2 = DAG.getNode(ISD::OR, DL, WideVT, Src2,
                       DAG.getConstant(uint32_t(-1) >> BitSize, WideVT));

  // Construct the ATOMIC_LOADW_* node.
  SDVTList VTList = DAG.getVTList(WideVT, MVT::Other);
  SDValue Ops[] = { ChainIn, AlignedAddr, Src2, BitShift, NegBitShift,
                    DAG.getConstant(BitSize, WideVT) };
  SDValue AtomicOp = DAG.getMemIntrinsicNode(Opcode, DL, VTList, Ops,
                                             array_lengthof(Ops),
                                             NarrowVT, MMO);

  // Rotate the result of the final CS so that the field is in the lower
  // bits of a GR32, then truncate it.
  SDValue ResultShift = DAG.getNode(ISD::ADD, DL, WideVT, BitShift,
                                    DAG.getConstant(BitSize, WideVT));
  SDValue Result = DAG.getNode(ISD::ROTL, DL, WideVT, AtomicOp, ResultShift);

  SDValue RetOps[2] = { Result, AtomicOp.getValue(1) };
  return DAG.getMergeValues(RetOps, 2, DL);
}

// Node is an 8- or 16-bit ATOMIC_CMP_SWAP operation.  Lower the first two
// into a fullword ATOMIC_CMP_SWAPW operation.
SDValue RISCVTargetLowering::lowerATOMIC_CMP_SWAP(SDValue Op,
                                                    SelectionDAG &DAG) const {
  AtomicSDNode *Node = cast<AtomicSDNode>(Op.getNode());

  // We have native support for 32-bit compare and swap.
  EVT NarrowVT = Node->getMemoryVT();
  EVT WideVT = MVT::i32;
  if (NarrowVT == WideVT)
    return Op;

  int64_t BitSize = NarrowVT.getSizeInBits();
  SDValue ChainIn = Node->getOperand(0);
  SDValue Addr = Node->getOperand(1);
  SDValue CmpVal = Node->getOperand(2);
  SDValue SwapVal = Node->getOperand(3);
  MachineMemOperand *MMO = Node->getMemOperand();
  DebugLoc DL = Node->getDebugLoc();
  EVT PtrVT = Addr.getValueType();

  // Get the address of the containing word.
  SDValue AlignedAddr = DAG.getNode(ISD::AND, DL, PtrVT, Addr,
                                    DAG.getConstant(-4, PtrVT));

  // Get the number of bits that the word must be rotated left in order
  // to bring the field to the top bits of a GR32.
  SDValue BitShift = DAG.getNode(ISD::SHL, DL, PtrVT, Addr,
                                 DAG.getConstant(3, PtrVT));
  BitShift = DAG.getNode(ISD::TRUNCATE, DL, WideVT, BitShift);

  // Get the complementing shift amount, for rotating a field in the top
  // bits back to its proper position.
  SDValue NegBitShift = DAG.getNode(ISD::SUB, DL, WideVT,
                                    DAG.getConstant(0, WideVT), BitShift);

  // Construct the ATOMIC_CMP_SWAPW node.
  SDVTList VTList = DAG.getVTList(WideVT, MVT::Other);
  SDValue Ops[] = { ChainIn, AlignedAddr, CmpVal, SwapVal, BitShift,
                    NegBitShift, DAG.getConstant(BitSize, WideVT) };
  SDValue AtomicOp = DAG.getMemIntrinsicNode(RISCVISD::ATOMIC_CMP_SWAPW, DL,
                                             VTList, Ops, array_lengthof(Ops),
                                             NarrowVT, MMO);
  return AtomicOp;
}

SDValue RISCVTargetLowering::lowerSTACKSAVE(SDValue Op,
                                              SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MF.getInfo<RISCVMachineFunctionInfo>()->setManipulatesSP(true);
  unsigned sp = Subtarget.isRV64() ? RISCV::sp_64 : RISCV::sp;
  return DAG.getCopyFromReg(Op.getOperand(0), Op.getDebugLoc(),
                            sp, Op.getValueType());
}

SDValue RISCVTargetLowering::lowerSTACKRESTORE(SDValue Op,
                                                 SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MF.getInfo<RISCVMachineFunctionInfo>()->setManipulatesSP(true);
  unsigned sp = Subtarget.isRV64() ? RISCV::sp_64 : RISCV::sp;
  return DAG.getCopyToReg(Op.getOperand(0), Op.getDebugLoc(),
                          sp, Op.getOperand(1));
}

SDValue RISCVTargetLowering::LowerOperation(SDValue Op,
                                              SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  case ISD::RETURNADDR:
    return lowerRETURNADDR(Op, DAG);
  //case ISD::BR_CC:
    //return lowerBR_CC(Op, DAG);
  case ISD::SELECT_CC:
    return lowerSELECT_CC(Op, DAG);
  case ISD::GlobalAddress:
    return lowerGlobalAddress(cast<GlobalAddressSDNode>(Op), DAG);
  case ISD::GlobalTLSAddress:
    return lowerGlobalTLSAddress(cast<GlobalAddressSDNode>(Op), DAG);
  case ISD::BlockAddress:
    return lowerBlockAddress(cast<BlockAddressSDNode>(Op), DAG);
  case ISD::JumpTable:
    return lowerJumpTable(cast<JumpTableSDNode>(Op), DAG);
  case ISD::ConstantPool:
    return lowerConstantPool(cast<ConstantPoolSDNode>(Op), DAG);
  //case ISD::BITCAST:
    //return lowerBITCAST(Op, DAG);
  case ISD::VASTART:
    return lowerVASTART(Op, DAG);
  case ISD::VACOPY:
    return lowerVACOPY(Op, DAG);
  //case ISD::DYNAMIC_STACKALLOC:
    //return lowerDYNAMIC_STACKALLOC(Op, DAG);
  //case ISD::UMUL_LOHI:
    //return lowerUMUL_LOHI(Op, DAG);
  //case ISD::SDIVREM:
    //return lowerSDIVREM(Op, DAG);
  //case ISD::UDIVREM:
    //return lowerUDIVREM(Op, DAG);
  //case ISD::OR:
    //return lowerOR(Op, DAG);
  case ISD::ATOMIC_SWAP:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_SWAPW);
  case ISD::ATOMIC_LOAD_ADD:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_ADD);
  case ISD::ATOMIC_LOAD_SUB:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_SUB);
  case ISD::ATOMIC_LOAD_AND:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_AND);
  case ISD::ATOMIC_LOAD_OR:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_OR);
  case ISD::ATOMIC_LOAD_XOR:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_XOR);
  case ISD::ATOMIC_LOAD_NAND:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_NAND);
  case ISD::ATOMIC_LOAD_MIN:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_MIN);
  case ISD::ATOMIC_LOAD_MAX:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_MAX);
  case ISD::ATOMIC_LOAD_UMIN:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_UMIN);
  case ISD::ATOMIC_LOAD_UMAX:
    return lowerATOMIC_LOAD(Op, DAG, RISCVISD::ATOMIC_LOADW_UMAX);
  case ISD::ATOMIC_CMP_SWAP:
    return lowerATOMIC_CMP_SWAP(Op, DAG);
  case ISD::STACKSAVE:
    return lowerSTACKSAVE(Op, DAG);
  case ISD::STACKRESTORE:
    return lowerSTACKRESTORE(Op, DAG);
  default:
    llvm_unreachable("Unexpected node to lower");
  }
}

const char *RISCVTargetLowering::getTargetNodeName(unsigned Opcode) const {
#define OPCODE(NAME) case RISCVISD::NAME: return "RISCVISD::" #NAME
  switch (Opcode) {
    OPCODE(RET_FLAG);
    OPCODE(CALL);
    OPCODE(PCREL_WRAPPER);
    OPCODE(CMP);
    OPCODE(UCMP);
    OPCODE(SELECT_CC);
    OPCODE(ADJDYNALLOC);
    OPCODE(EXTRACT_ACCESS);
    OPCODE(SDIVREM64);
    OPCODE(UDIVREM32);
    OPCODE(UDIVREM64);
    OPCODE(ATOMIC_SWAPW);
    OPCODE(ATOMIC_LOADW_ADD);
    OPCODE(ATOMIC_LOADW_SUB);
    OPCODE(ATOMIC_LOADW_AND);
    OPCODE(ATOMIC_LOADW_OR);
    OPCODE(ATOMIC_LOADW_XOR);
    OPCODE(ATOMIC_LOADW_NAND);
    OPCODE(ATOMIC_LOADW_MIN);
    OPCODE(ATOMIC_LOADW_MAX);
    OPCODE(ATOMIC_LOADW_UMIN);
    OPCODE(ATOMIC_LOADW_UMAX);
    OPCODE(ATOMIC_CMP_SWAPW);
  }
  return NULL;
#undef OPCODE
}

//===----------------------------------------------------------------------===//
// Custom insertion
//===----------------------------------------------------------------------===//

// Create a new basic block after MBB.
static MachineBasicBlock *emitBlockAfter(MachineBasicBlock *MBB) {
  MachineFunction &MF = *MBB->getParent();
  MachineBasicBlock *NewMBB = MF.CreateMachineBasicBlock(MBB->getBasicBlock());
  MF.insert(llvm::next(MachineFunction::iterator(MBB)), NewMBB);
  return NewMBB;
}

// Split MBB after MI and return the new block (the one that contains
// instructions after MI).
static MachineBasicBlock *splitBlockAfter(MachineInstr *MI,
                                          MachineBasicBlock *MBB) {
  MachineBasicBlock *NewMBB = emitBlockAfter(MBB);
  NewMBB->splice(NewMBB->begin(), MBB,
                 llvm::next(MachineBasicBlock::iterator(MI)),
                 MBB->end());
  NewMBB->transferSuccessorsAndUpdatePHIs(MBB);
  return NewMBB;
}

MachineBasicBlock *RISCVTargetLowering::
emitSelectCC(MachineInstr *MI, MachineBasicBlock *BB) const {

  const TargetInstrInfo *TII = getTargetMachine().getInstrInfo();
  DebugLoc DL = MI->getDebugLoc();

  // To "insert" a SELECT_CC instruction, we actually have to insert the
  // diamond control-flow pattern.  The incoming instruction knows the
  // destination vreg to set, the condition code register to branch on, the
  // true/false values to select between, and a branch opcode to use.
  const BasicBlock *LLVM_BB = BB->getBasicBlock();
  MachineFunction::iterator It = BB;
  ++It;

  //  thisMBB:
  //  ...
  //   TrueVal = ...
  //   setcc r1, r2, r3
  //   bNE   r1, r0, copy1MBB
  //   fallthrough --> copy0MBB
  MachineBasicBlock *thisMBB  = BB;
  MachineFunction *F = BB->getParent();
  MachineBasicBlock *copy0MBB = F->CreateMachineBasicBlock(LLVM_BB);
  MachineBasicBlock *sinkMBB  = F->CreateMachineBasicBlock(LLVM_BB);
  F->insert(It, copy0MBB);
  F->insert(It, sinkMBB);

  // Transfer the remainder of BB and its successor edges to sinkMBB.
  sinkMBB->splice(sinkMBB->begin(), BB,
                  llvm::next(MachineBasicBlock::iterator(MI)),
                  BB->end());
  sinkMBB->transferSuccessorsAndUpdatePHIs(BB);

  // Next, add the true and fallthrough blocks as its successors.
  BB->addSuccessor(copy0MBB);
  BB->addSuccessor(sinkMBB);

  unsigned bne = Subtarget.isRV64() ? RISCV::BNE64 : RISCV::BNE;
  unsigned zero = Subtarget.isRV64() ? RISCV::zero_64 : RISCV::zero;
  BuildMI(BB, DL, TII->get(bne)).addReg(zero).addReg(MI->getOperand(3).getReg())
    .addMBB(sinkMBB);

  //  copy0MBB:
  //   %FalseValue = ...
  //   # fallthrough to sinkMBB
  BB = copy0MBB;

  // Update machine-CFG edges
  BB->addSuccessor(sinkMBB);

  //  sinkMBB:
  //   %Result = phi [ %TrueValue, thisMBB ], [ %FalseValue, copy0MBB ]
  //  ...
  BB = sinkMBB;

  BuildMI(*BB, BB->begin(), DL,
          TII->get(RISCV::PHI), MI->getOperand(0).getReg())
    .addReg(MI->getOperand(1).getReg()).addMBB(thisMBB)
    .addReg(MI->getOperand(2).getReg()).addMBB(copy0MBB);

  MI->eraseFromParent();   // The pseudo instruction is gone now.
  return BB;
}


MachineBasicBlock *RISCVTargetLowering::
EmitInstrWithCustomInserter(MachineInstr *MI, MachineBasicBlock *MBB) const {
  switch (MI->getOpcode()) {
  case RISCV::SELECT_CC:
      return emitSelectCC(MI, MBB);
/*TODO: no custom inserters (selects, atmoics)
  case RISCV::SelectF32:
  case RISCV::Select64:
  case RISCV::SelectF64:
  case RISCV::SelectF128:
    return emitSelect(MI, MBB);

  case RISCV::AEXT128_64:
    return emitExt128(MI, MBB, false, RISCV::subreg_low);
  case RISCV::ZEXT128_32:
    return emitExt128(MI, MBB, true, RISCV::subreg_low32);
  case RISCV::ZEXT128_64:
    return emitExt128(MI, MBB, true, RISCV::subreg_low);

  case RISCV::ATOMIC_SWAPW:
    return emitAtomicLoadBinary(MI, MBB, 0, 0);
  case RISCV::ATOMIC_SWAP_32:
    return emitAtomicLoadBinary(MI, MBB, 0, 32);
  case RISCV::ATOMIC_SWAP_64:
    return emitAtomicLoadBinary(MI, MBB, 0, 64);

  case RISCV::ATOMIC_LOADW_AR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AR, 0);
  case RISCV::ATOMIC_LOADW_AFI:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AFI, 0);
  case RISCV::ATOMIC_LOAD_AR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AR, 32);
  case RISCV::ATOMIC_LOAD_AHI:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AHI, 32);
  case RISCV::ATOMIC_LOAD_AFI:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AFI, 32);
  case RISCV::ATOMIC_LOAD_AGR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AGR, 64);
  case RISCV::ATOMIC_LOAD_AGHI:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AGHI, 64);
  case RISCV::ATOMIC_LOAD_AGFI:
    return emitAtomicLoadBinary(MI, MBB, RISCV::AGFI, 64);

  case RISCV::ATOMIC_LOADW_SR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::SR, 0);
  case RISCV::ATOMIC_LOAD_SR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::SR, 32);
  case RISCV::ATOMIC_LOAD_SGR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::SGR, 64);

  case RISCV::ATOMIC_LOADW_NR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NR, 0);
  case RISCV::ATOMIC_LOADW_NILH:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILH32, 0);
  case RISCV::ATOMIC_LOAD_NR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NR, 32);
  case RISCV::ATOMIC_LOAD_NILL32:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILL32, 32);
  case RISCV::ATOMIC_LOAD_NILH32:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILH32, 32);
  case RISCV::ATOMIC_LOAD_NILF32:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILF32, 32);
  case RISCV::ATOMIC_LOAD_NGR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NGR, 64);
  case RISCV::ATOMIC_LOAD_NILL:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILL, 64);
  case RISCV::ATOMIC_LOAD_NILH:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILH, 64);
  case RISCV::ATOMIC_LOAD_NIHL:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NIHL, 64);
  case RISCV::ATOMIC_LOAD_NIHH:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NIHH, 64);
  case RISCV::ATOMIC_LOAD_NILF:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILF, 64);
  case RISCV::ATOMIC_LOAD_NIHF:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NIHF, 64);

  case RISCV::ATOMIC_LOADW_OR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OR, 0);
  case RISCV::ATOMIC_LOADW_OILH:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OILH32, 0);
  case RISCV::ATOMIC_LOAD_OR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OR, 32);
  case RISCV::ATOMIC_LOAD_OILL32:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OILL32, 32);
  case RISCV::ATOMIC_LOAD_OILH32:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OILH32, 32);
  case RISCV::ATOMIC_LOAD_OILF32:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OILF32, 32);
  case RISCV::ATOMIC_LOAD_OGR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OGR, 64);
  case RISCV::ATOMIC_LOAD_OILL:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OILL, 64);
  case RISCV::ATOMIC_LOAD_OILH:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OILH, 64);
  case RISCV::ATOMIC_LOAD_OIHL:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OIHL, 64);
  case RISCV::ATOMIC_LOAD_OIHH:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OIHH, 64);
  case RISCV::ATOMIC_LOAD_OILF:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OILF, 64);
  case RISCV::ATOMIC_LOAD_OIHF:
    return emitAtomicLoadBinary(MI, MBB, RISCV::OIHF, 64);

  case RISCV::ATOMIC_LOADW_XR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::XR, 0);
  case RISCV::ATOMIC_LOADW_XILF:
    return emitAtomicLoadBinary(MI, MBB, RISCV::XILF32, 0);
  case RISCV::ATOMIC_LOAD_XR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::XR, 32);
  case RISCV::ATOMIC_LOAD_XILF32:
    return emitAtomicLoadBinary(MI, MBB, RISCV::XILF32, 32);
  case RISCV::ATOMIC_LOAD_XGR:
    return emitAtomicLoadBinary(MI, MBB, RISCV::XGR, 64);
  case RISCV::ATOMIC_LOAD_XILF:
    return emitAtomicLoadBinary(MI, MBB, RISCV::XILF, 64);
  case RISCV::ATOMIC_LOAD_XIHF:
    return emitAtomicLoadBinary(MI, MBB, RISCV::XIHF, 64);

  case RISCV::ATOMIC_LOADW_NRi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NR, 0, true);
  case RISCV::ATOMIC_LOADW_NILHi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILH32, 0, true);
  case RISCV::ATOMIC_LOAD_NRi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NR, 32, true);
  case RISCV::ATOMIC_LOAD_NILL32i:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILL32, 32, true);
  case RISCV::ATOMIC_LOAD_NILH32i:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILH32, 32, true);
  case RISCV::ATOMIC_LOAD_NILF32i:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILF32, 32, true);
  case RISCV::ATOMIC_LOAD_NGRi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NGR, 64, true);
  case RISCV::ATOMIC_LOAD_NILLi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILL, 64, true);
  case RISCV::ATOMIC_LOAD_NILHi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILH, 64, true);
  case RISCV::ATOMIC_LOAD_NIHLi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NIHL, 64, true);
  case RISCV::ATOMIC_LOAD_NIHHi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NIHH, 64, true);
  case RISCV::ATOMIC_LOAD_NILFi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NILF, 64, true);
  case RISCV::ATOMIC_LOAD_NIHFi:
    return emitAtomicLoadBinary(MI, MBB, RISCV::NIHF, 64, true);

  case RISCV::ATOMIC_LOADW_MIN:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CR,
                                RISCV::CCMASK_CMP_LE, 0);
  case RISCV::ATOMIC_LOAD_MIN_32:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CR,
                                RISCV::CCMASK_CMP_LE, 32);
  case RISCV::ATOMIC_LOAD_MIN_64:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CGR,
                                RISCV::CCMASK_CMP_LE, 64);

  case RISCV::ATOMIC_LOADW_MAX:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CR,
                                RISCV::CCMASK_CMP_GE, 0);
  case RISCV::ATOMIC_LOAD_MAX_32:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CR,
                                RISCV::CCMASK_CMP_GE, 32);
  case RISCV::ATOMIC_LOAD_MAX_64:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CGR,
                                RISCV::CCMASK_CMP_GE, 64);

  case RISCV::ATOMIC_LOADW_UMIN:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CLR,
                                RISCV::CCMASK_CMP_LE, 0);
  case RISCV::ATOMIC_LOAD_UMIN_32:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CLR,
                                RISCV::CCMASK_CMP_LE, 32);
  case RISCV::ATOMIC_LOAD_UMIN_64:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CLGR,
                                RISCV::CCMASK_CMP_LE, 64);

  case RISCV::ATOMIC_LOADW_UMAX:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CLR,
                                RISCV::CCMASK_CMP_GE, 0);
  case RISCV::ATOMIC_LOAD_UMAX_32:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CLR,
                                RISCV::CCMASK_CMP_GE, 32);
  case RISCV::ATOMIC_LOAD_UMAX_64:
    return emitAtomicLoadMinMax(MI, MBB, RISCV::CLGR,
                                RISCV::CCMASK_CMP_GE, 64);

  case RISCV::ATOMIC_CMP_SWAPW:
    return emitAtomicCmpSwapW(MI, MBB);
*/
  default:
    llvm_unreachable("Unexpected instr type to insert");
  }
}

void
RISCVTargetLowering::writeVarArgRegs(std::vector<SDValue> &OutChains,
                                    const RISCVCC &CC, SDValue Chain,
                                    DebugLoc DL, SelectionDAG &DAG) const {
  unsigned NumRegs = CC.numIntArgRegs();
  const uint16_t *ArgRegs = CC.intArgRegs();
  const CCState &CCInfo = CC.getCCInfo();
  unsigned Idx = CCInfo.getFirstUnallocated(ArgRegs, NumRegs);
  unsigned RegSize = CC.regSize();
  MVT RegTy = MVT::getIntegerVT(RegSize * 8);
  const TargetRegisterClass *RC = getRegClassFor(RegTy);
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  RISCVMachineFunctionInfo *RISCVFI = MF.getInfo<RISCVMachineFunctionInfo>();

  // Offset of the first variable argument from stack pointer.
  int VaArgOffset;

  if (NumRegs == Idx)
    VaArgOffset = RoundUpToAlignment(CCInfo.getNextStackOffset(), RegSize);
  else
    VaArgOffset =
      (int)CC.reservedArgArea() - (int)(RegSize * (NumRegs - Idx));

  // Record the frame index of the first variable argument
  // which is a value necessary to VASTART.
  int FI = MFI->CreateFixedObject(RegSize, VaArgOffset, true);
  RISCVFI->setVarArgsFrameIndex(FI);

  // Copy the integer registers that have not been used for argument passing
  // to the argument register save area. For O32, the save area is allocated
  // in the caller's stack frame, while for N32/64, it is allocated in the
  // callee's stack frame.
  for (unsigned I = Idx; I < NumRegs; ++I, VaArgOffset += RegSize) {
    unsigned Reg = addLiveIn(MF, ArgRegs[I], RC);
    SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, Reg, RegTy);
    FI = MFI->CreateFixedObject(RegSize, VaArgOffset, true);
    SDValue PtrOff = DAG.getFrameIndex(FI, getPointerTy());
    SDValue Store = DAG.getStore(Chain, DL, ArgValue, PtrOff,
                                 MachinePointerInfo(), false, false, 0);
    cast<StoreSDNode>(Store.getNode())->getMemOperand()->setValue(0);
    OutChains.push_back(Store);
  }
}
