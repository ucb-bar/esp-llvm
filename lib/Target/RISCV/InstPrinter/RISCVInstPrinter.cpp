//===-- RISCVInstPrinter.cpp - Convert RISCV MCInst to assembly syntax ===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "asm-printer"

#include "RISCVInstPrinter.h"
#include "RISCVInstrInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#include "RISCVGenAsmWriter.inc"

void RISCVInstPrinter::printAddress(unsigned Base, int64_t Disp,
                                      raw_ostream &O) {
  O << Disp;
  if (Base) {
    O << '(';
    O << getRegisterName(Base) << ')';
  }
}

static void printExpr(const MCExpr *Expr, raw_ostream &OS) {
  int Offset = 0;
  const MCSymbolRefExpr *SRE;
  
  if (const MCBinaryExpr *BE = dyn_cast<MCBinaryExpr>(Expr)) {
    SRE = dyn_cast<MCSymbolRefExpr>(BE->getLHS());
    const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(BE->getRHS());
    assert(SRE && CE && "Binary expression must be sym+const.");
    Offset = CE->getValue();
  }
  else if (!(SRE = dyn_cast<MCSymbolRefExpr>(Expr)))
    assert(false && "Unexpected MCExpr type.");
 
  MCSymbolRefExpr::VariantKind Kind = SRE->getKind();
    
  switch (Kind) {
  default:                                 llvm_unreachable("Invalid kind!");
  case MCSymbolRefExpr::VK_None:           break;
  case MCSymbolRefExpr::VK_Mips_ABS_HI:    OS << "%hi(";     break;
  case MCSymbolRefExpr::VK_Mips_ABS_LO:    OS << "%lo(";     break;
  case MCSymbolRefExpr::VK_Mips_TPREL_HI:    OS << "%tprel_hi(";     break;
  case MCSymbolRefExpr::VK_Mips_TPREL_LO:    OS << "%tprel_lo(";     break;
  }

  OS << SRE->getSymbol();
      
  if (Offset) {
    if (Offset > 0)
      OS << '+';
    OS << Offset; 
  }                   
                          
  if (Kind != MCSymbolRefExpr::VK_None)
    OS << ')';
}

void RISCVInstPrinter::printOperand(const MCOperand &MC, raw_ostream &O) {
  if (MC.isReg())
    O << getRegisterName(MC.getReg());
  else if (MC.isImm())
    O << MC.getImm();
  else if (MC.isExpr())
    printExpr(MC.getExpr(), O);
  else
    llvm_unreachable("Invalid operand");
}

void RISCVInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                   StringRef Annot) {
  printInstruction(MI, O);
  printAnnotation(O, Annot);
}

void RISCVInstPrinter::printRegName(raw_ostream &O, unsigned RegNo) const {
  O << getRegisterName(RegNo);
}

void RISCVInstPrinter::printMemOperand(const MCInst *MI, int opNum, 
                                         raw_ostream &OS) {
     printOperand(MI, opNum+1, OS);
     OS << "(";
     OS << getRegisterName(MI->getOperand(opNum).getReg());
     OS << ")";
}

void RISCVInstPrinter::printJALRMemOperand(const MCInst *MI, int opNum, 
                                         raw_ostream &OS) {
     OS << getRegisterName(MI->getOperand(opNum).getReg());
     OS << ",";
     printOperand(MI, opNum+1, OS);
}

void RISCVInstPrinter::printBranchTarget(const MCInst *MI, int opNum, 
                                         raw_ostream &OS) {
    if(MI->getOperand(opNum).isImm()){
      OS << ".+";//constant branch
    }
    printOperand(MI, opNum, OS);
}

void RISCVInstPrinter::printMemRegOperand(const MCInst *MI, int opNum, 
                                         raw_ostream &OS) {
     OS << "0"; //No offset for this ever
     OS << "(";
     OS << getRegisterName(MI->getOperand(opNum).getReg());
     OS << ")";
}

void RISCVInstPrinter::printS12ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isInt<12>(Value) && "Invalid s12imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printU12ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isUInt<12>(Value) && "Invalid u12imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printS20ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isInt<20>(Value) && "Invalid s20imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printU20ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isUInt<20>(Value) && "Invalid u20imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printS32ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isInt<32>(Value) && "Invalid s32imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printU32ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isUInt<32>(Value) && "Invalid u32imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printS64ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isInt<64>(Value) && "Invalid s64imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printU64ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  if(MI->getOperand(OpNum).isImm()){
    int64_t Value = MI->getOperand(OpNum).getImm();
    assert(isUInt<64>(Value) && "Invalid u64imm argument");
    O << Value;
  }else
    printOperand(MI, OpNum, O);
}

void RISCVInstPrinter::printAccessRegOperand(const MCInst *MI, int OpNum,
                                               raw_ostream &O) {
  uint64_t Value = MI->getOperand(OpNum).getImm();
  assert(Value < 16 && "Invalid access register number");
  O << "%a" << (unsigned int)Value;
}

void RISCVInstPrinter::printCallOperand(const MCInst *MI, int OpNum,
                                          raw_ostream &O) {
  printOperand(MI, OpNum, O);
  //O << "@PLT";
}

void RISCVInstPrinter::printOperand(const MCInst *MI, int OpNum,
                                      raw_ostream &O) {
  printOperand(MI->getOperand(OpNum), O);
}

void RISCVInstPrinter::printBDAddrOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  printAddress(MI->getOperand(OpNum).getReg(),
               MI->getOperand(OpNum + 1).getImm(), O);
}

void RISCVInstPrinter::printBDXAddrOperand(const MCInst *MI, int OpNum,
                                             raw_ostream &O) {
  printAddress(MI->getOperand(OpNum).getReg(),
               MI->getOperand(OpNum + 1).getImm(),
               O);
}

void RISCVInstPrinter::printCond4Operand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  static const char *const CondNames[] = {
    "o", "h", "nle", "l", "nhe", "lh", "ne",
    "e", "nlh", "he", "nl", "le", "nh", "no"
  };
  uint64_t Imm = MI->getOperand(OpNum).getImm();
  assert(Imm > 0 && Imm < 15 && "Invalid condition");
  O << CondNames[Imm - 1];
}
