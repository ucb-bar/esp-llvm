//===-- RISCVTargetMachine.cpp - Define TargetMachine for RISCV -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

extern "C" void LLVMInitializeRISCVTarget() {
  // Register the target.
  RegisterTargetMachine<RISCVTargetMachine> A(TheRISCVTarget);
  RegisterTargetMachine<RISCV64TargetMachine> B(TheRISCV64Target);
}

static std::string computeDataLayout(const Triple &TT) {
  
  std::string Ret =
       TT.isArch64Bit() ? "e-m:e-i1:8:16-i8:8:16-i64:64-f80:128-n32:64" :
       "e-m:e-p:32:32:32-i1:8:16-i8:8:16-i16:16-i32:32-"
       "f32:32-f64:64-f80:128-f128:128-n32";
  return Ret;
}

RISCVTargetMachine::RISCVTargetMachine(const Target &T, const Triple &TT,
                                       StringRef CPU, StringRef FS,
                                       const TargetOptions &Options,
                                       Reloc::Model RM, CodeModel::Model CM,
                                       CodeGenOpt::Level OL)
    : LLVMTargetMachine(T, computeDataLayout(TT), TT, CPU, FS, Options, RM, CM, OL),
      TLOF(make_unique<RISCVTargetObjectFile>()),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

RISCV64TargetMachine::RISCV64TargetMachine(const Target &T, const Triple &TT,
                                       StringRef CPU, StringRef FS,
                                       const TargetOptions &Options,
                                       Reloc::Model RM, CodeModel::Model CM,
                                       CodeGenOpt::Level OL)
  :RISCVTargetMachine(T, TT, CPU, FS, Options, RM, CM, OL) {}


const RISCVSubtarget *
RISCVTargetMachine::getSubtargetImpl(const Function &F) const {
  Attribute CPUAttr = F.getFnAttribute("target-cpu");
  Attribute FSAttr = F.getFnAttribute("target-features");

  std::string CPU = !CPUAttr.hasAttribute(Attribute::None)
                        ? CPUAttr.getValueAsString().str()
                        : TargetCPU;
  std::string FS = !FSAttr.hasAttribute(Attribute::None)
                       ? FSAttr.getValueAsString().str()
                       : TargetFS;

  auto &I = SubtargetMap[CPU + FS];
  if (!I) {
    // This needs to be done before we create a new subtarget since any
    // creation will depend on the TM and the code generation flags on the
    // function that reside in TargetOptions.
    resetTargetOptions(F);
    I = llvm::make_unique<RISCVSubtarget>(TargetTriple, CPU, FS, *this);
  }
  return I.get();
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

  bool addInstSelector() override;
  void addPreEmitPass() override;
};
} // end anonymous namespace

bool RISCVPassConfig::addInstSelector() {
  addPass(createRISCVISelDag(getRISCVTargetMachine(), getOptLevel()));
  return false;
}

void RISCVPassConfig::addPreEmitPass(){
  addPass(createRISCVBranchSelectionPass());
}

TargetPassConfig *RISCVTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new RISCVPassConfig(this, PM);
}
