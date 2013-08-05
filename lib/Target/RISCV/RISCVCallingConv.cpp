//===-- RISCVCallingConv.cpp - Calling conventions for RISCV ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVCallingConv.h"
#include "RISCVRegisterInfo.h"

using namespace llvm;

const unsigned RISCV::ArgGPRs[RISCV::NumArgGPRs] = {
  RISCV::X18, RISCV::X19, RISCV::X20, RISCV::X21, RISCV::X22,
  RISCV::X23, RISCV::X24, RISCV::X25, RISCV::X26, RISCV::X27,
  RISCV::X28, RISCV::X29, RISCV::X30, RISCV::X31
};

const unsigned RISCV::ArgFPRs[RISCV::NumArgFPRs] = {
  RISCV::F18, RISCV::F19, RISCV::F20, RISCV::F21, RISCV::F22,
  RISCV::F23, RISCV::F24, RISCV::F25, RISCV::F26, RISCV::F27,
  RISCV::F28, RISCV::F29, RISCV::F30, RISCV::F31
};
