//====-- RISCVMCAsmInfo.h - RISCV asm properties ---------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVTARGETASMINFO_H
#define LLVM_LIB_TARGET_RISCV_RISCVTARGETASMINFO_H

#include "llvm/MC/MCAsmInfo.h"
#include "llvm/Support/Compiler.h"

namespace llvm {
class StringRef;

class RISCVMCAsmInfo : public MCAsmInfo {
public:
  explicit RISCVMCAsmInfo();

};

} // namespace llvm

#endif
