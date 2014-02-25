//===-- RISCVISelLowering.h - RISCV DAG lowering interface --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that RISCV uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TARGET_RISCV_ISELLOWERING_H
#define LLVM_TARGET_RISCV_ISELLOWERING_H

#include "RISCV.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/IR/Function.h"
#include "llvm/Target/TargetLowering.h"
#include <string>
#include <deque>

namespace llvm {
namespace RISCVISD {
  enum {
    FIRST_NUMBER = ISD::BUILTIN_OP_END,

    // Return with a flag operand.  Operand 0 is the chain operand.
    RET_FLAG,

    // Calls a function.  Operand 0 is the chain operand and operand 1
    // is the target address.  The arguments start at operand 2.
    // There is an optional glue operand at the end.
    CALL,

    // Wraps a TargetGlobalAddress that should be loaded using PC-relative
    // accesses (LARL).  Operand 0 is the address.
    PCREL_WRAPPER,

    // Get the Higher 20 bits from a 32-bit immediate
    // No relation with Mips Hi register
    Hi,

    // Get the Lower 12 bits from a 32-bit immediate
    // No relation with Mips Lo register
    Lo,

    // TprelHi and TprelLo nodes are used to handle Local Exec TLS
    TprelHi,
    TprelLo,

    // Signed integer and floating-point comparisons.  The operands are the
    // two values to compare.
    CMP,

    // Likewise unsigned integer comparison.
    UCMP,

    // Branches if a condition is true.  Operand 0 is the chain operand;
    // operand 1 is the 4-bit condition-code mask, with bit N in
    // big-endian order meaning "branch if CC=N"; operand 2 is the
    // target block and operand 3 is the flag operand.
    //BR_CCMASK,
    BRCOND,

    // Selects between operand 0 and operand 1.  Operand 2 is the
    // mask of condition-code values for which operand 0 should be
    // chosen over operand 1; it has the same form as BR_CCMASK.
    // Operand 3 is the flag operand.
    SELECT_CC,

    // Evaluates to the gap between the stack pointer and the
    // base of the dynamically-allocatable area.
    ADJDYNALLOC,

    // Wrappers around the ISD opcodes of the same name.  The output and
    // first input operands are GR128s.  The trailing numbers are the
    // widths of the second operand in bits.
    UMUL_LOHI64,
    SDIVREM64,
    UDIVREM32,
    UDIVREM64,

    FENCE,

    // Wrappers around the inner loop of an 8- or 16-bit ATOMIC_SWAP or
    // ATOMIC_LOAD_<op>.
    //
    // Operand 0: the address of the containing 32-bit-aligned field
    // Operand 1: the second operand of <op>, in the high bits of an i32
    //            for everything except ATOMIC_SWAPW
    // Operand 2: how many bits to rotate the i32 left to bring the first
    //            operand into the high bits
    // Operand 3: the negative of operand 2, for rotating the other way
    // Operand 4: the width of the field in bits (8 or 16)
    ATOMIC_SWAPW = ISD::FIRST_TARGET_MEMORY_OPCODE,
    ATOMIC_LOADW_ADD,
    ATOMIC_LOADW_SUB,
    ATOMIC_LOADW_AND,
    ATOMIC_LOADW_OR,
    ATOMIC_LOADW_XOR,
    ATOMIC_LOADW_NAND,
    ATOMIC_LOADW_MIN,
    ATOMIC_LOADW_MAX,
    ATOMIC_LOADW_UMIN,
    ATOMIC_LOADW_UMAX,

    // A wrapper around the inner loop of an ATOMIC_CMP_SWAP.
    //
    // Operand 0: the address of the containing 32-bit-aligned field
    // Operand 1: the compare value, in the low bits of an i32
    // Operand 2: the swap value, in the low bits of an i32
    // Operand 3: how many bits to rotate the i32 left to bring the first
    //            operand into the high bits
    // Operand 4: the negative of operand 2, for rotating the other way
    // Operand 5: the width of the field in bits (8 or 16)
    ATOMIC_CMP_SWAPW
  };
}

class RISCVSubtarget;
class RISCVTargetMachine;

class RISCVTargetLowering : public TargetLowering {
public:
  explicit RISCVTargetLowering(RISCVTargetMachine &TM);

