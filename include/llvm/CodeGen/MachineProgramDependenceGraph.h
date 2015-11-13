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
#include "llvm/CodeGen/MachineLoopInfo.h"
#include <map>
#include <set>
#include <utility>

namespace llvm {

class MachineProgramDependenceGraph;
MachineFunctionPass *createMachineProgramDependenceGraphPass();

class MachinePDGNode;

//===----------------------------------------------------------------------===//
/// @brief Analysis that detects all canonical Regions.
///
/// The MachineProgramDependenceGraph pass detects all canonical regions in a function. The Regions
/// are connected using the parent relation. This builds a Program Structure
/// Tree.
class MachineProgramDependenceGraph : public MachineFunctionPass {
public:
  typedef std::set<std::pair<const MachineBasicBlock*, bool> > CDSet;
  typedef std::map<const MachineBasicBlock*, MachinePDGNode* > BBtoCDSMap;
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
  const MachineLoopInfo *LI;

  bool runOnMachineFunction(MachineFunction &F) override;

  void releaseMemory() override;

  void getAnalysisUsage(AnalysisUsage &AU) const override;


  ~MachineProgramDependenceGraph();
};

class MachinePDGNode {
public:
  const MachineBasicBlock *bb;
  MachineProgramDependenceGraph::CDSet cds;
  std::set<std::pair<MachinePDGNode*,bool> > children;
  MachineProgramDependenceGraph *parent;

  MachinePDGNode(const MachineBasicBlock *bb, MachineProgramDependenceGraph::CDSet cds, 
      MachineProgramDependenceGraph *parent):
    bb(bb), cds(cds), parent(parent) {}
  void addChild(std::pair<MachinePDGNode*,bool> kid){
    children.insert(kid);
  }
};

class MachinePDGChildIterator: public std::iterator<std::forward_iterator_tag, MachinePDGNode, ptrdiff_t>
{
  typedef std::iterator<std::forward_iterator_tag, MachinePDGNode, ptrdiff_t> super;

  MachinePDGNode* Node;

  // The inner iterator.
  std::set<std::pair<MachinePDGNode*,bool> >::iterator BItor;


public:
  typedef MachinePDGChildIterator Self;

  typedef typename super::pointer pointer;

  /// @brief Create begin iterator of a RegionNode.
  inline MachinePDGChildIterator(MachinePDGNode* node)
    : Node(node), BItor(node->children.begin()) {}

  /// @brief Create an end iterator.
  inline MachinePDGChildIterator(MachinePDGNode* node, bool end)
    : Node(node), BItor(node->children.end()) {}

  inline bool operator==(const Self& x) const {
    return BItor == x.BItor;
  }

  inline bool operator!=(const Self& x) const { return !operator==(x); }

  inline pointer operator*() const {
    return BItor->first;
  }
  inline bool cond() const {
    return BItor->second;
  }

  inline Self& operator++() {
    ++BItor;
    return *this;
  }

  inline Self operator++(int) {
    Self tmp = *this;
    ++*this;
    return tmp;
  }

  inline const Self &operator=(const Self &I) {
    if (this != &I) {
      Node = I.Node;
      BItor = I.BItor;
    }
    return *this;
  }
};

class MachinePDGNodeIterator: public std::iterator<std::forward_iterator_tag, MachinePDGNode, ptrdiff_t>
{
  typedef std::iterator<std::forward_iterator_tag, MachinePDGNode, ptrdiff_t> super;

  MachinePDGNode* Node;

  // The BBMap iterator.
  MachineProgramDependenceGraph::BBtoCDSMap::iterator BItor;


public:
  typedef MachinePDGNodeIterator Self;

  typedef typename super::pointer pointer;

  /// @brief Create begin iterator of a RegionNode.
  inline MachinePDGNodeIterator(MachinePDGNode* node, MachineProgramDependenceGraph *MachinePDG)
    : Node(node), BItor(MachinePDG->BBtoCDS.begin()) {}

  /// @brief Create an end iterator.
  inline MachinePDGNodeIterator(MachinePDGNode* node, MachineProgramDependenceGraph *MachinePDG, bool)
    : Node(node), BItor(MachinePDG->BBtoCDS.end()) {}

  inline bool operator==(const Self& x) const {
    return BItor == x.BItor;
  }

  inline bool operator!=(const Self& x) const { return !operator==(x); }

  inline pointer operator*() const {
    //return Node->parent->BBtoCDS.find(*BItor)->second;
    return BItor->second;
  }

  inline Self& operator++() {
    ++BItor;
    return *this;
  }

  inline Self operator++(int) {
    Self tmp = *this;
    ++*this;
    return tmp;
  }

  inline const Self &operator=(const Self &I) {
    if (this != &I) {
      Node = I.Node;
      BItor = I.BItor;
    }
    return *this;
  }
};

template <> struct GraphTraits<MachinePDGNode*>{
  typedef MachinePDGNode NodeType;
  typedef MachinePDGChildIterator ChildIteratorType;

  static NodeType *getEntryNode(NodeType* N) { return N; } 

  static inline ChildIteratorType child_begin(NodeType *N) { 
    return MachinePDGChildIterator(N);
  } 

  static inline ChildIteratorType child_end(NodeType *N) { 
    return MachinePDGChildIterator(N,true);
  } 
};

template <> struct GraphTraits<MachineProgramDependenceGraph*>
 : public GraphTraits<MachinePDGNode*>{

  static NodeType *getEntryNode(const MachineProgramDependenceGraph *MachinePDG) {
    return MachinePDG->BBtoCDS.begin()->second;
  }

  // nodes_iterator/begin/end - Allow iteration over all nodes in the graph
  typedef MachinePDGNodeIterator nodes_iterator;

  static nodes_iterator nodes_begin(MachineProgramDependenceGraph *MachinePDG) {
    return nodes_iterator(MachinePDG->BBtoCDS.begin()->second, MachinePDG); 
  }
  static nodes_iterator nodes_end  (MachineProgramDependenceGraph *MachinePDG) {
    return nodes_iterator(MachinePDG->BBtoCDS.begin()->second, MachinePDG, true);
  }
};
} // End llvm namespace
#endif
