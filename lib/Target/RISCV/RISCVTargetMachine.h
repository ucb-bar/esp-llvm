//==- RISCVTargetMachine.h - Define TargetMachine for RISCV ---*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the RISCV specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//


#ifndef RISCVTARGETMACHINE_H
#define RISCVTARGETMACHINE_H

#include "RISCVSubtarget.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class TargetFrameLowering;

class RISCVTargetMachine : public LLVMTargetMachine {
  RISCVSubtarget Subtarget;

public:
  RISCVTargetMachine(const Target &T, StringRef TT, StringRef CPU,
                       StringRef FS, const TargetOptions &Options,
                       Reloc::Model RM, CodeModel::Model CM,
                       CodeGenOpt::Level OL);

  // Override TargetMachine.
  const TargetFrameLowering *getFrameLowering() const override {
    return getSubtargetImpl()->getFrameLowering();
  }
  const RISCVInstrInfo *getInstrInfo() const override {
    return getSubtargetImpl()->getInstrInfo();
  }
  const RISCVSubtarget *getSubtargetImpl() const override { return &Subtarget; }
  const DataLayout *getDataLayout() const override {
    return getSubtargetImpl()->getDataLayout();
  }
  const RISCVRegisterInfo *getRegisterInfo() const override {
    return getSubtargetImpl()->getRegisterInfo();
  }
  const RISCVTargetLowering *getTargetLowering() const override {
    return getSubtargetImpl()->getTargetLowering();
  }
  const TargetSelectionDAGInfo *getSelectionDAGInfo() const override {
    return getSubtargetImpl()->getSelectionDAGInfo();
  }

  // Override LLVMTargetMachine
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;
};

} // end namespace llvm

#endif
