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

#include "RISCVFrameLowering.h"
#include "RISCVISelLowering.h"
#include "RISCVInstrInfo.h"
#include "RISCVRegisterInfo.h"
#include "RISCVSubtarget.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetSelectionDAGInfo.h"

namespace llvm {

class RISCVTargetMachine : public LLVMTargetMachine {
  RISCVSubtarget        Subtarget;
  const DataLayout        DL;
  RISCVInstrInfo        InstrInfo;
  RISCVTargetLowering   TLInfo;
  TargetSelectionDAGInfo  TSInfo;
  RISCVFrameLowering    FrameLowering;

public:
  RISCVTargetMachine(const Target &T, StringRef TT, StringRef CPU,
                       StringRef FS, const TargetOptions &Options,
                       Reloc::Model RM, CodeModel::Model CM,
                       CodeGenOpt::Level OL);

  // Override TargetMachine.
  virtual const TargetFrameLowering *getFrameLowering() const LLVM_OVERRIDE {
    return &FrameLowering;
  }
  virtual const RISCVInstrInfo *getInstrInfo() const LLVM_OVERRIDE {
    return &InstrInfo;
  }
  virtual const RISCVSubtarget *getSubtargetImpl() const LLVM_OVERRIDE {
    return &Subtarget;
  }
  virtual const DataLayout *getDataLayout() const LLVM_OVERRIDE {
    return &DL;
  }
  virtual const RISCVRegisterInfo *getRegisterInfo() const LLVM_OVERRIDE {
    return &InstrInfo.getRegisterInfo();
  }
  virtual const RISCVTargetLowering *getTargetLowering() const LLVM_OVERRIDE {
    return &TLInfo;
  }
  virtual const TargetSelectionDAGInfo *getSelectionDAGInfo() const
    LLVM_OVERRIDE {
    return &TSInfo;
  }

  // Override LLVMTargetMachine
  virtual TargetPassConfig *createPassConfig(PassManagerBase &PM) LLVM_OVERRIDE;
};

} // end namespace llvm

#endif
