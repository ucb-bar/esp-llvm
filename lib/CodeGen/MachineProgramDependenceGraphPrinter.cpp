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

  std::string getNodeLabel(const MachineBasicBlock *Node, MachineProgramDependenceGraph *PDG){
    std::string Str;
    raw_string_ostream OS(Str);

    OS << "BB#" << Node->getNumber();
    if (const BasicBlock *BB = Node->getBasicBlock())
      OS << ": " << BB->getName();
    OS << "\n";
    MachineProgramDependenceGraph::CDSet cdSet;
    if(PDG->BBtoCDS.find(Node) != PDG->BBtoCDS.end())
      cdSet = PDG->BBtoCDS.find(Node)->second;
    if(!cdSet.empty())
      OS << "Control dependent on\n";
    for(MachineProgramDependenceGraph::CDSet::iterator itr = cdSet.begin(); itr != cdSet.end(); itr++){
      OS << "(" << itr->first->getName().str() << ", " << (itr->second ? "F" : "T") << ")\n";
    }
    return OS.str();
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

INITIALIZE_PASS(MachineProgramDependenceGraphPrinter, "dot-pdg",
                "Print the pdf of function to 'dot' file", true, true)

MachineFunctionPass* llvm::createMachineProgramDependenceGraphPrinterPass() {
  return new MachineProgramDependenceGraphPrinter();
}
