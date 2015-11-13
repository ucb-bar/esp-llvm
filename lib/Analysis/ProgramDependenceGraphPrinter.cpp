//===- ProgramDependenceGraphPrinter.cpp - Print regions tree pass ------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Print out the region tree of a function using dotty/graphviz.
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/Passes.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/DOTGraphTraitsPass.h"
#include "llvm/Analysis/ProgramDependenceGraph.h"
#include "llvm/Analysis/ProgramDependenceGraphPrinter.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace llvm {
template<>
struct DOTGraphTraits<ProgramDependenceGraph*> : public DefaultDOTGraphTraits {

  DOTGraphTraits (bool isSimple=true)
    : DefaultDOTGraphTraits(isSimple) {}

  static std::string getGraphName(ProgramDependenceGraph *DT) {
    return "Program Dependence Graph";
  }
  static std::string getGraphProperties(ProgramDependenceGraph *PDG) {
    return "colorscheme=set19";
  }

  std::string getEdgeSourceLabel(const PDGNode *Node, PDGChildIterator itr){
    ProgramDependenceGraph::CDSet condSet = (*itr)->cds;
    for(ProgramDependenceGraph::CDSet::iterator citr = condSet.begin(), cend = condSet.end(); citr != cend; ++citr){
      if(citr->first == Node->bb)
        return itr.cond() ? "F" : "T";
    }
    return "ERR";
  }

  std::string getNodeDescription(const PDGNode *Node, ProgramDependenceGraph *PDG){
    std::string Str;
    raw_string_ostream OS(Str);

    Loop *L = PDG->LI->getLoopFor(Node->bb);
    if(L){
      if(L->getHeader()==Node->bb) OS << "Header ";
      if(L->getLoopPreheader()==Node->bb) OS << "PreHeader ";
      if(L->getLoopLatch() == Node->bb) OS << "Latch ";
      SmallVector<BasicBlock *, 8> Blocks;
      L->getExitingBlocks(Blocks);
      for(unsigned i = 0, e = Blocks.size(); i != e; ++i)
        if(Blocks[i] == Node->bb) OS << "Exiting ";
    }

    if(isSimple()) return OS.str();

    OS << "\n";
    ProgramDependenceGraph::CDSet cdSet = Node->cds;
    for(ProgramDependenceGraph::CDSet::iterator itr = cdSet.begin(); itr != cdSet.end(); itr++){
      OS << "(" << itr->first->getName().str() << ", " << (itr->second ? "F" : "T") << ")";
    }
    return OS.str();
  }

  std::string getNodeLabel(const PDGNode *Node, ProgramDependenceGraph *PDG){
    std::string Str;
    raw_string_ostream OS(Str);

    ProgramDependenceGraph::CDSet cdSet = Node->cds;
    for(ProgramDependenceGraph::CDSet::iterator itr = cdSet.begin(); itr != cdSet.end(); itr++){
      OS << "(" << itr->first->getName().str() << ", " << (itr->second ? "F" : "T") << ")";
    }

    std::string name = DOTGraphTraits<const llvm::Function*>::getSimpleNodeLabel(Node->bb, PDG->Func);
    return name;
  }

  std::string getNodeAttributes(const PDGNode *Node, ProgramDependenceGraph *PDG){
    Loop *L = PDG->LI->getLoopFor(Node->bb);
    if(L){
      if(L->getHeader()==Node->bb) return "color=1";
      if(L->getLoopPreheader()==Node->bb) return "color=2";
      if(L->getLoopLatch() == Node->bb) return "color=3";
      SmallVector<BasicBlock *, 8> Blocks;
      L->getExitingBlocks(Blocks);
      for(unsigned i = 0, e = Blocks.size(); i != e; ++i)
        if(Blocks[i] == Node->bb) return "color=4";
    }
    return "";
  }

};
template<>
bool GraphWriter<ProgramDependenceGraph*>::getEdgeSourceLabels(raw_ostream &O, PDGNode *Node){
  if(Node->children.empty())
    return false;
  O <<  "<s0>T|<s1>F";
  return true;
}
template<>
void GraphWriter<ProgramDependenceGraph*>::writeEdge(PDGNode *Node, unsigned edgeidx, PDGChildIterator EI){
  if (NodeType *TargetNode = *EI) {
    int DestPort = -1;
  if (DTraits.edgeTargetsEdgeSource(Node, EI)) {
    child_iterator TargetIt = DTraits.getEdgeTarget(Node, EI);

    // Figure out which edge this targets...
    unsigned Offset =
    (unsigned)std::distance(GTraits::child_begin(TargetNode), TargetIt);
    DestPort = static_cast<int>(Offset);
  }

  if (DTraits.getEdgeSourceLabel(Node, EI).empty())
    edgeidx = -1;
  if (DTraits.getEdgeSourceLabel(Node, EI) == "T")
    edgeidx = 0;
  if (DTraits.getEdgeSourceLabel(Node, EI) == "F")
    edgeidx = 1;

  emitEdge(static_cast<const void*>(Node), edgeidx,
           static_cast<const void*>(TargetNode), DestPort,
           DTraits.getEdgeAttributes(Node, EI, G));
  }
}
} //end namespace llvm

namespace {
struct ProgramDependenceGraphPrinter
  : public DOTGraphTraitsPrinter<ProgramDependenceGraph, false> {
  static char ID;
  ProgramDependenceGraphPrinter() :
    DOTGraphTraitsPrinter<ProgramDependenceGraph, false>("pdg", ID) {
      initializeProgramDependenceGraphPrinterPass(*PassRegistry::getPassRegistry());
    }
};
char ProgramDependenceGraphPrinter::ID = 0;

struct ProgramDependenceGraphOnlyPrinter
  : public DOTGraphTraitsPrinter<ProgramDependenceGraph, true> {
  static char ID;
  ProgramDependenceGraphOnlyPrinter() :
    DOTGraphTraitsPrinter<ProgramDependenceGraph, true>("pdg", ID) {
      initializeProgramDependenceGraphOnlyPrinterPass(*PassRegistry::getPassRegistry());
    }
};
char ProgramDependenceGraphOnlyPrinter::ID = 0;
} //end anonymous namespace

INITIALIZE_PASS(ProgramDependenceGraphPrinter, "dot-pdg",
                "Print the pdg of function to 'dot' file", true, true)

INITIALIZE_PASS(ProgramDependenceGraphOnlyPrinter, "dot-pdg-only",
                "Print the pdg of function to 'dot' file", true, true)

FunctionPass* llvm::createProgramDependenceGraphPrinterPass() {
  return new ProgramDependenceGraphPrinter();
}

FunctionPass* llvm::createProgramDependenceGraphOnlyPrinterPass() {
  return new ProgramDependenceGraphOnlyPrinter();
}
