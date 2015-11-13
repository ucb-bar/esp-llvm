//===- ProgramDependenceGraph.cpp - PDG analysis --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Generates a program depdence graph based on the Jeanne Ferrante paper
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/ProgramDependenceGraph.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/RegionIterator.h"
#include "llvm/Assembly/Writer.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/CFG.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"

#define DEBUG_TYPE "pdg"
#include "llvm/Support/Debug.h"

#include <set>
#include <algorithm>

using namespace llvm;

//TODO:How do you verify PDG
// Always verify if expensive checking is enabled.
#ifdef XDEBUG
static bool VerifyPDG = true;
#else
static bool VerifyPDG = false;
#endif

static cl::opt<bool,true>
VerifyPDGX("verify-pdg", cl::location(VerifyPDG),
                cl::desc("Verify PDG (time consuming)"));

//TODO:what are actual useful statistics
//STATISTIC(numRegions,       "The # of regions");
//STATISTIC(numSimpleRegions, "The # of simple regions");

/*
static cl::opt<enum Region::PrintStyle> printStyle("print-region-style",
  cl::Hidden,
  cl::desc("style of printing regions"),
  cl::values(
    clEnumValN(Region::PrintNone, "none",  "print no details"),
    clEnumValN(Region::PrintBB, "bb",
               "print regions in detail with block_iterator"),
    clEnumValN(Region::PrintRN, "rn",
               "print regions in detail with element_iterator"),
    clEnumValEnd));
    */

//===----------------------------------------------------------------------===//
// ProgramDependenceGraph implementation
//

void ProgramDependenceGraph::releaseMemory() {
  BBtoCDS.clear();
}

ProgramDependenceGraph::ProgramDependenceGraph() : FunctionPass(ID) {
  initializeProgramDependenceGraphPass(*PassRegistry::getPassRegistry());
}

ProgramDependenceGraph::~ProgramDependenceGraph() {
  releaseMemory();
}

