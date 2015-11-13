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
#include "llvm/CodeGen/MachineLoopInfo.h"
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
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfo)
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
        std::set<std::pair<const MachineBasicBlock*, bool> > condSet;
        MachinePDGNode *newNode = new MachinePDGNode(A,condSet, this);
        BBtoCDS.insert(std::make_pair(A,newNode));

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
        if(!PDT->properlyDominates(TBB,A))
          s.insert(std::make_pair(std::make_pair(A,TBB),1));
        if(!PDT->properlyDominates(FBB,A))
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
    Worklist.push_back(B);
    do {
      MachineBasicBlock *BB = Worklist.pop_back_val();
      if(BBtoCDS.find(BB)->second->cds.count(std::make_pair(A,cond)) > 0){
        continue;
      }
      BBtoCDS.find(BB)->second->cds.insert(std::make_pair(A,cond));
      BBtoCDS.find(A)->second->addChild(std::make_pair(BBtoCDS.find(BB)->second,cond));
      // TODO: are these the successors we are looking for?
      //push all CFG successors to worklist 
      for(MachineBasicBlock *si : BB->successors())
        if(si != aParent->getBlock())
          Worklist.push_back(si);
    } while (!Worklist.empty());
  }
  //clean up the extra children so the graph looks pretty
  for(BBtoCDSMap::iterator bi = BBtoCDS.begin(), be = BBtoCDS.end(); bi != be; ++bi){
    if(bi->second->cds.size() < 2)
      continue; //empty and only one parent is fine
    //Look at our parents and see which is closer to use.
    //The correct has all of our control deps after adding itself
        for(MachineProgramDependenceGraph::CDSet::iterator pdi =
             bi->second->cds.begin(), pde =
             bi->second->cds.end(); pdi != pde; ++pdi){
          bool foundAll = true;
          MachineProgramDependenceGraph::CDSet::iterator checkItr, checkEnd;
          for( checkItr =
               bi->second->cds.begin(), checkEnd =
               bi->second->cds.end(); checkItr != checkEnd; ++checkItr){
            //loop over all of our parents deps
            bool found = (checkItr->first == pdi->first || checkItr->first == bi->first);
            //the second part of this conditional only compares bbs because if both side of the bb terminator branch to itself it is an infinite loop
            //bool found = false;
            //bool found = (*checkItr == *pdi || checkItr->first == bi->first);
            for(MachineProgramDependenceGraph::CDSet::iterator cdi =
                 BBtoCDS.find(pdi->first)->second->cds.begin(), cde =
                 BBtoCDS.find(pdi->first)->second->cds.end(); cdi != cde; ++cdi){
                //check for our parent being the missing dep first
              if(checkItr->first == cdi->first && checkItr->second == cdi->second) {
              //if(checkItr == cdi)
                found = true; break;
              }
            }
            //loop over our parents children

            for(MachinePDGChildIterator ki = MachinePDGChildIterator(BBtoCDS.find(pdi->first)->second),
                                 ke = MachinePDGChildIterator(BBtoCDS.find(pdi->first)->second,true); ki != ke; ++ki){
              /*bool cond = false;
              if(bi->second->cds.count(std::make_pair((*ki)->bb, false)) > 0)
                cond = false;
              if(bi->second->cds.count(std::make_pair((*ki)->bb, true)) > 0)
                cond = true;*/
              if(checkItr->first == (*ki)->bb &&
                  ((*ki)->cds.count(std::make_pair(bi->second->bb,true)) > 0 ||
                  (*ki)->cds.count(std::make_pair(bi->second->bb,false)) > 0))
                found = true;

              //if(*checkItr == std::make_pair((*ki)->bb, ki.cond()))
                  //((ki->first)->cds.count(std::make_pair(bi->second->bb,true)) > 0 ||
                  //(ki->first)->cds.count(std::make_pair(bi->second->bb,false)) > 0))
            }

            //if(!found) foundAll = false;
            if(!found)foundAll = false;
            if(!found)break;
          }
          if(!foundAll) {//remove bi from pdi's children
/*
            PDGChildIterator children = BBtoCDS.find(pdi->first)->second->children;
            for(PDGChildIterator it = children.begin(), ie = children.end(); it != ie; ++it){
              if(*it == bi->second)
                children.erase(it);
*/
              BBtoCDS.find(pdi->first)->second->children.erase(
              std::make_pair(bi->second, pdi->second));
          }
        }
  }
}

bool MachineProgramDependenceGraph::runOnMachineFunction(MachineFunction &F) {
  releaseMemory();

  DT = &getAnalysis<MachineDominatorTree>();
  PDT = &getAnalysis<MachinePostDominatorTree>();
  LI = &getAnalysis<MachineLoopInfo>();
  MF = &F;

  printf("RUNNING PDG\n");
  MF->dump();
  Calculate(F);

  return false;
}

void MachineProgramDependenceGraph::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<MachineDominatorTree>();
  AU.addRequired<MachinePostDominatorTree>();
  AU.addRequired<MachineLoopInfo>();
  MachineFunctionPass::getAnalysisUsage(AU);
}

namespace llvm {
  MachineFunctionPass *createMachineProgramDependenceGraphPass() {
    return new MachineProgramDependenceGraph();
  }
}
