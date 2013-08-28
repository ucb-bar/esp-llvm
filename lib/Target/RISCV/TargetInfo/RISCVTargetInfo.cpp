//===-- RISCVTargetInfo.cpp - RISCV target implementation -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

Target llvm::TheRISCVTarget;

extern "C" void LLVMInitializeRISCVTargetInfo() {
  RegisterTarget<Triple::riscv, /*HasJIT=*/false>
    X(TheRISCVTarget, "riscv", "RISCV");
}
