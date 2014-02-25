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

void RISCVAsmPrinter::printOperand(const MachineInstr *MI, int OpNo, raw_ostream &O) {
  const MachineOperand &MO = MI->getOperand(OpNo); 
  //look at target flags to see if we should wrap this operand
  switch(MO.getTargetFlags()){
    case RISCVII::MO_ABS_HI: O << "%hi("; break;
    case RISCVII::MO_ABS_LO: O << "%lo("; break;
    case RISCVII::MO_TPREL_HI: O << "%tprel_hi("; break;
    case RISCVII::MO_TPREL_LO: O << "%tprel_lo("; break;
  }
 switch (MO.getType()) {
    case MachineOperand::MO_Register:
    case MachineOperand::MO_Immediate: {
      RISCVMCInstLower Lower(Mang, MF->getContext(), *this);
      MCOperand MC(Lower.lowerOperand(MI->getOperand(OpNo)));
      RISCVInstPrinter::printOperand(MC, O);
      break;
      }
    case MachineOperand::MO_GlobalAddress:
      O << Mang->getSymbol(MO.getGlobal());
      break;
    default:
      llvm_unreachable("<unknown operand type>");
  }

  if(MO.getTargetFlags()) {
    O << ")";
  }
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
    printOperand(MI, OpNo, OS);
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
                                   OS);
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
