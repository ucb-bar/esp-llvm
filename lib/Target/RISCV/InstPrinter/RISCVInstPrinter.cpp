//===-- RISCVInstPrinter.cpp - Convert RISCV MCInst to assembly syntax ----===//
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

void RISCVInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                   StringRef Annot, const MCSubtargetInfo &STI) {
  printInstruction(MI, O);
  printAnnotation(O, Annot);
}

void RISCVInstPrinter::printRegName(raw_ostream &O, unsigned RegNo) const {
  O << getRegisterName(RegNo);
}

void RISCVInstPrinter::printMemOperand(const MCInst *MI, int opNum, 
                                         raw_ostream &OS) {
     printOperand(MI, opNum, OS);
     OS << "(";
     OS << getRegisterName(MI->getOperand(opNum+1).getReg());
     OS << ")";
}

void RISCVInstPrinter::printJALRMemOperand(const MCInst *MI, int opNum, 
                                         raw_ostream &OS) {
     OS << getRegisterName(MI->getOperand(opNum+1).getReg());
     OS << ", ";
     printOperand(MI, opNum, OS);
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
  const MCOperand &MC = MI->getOperand(OpNum);
  if (MC.isReg())
    O << getRegisterName(MC.getReg());
  else if (MC.isImm())
    O << MC.getImm();
  else if (MC.isExpr())
    MC.getExpr()->print(O, &MAI, true);
  else
    llvm_unreachable("Invalid operand");
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
