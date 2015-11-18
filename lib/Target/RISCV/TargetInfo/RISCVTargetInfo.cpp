//===-- RISCVTargetInfo.cpp - RISCV target implementation -------*- C++ -*-===//
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

Target llvm::TheRISCVTarget, llvm::TheRISCV64Target;

extern "C" void LLVMInitializeRISCVTargetInfo() {
  RegisterTarget<Triple::riscv, /*HasJIT=*/false>
    A(TheRISCVTarget, "riscv", "RISCV");

  RegisterTarget<Triple::riscv64, /*HasJIT=*/false>
    B(TheRISCV64Target, "riscv64", "RISCV 64");
}
