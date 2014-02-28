//===-- RISCVConstantPoolValue.cpp - RISCV constant-pool value --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVConstantPoolValue.h"
#include "llvm/ADT/FoldingSet.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

RISCVConstantPoolValue::
RISCVConstantPoolValue(const GlobalValue *gv,
                         RISCVCP::RISCVCPModifier modifier)
  : MachineConstantPoolValue(gv->getType()), GV(gv), Modifier(modifier) {}

RISCVConstantPoolValue *
RISCVConstantPoolValue::Create(const GlobalValue *GV,
                                 RISCVCP::RISCVCPModifier Modifier) {
  return new RISCVConstantPoolValue(GV, Modifier);
}

unsigned RISCVConstantPoolValue::getRelocationInfo() const {
  switch (Modifier) {
  case RISCVCP::NTPOFF:
    // May require a relocation, but the relocations are always resolved
    // by the static linker.
    return 1;
  }
  llvm_unreachable("Unknown modifier");
}

int RISCVConstantPoolValue::
getExistingMachineCPValue(MachineConstantPool *CP, unsigned Alignment) {
  unsigned AlignMask = Alignment - 1;
  const std::vector<MachineConstantPoolEntry> Constants = CP->getConstants();
  for (unsigned I = 0, E = Constants.size(); I != E; ++I) {
    if (Constants[I].isMachineConstantPoolEntry() &&
        (Constants[I].getAlignment() & AlignMask) == 0) {
      RISCVConstantPoolValue *RCPV =
        static_cast<RISCVConstantPoolValue *>(Constants[I].Val.MachineCPVal);
      if (RCPV->GV == GV && RCPV->Modifier == Modifier)
        return I;
    }
  }
  return -1;
}

void RISCVConstantPoolValue::addSelectionDAGCSEId(FoldingSetNodeID &ID) {
  ID.AddPointer(GV);
  ID.AddInteger(Modifier);
}

void RISCVConstantPoolValue::print(raw_ostream &O) const {
  O << GV ;//<< "@" << int(Modifier);
}
