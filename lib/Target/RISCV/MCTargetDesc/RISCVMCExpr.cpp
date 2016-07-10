//===-- RISCVMCExpr.cpp - RISCV specific MC expression classes --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the implementation of the assembly expression modifiers
// accepted by the RISCV architecture (e.g. "%hi", "%lo", ...).
//
//===----------------------------------------------------------------------===//

#include "RISCVMCExpr.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Object/ELF.h"


using namespace llvm;

const RISCVMCExpr*
RISCVMCExpr::create(RISCVMCExpr::VariantKind Kind, const MCExpr *Expr,
                      MCContext &Ctx) {
    return new (Ctx) RISCVMCExpr(Kind, Expr);
}

void RISCVMCExpr::printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const {

  bool closeParen = printVariantKind(OS, Kind);

  const MCExpr *Expr = getSubExpr();
  Expr->print(OS, MAI);

  if (closeParen)
    OS << ')';
}

bool RISCVMCExpr::printVariantKind(raw_ostream &OS, VariantKind Kind)
{
  bool closeParen = true;
  switch (Kind) {
  case VK_RISCV_None:     closeParen = false; break;
  case VK_RISCV_LO12:       OS << "%lo(";  break;
  case VK_RISCV_HI20:       OS << "%hi(";  break;
  case VK_RISCV_PCREL_LO12: OS << "%pcrel_lo(";  break;
  case VK_RISCV_PCREL_HI20: OS << "%pcrel_hi(";  break;
  case VK_RISCV_TPREL_LO12: OS << "%tprel_lo(";  break;
  case VK_RISCV_TPREL_HI20: OS << "%tprel_hi(";  break;
  }
  return closeParen;
}

RISCVMCExpr::VariantKind RISCVMCExpr::parseVariantKind(StringRef name)
{
  return StringSwitch<RISCVMCExpr::VariantKind>(name)
    .Case("lo",  VK_RISCV_LO12)
    .Case("hi",  VK_RISCV_HI20)
    .Case("pcrel_lo",  VK_RISCV_PCREL_LO12)
    .Case("pcrel_hi",  VK_RISCV_PCREL_HI20)
    .Case("tprel_lo",  VK_RISCV_TPREL_LO12)
    .Case("tprel_hi",  VK_RISCV_TPREL_HI20)
    .Default(VK_RISCV_None);
}

RISCV::FixupKind RISCVMCExpr::getFixupKind(RISCVMCExpr::VariantKind Kind) {
  switch (Kind) {
  default: llvm_unreachable("Unhandled RISCVMCExpr::VariantKind");
  case VK_RISCV_LO12:       return RISCV::fixup_riscv_lo12;
  case VK_RISCV_HI20:       return RISCV::fixup_riscv_hi20;
  case VK_RISCV_PCREL_LO12: return RISCV::fixup_riscv_pcrel_lo12;
  case VK_RISCV_PCREL_HI20: return RISCV::fixup_riscv_pcrel_hi20;
  case VK_RISCV_TPREL_LO12: return RISCV::fixup_riscv_tprel_lo12;
  case VK_RISCV_TPREL_HI20: return RISCV::fixup_riscv_tprel_hi20;
  }
}

bool
RISCVMCExpr::evaluateAsRelocatableImpl(MCValue &Res,
                                       const MCAsmLayout *Layout,
                                       const MCFixup *Fixup) const {
  return getSubExpr()->evaluateAsRelocatable(Res, Layout, Fixup);
}

static void fixELFSymbolsInTLSFixupsImpl(const MCExpr *Expr, MCAssembler &Asm) {
  switch (Expr->getKind()) {
  case MCExpr::Target:
    llvm_unreachable("Can't handle nested target expr!");
    break;

  case MCExpr::Constant:
    break;

  case MCExpr::Binary: {
    const MCBinaryExpr *BE = cast<MCBinaryExpr>(Expr);
    fixELFSymbolsInTLSFixupsImpl(BE->getLHS(), Asm);
    fixELFSymbolsInTLSFixupsImpl(BE->getRHS(), Asm);
    break;
  }

  case MCExpr::SymbolRef: {
    const MCSymbolRefExpr &SymRef = *cast<MCSymbolRefExpr>(Expr);
    cast<MCSymbolELF>(SymRef.getSymbol()).setType(ELF::STT_TLS);
    break;
  }

  case MCExpr::Unary:
    fixELFSymbolsInTLSFixupsImpl(cast<MCUnaryExpr>(Expr)->getSubExpr(), Asm);
    break;
  }

}

void RISCVMCExpr::fixELFSymbolsInTLSFixups(MCAssembler &Asm) const {
  switch(getKind()) {
  default: return;
  case VK_RISCV_TPREL_HI20:
  case VK_RISCV_TPREL_LO12: break;
  }
  fixELFSymbolsInTLSFixupsImpl(getSubExpr(), Asm);
}

void RISCVMCExpr::visitUsedExpr(MCStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}
