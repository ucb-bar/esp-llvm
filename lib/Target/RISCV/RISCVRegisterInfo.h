//===-- RISCVRegisterInfo.h - RISCV register information --------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVREGISTERINFO_H
#define LLVM_LIB_TARGET_RISCV_RISCVREGISTERINFO_H

#include "RISCV.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "RISCVMachineFunctionInfo.h"

#define GET_REGINFO_HEADER
#include "RISCVGenRegisterInfo.inc"

namespace llvm {

class RISCVInstrInfo;
class RISCVSubtarget;

struct RISCVRegisterInfo : public RISCVGenRegisterInfo {
public:
  const RISCVSubtarget &Subtarget;
  
  RISCVRegisterInfo(const RISCVSubtarget &STI);

  // Override TargetRegisterInfo.h.
  bool requiresRegisterScavenging(const MachineFunction &MF) const override {
    return true;
  }
  bool requiresFrameIndexScavenging(const MachineFunction &MF) const override {
    return true;
  }
  const uint16_t *
  getCalleeSavedRegs(const MachineFunction *MF = 0) const override;
  const uint32_t *
  getCallPreservedMask(const MachineFunction &MF, CallingConv::ID) const override;
  BitVector getReservedRegs(const MachineFunction &MF) const override;
  void eliminateFrameIndex(MachineBasicBlock::iterator MI, int SPAdj,
                           unsigned FIOperandNum,
                           RegScavenger *RS) const override;
  unsigned getFrameRegister(const MachineFunction &MF) const override;

private:
  virtual void eliminateFI(MachineBasicBlock::iterator II, unsigned OpNo,
                           int FrameIndex, uint64_t StackSize,
                           int64_t SPOffset) const;
};

} // end namespace llvm

#endif
