//===- RISCVTargetMachine.h - Define TargetMachine for RISCV ----*- C++ -*-===//
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


#ifndef LLVM_LIB_TARGET_RISCV_RISCVTARGETMACHINE_H
#define LLVM_LIB_TARGET_RISCV_RISCVTARGETMACHINE_H

#include "RISCVSubtarget.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class TargetFrameLowering;

class RISCVTargetMachine : public LLVMTargetMachine {

public:
  RISCVTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                       StringRef FS, const TargetOptions &Options,
                       Reloc::Model RM, CodeModel::Model CM,
                       CodeGenOpt::Level OL);

  // Override TargetMachine.
  const RISCVSubtarget *getSubtargetImpl() const { return &Subtarget; }
  const RISCVSubtarget *getSubtargetImpl(const Function &F) const override;
  // Override LLVMTargetMachine
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;
  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }

protected:
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  RISCVSubtarget Subtarget;

private:
  mutable StringMap<std::unique_ptr<RISCVSubtarget>> SubtargetMap;
};

class RISCV64TargetMachine : public RISCVTargetMachine {

public:
  RISCV64TargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                       StringRef FS, const TargetOptions &Options,
                       Reloc::Model RM, CodeModel::Model CM,
                       CodeGenOpt::Level OL);
};

} // end namespace llvm

#endif
