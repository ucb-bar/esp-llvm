//===- MachineScalarization.h - Scalarization analysis ----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Determines which MBB are convergent across elements and which MI are
// element-invariant
// Based on [Lee, CGO, 2013]
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_MACHINESCALARIZATION_H
#define LLVM_CODEGEN_MACHINESCALARIZATION_H

#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineProgramDependenceGraph.h"
#include <map>
#include <utility>

namespace llvm {

class MachineScalarization;
MachineFunctionPass *createMachineScalarizationPass();

//===----------------------------------------------------------------------===//
/// @brief Analysis that detects convergence and scalars
///
class MachineScalarization : public MachineFunctionPass {
public:
  //convergent basicblocks
  std::map<const MachineBasicBlock*, bool> conv;
  //invariant instructions
  std::map<const MachineInstr*, bool> invar;

private:
  MachineScalarization(const MachineScalarization &) = delete;
  const MachineScalarization &operator=(const MachineScalarization &) = delete;

  MachineProgramDependenceGraph *PDG;

  // Helper function to find iterated control dependencies
  void markAllCDChildren(const MachineBasicBlock* mbb, SmallVector<const MachineInstr*,128> worklist);

  // Calculate - detecte all regions in function and build the region tree.
  void Calculate(MachineFunction& F);
public:
  static char ID;

  MachineScalarization() : MachineFunctionPass(ID) {
    initializeMachineScalarizationPass(*PassRegistry::getPassRegistry());
  }

  MachineFunction *MF;

  bool runOnMachineFunction(MachineFunction &F) override;

  void releaseMemory() override;

  void getAnalysisUsage(AnalysisUsage &AU) const override;


  ~MachineScalarization();
};
}
#endif
