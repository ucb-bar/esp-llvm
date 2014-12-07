//===-- RISCVMCTargetDesc.h - RISCV target descriptions -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef RISCVMCTARGETDESC_H
#define RISCVMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

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

namespace RISCVMC {
  // How many bytes are in the ABI-defined, caller-allocated part of
  // a stack frame.
  const int64_t CallFrameSize = 160;

  // The offset of the DWARF CFA from the incoming stack pointer.
  const int64_t CFAOffsetFromInitialSP = CallFrameSize;
}

MCCodeEmitter *createRISCVMCCodeEmitter(const MCInstrInfo &MCII,
                                          const MCRegisterInfo &MRI,
                                          const MCSubtargetInfo &STI,
                                          MCContext &Ctx);

MCAsmBackend *createRISCVMCAsmBackend(const Target &T,
                                      const MCRegisterInfo &MRI, StringRef TT,
                                      StringRef CPU);

MCObjectWriter *createRISCVObjectWriter(raw_ostream &OS, uint8_t OSABI);
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
