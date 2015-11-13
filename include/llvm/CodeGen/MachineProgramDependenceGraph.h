//===- MachineProgramDependenceGraph.h - PDG analysis ----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Generates a program depdence graph based on the Jeanne Ferrante paper
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_MACHINEPROGRAMDEPENDENCEGRAPH_H
#define LLVM_CODEGEN_MACHINEPROGRAMDEPENDENCEGRAPH_H

#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachinePostDominators.h"
#include <map>
#include <set>
#include <utility>

namespace llvm {

class MachineProgramDependenceGraph;
MachineFunctionPass *createMachineProgramDependenceGraphPass();

//class raw_ostream;
//class Loop;
//class LoopInfo;

//===----------------------------------------------------------------------===//
/// @brief Analysis that detects all canonical Regions.
///
/// The MachineProgramDependenceGraph pass detects all canonical regions in a function. The Regions
/// are connected using the parent relation. This builds a Program Structure
/// Tree.
class MachineProgramDependenceGraph : public MachineFunctionPass {
public:
  typedef std::set<std::pair<const MachineBasicBlock*, bool> > CDSet;
  typedef std::map<const MachineBasicBlock*, CDSet > BBtoCDSMap;
  /// Map every BB to the set of control dependencies it has
  BBtoCDSMap BBtoCDS;
private:

  MachineProgramDependenceGraph(const MachineProgramDependenceGraph &) = delete;
  const MachineProgramDependenceGraph &operator=(const MachineProgramDependenceGraph &) = delete;

  MachineDominatorTree *DT;
  MachinePostDominatorTree *PDT;


  // Calculate - detecte all regions in function and build the region tree.
  void Calculate(MachineFunction& F);
public:
  static char ID;

  MachineProgramDependenceGraph() : MachineFunctionPass(ID) {
    initializeMachineProgramDependenceGraphPass(*PassRegistry::getPassRegistry());
  }

  MachineFunction *MF;

  bool runOnMachineFunction(MachineFunction &F) override;

  void releaseMemory() override;

  void getAnalysisUsage(AnalysisUsage &AU) const override;


  ~MachineProgramDependenceGraph();
};

template <> struct GraphTraits<MachineProgramDependenceGraph*> :
  public GraphTraits<const MachineBasicBlock*> {
    static NodeType *getEntryNode(const MachineProgramDependenceGraph *PDG) {return &PDG->MF->front();}

    // nodes_iterator/begin/end - Allow iteration over all nodes in the graph
    typedef MachineFunction::const_iterator nodes_iterator;
    static nodes_iterator nodes_begin(MachineProgramDependenceGraph *PDG) { return PDG->MF->begin(); }
    static nodes_iterator nodes_end  (MachineProgramDependenceGraph *PDG) { return PDG->MF->end(); }
    static unsigned       size       (MachineProgramDependenceGraph *PDG) { return PDG->MF->size(); }
  };
} // End llvm namespace
#endif
