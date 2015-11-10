//===-- RISCVXhwachaUtilities - Utilities -----------------------------*- C++ -*-====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the Xhwacha specific utlities
//
//===----------------------------------------------------------------------===//
//
#ifndef LLVM_LIB_TARGET_RISCV_RISCVXHWACHAUTILITIES_H
#define LLVM_LIB_TARGET_RISCV_RISCVXHWACHAUTILITIES_H

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

namespace llvm {

bool isOpenCLKernelFunction(const Function &F);

}
#endif
