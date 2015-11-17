//===-- RISCVCallingConv.h - Calling conventions for RISCV ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVCALLINGCONV_H
#define LLVM_LIB_TARGET_RISCV_RISCVCALLINGCONV_H

namespace llvm {
  namespace RISCV {
    const unsigned NumArgGPRs = 8;

    const unsigned NumArgFPRs = 8;
  }
}

#endif
