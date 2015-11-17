//===-- RISCVMCTargetDesc.h - RISCV target descriptions ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVMCTARGETDESC_H
#define LLVM_LIB_TARGET_RISCV_RISCVMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"
#include "llvm/Support/TargetRegistry.h"

namespace llvm {

class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class StringRef;
class Target;
class raw_ostream;

extern Target TheRISCVTarget;
extern Target TheRISCV64Target;

MCCodeEmitter *createRISCVMCCodeEmitter(const MCInstrInfo &MCII,
                                          const MCRegisterInfo &MRI,
                                          MCContext &Ctx);

MCAsmBackend *createRISCVMCAsmBackend(const Target &T,
                                      const MCRegisterInfo &MRI, const Triple &TT,
                                      StringRef CPU);

MCObjectWriter *createRISCVObjectWriter(raw_pwrite_stream &OS, uint8_t OSABI);

namespace RISCVMC {
  // How many bytes are in the ABI-defined, caller-allocated part of
  // a stack frame.
  const int64_t CallFrameSize = 160;

  // The offset of the DWARF CFA from the incoming stack pointer.
  const int64_t CFAOffsetFromInitialSP = CallFrameSize;
}
} // end namespace llvm

// Defines symbolic names for RISCV registers.
// This defines a mapping from register name to register number.
#define GET_REGINFO_ENUM
#include "RISCVGenRegisterInfo.inc"

// Defines symbolic names for the RISCV instructions.
#define GET_INSTRINFO_ENUM
#include "RISCVGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "RISCVGenSubtargetInfo.inc"

#endif
