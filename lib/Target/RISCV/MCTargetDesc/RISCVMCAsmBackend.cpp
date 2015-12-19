//===-- RISCVMCAsmBackend.cpp - RISCV assembler backend ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/RISCVMCTargetDesc.h"
#include "MCTargetDesc/RISCVMCFixups.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCObjectWriter.h"

using namespace llvm;

// Value is a fully-resolved relocation value: Symbol + Addend [- Pivot].
// Return the bits that should be installed in a relocation field for
// fixup kind Kind.
static uint64_t extractBitsForFixup(MCFixupKind Kind, uint64_t Value) {
  if (Kind < FirstTargetFixupKind)
    return Value;

  switch (unsigned(Kind)) {
  case RISCV::fixup_riscv_brlo:
  case RISCV::fixup_riscv_brhi:
  case RISCV::fixup_riscv_jal:
    return (int64_t)Value / 2;
  }

  llvm_unreachable("Unknown fixup kind!");
}

// If Opcode can be relaxed, return the relaxed form, otherwise return 0.
static unsigned getRelaxedOpcode(unsigned Opcode) {
  switch (Opcode) {
  //case RISCV::BRC:  return RISCV::BRCL;
  //case RISCV::J:    return RISCV::JG;
  //case RISCV::BRAS: return RISCV::BRASL;
  }
  return 0;
}

namespace {
class RISCVMCAsmBackend : public MCAsmBackend {
  uint8_t OSABI;
public:
  RISCVMCAsmBackend(uint8_t osABI)
    : OSABI(osABI) {}

  // Override MCAsmBackend
  unsigned getNumFixupKinds() const override {
    return RISCV::NumTargetFixupKinds;
  }
  const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const override;
  void applyFixup(const MCFixup &Fixup, char *Data, unsigned DataSize,
                  uint64_t Value, bool IsPCRel) const override;
  bool mayNeedRelaxation(const MCInst &Inst) const override;
  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *Fragment,
                            const MCAsmLayout &Layout) const override;
  void relaxInstruction(const MCInst &Inst, MCInst &Res) const override;
  bool writeNopData(uint64_t Count, MCObjectWriter *OW) const override;
  MCObjectWriter *createObjectWriter(raw_pwrite_stream &OS) const override {
    return createRISCVObjectWriter(OS, OSABI);
  }
};
} // end anonymous namespace

const MCFixupKindInfo &
RISCVMCAsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  const static MCFixupKindInfo Infos[RISCV::NumTargetFixupKinds] = {
    { "fixup_riscv_brlo",  10, 7, MCFixupKindInfo::FKF_IsPCRel },
    { "fixup_riscv_brhi",  27, 5, MCFixupKindInfo::FKF_IsPCRel },
    { "fixup_riscv_jal", 0, 20, MCFixupKindInfo::FKF_IsPCRel },
    // target offset(0) doesn't make sense here: bits are non continuous
  };

  if (Kind < FirstTargetFixupKind)
    return MCAsmBackend::getFixupKindInfo(Kind);

  assert(unsigned(Kind - FirstTargetFixupKind) < getNumFixupKinds() &&
         "Invalid kind!");
  return Infos[Kind - FirstTargetFixupKind];
}

void RISCVMCAsmBackend::applyFixup(const MCFixup &Fixup, char *Data,
                                   unsigned DataSize, uint64_t Value,
                                   bool IsPCRel) const {
  MCFixupKind Kind = Fixup.getKind();
  unsigned Offset = Fixup.getOffset();
  unsigned Size = (getFixupKindInfo(Kind).TargetSize + 7) / 8;

  assert(Offset + Size <= DataSize && "Invalid fixup offset!");

  // Big-endian insertion of Size bytes.
  Value = extractBitsForFixup(Kind, Value);
  unsigned ShiftValue = (Size * 8) - 8;
  for (unsigned I = 0; I != Size; ++I) {
    Data[Offset + I] |= uint8_t(Value >> ShiftValue);
    ShiftValue -= 8;
  }
}

bool RISCVMCAsmBackend::mayNeedRelaxation(const MCInst &Inst) const {
  return getRelaxedOpcode(Inst.getOpcode()) != 0;
}

bool
RISCVMCAsmBackend::fixupNeedsRelaxation(const MCFixup &Fixup,
                                          uint64_t Value,
                                          const MCRelaxableFragment *Fragment,
                                          const MCAsmLayout &Layout) const {
  // At the moment we just need to relax 16-bit fields to wider fields.
  Value = extractBitsForFixup(Fixup.getKind(), Value);
  return (int16_t)Value != (int64_t)Value;
}

void RISCVMCAsmBackend::relaxInstruction(const MCInst &Inst,
                                           MCInst &Res) const {
  unsigned Opcode = getRelaxedOpcode(Inst.getOpcode());
  assert(Opcode && "Unexpected insn to relax");
  Res = Inst;
  Res.setOpcode(Opcode);
}

bool RISCVMCAsmBackend::writeNopData(uint64_t Count,
                                       MCObjectWriter *OW) const {
  for (uint64_t I = 0; I != Count; ++I)
    OW->write8(7);
  return true;
}

MCAsmBackend *llvm::createRISCVMCAsmBackend(const Target &T,
                                            const MCRegisterInfo &MRI,
                                            const Triple &TT, StringRef CPU) {
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TT.getOS());
  return new RISCVMCAsmBackend(OSABI);
}
