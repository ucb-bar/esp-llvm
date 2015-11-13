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
class PDGNode;
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
  typedef std::map<const BasicBlock*, PDGNode* > BBtoCDSMap;
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
  const LoopInfo *LI;


  ~ProgramDependenceGraph();

  /// @name FunctionPass interface
  //@{
  virtual bool runOnFunction(Function &F);
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;
  //virtual void print(raw_ostream &OS, const Module *) const;
  //@}

};
class PDGNode {
public:
  const BasicBlock *bb;
  ProgramDependenceGraph::CDSet cds;
  std::set<std::pair<PDGNode*,bool> > children;
  ProgramDependenceGraph *parent;

  PDGNode(const BasicBlock *bb, ProgramDependenceGraph::CDSet cds, 
      ProgramDependenceGraph *parent):
    bb(bb), cds(cds), parent(parent) {}
  void addChild(std::pair<PDGNode*,bool> kid){
    children.insert(kid);
  }
};

class PDGChildIterator: public std::iterator<std::forward_iterator_tag, PDGNode, ptrdiff_t>
{
  typedef std::iterator<std::forward_iterator_tag, PDGNode, ptrdiff_t> super;

  PDGNode* Node;

  // The inner iterator.
  std::set<std::pair<PDGNode*,bool> >::iterator BItor;


public:
  typedef PDGChildIterator Self;

  typedef typename super::pointer pointer;

  /// @brief Create begin iterator of a RegionNode.
  inline PDGChildIterator(PDGNode* node)
    : Node(node), BItor(node->children.begin()) {}

  /// @brief Create an end iterator.
  inline PDGChildIterator(PDGNode* node, bool end)
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

class PDGNodeIterator: public std::iterator<std::forward_iterator_tag, PDGNode, ptrdiff_t>
{
  typedef std::iterator<std::forward_iterator_tag, PDGNode, ptrdiff_t> super;

  PDGNode* Node;

  // The BBMap iterator.
  ProgramDependenceGraph::BBtoCDSMap::iterator BItor;


public:
  typedef PDGNodeIterator Self;

  typedef typename super::pointer pointer;

  /// @brief Create begin iterator of a RegionNode.
  inline PDGNodeIterator(PDGNode* node, ProgramDependenceGraph *PDG)
    : Node(node), BItor(PDG->BBtoCDS.begin()) {}

  /// @brief Create an end iterator.
  inline PDGNodeIterator(PDGNode* node, ProgramDependenceGraph *PDG, bool)
    : Node(node), BItor(PDG->BBtoCDS.end()) {}

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


template <> struct GraphTraits<PDGNode*>{
  typedef PDGNode NodeType;
  typedef PDGChildIterator ChildIteratorType;

  static NodeType *getEntryNode(NodeType* N) { return N; } 

  static inline ChildIteratorType child_begin(NodeType *N) { 
    return PDGChildIterator(N);
  } 

  static inline ChildIteratorType child_end(NodeType *N) { 
    return PDGChildIterator(N,true);
  } 
};

template <> struct GraphTraits<ProgramDependenceGraph*>
 : public GraphTraits<PDGNode*>{

  static NodeType *getEntryNode(const ProgramDependenceGraph *PDG) {
    return PDG->BBtoCDS.begin()->second;
  }

  // nodes_iterator/begin/end - Allow iteration over all nodes in the graph
  typedef PDGNodeIterator nodes_iterator;

  static nodes_iterator nodes_begin(ProgramDependenceGraph *PDG) {
    return nodes_iterator(PDG->BBtoCDS.begin()->second, PDG); 
  }
  static nodes_iterator nodes_end  (ProgramDependenceGraph *PDG) {
    return nodes_iterator(PDG->BBtoCDS.begin()->second, PDG, true);
  }
};
} // End llvm namespace
#endif