void ProgramDependenceGraph::Calculate(Function &F) {
  //TODO:LLVM may have multiple exit blocks
  //Add Start
  //BasicBlock *startBB = BasicBlock::Create(F.getContext(), "Start", &F, &F.getEntryBlock());
  //BranchInst::Create(&F.getEntryBlock(), startBB);

  typedef std::map<std::pair<BasicBlock*, BasicBlock*>,bool> s_map;
  s_map s;
  //Loop over CFG
  for(Function::iterator A = F.begin(), E = F.end(); A != E; ++A){
        std::set<std::pair<const BasicBlock*, bool> > condSet;
        PDGNode *newNode = new PDGNode(A,condSet, this);
        BBtoCDS.insert(std::make_pair(A,newNode));

    //TODO:only look at conditional terminators?
    if(isa<BranchInst>(A->getTerminator())){
      BranchInst *term = (BranchInst*)A->getTerminator();
      for(unsigned i = 0; i < term->getNumSuccessors(); ++i){
        BasicBlock *B = term->getSuccessor(i);
        //i==0 F branch
        //i==1 T branch
        if(!PDT->properlyDominates(B,A))
          s.insert(std::make_pair(std::make_pair(A,B),i));
      }
    }
  }
  
  //Examine S
  //for each edge in S
  typedef s_map::iterator s_itr;
  SmallVector<BasicBlock*, 128> Worklist;
  for(s_itr it = s.begin(); it != s.end(); ++it){
    BasicBlock *A = it->first.first;
    BasicBlock *B = it->first.second;
    bool cond = it->second;
    //find the common ancestor named L of (A,B) in the PDT
    //Two cases for L
    //Case 1) L = parent of A
    //Case 2) L = A
    //Both cases are solved by traversing PDT from B to A's parent marking everything but 
    //A's parent as control dependent on A
    DomTreeNode *aParent = PDT->getNode(A)->getIDom();
    DomTreeNode *travel  = PDT->getNode(B);
    Worklist.push_back(B);
    do {
      BasicBlock *BB = Worklist.pop_back_val();
      //mark travel
      if(BBtoCDS.find(BB)->second->cds.count(std::make_pair(A,cond)) > 0){
        continue;
      }
      BBtoCDS.find(BB)->second->cds.insert(std::make_pair(A,cond));
      BBtoCDS.find(A)->second->addChild(std::make_pair(BBtoCDS.find(BB)->second,cond));
      //push all CFG successors to worklist
      for(succ_iterator SI = succ_begin(BB), SE = succ_end(BB); SI != SE; ++SI)
        if(*SI != aParent->getBlock())
          Worklist.push_back(*SI);
    } while (!Worklist.empty());
  }
  //clean up the extra children so the graph looks pretty
  for(BBtoCDSMap::iterator bi = BBtoCDS.begin(), be = BBtoCDS.end(); bi != be; ++bi){
    if(bi->second->cds.size() < 2)
      continue; //empty and only one parent is fine
    //Look at our parents and see which is closer to use.
    //The correct has all of our control deps after adding itself
        for(ProgramDependenceGraph::CDSet::iterator pdi =
             bi->second->cds.begin(), pde =
             bi->second->cds.end(); pdi != pde; ++pdi){
          bool foundAll = true;
          ProgramDependenceGraph::CDSet::iterator checkItr, checkEnd;
          for( checkItr =
               bi->second->cds.begin(), checkEnd =
               bi->second->cds.end(); checkItr != checkEnd; ++checkItr){
            //loop over all of our parents deps
            bool found = (checkItr->first == pdi->first || checkItr->first == bi->first);
            //the second part of this conditional only compares bbs because if both side of the bb terminator branch to itself it is an infinite loop
            //bool found = false;
            //bool found = (*checkItr == *pdi || checkItr->first == bi->first);
            for(ProgramDependenceGraph::CDSet::iterator cdi =
                 BBtoCDS.find(pdi->first)->second->cds.begin(), cde =
                 BBtoCDS.find(pdi->first)->second->cds.end(); cdi != cde; ++cdi){
                //check for our parent being the missing dep first
              if(checkItr->first == cdi->first && checkItr->second == cdi->second) {
              //if(checkItr == cdi)
                found = true; break;
              }
            }
            //loop over our parents children

            for(PDGChildIterator ki = PDGChildIterator(BBtoCDS.find(pdi->first)->second),
                                 ke = PDGChildIterator(BBtoCDS.find(pdi->first)->second,true); ki != ke; ++ki){
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

bool ProgramDependenceGraph::runOnFunction(Function &F) {
  releaseMemory();

  DT = &getAnalysis<DominatorTree>();
  PDT = &getAnalysis<PostDominatorTree>();
  LI = &getAnalysis<LoopInfo>();
  Func = &F;

  Calculate(F);

  return false;
}

void ProgramDependenceGraph::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequiredTransitive<DominatorTree>();
  AU.addRequired<PostDominatorTree>();
  AU.addRequired<LoopInfo>();
}

/*
void ProgramDependenceGraph::print(raw_ostream &OS, const Module *) const {
  OS << "PDG tree:\n";
  OS << "End PDG tree\n";
}
*/

char ProgramDependenceGraph::ID = 0;
INITIALIZE_PASS_BEGIN(ProgramDependenceGraph, "pdg",
                "Determine the program dependence graph", true, true)
INITIALIZE_PASS_DEPENDENCY(DominatorTree)
INITIALIZE_PASS_DEPENDENCY(PostDominatorTree)
INITIALIZE_PASS_DEPENDENCY(LoopInfo)
INITIALIZE_PASS_END(ProgramDependenceGraph, "pdg",
                "Determine the program dependence graph", true, true)

// Create methods available outside of this file, to use them
// "include/llvm/LinkAllPasses.h". Otherwise the pass would be deleted by
// the link time optimization.

namespace llvm {
  FunctionPass *createProgramDependenceGraphPass() {
    return new ProgramDependenceGraph();
  }
}

