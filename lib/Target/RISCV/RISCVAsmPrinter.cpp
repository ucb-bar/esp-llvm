//===-- RISCVAsmPrinter.cpp - RISCV LLVM assembly printer -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Streams RISCV assembly language and associated data, in the form of
// MCInsts and MCExprs respectively.
//
//===----------------------------------------------------------------------===//

#include "RISCVAsmPrinter.h"
#include "InstPrinter/RISCVInstPrinter.h"
#include "RISCVConstantPoolValue.h"
#include "RISCVMCInstLower.h"
#include "llvm/CodeGen/MachineModuleInfoImpls.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/Mangler.h"

using namespace llvm;

void RISCVAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  RISCVMCInstLower Lower(Mang, MF->getContext(), *this);
  MCInst LoweredMI;
  Lower.lower(MI, LoweredMI);
  OutStreamer.EmitInstruction(LoweredMI);
}

// Convert a RISCV-specific constant pool modifier into the associated
// MCSymbolRefExpr variant kind.
static MCSymbolRefExpr::VariantKind
getModifierVariantKind(RISCVCP::RISCVCPModifier Modifier) {
  switch (Modifier) {
  case RISCVCP::NTPOFF: return MCSymbolRefExpr::VK_NTPOFF;
  }
  llvm_unreachable("Invalid SystemCPModifier!");
}

void RISCVAsmPrinter::
EmitMachineConstantPoolValue(MachineConstantPoolValue *MCPV) {
  RISCVConstantPoolValue *ZCPV =
    static_cast<RISCVConstantPoolValue*>(MCPV);

  const MCExpr *Expr =
    MCSymbolRefExpr::Create(Mang->getSymbol(ZCPV->getGlobalValue()),
                            getModifierVariantKind(ZCPV->getModifier()),
                            OutContext);
  uint64_t Size = TM.getDataLayout()->getTypeAllocSize(ZCPV->getType());

  OutStreamer.EmitValue(Expr, Size);
}

bool RISCVAsmPrinter::PrintAsmOperand(const MachineInstr *MI,
                                        unsigned OpNo,
                                        unsigned AsmVariant,
                                        const char *ExtraCode,
                                        raw_ostream &OS) {
  if (ExtraCode && *ExtraCode == 'n') {
    if (!MI->getOperand(OpNo).isImm())
      return true;
    OS << -int64_t(MI->getOperand(OpNo).getImm());
  } else {
    RISCVMCInstLower Lower(Mang, MF->getContext(), *this);
    MCOperand MO(Lower.lowerOperand(MI->getOperand(OpNo)));
    RISCVInstPrinter::printOperand(MO, OS);
  }
  return false;
}

bool RISCVAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI,
                                              unsigned OpNo,
                                              unsigned AsmVariant,
                                              const char *ExtraCode,
                                              raw_ostream &OS) {
  RISCVInstPrinter::printAddress(MI->getOperand(OpNo).getReg(),
                                   MI->getOperand(OpNo + 1).getImm(),
                                   MI->getOperand(OpNo + 2).getReg(), OS);
  return false;
}

//RISCV
void RISCVAsmPrinter::printMemOperand(const MachineInstr *MI, int opNum,
                                      raw_ostream &OS) {
    OS << '%' << RISCVInstPrinter::getRegisterName(MI->getOperand(opNum).getReg());
    OS << "(";
    OS << MI->getOperand(opNum+1).getImm();
    OS << ")";
}
//End RISCV

void RISCVAsmPrinter::EmitEndOfAsmFile(Module &M) {
  if (Subtarget->isTargetELF()) {
    const TargetLoweringObjectFileELF &TLOFELF =
      static_cast<const TargetLoweringObjectFileELF &>(getObjFileLowering());

    MachineModuleInfoELF &MMIELF = MMI->getObjFileInfo<MachineModuleInfoELF>();

    // Output stubs for external and common global variables.
    MachineModuleInfoELF::SymbolListTy Stubs = MMIELF.GetGVStubList();
    if (!Stubs.empty()) {
      OutStreamer.SwitchSection(TLOFELF.getDataRelSection());
      const DataLayout *TD = TM.getDataLayout();

      for (unsigned i = 0, e = Stubs.size(); i != e; ++i) {
        OutStreamer.EmitLabel(Stubs[i].first);
        OutStreamer.EmitSymbolValue(Stubs[i].second.getPointer(),
                                    TD->getPointerSize(0), 0);
      }
      Stubs.clear();
    }
  }
}

// Force static initialization.
extern "C" void LLVMInitializeRISCVAsmPrinter() {
  RegisterAsmPrinter<RISCVAsmPrinter> X(TheRISCVTarget);
}
