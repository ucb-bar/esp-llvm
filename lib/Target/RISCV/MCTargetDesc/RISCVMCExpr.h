//====- RISCVMCExpr.h - RISCV specific MC expression classes --*- C++ -*-=====//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes RISCV-specific MCExprs, used for modifiers like
// "%hi" or "%lo" etc.,
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_MCTARGETDESC_RISCVMCEXPR_H
#define LLVM_LIB_TARGET_RISCV_MCTARGETDESC_RISCVMCEXPR_H

#include "RISCVMCFixups.h"
#include "llvm/MC/MCExpr.h"

namespace llvm {

class StringRef;
class RISCVMCExpr : public MCTargetExpr {
public:
  enum VariantKind {
    VK_RISCV_None,
    VK_RISCV_LO12,
    VK_RISCV_HI20,
    VK_RISCV_PCREL_LO12,
    VK_RISCV_PCREL_HI20,
    VK_RISCV_TPREL_LO12,
    VK_RISCV_TPREL_HI20
  };

private:
  const VariantKind Kind;
  const MCExpr *Expr;

  explicit RISCVMCExpr(VariantKind Kind, const MCExpr *Expr)
      : Kind(Kind), Expr(Expr) {}

public:
  /// @name Construction
  /// @{

  static const RISCVMCExpr *create(RISCVMCExpr::VariantKind Kind, const MCExpr *Expr,
                                 MCContext &Ctx);
  /// @}
  /// @name Accessors
  /// @{

  /// getOpcode - Get the kind of this expression.
  VariantKind getKind() const { return Kind; }

  /// getSubExpr - Get the child of this expression.
  const MCExpr *getSubExpr() const { return Expr; }

  /// getFixupKind - Get the fixup kind of this expression.
  RISCV::FixupKind getFixupKind() const { return getFixupKind(Kind); }

  /// @}
  void printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const override;
  bool evaluateAsRelocatableImpl(MCValue &Res,
                                 const MCAsmLayout *Layout,
                                 const MCFixup *Fixup) const override;
  void visitUsedExpr(MCStreamer &Streamer) const override;
  MCFragment *findAssociatedFragment() const override {
    return getSubExpr()->findAssociatedFragment();
  }

  void fixELFSymbolsInTLSFixups(MCAssembler &Asm) const override;

  static bool classof(const MCExpr *E) {
    return E->getKind() == MCExpr::Target;
  }

  static bool classof(const RISCVMCExpr *) { return true; }

  static VariantKind parseVariantKind(StringRef name);
  static bool printVariantKind(raw_ostream &OS, VariantKind Kind);
  static RISCV::FixupKind getFixupKind(VariantKind Kind);
};

} // end namespace llvm.

#endif
