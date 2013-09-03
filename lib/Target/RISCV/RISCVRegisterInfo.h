//===-- RISCVRegisterInfo.h - RISCV register information ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef RISCVREGISTERINFO_H
#define RISCVREGISTERINFO_H

#include "RISCV.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "RISCVMachineFunctionInfo.h"

#define GET_REGINFO_HEADER
#include "RISCVGenRegisterInfo.inc"

namespace llvm {

class RISCVSubtarget;
class RISCVInstrInfo;

struct RISCVRegisterInfo : public RISCVGenRegisterInfo {
private:
  RISCVTargetMachine &TM;
  const RISCVInstrInfo &TII;

public:
  RISCVRegisterInfo(RISCVTargetMachine &tm, const RISCVInstrInfo &tii);

  // Override TargetRegisterInfo.h.
  virtual bool requiresRegisterScavenging(const MachineFunction &MF) const
    LLVM_OVERRIDE {
    return true;
  }
  virtual bool requiresFrameIndexScavenging(const MachineFunction &MF) const
    LLVM_OVERRIDE {
    return true;
  }
  virtual const uint16_t *getCalleeSavedRegs(const MachineFunction *MF = 0)
    const LLVM_OVERRIDE;
  const uint32_t *getCallPreservedMask(CallingConv::ID) const;
  virtual BitVector getReservedRegs(const MachineFunction &MF)
    const LLVM_OVERRIDE;
  virtual void eliminateFrameIndex(MachineBasicBlock::iterator MI,
                                   int SPAdj, unsigned FIOperandNum,
                                   RegScavenger *RS) const LLVM_OVERRIDE;
  virtual unsigned getFrameRegister(const MachineFunction &MF) const
    LLVM_OVERRIDE;
private:
  virtual void eliminateFI(MachineBasicBlock::iterator II, unsigned OpNo,
                           int FrameIndex, uint64_t StackSize,
                           int64_t SPOffset) const;
};

} // end namespace llvm

#endif
