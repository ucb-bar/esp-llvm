//===-- RISCVMCFixups.h - RISCV-specific fixup entries ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_RISCVMCFIXUPS_H
#define LLVM_RISCVMCFIXUPS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace RISCV {
  enum FixupKind {
    // These correspond directly to R_390_* relocations.
    FK_390_PC16DBL = FirstTargetFixupKind,
    FK_390_PC32DBL,
    FK_390_PLT16DBL,
    FK_390_PLT32DBL,
    FK_390_PLT64DBL,

    // Marker
    LastTargetFixupKind,
    NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
  };
}
} // end namespace llvm

#endif
