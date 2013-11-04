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
                                           Reloc::Model RM,
                                           CodeModel::Model CM,
                                           CodeGenOpt::Level OL)
  : LLVMTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL),
    Subtarget(TT, CPU, FS),
    // Make sure that global data has at least 16 bits of alignment by default,
    // so that we can refer to it using LARL.  We don't have any special
    // requirements for stack variables though.

    //Quick doc on this incomprehensible garbage below ('-' are delimiters)
    //e -- little endian
    //p:64:64:64 -- pointers are 32bits abi alignment is 32bits preferred alignment is also 32 bits
    //i1:8:16 -- int1 are abi 8 bit aligned and preferred 16
    //i8,u16,i32,f32 -- same as above omitting preferred as needed
    //a0:8:16 -- aggregate type of 0bit? should be 8 bit by api and 16 by pref
    //n32 -- native integer width is 32bits
    DL(Subtarget.isRV64() ? 
       "e-p:64:64:64-i1:8:16-i8:8:16-i16:16-i32:32-i64:64-"
       "f64:64-f128:128-n32:64" :
       "e-p:32:32:32-i1:8:16-i8:8:16-i16:16-i32:32-"
       "f32:32-f64:64-f128:128-n32"),
    InstrInfo(*this), TLInfo(*this), TSInfo(*this),
    FrameLowering(*this, Subtarget) {
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
};
} // end anonymous namespace

bool RISCVPassConfig::addInstSelector() {
  addPass(createRISCVISelDag(getRISCVTargetMachine(), getOptLevel()));
  return false;
}

TargetPassConfig *RISCVTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new RISCVPassConfig(this, PM);
}
