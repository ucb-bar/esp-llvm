//===- Scalarization.h - Scalarization analysis ----------------------*- C++ -*-===//
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

#ifndef LLVM_CODEGEN_SCALARIZATION_H
#define LLVM_CODEGEN_SCALARIZATION_H

#include "llvm/Analysis/ProgramDependenceGraph.h"
#include <map>
#include <utility>

namespace llvm {

class Scalarization;
FunctionPass *createScalarizationPass();

//===----------------------------------------------------------------------===//
/// @brief Analysis that detects convergence and scalars
///
class Scalarization : public FunctionPass {
public:
  //convergent basicblocks
  std::map<const BasicBlock*, bool> conv;
  //invariant instructions
  std::map<const Instruction*, bool> invar;

private:
  Scalarization(const Scalarization &) = delete;
  const Scalarization &operator=(const Scalarization &) = delete;

  ProgramDependenceGraph *PDG;

  // Helper function to find iterated control dependencies
  void markAllCDChildren(const BasicBlock* mbb, SmallVector<const Instruction*,128> worklist);

  // Calculate - detecte all regions in function and build the region tree.
  void Calculate(Function& F);
public:
  static char ID;

  Scalarization() : FunctionPass(ID) {
    initializeScalarizationPass(*PassRegistry::getPassRegistry());
  }

  Function *MF;

  bool runOnFunction(Function &F) override;

  void releaseMemory() override;

  void getAnalysisUsage(AnalysisUsage &AU) const override;


  ~Scalarization();
};
}
#endif
