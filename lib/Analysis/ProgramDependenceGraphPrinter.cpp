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

  /*std::string llvm::DOTGraphTraits<llvm::ProgramDependenceGraph*>::getNodeLabel(llvm::GraphWriter<llvm::ProgramDependenceGraph*>::NodeType*&, llvm::ProgramDependenceGraph* const&){
    return DOTGraphTraits<const llvm::Function*>::getNodeLabel(Node, PDG->Func);
  }*/
  /*bool isNodeHidden(const BasicBlock *Node){
    ProgramDependenceGraph::CDSet cdSet;
    if(PDG->BBtoCDS.find(Node) != PDG->BBtoCDS.end())
      cdSet = PDG->BBtoCDS.find(Node)->second;
    return cdSet.empty();
  }*/

  std::string getNodeLabel(const BasicBlock *Node, ProgramDependenceGraph *PDG){
    std::string Str;
    raw_string_ostream OS(Str);

    std::string name = DOTGraphTraits<const llvm::Function*>::getSimpleNodeLabel(Node, PDG->Func);
    OS << name << "\n";
    ProgramDependenceGraph::CDSet cdSet;
    if(PDG->BBtoCDS.find(Node) != PDG->BBtoCDS.end())
      cdSet = PDG->BBtoCDS.find(Node)->second;
    if(!cdSet.empty())
      OS << "Control dependent on\n";
    for(ProgramDependenceGraph::CDSet::iterator itr = cdSet.begin(); itr != cdSet.end(); itr++){
      OS << "(" << itr->first->getName().str() << ", " << (itr->second ? "F" : "T") << ")\n";
    }
    return OS.str();
  }

};
} //end namespace llvm

namespace {
struct ProgramDependenceGraphPrinter
  : public DOTGraphTraitsPrinter<ProgramDependenceGraph, true> {
  static char ID;
  ProgramDependenceGraphPrinter() :
    DOTGraphTraitsPrinter<ProgramDependenceGraph, true>("pdg", ID) {
      initializeProgramDependenceGraphPrinterPass(*PassRegistry::getPassRegistry());
    }
};
char ProgramDependenceGraphPrinter::ID = 0;
} //end anonymous namespace

INITIALIZE_PASS(ProgramDependenceGraphPrinter, "dot-pdg",
                "Print the pdf of function to 'dot' file", true, true)

FunctionPass* llvm::createProgramDependenceGraphPrinterPass() {
  return new ProgramDependenceGraphPrinter();
}
