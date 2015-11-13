//===- MachineProgramDependenceGraph.cpp - PDG analysis --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Generates a program depdence graph based on the Jeanne Ferrante paper
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetRegisterInfo.h"
#include "llvm/Target/TargetSubtargetInfo.h"
#include "llvm/CodeGen/MachineProgramDependenceGraph.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachinePostDominators.h"
#include "llvm/CodeGen/MachineFunctionAnalysis.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/Debug.h"

#include <set>
#include <algorithm>

using namespace llvm;

char MachineProgramDependenceGraph::ID = 0;
INITIALIZE_PASS_BEGIN(MachineProgramDependenceGraph, "machinepdg",
                "Machine Program Dependence graph Construction", true, true)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTree)
INITIALIZE_PASS_DEPENDENCY(MachinePostDominatorTree)
INITIALIZE_PASS_END(MachineProgramDependenceGraph, "machinepdg",
                "Machine Program Dependence graph Construction", true, true)

char &llvm::MachineProgramDependenceGraphID = MachineProgramDependenceGraph::ID;

void MachineProgramDependenceGraph::releaseMemory() {
  BBtoCDS.clear();
}

MachineProgramDependenceGraph::~MachineProgramDependenceGraph() {
  releaseMemory();
}

void MachineProgramDependenceGraph::Calculate(MachineFunction &F) {
  //TODO:LLVM may have multiple exit blocks
  const TargetInstrInfo *TII = F.getSubtarget().getInstrInfo();

  typedef std::map<std::pair<MachineBasicBlock*, MachineBasicBlock*>,bool> s_map;
  s_map s;
  //Loop over CFG
  for(MachineFunction::iterator A = F.begin(), E = F.end(); A != E; ++A) {
    //TODO: why do we replicate MBB functionality
    MachineBasicBlock *TBB = nullptr, *FBB = nullptr;
    SmallVector<MachineOperand, 4> Cond;
    bool B = TII->AnalyzeBranch(*A, TBB, FBB, Cond);
    (void) B;
    //assert(!B && "PDG requires analyzable cfg!");
    if (Cond.empty()) {
      // The block has an unconditional branch. Do nothing
    } else {
      // Conditional Branch
      if (FBB) {
        // Two-way conditional Branch: This is the case we care about
        //i==0 F branch
        //i==1 T branch
        if(!PDT->dominates(TBB,A))
          s.insert(std::make_pair(std::make_pair(A,TBB),1));
        if(!PDT->dominates(FBB,A))
          s.insert(std::make_pair(std::make_pair(A,FBB),0));
      } else {
        // Single successor branch shouldn't exist (update terminator first)
      }
    }
  }
  
  //Examine S
  //for each edge in S
  typedef s_map::iterator s_itr;
  SmallVector<MachineBasicBlock*, 128> Worklist;
  for(s_itr it = s.begin(); it != s.end(); ++it){
    MachineBasicBlock *A = it->first.first;
    MachineBasicBlock *B = it->first.second;
    bool cond = it->second;
    //find the common ancestor named L of (A,B) in the PDT
    //Two cases for L
    //Case 1) L = parent of A
    //Case 2) L = A
    //Both cases are solved by traversing PDT from B to A's parent marking everything but 
    //A's parent as control dependent on A
    MachineDomTreeNode *aParent = PDT->getNode(A)->getIDom();
    MachineDomTreeNode *travel  = PDT->getNode(B);
    Worklist.push_back(travel->getBlock());
    do {
      MachineBasicBlock *BB = Worklist.pop_back_val();
      //mark travel
      if(BBtoCDS.find(BB) == BBtoCDS.end()){
        std::set<std::pair<const MachineBasicBlock*, bool> > condSet;
        condSet.insert(std::make_pair(A,cond));
        BBtoCDS.insert(std::make_pair(BB,condSet));
      }else{
        if(BBtoCDS.find(BB)->second.count(std::make_pair(A,cond)) > 0)
          continue;
        BBtoCDS.find(BB)->second.insert(std::make_pair(A,cond));
      }
      // TODO: are these the successors we are looking for?
      //push all CFG successors to worklist 
      for(MachineBasicBlock *si : BB->successors())
        if(si != aParent->getBlock())
          Worklist.push_back(si);
    } while (!Worklist.empty());
  }
}

bool MachineProgramDependenceGraph::runOnMachineFunction(MachineFunction &F) {
  releaseMemory();

  DT = &getAnalysis<MachineDominatorTree>();
  PDT = &getAnalysis<MachinePostDominatorTree>();
  MF = &F;

  Calculate(F);

  return false;
}

void MachineProgramDependenceGraph::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<MachineDominatorTree>();
  AU.addRequired<MachinePostDominatorTree>();
  MachineFunctionPass::getAnalysisUsage(AU);
}

namespace llvm {
  MachineFunctionPass *createMachineProgramDependenceGraphPass() {
    return new MachineProgramDependenceGraph();
  }
}
