//===- ProgramDependenceGraph.h - PDG analysis ----------------------*- C++ -*-===//
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

#ifndef LLVM_ANALYSIS_PROGRAMDEPENDENCEGRAPH_H
#define LLVM_ANALYSIS_PROGRAMDEPENDENCEGRAPH_H

#include "llvm/ADT/PointerIntPair.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Support/Allocator.h"
#include <map>
#include <set>
#include <utility>

namespace llvm {

class ProgramDependenceGraph;
class raw_ostream;
class Loop;
class LoopInfo;

//===----------------------------------------------------------------------===//
/// @brief Analysis that detects all canonical Regions.
///
/// The ProgramDependenceGraph pass detects all canonical regions in a function. The Regions
/// are connected using the parent relation. This builds a Program Structure
/// Tree.
class ProgramDependenceGraph : public FunctionPass {
public:
  typedef std::set<std::pair<const BasicBlock*, bool> > CDSet;
  typedef std::map<const BasicBlock*, CDSet > BBtoCDSMap;
  /// Map every BB to the set of control dependencies it has
  BBtoCDSMap BBtoCDS;
private:

  ProgramDependenceGraph(const ProgramDependenceGraph &) LLVM_DELETED_FUNCTION;
  const ProgramDependenceGraph &operator=(const ProgramDependenceGraph &) LLVM_DELETED_FUNCTION;

  DominatorTree *DT;
  PostDominatorTree *PDT;


  // Calculate - detecte all regions in function and build the region tree.
  void Calculate(Function& F);

  void releaseMemory();

public:
  static char ID;
  explicit ProgramDependenceGraph();
  Function *Func;

  ~ProgramDependenceGraph();

  /// @name FunctionPass interface
  //@{
  virtual bool runOnFunction(Function &F);
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;
  //virtual void print(raw_ostream &OS, const Module *) const;
  //@}

};

/*
template <> struct GraphTraits<ProgramDependenceGraph*>
  : public GraphTraits<const Function*> { 

    typedef const BasicBlock NodeType;
  static nodes_iterator nodes_begin(ProgramDependenceGraph *PDG) {
    return GraphTraits<const Function*>::nodes_begin(PDG->Func);
  }

  static nodes_iterator nodes_end(ProgramDependenceGraph *PDG) {
    return GraphTraits<const Function*>::nodes_end(PDG->Func);
  }

  };
  */

template <> struct GraphTraits<ProgramDependenceGraph*> :
  public GraphTraits<const BasicBlock*> {
  static NodeType *getEntryNode(const ProgramDependenceGraph *PDG) {return &PDG->Func->getEntryBlock();}

  // nodes_iterator/begin/end - Allow iteration over all nodes in the graph
  typedef Function::const_iterator nodes_iterator;
  static nodes_iterator nodes_begin(ProgramDependenceGraph *PDG) { return PDG->Func->begin(); }
  static nodes_iterator nodes_end  (ProgramDependenceGraph *PDG) { return PDG->Func->end(); }
  static unsigned       size       (ProgramDependenceGraph *PDG) { return PDG->Func->size(); }
};
} // End llvm namespace
#endif

