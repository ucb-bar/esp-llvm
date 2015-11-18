//===- Scalarization.cpp - Scalarization analysis --------------------===//
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

#include "llvm/Analysis/Scalarization.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/Debug.h"

#include <set>
#include <algorithm>

using namespace llvm;

char Scalarization::ID = 0;
INITIALIZE_PASS_BEGIN(Scalarization, "scalar",
                " Scalarization Analysis", true, true)
INITIALIZE_PASS_DEPENDENCY(ProgramDependenceGraph)
INITIALIZE_PASS_END(Scalarization, "scalar",
                " Scalarization Analysis", true, true)

void Scalarization::releaseMemory() {
  invar.clear();
  conv.clear();
}

Scalarization::~Scalarization() {
  releaseMemory();
}

void Scalarization::markAllCDChildren(const BasicBlock* mbb, SmallVector<const Instruction*,128> worklist) {
  PDGChildIterator child_itr = PDGChildIterator(PDG->BBtoCDS.find(mbb)->second);
  PDGChildIterator child_end = PDGChildIterator(PDG->BBtoCDS.find(mbb)->second,true);
  for(;child_itr != child_end; child_itr++) {
    //TODO: check for opencl barrier call in thie mbb
    if(conv[(*child_itr)->bb]) {
      conv[(*child_itr)->bb] = false;
      const BasicBlock *bb = (*child_itr)->bb;
      BasicBlock::const_iterator MII = bb->begin();
      BasicBlock::const_iterator MIE = bb->end();
      for(; MII != MIE; ++MII) {
        worklist.push_back(MII);
      }
    }
    markAllCDChildren((*child_itr)->bb,worklist);
  }
}

void Scalarization::Calculate(Function &F) {
  SmallVector<const Instruction*, 128> worklist;
  //Initialization
  for(Function::iterator MBBI = F.begin(), MBBE = F.end(); MBBI != MBBE; ++MBBI) {
    conv.insert(std::make_pair(MBBI, true));
    for(BasicBlock::iterator MII = MBBI->begin(), MIE = MBBI->end(); MII != MIE; ++MII) {
      invar.insert(std::make_pair(MII, true));
      if(isa<IntrinsicInst>(MII))
        if(cast<IntrinsicInst>(MII)->getIntrinsicID() == Intrinsic::hwacha_veidx) 
          worklist.push_back(MII);

      //if(MII->getOpcode() == RISCV::VEIDX) 
        //worklist.push_back(MII);
      //if(MI->getOpcode() == AMO)
        //worklist.push_back(MI);
    }
  }
  while(!worklist.empty()) {
    const Instruction* MI = worklist.pop_back_val();
    invar[MI] = false;
    // Walk dataflow successors
    for(const Use &use : MI->uses()) {
      const Instruction* user = cast<Instruction>(use.getUser());
      if(invar[user])
        worklist.push_back(user);
    }
    if(isa<BranchInst>(MI) && cast<BranchInst>(MI)->isConditional())
      markAllCDChildren(MI->getParent(), worklist);
  }
}

bool Scalarization::runOnFunction(Function &F) {
  releaseMemory();

  PDG = &getAnalysis<ProgramDependenceGraph>();
  MF = &F;

  Calculate(F);

  return false;
}

void Scalarization::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequired<ProgramDependenceGraph>();
  FunctionPass::getAnalysisUsage(AU);
}

namespace llvm {
  FunctionPass *createScalarizationPass() {
    return new Scalarization();
  }
}

