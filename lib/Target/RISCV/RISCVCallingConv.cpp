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
  RISCV::a0,  RISCV::a1,  RISCV::a2,  RISCV::a3, RISCV::a4,
  RISCV::a5,  RISCV::a6,  RISCV::a7  
};

const unsigned RISCV::ArgFPRs[RISCV::NumArgFPRs] = {
  RISCV::fa0,  RISCV::fa1,  RISCV::fa2,  RISCV::fa3, RISCV::fa4,
  RISCV::fa5,  RISCV::fa6,  RISCV::fa7
};