  // Override TargetLowering.
  virtual MVT getScalarShiftAmountTy(EVT LHSTy) const LLVM_OVERRIDE {
    return LHSTy.getSimpleVT();
  }
  virtual EVT getSetCCResultType(EVT VT) const {
    return MVT::i32;
  }
  virtual bool isFMAFasterThanMulAndAdd(EVT) const LLVM_OVERRIDE {
    return true;
  }
  bool isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const;
  virtual bool isFPImmLegal(const APFloat &Imm, EVT VT) const;
  virtual const char *getTargetNodeName(unsigned Opcode) const LLVM_OVERRIDE;
  virtual std::pair<unsigned, const TargetRegisterClass *>
    getRegForInlineAsmConstraint(const std::string &Constraint,
                                 EVT VT) const LLVM_OVERRIDE;
  virtual TargetLowering::ConstraintType
    getConstraintType(const std::string &Constraint) const LLVM_OVERRIDE;
  virtual TargetLowering::ConstraintWeight
    getSingleConstraintMatchWeight(AsmOperandInfo &info,
                                   const char *constraint) const LLVM_OVERRIDE;
  virtual void
    LowerAsmOperandForConstraint(SDValue Op,
                                 std::string &Constraint,
                                 std::vector<SDValue> &Ops,
                                 SelectionDAG &DAG) const LLVM_OVERRIDE;
  virtual MachineBasicBlock *
    EmitInstrWithCustomInserter(MachineInstr *MI,
                                MachineBasicBlock *BB) const LLVM_OVERRIDE;
  virtual SDValue LowerOperation(SDValue Op,
                                 SelectionDAG &DAG) const LLVM_OVERRIDE;
  virtual SDValue
    LowerFormalArguments(SDValue Chain,
                         CallingConv::ID CallConv, bool isVarArg,
                         const SmallVectorImpl<ISD::InputArg> &Ins,
                         DebugLoc DL, SelectionDAG &DAG,
                         SmallVectorImpl<SDValue> &InVals) const LLVM_OVERRIDE;
  virtual SDValue
    LowerCall(CallLoweringInfo &CLI,
              SmallVectorImpl<SDValue> &InVals) const LLVM_OVERRIDE;

  virtual bool
    CanLowerReturn(CallingConv::ID CallConv, MachineFunction &MF,
                   bool isVarArg,
                   const SmallVectorImpl<ISD::OutputArg> &Outs,
                   LLVMContext &Context) const;

  virtual SDValue
    LowerReturn(SDValue Chain,
                CallingConv::ID CallConv, bool IsVarArg,
                const SmallVectorImpl<ISD::OutputArg> &Outs,
                const SmallVectorImpl<SDValue> &OutVals,
                DebugLoc DL, SelectionDAG &DAG) const LLVM_OVERRIDE;

    struct LTStr {
      bool operator()(const char *S1, const char *S2) const {
        return strcmp(S1, S2) < 0;
      }
    };

    /// ByValArgInfo - Byval argument information.
    struct ByValArgInfo {
      unsigned FirstIdx; // Index of the first register used.
      unsigned NumRegs;  // Number of registers used for this argument.
      unsigned Address;  // Offset of the stack area used to pass this argument.

      ByValArgInfo() : FirstIdx(0), NumRegs(0), Address(0) {}
    };

    /// RISCVCC - This class provides methods used to analyze formal and call
    /// arguments and inquire about calling convention information.
    class RISCVCC {
    public:
      RISCVCC(CallingConv::ID CallConv, bool IsRV32, CCState &Info, const RISCVSubtarget &Subtarget);

      void analyzeCallOperands(const SmallVectorImpl<ISD::OutputArg> &Outs,
                               bool IsVarArg, bool IsSoftFloat,
                               const SDNode *CallNode,
                               std::vector<ArgListEntry> &FuncArgs);
      void analyzeFormalArguments(const SmallVectorImpl<ISD::InputArg> &Ins,
                                  bool IsSoftFloat,
                                  Function::const_arg_iterator FuncArg);

      void analyzeCallResult(const SmallVectorImpl<ISD::InputArg> &Ins,
                             bool IsSoftFloat, const SDNode *CallNode,
                             const Type *RetTy) const;

      void analyzeReturn(const SmallVectorImpl<ISD::OutputArg> &Outs,
                         bool IsSoftFloat, const Type *RetTy) const;

      const CCState &getCCInfo() const { return CCInfo; }

      /// hasByValArg - Returns true if function has byval arguments.
      bool hasByValArg() const { return !ByValArgs.empty(); }

      /// regSize - Size (in number of bytes) of integer registers.
      unsigned regSize() const { return IsRV32 ? 4 : 8; }

      /// regSize - Size (in number of bytes) of fp registers.
      unsigned fpRegSize() const { return Subtarget.hasD() ? 8 : 
                                        Subtarget.hasF() ? 4 :
                                        regSize(); }

      /// numIntArgRegs - Number of integer registers available for calls.
      unsigned numIntArgRegs() const;

      /// numFPArgRegs - Number of fp registers available for calls.
      unsigned numFPArgRegs() const;

      /// reservedArgArea - The size of the area the caller reserves for
      /// register arguments. This is 16-byte if ABI is O32.
      unsigned reservedArgArea() const;

      /// Return pointer to array of integer argument registers.
      const uint16_t *intArgRegs() const;

      /// Return pointer to array of fp argument registers.
      const uint16_t *fpArgRegs() const;

      typedef SmallVector<ByValArgInfo, 2>::const_iterator byval_iterator;
      byval_iterator byval_begin() const { return ByValArgs.begin(); }
      byval_iterator byval_end() const { return ByValArgs.end(); }

    private:
      void handleByValArg(unsigned ValNo, MVT ValVT, MVT LocVT,
                          CCValAssign::LocInfo LocInfo,
                          ISD::ArgFlagsTy ArgFlags);

