//===-- RISCVISelLowering.h - RISCV DAG lowering interface ------*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_RISCV_ISELLOWERING_H
#define LLVM_LIB_TARGET_RISCV_ISELLOWERING_H

#include "RISCV.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/IR/Function.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
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

    // Jump and link to Operand 0 is the chain operand and operand 1
    // is the register to store the return address. Operand 2 is the target address
    JAL,

    // Wraps a TargetGlobalAddress that should be loaded using PC-relative
    // accesses (AUIPC).  Operand 0 is the address.
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

    // Branches if a condition is true.  Operand 0 is the chain operand;
    // operand 1 is the 4-bit condition-code mask, with bit N in
    // big-endian order meaning "branch if CC=N"; operand 2 is the
    // target block and operand 3 is the flag operand.
    BRCOND,

    // Selects between operand 0 and operand 1.  Operand 2 is the
    // mask of condition-code values for which operand 0 should be
    // chosen over operand 1; it has the same form as BR_CCMASK.
    // Operand 3 is the flag operand.
    SELECT_CC,

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
    ATOMIC_LOADW_UMAX
  };
}

class RISCVSubtarget;

class RISCVTargetLowering : public TargetLowering {
public:
  explicit RISCVTargetLowering(const TargetMachine &TM, const RISCVSubtarget &STI);

  // Override TargetLowering.
  MVT getScalarShiftAmountTy(const DataLayout &, EVT LHSTy) const override {
    return LHSTy.getSizeInBits() <= 32 ? MVT::i32 : MVT::i64;
  }
  EVT getSetCCResultType(const DataLayout &, LLVMContext &, EVT VT) const override {
    return MVT::i32;
  }
  bool isFMAFasterThanFMulAndFAdd(EVT) const override {
    return true;
  }
  /// If a physical register, this returns the register that receives the
  /// exception address on entry to an EH pad.
  unsigned
  getExceptionPointerRegister(const Constant *PersonalityFn) const override;
  /// If a physical register, this returns the register that receives the
  /// exception typeid on entry to a landing pad.
  unsigned
  getExceptionSelectorRegister(const Constant *PersonalityFn) const override;

  bool isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const;
  bool isFPImmLegal(const APFloat &Imm, EVT VT) const override;
  const char *getTargetNodeName(unsigned Opcode) const override;
  std::pair<unsigned, const TargetRegisterClass *>
  getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                               StringRef Constraint,
                               MVT VT) const override;
  TargetLowering::ConstraintType
  getConstraintType(StringRef Constraint) const override;
  TargetLowering::ConstraintWeight
  getSingleConstraintMatchWeight(AsmOperandInfo &info,
                                 const char *constraint) const override;
  void LowerAsmOperandForConstraint(SDValue Op, std::string &Constraint,
                                    std::vector<SDValue> &Ops,
                                    SelectionDAG &DAG) const override;
  MachineBasicBlock *
  EmitInstrWithCustomInserter(MachineInstr *MI,
                              MachineBasicBlock *BB) const override;
  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;
  SDValue LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv,
                               bool isVarArg,
                               const SmallVectorImpl<ISD::InputArg> &Ins,
                               SDLoc DL, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) const override;
  SDValue LowerCall(CallLoweringInfo &CLI,
                    SmallVectorImpl<SDValue> &InVals) const override;

  virtual bool
    CanLowerReturn(CallingConv::ID CallConv, MachineFunction &MF,
                   bool isVarArg,
                   const SmallVectorImpl<ISD::OutputArg> &Outs,
                   LLVMContext &Context) const;

  SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      const SmallVectorImpl<SDValue> &OutVals, SDLoc DL,
                      SelectionDAG &DAG) const override;

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

private:
  const RISCVSubtarget &Subtarget;
public:
  bool IsRV32;
private:

  // Implement LowerOperation for individual opcodes.
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
  SDValue lowerBITCAST(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerOR(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerATOMIC_FENCE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerATOMIC_LOAD(SDValue Op, SelectionDAG &DAG,
                           unsigned Opcode) const;
  SDValue lowerSTACKSAVE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerSTACKRESTORE(SDValue Op, SelectionDAG &DAG) const;
  SDValue lowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;

  // Helper functions for above
  SDValue getTargetNode(SDValue Op, SelectionDAG &DAG, unsigned Flag) const;
  SDValue getAddrNonPIC(SDValue Op, SelectionDAG &DAG) const;
  SDValue getAddrPIC(SDValue Op, SelectionDAG &DAG) const;

  // Implement EmitInstrWithCustomInserter for individual operation types.
  MachineBasicBlock *emitCALL(MachineInstr *MI,
                                MachineBasicBlock *BB) const;
  MachineBasicBlock *emitSelectCC(MachineInstr *MI,
                                MachineBasicBlock *BB) const;

};

class RISCVTargetObjectFile : public TargetLoweringObjectFileELF {
  void Initialize(MCContext &Ctx, const TargetMachine &TM);
};

} // end namespace llvm

#endif
