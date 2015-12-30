//===- MachineProgramDependenceGraphPrinter.cpp - Print regions tree pass ------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Print out the region tree of a function using dotty/graphviz.
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/DOTGraphTraitsPass.h"
#include "llvm/CodeGen/MachineProgramDependenceGraph.h"
#include "llvm/CodeGen/MachineProgramDependenceGraphPrinter.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace llvm {
template<>
struct DOTGraphTraits<MachineProgramDependenceGraph*> : public DefaultDOTGraphTraits {

  explicit DOTGraphTraits (bool isSimple=true)
    : DefaultDOTGraphTraits(isSimple) {}

  static std::string getGraphName(const MachineProgramDependenceGraph *DT) {
    return "Program Dependence Graph";
  }
  static std::string getGraphProperties(MachineProgramDependenceGraph *MachinePDG) {
    return "colorscheme=set19";
  }

  std::string getEdgeSourceLabel(const MachinePDGNode *Node, MachinePDGChildIterator itr){
    MachineProgramDependenceGraph::CDSet condSet = (*itr)->cds;
    for(MachineProgramDependenceGraph::CDSet::iterator citr = condSet.begin(), cend = condSet.end(); citr != cend; ++citr){
      if(citr->first == Node->bb)
        return itr.cond() ? "T" : "F";
    }
    return "ERR";
  }

  std::string getNodeDescription(const MachinePDGNode *Node, MachineProgramDependenceGraph *MachinePDG){
    std::string Str;
    raw_string_ostream OS(Str);

    /*
    MachineLoop *L = MachinePDG->LI->getLoopFor(Node->bb);
    if(L){
      if(L->getHeader()==Node->bb) OS << "Header ";
      if(L->getLoopPreheader()==Node->bb) OS << "PreHeader ";
      if(L->getLoopLatch() == Node->bb) OS << "Latch ";
      SmallVector<MachineBasicBlock *, 8> Blocks;
      L->getExitingBlocks(Blocks);
      for(unsigned i = 0, e = Blocks.size(); i != e; ++i)
        if(Blocks[i] == Node->bb) OS << "Exiting ";
    }*/

    if(isSimple()) return OS.str();

    OS << "\n";
    MachineProgramDependenceGraph::CDSet cdSet = Node->cds;
    for(MachineProgramDependenceGraph::CDSet::iterator itr = cdSet.begin(); itr != cdSet.end(); itr++){
      OS << "(" << itr->first->getName().str() << ", " << (itr->second ? "T" : "F") << ")";
    }
    return OS.str();
  }

  std::string getNodeLabel(const MachinePDGNode *Node, MachineProgramDependenceGraph *MachinePDG){
    std::string Str;
    raw_string_ostream OS(Str);

    MachineProgramDependenceGraph::CDSet cdSet = Node->cds;
    for(MachineProgramDependenceGraph::CDSet::iterator itr = cdSet.begin(); itr != cdSet.end(); itr++){
      OS << "(" << itr->first->getName().str() << ", " << (itr->second ? "T" : "F") << ")";
    }

    //std::string name = DOTGraphTraits<const llvm::MachineFunction*>::getSimpleNodeLabel(Node->bb, MachinePDG->MF);

    std::string name;
    raw_string_ostream nOS(name);
    nOS << "BB#" << Node->bb->getNumber();
    if (const MachineBasicBlock *BB = Node->bb)
      nOS << ": " << BB->getName();
    
    return nOS.str();
  }

  std::string getNodeAttributes(const MachinePDGNode *Node, MachineProgramDependenceGraph *MachinePDG){
    /*
    Loop *L = MachinePDG->LI->getLoopFor(Node->bb);
    if(L){
      if(L->getHeader()==Node->bb) return "color=1";
      if(L->getLoopPreheader()==Node->bb) return "color=2";
      if(L->getLoopLatch() == Node->bb) return "color=3";
      SmallVector<MachineBasicBlock *, 8> Blocks;
      L->getExitingBlocks(Blocks);
      for(unsigned i = 0, e = Blocks.size(); i != e; ++i)
        if(Blocks[i] == Node->bb) return "color=4";
    }*/
    return "";
  }

};
} //end namespace llvm

namespace {

struct MachineProgramDependenceGraphPrinter
  : public DOTGraphTraitsMachinePrinter<MachineProgramDependenceGraph, true> {
  static char ID;
  MachineProgramDependenceGraphPrinter() :
    DOTGraphTraitsMachinePrinter<MachineProgramDependenceGraph, true>("pdg", ID) {
      initializeMachineProgramDependenceGraphPrinterPass(*PassRegistry::getPassRegistry());
    }
};
char MachineProgramDependenceGraphPrinter::ID = 0;
} //end anonymous namespace

INITIALIZE_PASS_BEGIN(MachineProgramDependenceGraphPrinter, "dot-pdg",
                "Print the pdg of function to 'dot' file", true, true)
INITIALIZE_PASS_DEPENDENCY(MachineProgramDependenceGraph)
INITIALIZE_PASS_END(MachineProgramDependenceGraphPrinter, "dot-pdg",
                "Print the pdg of function to 'dot' file", true, true)

MachineFunctionPass* llvm::createMachineProgramDependenceGraphPrinterPass() {
  return new MachineProgramDependenceGraphPrinter();
}
