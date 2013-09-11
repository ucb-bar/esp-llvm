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
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#include "RISCVGenAsmWriter.inc"

void RISCVInstPrinter::printAddress(unsigned Base, int64_t Disp,
                                      unsigned Index, raw_ostream &O) {
  O << Disp;
  if (Base) {
    O << '(';
    if (Index)
      O << '%' << getRegisterName(Index) << ',';
    O << '%' << getRegisterName(Base) << ')';
  } else
    assert(!Index && "Shouldn't have an index without a base");
}

void RISCVInstPrinter::printOperand(const MCOperand &MO, raw_ostream &O) {
  if (MO.isReg())
    O << '%' << getRegisterName(MO.getReg());
  else if (MO.isImm())
    O << MO.getImm();
  else if (MO.isExpr())
    O << *MO.getExpr();
  else
    llvm_unreachable("Invalid operand");
}

void RISCVInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                   StringRef Annot) {
  printInstruction(MI, O);
  printAnnotation(O, Annot);
}

void RISCVInstPrinter::printRegName(raw_ostream &O, unsigned RegNo) const {
  O << '%' << getRegisterName(RegNo);
}

void RISCVInstPrinter::printMemOperand(const MCInst *MI, int opNum, 
                                         raw_ostream &OS) {
     OS << '%' << getRegisterName(MI->getOperand(opNum).getReg());
     OS << "(";
     printOperand(MI, opNum+1, OS);
     OS << ")";
}

void RISCVInstPrinter::printS12ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isInt<12>(Value) && "Invalid s12imm argument");
  O << Value;
}

void RISCVInstPrinter::printU12ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isUInt<12>(Value) && "Invalid u12imm argument");
  O << Value;
}

void RISCVInstPrinter::printS20ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isInt<20>(Value) && "Invalid s20imm argument");
  O << Value;
}

void RISCVInstPrinter::printU20ImmOperand(const MCInst *MI, int OpNum,
                                           raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isUInt<20>(Value) && "Invalid u20imm argument");
  O << Value;
}

void RISCVInstPrinter::printS32ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isInt<32>(Value) && "Invalid s32imm argument");
  O << Value;
}

void RISCVInstPrinter::printU32ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isUInt<32>(Value) && "Invalid u32imm argument");
  O << Value;
}

void RISCVInstPrinter::printS64ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isInt<64>(Value) && "Invalid s64imm argument");
  O << Value;
}

void RISCVInstPrinter::printU64ImmOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  int64_t Value = MI->getOperand(OpNum).getImm();
  assert(isUInt<64>(Value) && "Invalid u64imm argument");
  O << Value;
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
  O << "@PLT";
}

void RISCVInstPrinter::printOperand(const MCInst *MI, int OpNum,
                                      raw_ostream &O) {
  printOperand(MI->getOperand(OpNum), O);
}

void RISCVInstPrinter::printBDAddrOperand(const MCInst *MI, int OpNum,
                                            raw_ostream &O) {
  printAddress(MI->getOperand(OpNum).getReg(),
               MI->getOperand(OpNum + 1).getImm(), 0, O);
}

void RISCVInstPrinter::printBDXAddrOperand(const MCInst *MI, int OpNum,
                                             raw_ostream &O) {
  printAddress(MI->getOperand(OpNum).getReg(),
               MI->getOperand(OpNum + 1).getImm(),
               MI->getOperand(OpNum + 2).getReg(), O);
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
