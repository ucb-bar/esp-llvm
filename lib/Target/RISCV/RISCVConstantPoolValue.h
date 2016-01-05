//===- RISCVConstantPoolValue.h - RISCV constant-pool value -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVCONSTANTPOOLVALUE_H
#define LLVM_LIB_TARGET_RISCV_RISCVCONSTANTPOOLVALUE_H

#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/Support/ErrorHandling.h"

namespace llvm {

class GlobalValue;

namespace RISCVCP {
  enum RISCVCPModifier {
    NTPOFF
  };
}

/// A RISCV-specific constant pool value.  At present, the only
/// defined constant pool values are offsets of thread-local variables
/// (written x@NTPOFF).
class RISCVConstantPoolValue : public MachineConstantPoolValue {
  const GlobalValue *GV;
  RISCVCP::RISCVCPModifier Modifier;

protected:
  RISCVConstantPoolValue(const GlobalValue *GV,
                           RISCVCP::RISCVCPModifier Modifier);

public:
  static RISCVConstantPoolValue *
    Create(const GlobalValue *GV, RISCVCP::RISCVCPModifier Modifier);

  // Override MachineConstantPoolValue.
  int getExistingMachineCPValue(MachineConstantPool *CP,
                                unsigned Alignment) override;
  void addSelectionDAGCSEId(FoldingSetNodeID &ID) override;
  void print(raw_ostream &O) const override;

  // Access RISCV-specific fields.
  const GlobalValue *getGlobalValue() const { return GV; }
  RISCVCP::RISCVCPModifier getModifier() const { return Modifier; }
};

} // End llvm namespace

#endif
