//===-- RISCVTargetMachine.cpp - Define TargetMachine for RISCV -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

extern "C" void LLVMInitializeRISCVTarget() {
  // Register the target.
  RegisterTargetMachine<RISCVTargetMachine> X(TheRISCVTarget);
}

RISCVTargetMachine::RISCVTargetMachine(const Target &T, StringRef TT,
                                       StringRef CPU, StringRef FS,
                                       const TargetOptions &Options,
                                       Reloc::Model RM, CodeModel::Model CM,
                                       CodeGenOpt::Level OL)
    : LLVMTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

namespace {
/// RISCV Code Generator Pass Configuration Options.
class RISCVPassConfig : public TargetPassConfig {
public:
  RISCVPassConfig(RISCVTargetMachine *TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  RISCVTargetMachine &getRISCVTargetMachine() const {
    return getTM<RISCVTargetMachine>();
  }

  virtual bool addInstSelector();
  virtual bool addPreEmitPass();
};
} // end anonymous namespace

bool RISCVPassConfig::addInstSelector() {
  addPass(createRISCVISelDag(getRISCVTargetMachine(), getOptLevel()));
  return false;
}

bool RISCVPassConfig::addPreEmitPass(){
  addPass(createRISCVBranchSelectionPass());
  return false;
}

TargetPassConfig *RISCVTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new RISCVPassConfig(this, PM);
}