      /// useRegsForByval - Returns true if the calling convention allows the
      /// use of registers to pass byval arguments.
      bool useRegsForByval() const { return CallConv != CallingConv::Fast; }

      /// Return the function that analyzes fixed argument list functions.
      llvm::CCAssignFn *fixedArgFn() const;

      /// Return the function that analyzes variable argument list functions.
      llvm::CCAssignFn *varArgFn() const;

      const uint16_t *shadowRegs() const;

      void allocateRegs(ByValArgInfo &ByVal, unsigned ByValSize,
                        unsigned Align, MVT ValVT);

      /// Return the type of the register which is used to pass an argument or
      /// return a value. This function returns f64 if the argument is an i64
      /// value which has been generated as a result of softening an f128 value.
      /// Otherwise, it just returns VT.
      MVT getRegVT(MVT VT, const Type *OrigTy, const SDNode *CallNode,
                   bool IsSoftFloat) const;

      template<typename Ty>
      void analyzeReturn(const SmallVectorImpl<Ty> &RetVals, bool IsSoftFloat,
                         const SDNode *CallNode, const Type *RetTy) const;

      CCState &CCInfo;
      CallingConv::ID CallConv;
      bool IsRV32;
      const RISCVSubtarget &Subtarget;
      SmallVector<ByValArgInfo, 2> ByValArgs;
    };

private:
  const RISCVSubtarget &Subtarget;
  const RISCVTargetMachine &TM;
public:
  bool IsRV32;
private:

  // Implement LowerOperation for individual opcodes.
  //SDValue lowerBR_CC(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerGlobalAddress(SDValue Op,
                             SelectionDAG &DAG) const;
  SDValue lowerGlobalTLSAddress(GlobalAddressSDNode *Node,
                                SelectionDAG &DAG) const;
  SDValue lowerBlockAddress(BlockAddressSDNode *Node,
                            SelectionDAG &DAG) const;
  SDValue lowerJumpTable(JumpTableSDNode *JT, SelectionDAG &DAG) const;
  SDValue lowerConstantPool(ConstantPoolSDNode *CP, SelectionDAG &DAG) const;
  SDValue lowerVASTART(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerVAARG(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerDYNAMIC_STACKALLOC(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerUMUL_LOHI(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSDIVREM(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerUDIVREM(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerBITCAST(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerOR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerATOMIC_FENCE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerATOMIC_LOAD(SDValue Op, SelectionDAG &DAG,
                           unsigned Opcode) const;
  SDValue lowerATOMIC_CMP_SWAP(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSTACKSAVE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSTACKRESTORE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;

  // Implement EmitInstrWithCustomInserter for individual operation types.
  MachineBasicBlock *emitSelectCC(MachineInstr *MI,
                                MachineBasicBlock *BB) const;
  MachineBasicBlock *emitAtomicCmpSwap(MachineInstr *MI,
                                        MachineBasicBlock *BB,
                                        unsigned Size) const;
  MachineBasicBlock *emitExt128(MachineInstr *MI,
                                MachineBasicBlock *MBB,
                                bool ClearEven, unsigned SubReg) const;
  MachineBasicBlock *emitAtomicLoadBinary(MachineInstr *MI,
                                          MachineBasicBlock *BB,
                                          unsigned BinOpcode, unsigned BitSize,
                                          bool Invert = false) const;
  MachineBasicBlock *emitAtomicLoadMinMax(MachineInstr *MI,
                                          MachineBasicBlock *MBB,
                                          unsigned CompareOpcode,
                                          unsigned KeepOldMask,
                                          unsigned BitSize) const;
  MachineBasicBlock *emitAtomicCmpSwapW(MachineInstr *MI,
                                        MachineBasicBlock *BB) const;

  // copyByValArg - Copy argument registers which were used to pass a byval
  // argument to the stack. Create a stack frame object for the byval
  // argument.
  void copyByValRegs(SDValue Chain, DebugLoc DL,
                     std::vector<SDValue> &OutChains, SelectionDAG &DAG,
                     const ISD::ArgFlagsTy &Flags,
                     SmallVectorImpl<SDValue> &InVals,
                     const Argument *FuncArg,
                     const RISCVCC &CC, const ByValArgInfo &ByVal) const;
    /// passByValArg - Pass a byval argument in registers or on stack.
    void passByValArg(SDValue Chain, DebugLoc DL,
                      std::deque< std::pair<unsigned, SDValue> > &RegsToPass,
                      SmallVector<SDValue, 8> &MemOpChains, SDValue StackPtr,
                      MachineFrameInfo *MFI, SelectionDAG &DAG, SDValue Arg,
                      const RISCVCC &CC, const ByValArgInfo &ByVal,
                      const ISD::ArgFlagsTy &Flags, bool isLittle) const;
  // writeVarArgRegs - Write variable function arguments passed in registers
  // to the stack. Also create a stack frame object for the first variable
  // argument.
  void writeVarArgRegs(std::vector<SDValue> &OutChains, const RISCVCC &CC,
                       SDValue Chain, DebugLoc DL, SelectionDAG &DAG) const;
};
} // end namespace llvm

#endif // LLVM_TARGET_RISCV_ISELLOWERING_H
