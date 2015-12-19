//===-- RISCVMCObjectWriter.cpp - RISCV ELF writer --------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/RISCVMCTargetDesc.h"
#include "MCTargetDesc/RISCVMCFixups.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCValue.h"

using namespace llvm;

namespace {
class RISCVObjectWriter : public MCELFObjectTargetWriter {
public:
  RISCVObjectWriter(uint8_t OSABI);

  virtual ~RISCVObjectWriter();

protected:
  // Override MCELFObjectTargetWriter.
  unsigned GetRelocType(const MCValue &Target, const MCFixup &Fixup,
                        bool IsPCRel) const override;
};
} // end anonymouse namespace

RISCVObjectWriter::RISCVObjectWriter(uint8_t OSABI)
  : MCELFObjectTargetWriter(/*Is64Bit=*/true, OSABI, ELF::EM_RISCV,
                            /*HasRelocationAddend=*/ true) {}

RISCVObjectWriter::~RISCVObjectWriter() {
}

// Return the relocation type for an absolute value of MCFixupKind Kind.
static unsigned getAbsoluteReloc(unsigned Kind) {
  switch (Kind) {
  case FK_Data_4: return ELF::R_RISCV_32;
  case FK_Data_8: return ELF::R_RISCV_64;
  }
  llvm_unreachable("Unsupported absolute address");
}

//TODO: fix relocation types
// Return the relocation type for a PC-relative value of MCFixupKind Kind.
static unsigned getPCRelReloc(unsigned Kind) {
  switch (Kind) {
  case FK_Data_4:                return ELF::R_RISCV_CALL;
  case RISCV::fixup_riscv_brlo:  return ELF::R_RISCV_BRANCH;
  case RISCV::fixup_riscv_brhi:  return ELF::R_RISCV_BRANCH;
  case RISCV::fixup_riscv_jal:   return ELF::R_RISCV_JAL;
  case RISCV::fixup_riscv_call:  return ELF::R_RISCV_CALL;
  }
  llvm_unreachable("Unsupported PC-relative address");
}

// Return the R_RISCV_TLS* relocation type for MCFixupKind Kind.
static unsigned getTLSLEReloc(unsigned Kind) {
  switch (Kind) {
  case FK_Data_4: return ELF::R_RISCV_TLS_TPREL32;
  case FK_Data_8: return ELF::R_RISCV_TLS_TPREL64;
  }
  llvm_unreachable("Unsupported absolute address");
}

// Return the PLT relocation counterpart of MCFixupKind Kind.
static unsigned getPLTReloc(unsigned Kind) {
  switch (Kind) {
  case RISCV::fixup_riscv_call_plt: return ELF::R_RISCV_CALL_PLT;
  }
  llvm_unreachable("Unsupported absolute address");
}

unsigned RISCVObjectWriter::GetRelocType(const MCValue &Target,
                                         const MCFixup &Fixup,
                                         bool IsPCRel) const {
  MCSymbolRefExpr::VariantKind Modifier = (Target.isAbsolute() ?
                                           MCSymbolRefExpr::VK_None :
                                           Target.getSymA()->getKind());
  unsigned Kind = Fixup.getKind();
  switch (Modifier) {
  case MCSymbolRefExpr::VK_None:
    if (IsPCRel)
      return getPCRelReloc(Kind);
    return getAbsoluteReloc(Kind);

  case MCSymbolRefExpr::VK_NTPOFF:
    assert(!IsPCRel && "NTPOFF shouldn't be PC-relative");
    return getTLSLEReloc(Kind);

  case MCSymbolRefExpr::VK_GOT:
    llvm_unreachable("GOT accesses are not supported yet");

  case MCSymbolRefExpr::VK_PLT:
    assert(IsPCRel && "@PLT shouldt be PC-relative");
    return getPLTReloc(Kind);

  default:
    llvm_unreachable("Modifier not supported");
  }
}

MCObjectWriter *llvm::createRISCVObjectWriter(raw_pwrite_stream &OS,
                                                uint8_t OSABI) {
  MCELFObjectTargetWriter *MOTW = new RISCVObjectWriter(OSABI);
  return createELFObjectWriter(MOTW, OS, /*IsLittleEndian=*/false);
}
