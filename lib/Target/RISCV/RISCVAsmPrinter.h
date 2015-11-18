//===-- RISCVAsmPrinter.h - RISCV LLVM assembly printer --------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVASMPRINTER_H
#define LLVM_LIB_TARGET_RISCV_RISCVASMPRINTER_H

#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/Support/Compiler.h"

namespace llvm {
class MCStreamer;
class MachineBasicBlock;
class MachineInstr;
class Module;
class raw_ostream;

class LLVM_LIBRARY_VISIBILITY RISCVAsmPrinter : public AsmPrinter {
private:
  const RISCVSubtarget *Subtarget;

public:
  RISCVAsmPrinter(TargetMachine &TM, std::unique_ptr<MCStreamer> Streamer)
    : AsmPrinter(TM, std::move(Streamer)) {}

  // Override AsmPrinter.
  const char *getPassName() const override {
    return "RISCV Assembly Printer";
  }
  void EmitInstruction(const MachineInstr *MI) override;
  void EmitMachineConstantPoolValue(MachineConstantPoolValue *MCPV) override;
  void printOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       unsigned AsmVariant, const char *ExtraCode,
                       raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             unsigned AsmVariant, const char *ExtraCode,
                             raw_ostream &OS) override;
  void printMemOperand(const MachineInstr *MI, int opNum, raw_ostream &OS);
  void EmitEndOfAsmFile(Module &M) override;
  bool runOnMachineFunction(MachineFunction &MF) override;
};
} // end namespace llvm

#endif
