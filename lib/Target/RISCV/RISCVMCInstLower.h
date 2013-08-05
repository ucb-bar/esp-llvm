//===-- RISCVMCInstLower.h - Lower MachineInstr to MCInst ----*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_RISCVMCINSTLOWER_H
#define LLVM_RISCVMCINSTLOWER_H

#include "llvm/Support/DataTypes.h"
#include "llvm/Support/Compiler.h"

namespace llvm {
class MCContext;
class MCInst;
class MCOperand;
class MCSymbol;
class MachineInstr;
class MachineOperand;
class Mangler;
class RISCVAsmPrinter;

class LLVM_LIBRARY_VISIBILITY RISCVMCInstLower {
  Mangler *Mang;
  MCContext &Ctx;
  RISCVAsmPrinter &AsmPrinter;

public:
  RISCVMCInstLower(Mangler *mang, MCContext &ctx,
                     RISCVAsmPrinter &asmPrinter);

  // Lower MachineInstr MI to MCInst OutMI.
  void lower(const MachineInstr *MI, MCInst &OutMI) const;

  // Return an MCOperand for MO.  Return an empty operand if MO is implicit.
  MCOperand lowerOperand(const MachineOperand& MO) const;

  // Return an MCOperand for MO, given that it equals Symbol + Offset.
  MCOperand lowerSymbolOperand(const MachineOperand &MO,
                               const MCSymbol *Symbol, int64_t Offset) const;
};
} // end namespace llvm

#endif
