#include "RISCV.h"
#include "RISCVSubtarget.h"
#include "RISCVXhwachaUtilities.h"
#include "llvm/Analysis/Scalarization.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Analysis/ScalarEvolutionExpander.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/CallGraphSCCPass.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Pass.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineScalarization.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/PassSupport.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Target/TargetInstrInfo.h"
#include <algorithm>
#include <vector>

using namespace llvm;

#define DEBUG_TYPE "vfopt"

namespace llvm {
  ModulePass *createRISCVVectorFetchIROpt();
  void initializeRISCVVectorFetchIROptPass(PassRegistry&);
  MachineFunctionPass *createRISCVVectorFetchMachOpt();
  void initializeRISCVVectorFetchMachOptPass(PassRegistry&);
  MachineFunctionPass *createRISCVVectorFetchRegFix();
  void initializeRISCVVectorFetchRegFixPass(PassRegistry&);
  MachineFunctionPass *createRISCVVectorFetchPreEmitOpt();
  void initializeRISCVVectorFetchPreEmitOptPass(PassRegistry&);
}

namespace {
  struct RISCVVectorFetchIROpt : public ModulePass {
    Scalarization       *MS;
    ScalarEvolution     *SE;
    std::map<Instruction *, const SCEV *> addrs;
    std::map<Instruction *, const SCEV *> scalars;
  public:
    static char ID;

    explicit RISCVVectorFetchIROpt() : ModulePass(ID) {
      initializeRISCVVectorFetchIROptPass(*PassRegistry::getPassRegistry());
    }

    bool runOnSCC(CallGraphSCC &SCC);
    bool runOnModule(Module &M) override;

    const char *getPassName() const override { return "RISCV Vector Fetch IROpt"; }

    void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.addRequired<CallGraphWrapperPass>();
      AU.addRequired<Scalarization>();
      AU.addRequired<ScalarEvolution>();
      ModulePass::getAnalysisUsage(AU);
    }
    virtual CallGraphNode *processOpenCLKernel(Function *F);
    virtual CallGraphNode *VectorFetchOpt(CallGraphNode *CGN);
    virtual const SCEV *attemptToHoistOffset(const SCEV *&expr, const SCEV *&parent,
        bool *found, unsigned bytewidth, const SCEV **veidx, Function *F);
  };

}

namespace {
  struct RISCVVectorFetchMachOpt : public MachineFunctionPass {
    MachineScalarization       *MS;
    MachineProgramDependenceGraph *PDG;
    const RISCVInstrInfo     *TII;
    const TargetRegisterInfo *TRI;
    MachineRegisterInfo *MRI;
  public:
    static char ID;

    RISCVVectorFetchMachOpt() : MachineFunctionPass(ID) {
      initializeRISCVVectorFetchMachOptPass(*PassRegistry::getPassRegistry());
    }

    bool runOnMachineFunction(MachineFunction &MF) override;

    const char *getPassName() const override { return "RISCV Vector Fetch MachOpt"; }

    void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.addRequired<MachineProgramDependenceGraph>();
      AU.addRequired<MachineScalarization>();
      MachineFunctionPass::getAnalysisUsage(AU);
    }
    virtual void processOpenCLKernel(MachineFunction &MF, unsigned defPredReg);
    virtual void convertToPredicates(MachineFunction &MF, unsigned defPredReg);

    // Helper functions for vectorization
    virtual void vectorizeBinOp(MachineInstr *I, unsigned defPredReg,
        unsigned VVV, unsigned VVS, unsigned VSV,
        unsigned VSS, unsigned SSS);
    virtual void vectorizeFPBinOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
        unsigned VVV, unsigned VVS, unsigned VSV,
        unsigned VSS, unsigned SSS);
    virtual void vectorizeFPTriOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
        unsigned VVVV, unsigned VVVS, unsigned VVSV,
        unsigned VVSS, unsigned VSVV, unsigned VSVS, unsigned VSSV,
        unsigned VSSS, unsigned SSSS);
    virtual void vectorizeBinImmOp(MachineInstr *I, unsigned defPredReg,
        unsigned IMM, unsigned VSS, unsigned SSS);
    virtual void vectorizeLoadOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
        unsigned VEC, unsigned IDX, unsigned SCALAR);
    virtual void vectorizeStoreOp(MachineInstr *I, unsigned defPredReg,
        unsigned VEC, unsigned IDX);
    virtual void vectorizeCvtOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
        unsigned VV, unsigned VS, unsigned SS);
    virtual void vectorizeIntCvtOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
        unsigned VV, unsigned VS, unsigned SS);
    virtual unsigned getVectorCompareOp(MachineInstr *I, unsigned VV, unsigned VS, unsigned SV, unsigned SS);
  };

  char RISCVVectorFetchMachOpt::ID = 0;

} // end anonymous namespace

namespace {
  struct RISCVVectorFetchRegFix : public MachineFunctionPass {
    const RISCVInstrInfo     *TII;
    public:
      static char ID;
    RISCVVectorFetchRegFix() : MachineFunctionPass(ID) {
      initializeRISCVVectorFetchRegFixPass(*PassRegistry::getPassRegistry());
    }

    bool runOnMachineFunction(MachineFunction &MF) override;

    const char *getPassName() const override { return "RISCV Vector Fetch RegFix"; }

    void getAnalysisUsage(AnalysisUsage &AU) const override {
      MachineFunctionPass::getAnalysisUsage(AU);
    }
    virtual void changeToPostRegAllocVecInst(MachineInstr &MI);
  };
  char RISCVVectorFetchRegFix::ID = 0;
}

INITIALIZE_PASS(RISCVVectorFetchRegFix, "vfregfix", "RISCV Vector Fetch RegFix", false, false)

namespace {
  struct RISCVVectorFetchPreEmitOpt : public MachineFunctionPass {
    const RISCVInstrInfo     *TII;
    public:
      static char ID;
    RISCVVectorFetchPreEmitOpt() : MachineFunctionPass(ID) {
      initializeRISCVVectorFetchPreEmitOptPass(*PassRegistry::getPassRegistry());
    }

    bool runOnMachineFunction(MachineFunction &MF) override;

    const char *getPassName() const override { return "RISCV Vector Fetch PreEmitOpt"; }

    void getAnalysisUsage(AnalysisUsage &AU) const override {
      MachineFunctionPass::getAnalysisUsage(AU);
    }
  };
  char RISCVVectorFetchPreEmitOpt::ID = 0;
}

INITIALIZE_PASS(RISCVVectorFetchPreEmitOpt, "vfPreEmitOpt", "RISCV Vector Fetch PreEmitOpt", false, false)


char RISCVVectorFetchIROpt::ID = 0;
INITIALIZE_PASS_BEGIN(RISCVVectorFetchIROpt, "vfiropt",
                      "RISCV Vector Fetch IROpt", false, false)
INITIALIZE_PASS_DEPENDENCY(CallGraphWrapperPass)
INITIALIZE_PASS_DEPENDENCY(Scalarization)
INITIALIZE_PASS_DEPENDENCY(ScalarEvolution)
INITIALIZE_PASS_END(RISCVVectorFetchIROpt, "vfiropt",
                    "RISCV Vector Fetch IROpt", false, false)

ModulePass *llvm::createRISCVVectorFetchIROpt() {
  return new RISCVVectorFetchIROpt();
}
bool RISCVVectorFetchIROpt::runOnModule(Module &M) {
    M.dump();
    CallGraph& cg = getAnalysis<CallGraphWrapperPass>().getCallGraph();

    scc_iterator<CallGraph*> cgSccIter = scc_begin(&cg);
    CallGraphSCC curSCC(&cgSccIter);
    while (!cgSccIter.isAtEnd())
    {
        const std::vector<CallGraphNode*>& nodeVec = *cgSccIter;
        curSCC.initialize(nodeVec.data(), nodeVec.data() + nodeVec.size());
        runOnSCC(curSCC);
        ++cgSccIter;
    }

    M.dump();

    return false;
}
bool RISCVVectorFetchIROpt::runOnSCC(CallGraphSCC &SCC) {
  bool Changed = false;

  // Attempt to promote arguments from all functions in this SCC.
  for (CallGraphSCC::iterator I = SCC.begin(), E = SCC.end(); I != E; ++I) {
    if (CallGraphNode *CGN = VectorFetchOpt(*I)) {
      Changed = true;
      SCC.ReplaceNode(*I, CGN);
    }
  }
  return Changed;
}

CallGraphNode *RISCVVectorFetchIROpt::VectorFetchOpt(CallGraphNode *CGN) {
  Function *F = CGN->getFunction();

  if(!F) return nullptr;
  if(F->isIntrinsic()) return nullptr;
  MS = &getAnalysis<Scalarization>(*F);
  SE = &getAnalysis<ScalarEvolution>(*F);

  if(isOpenCLKernelFunction(*F)) {
    if (CallGraphNode *CGN = processOpenCLKernel(F)) {
      return CGN;
    }
    return nullptr;
  }
  return nullptr;
}

const SCEV *RISCVVectorFetchIROpt::attemptToHoistOffset(const SCEV *&expr, const SCEV *&parent, bool *found, unsigned bytewidth, const SCEV **veidx, Function *F) {
  //psuedo code
  // recursively descend looking for eidx
  // once found, while we are coming up the tree
  // + ignore the + nodes since hoisting veidx above them doesn't matter
  // + record the other input to the first * we encounter
  // + any more than one * and we fail
  // + any less than one * and we fail
  // + if the recorded input is not equal to the bytewidth we fail
  // Once we arrive at the root of the tree which needs to be an add node
  // + append the mul of eidx and recorded input as another input
  if(const SCEVAddExpr *add = dyn_cast<SCEVAddExpr>(expr)) {
    bool lfound = *found;
    SmallVector<const SCEV *, 8> newops;
    for( const SCEV *op : add->operands() ) {
      *found = false;
      const SCEV *subexp = attemptToHoistOffset(op, expr, found, bytewidth, veidx, F);
      if(subexp == SE->getCouldNotCompute()) return subexp;
      if(lfound && *found) {
        printf("two uses of veidx: can't hoist\n");
        return SE->getCouldNotCompute();
      }
      newops.push_back(subexp);
      if(*found) {
        if(parent == expr) { // root node
          // add the veidx and the op
          const SCEV *eidxExpr = SE->getMulExpr(*veidx,
              SE->getConstant(expr->getType(), bytewidth));
          //newops.push_back(eidxExpr);
        }
      }
      lfound = lfound || *found;
    }
    *found = lfound;
    return SE->getAddExpr(newops);
  } else if(const SCEVMulExpr *mul = dyn_cast<SCEVMulExpr>(expr)) {
    bool lfound = *found;
    SmallVector<const SCEV *, 8> newops;
    for( const SCEV *op : mul->operands() ) {
      *found = false;
      const SCEV *subexp = attemptToHoistOffset(op, expr, found, bytewidth, veidx, F);
      if(subexp == SE->getCouldNotCompute()) return subexp;
      if(lfound && *found) {
        printf("two uses of veidx: can't hoist\n");
        return SE->getCouldNotCompute();
      }
      newops.push_back(subexp);
      if(*found) {
        if(parent == expr) { // root node
          printf("require a non-zero base: can't hoist\n");
          return SE->getCouldNotCompute(); // root node can't be *
        }
        // check constant
        if(const SCEVConstant *num = dyn_cast<SCEVConstant>(mul->getOperand(0))){
          if(num != SE->getConstant(num->getType(), bytewidth)) {
            printf("require bytewidth multipler on eidx: can't hoist\n");
            return SE->getCouldNotCompute();
          }
        } else {
          printf("require constant as bytewidth: can't hoist\n");
          return SE->getCouldNotCompute();
        }
      }
      lfound = lfound || *found;
    }
    *found = lfound;
    return SE->getMulExpr(newops);
  } else if(const SCEVUnknown *eidx = dyn_cast<SCEVUnknown>(expr)) {
    // Note that we found it
    if(isa<IntrinsicInst>(eidx->getValue())) {
      if(cast<IntrinsicInst>(eidx->getValue())->getIntrinsicID() == Intrinsic::hwacha_veidx) {
        *found = true;
        *veidx = eidx;
        // Replace  with identity constant based on parent
        if(parent->getSCEVType() == scAddExpr) {
          return SE->getConstant(expr->getType(),0);
        } else if(parent->getSCEVType() == scMulExpr) {
          return SE->getConstant(expr->getType(),1);
        } else {
          return SE->getCouldNotCompute(); // TODO: do we need to handle casts
        }
      }
    } else if(isa<Argument>(eidx->getValue())) { //std::find(F->arg_begin(),F->arg_end(), eidx->getValue())) {
      return expr; // some argument to this function
    } else {
      return SE->getCouldNotCompute(); // not an arugment so we can't hoist
    }
  } else if(isa<SCEVConstant>(expr)) {
    return expr;
  } else if(const SCEVCastExpr *Cast = dyn_cast<SCEVCastExpr>(expr)) {
    bool lfound = *found;
    *found = false;
    const SCEV *op = Cast->getOperand();
    const SCEV *subexp = attemptToHoistOffset(op, expr, found, bytewidth, veidx, F);
    if(subexp == SE->getCouldNotCompute()) return subexp;
    if(*found) {
      printf("Cannot cast veidx: can't hoist\n");
      return SE->getCouldNotCompute();
    }
    *found = lfound;
    return expr;
  } else {
    return SE->getCouldNotCompute();
  }
}

CallGraphNode *RISCVVectorFetchIROpt::processOpenCLKernel(Function *F) {
  for(Function::iterator BBI = F->begin(), MBBE = F->end(); BBI != MBBE; ++BBI) {
    for(BasicBlock::iterator MII = BBI->begin(), MIE = BBI->end(); MII != MIE; ++MII) {
      if(isa<StoreInst>(MII)) {
        const SCEV *store = SE->getSCEV(cast<StoreInst>(MII)->getPointerOperand());
        printf("found store inst in opencl kernel, trying to hoist\n");
        MII->dump();
        store->dump();
        fflush(stdout);fflush(stderr);
        const SCEV *ptrBase = SE->getPointerBase(store);
        // We need a base addr to start with
        if(!isa<SCEVUnknown>(ptrBase)) {
          break;
        }
        // Descend through NAry ops building up a global addexpr
        // Goal is something like AddExpr(base, offset, MulExpr(eidx,bytewidth))
        // where offset is another potentially deep scev tree as long as it doesn't
        // have base or eidx
        bool found = false;
        const SCEV *veidx;
        const SCEV *newSCEV = attemptToHoistOffset(store, store, &found, MII->getOperand(0)->getType()->getPrimitiveSizeInBits()/8, &veidx, F);
        if(newSCEV != SE->getCouldNotCompute()){
          if(found) {
            addrs.insert(std::make_pair(MII, newSCEV));
            printf("HOISTED ADDR\n");fflush(stdout);fflush(stderr);
          } else { // entirely scalar memop so we hoist it differently
            // TODO: Hoisting scalar stores requires checking that all values
            // in SCEV are known at the call site
            scalars.insert(std::make_pair(MII, newSCEV));
            printf("HOISTED SCALAR\n");fflush(stdout);fflush(stderr);
          }
        }
      }
      if(isa<LoadInst>(MII)) {
        const SCEV *load = SE->getSCEV(cast<LoadInst>(MII)->getPointerOperand());
        printf("found load inst in opencl kernel, trying to hoist\n");
        MII->dump();
        load->dump();
        fflush(stdout);fflush(stderr);
        const SCEV *ptrBase = SE->getPointerBase(load);
        // We need a base addr to start with
        if(!isa<SCEVUnknown>(ptrBase)) {
          break;
        }
        // Descend through NAry ops building up a global addexpr
        // Goal is something like AddExpr(base, offset, MulExpr(eidx,bytewidth))
        // where offset is another potentially deep scev tree as long as it doesn't
        // have base or eidx
        bool found = false;
        const SCEV *veidx;
        const SCEV *newSCEV = attemptToHoistOffset(load, load, &found, MII->getType()->getPrimitiveSizeInBits()/8, &veidx, F);
        if(newSCEV != SE->getCouldNotCompute()){
          if(found) {
            addrs.insert(std::make_pair(MII, newSCEV));
            printf("HOISTED ADDR\n");fflush(stdout);fflush(stderr);
          } else { // entirely scalar memop so we hoist it differently
            scalars.insert(std::make_pair(MII, newSCEV));
            printf("HOISTED SCALAR\n");fflush(stdout);fflush(stderr);
          }
        }
      }
    }
  }
  // Update function type based on new arguments
  FunctionType *FTy = F->getFunctionType();
  std::vector<Type*> Params;
  Params.insert(Params.end(), FTy->param_begin(), FTy->param_end());
  for(std::map<Instruction *, const SCEV *>::iterator it = addrs.begin(); it != addrs.end(); ++it) {
    if(isa<LoadInst>(it->first))
      Params.push_back(it->first->getType()->getPointerTo());
    if(isa<StoreInst>(it->first))
      Params.push_back(it->first->getOperand(0)->getType()->getPointerTo());
  }
  for(std::map<Instruction *, const SCEV *>::iterator it = scalars.begin(); it != scalars.end(); ++it) {
    if(isa<LoadInst>(it->first))
      Params.push_back(it->first->getType()->getPointerTo());
  }
  Type *RetTy = FTy->getReturnType();

  // Create new function with additional args to replace old one
  FunctionType *NFTy = FunctionType::get(RetTy, Params, false);
  Function *NF = Function::Create(NFTy, Function::InternalLinkage, F->getName());
  NF->copyAttributesFrom(F);
  for(unsigned i = 1; i <= addrs.size(); i++) {
    NF->addAttribute(FTy->getNumParams()+i, Attribute::ByVal);
  }

  F->getParent()->getFunctionList().insert(F, NF);
  NF->takeName(F);
  // Get the callgraph information that we need to update to reflect our
  // changes.
  CallGraph &CG = getAnalysis<CallGraphWrapperPass>().getCallGraph();

  // Get a new callgraph node for NF.
  CallGraphNode *NF_CGN = CG.getOrInsertFunction(NF);

  // Loop over all of the callers of the function, transforming the call sites
  // to pass in the loaded pointers.
  //
  SmallVector<Value*, 16> Args;
  SmallVector<AttributeSet, 8> AttributesVec;
  while (!F->use_empty()) {
    CallSite CS(F->user_back());
    assert(CS.getCalledFunction() == F);
    Instruction *Call = CS.getInstruction();
    const AttributeSet &CallPAL = CS.getAttributes();

    // Add any return attributes.
    if (CallPAL.hasAttributes(AttributeSet::ReturnIndex))
      AttributesVec.push_back(AttributeSet::get(F->getContext(),
                                                CallPAL.getRetAttributes()));

    // Create callee.args => callsite.args map for parameter rewriter
    ValueToValueMap argMap;
    // Loop over the operands, inserting GEP and loads in the caller as
    // appropriate.
    CallSite::arg_iterator AI = CS.arg_begin();
    unsigned ArgIndex = 1;
    for (Function::arg_iterator I = F->arg_begin(), E = F->arg_end();
         I != E; ++I, ++AI, ++ArgIndex) {
      if(ArgIndex <= FTy->getNumParams()) {
        Args.push_back(*AI); // Old unchanged args
        argMap[I] = *AI;
      }
    }
    AttributeSet aregAttrs();
    // Create code to generate SCEV in map
    SCEVExpander Expander(*SE, F->getParent()->getDataLayout(), "vfoptexp");
    for(std::map<Instruction *, const SCEV *>::iterator it = addrs.begin(); it != addrs.end(); ++it) {
      const SCEV *newSCEV = SCEVParameterRewriter::rewrite(it->second, *SE, argMap);
      Value *base;
      if(isa<LoadInst>(it->first))
        base = Expander.expandCodeFor(newSCEV, it->first->getType()->getPointerTo(),Call);
      if(isa<StoreInst>(it->first))
        base = Expander.expandCodeFor(newSCEV, it->first->getOperand(0)->getType()->getPointerTo(),Call);
      Args.push_back(base);
    }
    for(std::map<Instruction *, const SCEV *>::iterator it = scalars.begin(); it != scalars.end(); ++it) {
      const SCEV *newSCEV = SCEVParameterRewriter::rewrite(it->second, *SE, argMap);
      Value *base;
      if(isa<LoadInst>(it->first))
        base = Expander.expandCodeFor(newSCEV, it->first->getType()->getPointerTo(),Call);
      Args.push_back(base);
    }

    Instruction *New = CallInst::Create(NF, Args, "", Call);
    cast<CallInst>(New)->setCallingConv(CS.getCallingConv());
    cast<CallInst>(New)->setAttributes(AttributeSet::get(New->getContext(),
                                                        AttributesVec));
    for(unsigned i = 0;i < addrs.size(); i++) {
      cast<CallInst>(New)->addAttribute(ArgIndex+i, Attribute::ByVal);
    }
    if (cast<CallInst>(Call)->isTailCall())
      cast<CallInst>(New)->setTailCall();

    New->setDebugLoc(Call->getDebugLoc());
    Args.clear();
    AttributesVec.clear();
    // Update the callgraph to know that the callsite has been transformed.
    CallGraphNode *CalleeNode = CG[Call->getParent()->getParent()];
    CalleeNode->replaceCallEdge(CS, CallSite(New), NF_CGN);

    //migrate all named metadata
    llvm::NamedMDNode *nmd = F->getParent()->getNamedMetadata("opencl.kernels");
    for (unsigned i = 0, e = nmd->getNumOperands(); i != e; ++i) {
      MDNode *kernel_iter = nmd->getOperand(i);
      Function *k =
        cast<Function>(
          dyn_cast<ValueAsMetadata>(kernel_iter->getOperand(0))->getValue());
      if (k->getName() == F->getName()) {
        kernel_iter->replaceOperandWith(0, llvm::ValueAsMetadata::get(NF));
      }
    }

    if (!Call->use_empty()) {
      Call->replaceAllUsesWith(New);
      New->takeName(Call);
    }

    // Finally, remove the old call from the program, reducing the use-count of
    // F.
    Call->eraseFromParent();
  }
  // Since we have now created the new function, splice the body of the old
  // function right into the new function, leaving the old rotting hulk of the
  // function empty.
  NF->getBasicBlockList().splice(NF->begin(), F->getBasicBlockList());

  // Loop over the argument list, transferring uses of the old arguments over to
  // the new arguments, also transferring over the names as well.
  Function::arg_iterator I2 = NF->arg_begin();
  for (Function::arg_iterator I = F->arg_begin(), E = F->arg_end(); I != E; ++I) {
    // This is an unmodified argument, move the name and users over to the
    // new version.
    I->replaceAllUsesWith(I2);
    I2->takeName(I);
    ++I2;
    continue;
  }
  // Loop over the remaining args createing new loads to use the
  for(std::map<Instruction *, const SCEV *>::iterator it = addrs.begin(); it != addrs.end(); ++it) {

    Instruction *newMemOp;
    if(isa<LoadInst>(it->first)) {
      newMemOp = new LoadInst(I2, "vec_addr_base", it->first);
    }
    if(isa<StoreInst>(it->first)) {
      newMemOp = new StoreInst(it->first->getOperand(0), I2, "vec_addr_base", it->first);
    }
    it->first->replaceAllUsesWith(newMemOp);
    newMemOp->takeName(it->first);
    it->first->eraseFromParent();
    ++I2;
  }
  for(std::map<Instruction *, const SCEV *>::iterator it = scalars.begin(); it != scalars.end(); ++it) {
    Instruction *newMemOp;
    if(isa<LoadInst>(it->first)) {
      newMemOp = new LoadInst(I2, "vec_addr_base", it->first);
      it->first->replaceAllUsesWith(newMemOp);
      newMemOp->takeName(it->first);
      it->first->eraseFromParent();
    }
    ++I2;
  }
  // iterate of instruction in addr doing a few things
  // 1) add another argument for the address to be passed
  // 2) replace the memop with one that uses this new argument
  // 3) TODO: figure out how to ensure the new args are in va regs

  NF_CGN->stealCalledFunctionsFrom(CG[F]);

  // Now that the old function is dead, delete it.  If there is a dangling
  // reference to the CallgraphNode, just leave the dead function around for
  // someone else to nuke.
  CallGraphNode *CGN = CG[F];
  if (CGN->getNumReferences() == 0)
    delete CG.removeFunctionFromModule(CGN);
  else
    F->setLinkage(Function::ExternalLinkage);

  return NF_CGN;
}

INITIALIZE_PASS_BEGIN(RISCVVectorFetchMachOpt, "vfmachopt",
                      "RISCV Vector Fetch MachOpt", false, false)
INITIALIZE_PASS_DEPENDENCY(MachineScalarization)
INITIALIZE_PASS_END(RISCVVectorFetchMachOpt, "vfmachopt",
                    "RISCV Vector Fetch MachOpt", false, false)

MachineFunctionPass *llvm::createRISCVVectorFetchMachOpt() {
  return new RISCVVectorFetchMachOpt();
}

bool RISCVVectorFetchMachOpt::runOnMachineFunction(MachineFunction &MF) {
  bool Changed = false;

  MS = &getAnalysis<MachineScalarization>();
  PDG = &getAnalysis<MachineProgramDependenceGraph>();
  TII = MF.getSubtarget<RISCVSubtarget>().getInstrInfo();
  TRI = MF.getSubtarget().getRegisterInfo();
  MRI = &MF.getRegInfo();

  if(isOpenCLKernelFunction(*(MF.getFunction()))) {
    unsigned defPredReg = MRI->createVirtualRegister(&RISCV::VPRBitRegClass);
    processOpenCLKernel(MF, defPredReg);
    convertToPredicates(MF, defPredReg);
  }

  return Changed;
}

void RISCVVectorFetchMachOpt::vectorizeBinOp(MachineInstr *I, unsigned defPredReg,
    unsigned VVV, unsigned VVS, unsigned VSV, unsigned VSS, unsigned SSS) {
  if(TRI->isPhysicalRegister(I->getOperand(1).getReg())) {
    //Can only handle zero case
    assert((I->getOperand(1).getReg() == RISCV::zero ||
            I->getOperand(1).getReg() == RISCV::zero_64) &&
           "Cannot convert binop with phys reg arg that is non zero");
    I->getOperand(1).setReg(RISCV::vs0);
    if(MS->invar[I]) {
      I->setDesc(TII->get(SSS));
      MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
    } else {
      if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
        I->setDesc(TII->get(VSS));
      } else {
        I->setDesc(TII->get(VSV));
      }
      // Destination is always vector
      MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
      I->addOperand(MachineOperand::CreateImm(0));
      I->addOperand(MachineOperand::CreateReg(defPredReg, false));
    }
  } else if(TRI->isPhysicalRegister(I->getOperand(2).getReg())) {
    //Can only handle zero case
    assert((I->getOperand(2).getReg() == RISCV::zero ||
            I->getOperand(2).getReg() == RISCV::zero_64) &&
           "Cannot convert binop with phys reg arg that is non zero");
    I->getOperand(2).setReg(RISCV::vs0);
    if(MS->invar[I]) {
      I->setDesc(TII->get(SSS));
      MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
    } else {
      if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
        I->setDesc(TII->get(VSS));
      } else {
        I->setDesc(TII->get(VVS));
      }
      // Destination is always vector
      MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
      I->addOperand(MachineOperand::CreateImm(0));
      I->addOperand(MachineOperand::CreateReg(defPredReg, false));
    }
  } else if(MS->invar[I]) {
    I->setDesc(TII->get(SSS));
    MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
  } else {
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
      if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
        I->setDesc(TII->get(VSS));
      } else {
        I->setDesc(TII->get(VSV));
      }
    } else {
      if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
        I->setDesc(TII->get(VVS));
      } else {
        I->setDesc(TII->get(VVV));
      }
    }
    // Destination is always vector
    MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  }
}

void RISCVVectorFetchMachOpt::vectorizeFPBinOp(MachineInstr *I,
    const TargetRegisterClass *destRC, unsigned defPredReg,
    unsigned VVV, unsigned VVS, unsigned VSV, unsigned VSS, unsigned SSS) {
  const TargetRegisterClass *destClass = destRC;
  if(MS->invar[I]) {
    //if we were invariant but have a vector src it means there was a vector load
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
       MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
      destClass = &RISCV::VVRBitRegClass;
    } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
              MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass) {
      destClass = &RISCV::VVWBitRegClass;
    } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
              MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass) {
      destClass = &RISCV::VVHBitRegClass;
    } else
      destClass = &RISCV::VSRBitRegClass;
  }
  if(destClass == &RISCV::VVRBitRegClass ||
     destClass == &RISCV::VVWBitRegClass ||
     destClass == &RISCV::VVHBitRegClass) {
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
      if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
        I->setDesc(TII->get(VSS));
      } else {
        I->setDesc(TII->get(VSV));
      }
    } else {
      if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
        I->setDesc(TII->get(VVS));
      } else {
        I->setDesc(TII->get(VVV));
      }
    }
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  } else {
    I->setDesc(TII->get(SSS));
  }
  MRI->setRegClass(I->getOperand(0).getReg(), destClass);
}

void RISCVVectorFetchMachOpt::vectorizeFPTriOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
        unsigned VVVV, unsigned VVVS, unsigned VVSV,
        unsigned VVSS, unsigned VSVV, unsigned VSVS, unsigned VSSV,
        unsigned VSSS, unsigned SSSS) {
  const TargetRegisterClass *destClass = destRC;
  if(MS->invar[I]) {
    //if we were invariant but have a vector src it means there was a vector load
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
       MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass ||
       MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VVRBitRegClass) {
      destClass = &RISCV::VVRBitRegClass;
    } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
              MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass ||
              MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VVWBitRegClass) {
      destClass = &RISCV::VVWBitRegClass;
    } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
              MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass ||
              MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VVHBitRegClass) {
      destClass = &RISCV::VVHBitRegClass;
    } else
      destClass = &RISCV::VSRBitRegClass;
  }
  if(destClass == &RISCV::VVRBitRegClass ||
     destClass == &RISCV::VVWBitRegClass ||
     destClass == &RISCV::VVHBitRegClass) {
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
      if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
        if(MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
          I->setDesc(TII->get(VSSS));
        } else {
          I->setDesc(TII->get(VSSV));
        }
      } else {
        if(MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
          I->setDesc(TII->get(VSVS));
        } else {
          I->setDesc(TII->get(VSVV));
        }
      }
    } else {
      if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
        if(MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
          I->setDesc(TII->get(VVSS));
        } else {
          I->setDesc(TII->get(VVSV));
        }
      } else {
        if(MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
          I->setDesc(TII->get(VVVS));
        } else {
          I->setDesc(TII->get(VVVV));
        }
      }
    }
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  } else {
    I->setDesc(TII->get(SSSS));
  }
  MRI->setRegClass(I->getOperand(0).getReg(), destClass);
}

void RISCVVectorFetchMachOpt::vectorizeBinImmOp(MachineInstr *I, unsigned defPredReg,
    unsigned IMM, unsigned VVS, unsigned SSS) {
  if(MS->invar[I]) {
    // Generate one instruction
    // vADDi vsdest, vssrc, imm
    I->setDesc(TII->get(IMM));
    MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
  } else {
    // Generate two instructions
    // 1. vaddi vstemp, vs0, imm
    unsigned vstemp = MRI->createVirtualRegister(&RISCV::VSRBitRegClass);
    MachineOperand &imm = I->getOperand(2);
    BuildMI(*I->getParent(), I, I->getDebugLoc(), TII->get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
    // 1. vADD vvdest, vssrc, vstemp
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
      I->setDesc(TII->get(SSS));
      MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
    } else {
      I->setDesc(TII->get(VVS));
      MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
      I->addOperand(MachineOperand::CreateImm(0));
      I->addOperand(MachineOperand::CreateReg(defPredReg, false));
    }
    I->getOperand(2).ChangeToRegister(vstemp, false);
  }
}

void RISCVVectorFetchMachOpt::vectorizeLoadOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
    unsigned VEC, unsigned IDX, unsigned SCALAR) {
  //TODO: support invariant memops becoming scalar memops
  if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
    I->setDesc(TII->get(VEC));
    MRI->setRegClass(I->getOperand(0).getReg(), destRC);
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
    I->setDesc(TII->get(SCALAR));
    MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
  } else {
    I->setDesc(TII->get(IDX));
    // Destination is always vector
    MRI->setRegClass(I->getOperand(0).getReg(), destRC);
    // Shift vector portion to second src
    I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
    I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  }
}

void RISCVVectorFetchMachOpt::vectorizeStoreOp(MachineInstr *I, unsigned defPredReg,
    unsigned VEC, unsigned IDX) {
  //TODO: support invariant memops becoming scalar memops
  if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
    I->setDesc(TII->get(VEC));
    I->RemoveOperand(2);
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  } else {
    I->setDesc(TII->get(IDX));
    // Shift vector portion to second src
    I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
    I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  }
}

void RISCVVectorFetchMachOpt::vectorizeCvtOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
    unsigned VV, unsigned VS, unsigned SS) {
  const TargetRegisterClass *destClass = destRC;
  if(MS->invar[I]) {
    //if we were invariant but have a vector src it means there was a vector load
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass) {
      destClass = destRC;
    } else
      destClass = &RISCV::VSRBitRegClass;
  }
  if(destClass == destRC) {
    if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
      I->setDesc(TII->get(VS));
    } else {
      I->setDesc(TII->get(VV));
    }
    I->addOperand(MachineOperand::CreateImm(0));
    I->addOperand(MachineOperand::CreateReg(defPredReg, false));
  } else {
    I->setDesc(TII->get(SS));
  }
  MRI->setRegClass(I->getOperand(0).getReg(), destClass);
}

void RISCVVectorFetchMachOpt::vectorizeIntCvtOp(MachineInstr *I, const TargetRegisterClass *destRC, unsigned defPredReg,
    unsigned VV, unsigned VS, unsigned SS) {
  if(TRI->isPhysicalRegister(I->getOperand(1).getReg())) {
    //handle cvt from zero specially
    assert((I->getOperand(1).getReg() == RISCV::zero) &&
           "Cannot convert op with phys reg arg that is non zero");
    I->setDesc(TII->get(SS));
    MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
    I->getOperand(1).setReg(RISCV::vs0);
    return;
  }
  vectorizeCvtOp(I, destRC, defPredReg, VV, VS, SS);
}

unsigned RISCVVectorFetchMachOpt::getVectorCompareOp(MachineInstr *I, unsigned VV, unsigned VS, unsigned SV, unsigned SS) {
  if(TRI->isPhysicalRegister(I->getOperand(1).getReg())) {
    assert(I->getOperand(1).getReg() == RISCV::vs0);
    if(TRI->isPhysicalRegister(I->getOperand(2).getReg())) {
      assert(I->getOperand(2).getReg() == RISCV::vs0);
      return SS;
    } else if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
      return SS;
    } else {
      return SV;
    }
  } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass){
    if(TRI->isPhysicalRegister(I->getOperand(2).getReg())) {
      assert(I->getOperand(2).getReg() == RISCV::vs0);
      return SS;
    } else if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
      return SS;
    } else {
      return SV;
    }
  } else {
    if(TRI->isPhysicalRegister(I->getOperand(2).getReg())) {
      assert(I->getOperand(2).getReg() == RISCV::vs0);
      return VS;
    } else if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
      return VS;
    } else {
      return VV;
    }
  }
}

void RISCVVectorFetchMachOpt::processOpenCLKernel(MachineFunction &MF, unsigned defPredReg) {
  std::vector<unsigned> vregs;
  // add vpset vp0 at start of function
  MachineBasicBlock &entryBlock = MF.front();
  MachineBasicBlock::iterator entryBegin = entryBlock.begin();
  DebugLoc entryDL = entryBegin != entryBlock.end() ? entryBegin->getDebugLoc() : DebugLoc();
  BuildMI(entryBlock, entryBegin, entryDL, TII->get(RISCV::VPSET), defPredReg);
  for (MachineFunction::iterator MFI = MF.begin(), MFE = MF.end(); MFI != MFE;
       ++MFI) {
    vregs.clear();
    // In each BB change each instruction
    for (MachineBasicBlock::iterator I = MFI->begin(); I != MFI->end(); ++I) {
      printf("Inst:");I->dump();fflush(stdout);fflush(stderr);
      printf("invar?%d\n",MS->invar[I]);fflush(stdout);fflush(stderr);
      // All inputs are vs registers and outputs are vv registers
      switch(I->getOpcode()) {
        case TargetOpcode::COPY : // TODO: look at whether to copy into different reg class based on subreg
          // If this is physical to virt copy do nothing
          if(TRI->isPhysicalRegister(I->getOperand(1).getReg())) {
            if(RISCV::VARBitRegClass.contains(I->getOperand(1).getReg()))
              MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VARBitRegClass);
            if(I->getOperand(1).getReg() == RISCV::zero || I->getOperand(1).getReg() == RISCV::zero_64) {
              I->getOperand(1).setReg(RISCV::vs0);
              MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            }

            continue;
          }
          if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass ||
             MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass ||
             MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
             MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
             MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass
              ) {
            MRI->setRegClass(I->getOperand(0).getReg(),
              MRI->getRegClass(I->getOperand(1).getReg()));
            I->getOperand(1).setSubReg(0); // v registers hold all values with no sub regs for now
          }
          continue;
        case TargetOpcode::SUBREG_TO_REG :// v registers hold all values with no sub regs for now
          if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass ||
             MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VARBitRegClass ||
             MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass ||
             MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass ||
             MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass
              ) {
            //turn in into a copy
            unsigned srcReg = I->getOperand(2).getReg();
            MRI->setRegClass(I->getOperand(0).getReg(),
              MRI->getRegClass(I->getOperand(2).getReg()));
            I->RemoveOperand(3);
            I->RemoveOperand(2);
            I->RemoveOperand(1);
            I->addOperand(MachineOperand::CreateReg(srcReg, false));
            I->setDesc(TII->get(TargetOpcode::COPY));
          }
          continue;
        case TargetOpcode::PHI :
          // Phi nodes may be muxing scalar and vector inputs so we need to move scalar values into vectors
          // But since Phi nodes need to be first in the basic block we should find
          // where this operand is defined, and insert the vadd there.
          if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass &&
             MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass){
            MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            continue;
          } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass &&
             MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VVRBitRegClass){
            MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            continue;
          // In the remaining cases we should consider normal scalar registers to also be VSRs
          // This case showed up when we had backwards branches to the same BB.
          } else if(MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass ||
                    MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::GR32BitRegClass ||
                    MRI->getRegClass(I->getOperand(1).getReg()) == &RISCV::GR64BitRegClass){
            assert(MRI->hasOneDef(I->getOperand(1).getReg()) && "vsreg has more than one def");
            const TargetRegisterClass *otherClass = MRI->getRegClass(I->getOperand(3).getReg());
            if(otherClass == &RISCV::GR32BitRegClass || otherClass == &RISCV::GR64BitRegClass) {
              MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
              continue;
            }
            MRI->setRegClass(I->getOperand(1).getReg(), &RISCV::VSRBitRegClass);
            for(MachineInstr &def : MRI->def_instructions(I->getOperand(1).getReg())) {
              unsigned vstemp = MRI->createVirtualRegister(otherClass);
              // TODO: we could propogate this info the source folding this add with another operation perhaps
              MachineBasicBlock::iterator defI = def.getParent()->getFirstTerminator();
              if(defI == def.getParent()->end())
                defI = std::prev(defI);
              MachineInstrBuilder b;
              if(&def == defI) // only instruction is the def itself so put it at the end of the block
                b = BuildMI(def.getParent(), def.getDebugLoc(), TII->get(RISCV::VADD_VSS), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(1).getReg());
              else
                b = BuildMI(*(def.getParent()), defI, def.getDebugLoc(), TII->get(RISCV::VADD_VSS), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(1).getReg());
              b.addImm(0).addReg(defPredReg);
              I->getOperand(1).setReg(vstemp);
            }
            MRI->setRegClass(I->getOperand(0).getReg(), otherClass);
          } else if(MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass ||
                    MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::GR32BitRegClass ||
                    MRI->getRegClass(I->getOperand(3).getReg()) == &RISCV::GR64BitRegClass){
            assert(MRI->hasOneDef(I->getOperand(3).getReg()) && "vsreg has more than one def");
            const TargetRegisterClass *otherClass = MRI->getRegClass(I->getOperand(1).getReg());
            unsigned opcode = RISCV::VADD_VSS;
            if(otherClass == &RISCV::GR32BitRegClass || otherClass == &RISCV::GR64BitRegClass) {
              MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
              continue;
            }
            MRI->setRegClass(I->getOperand(3).getReg(), &RISCV::VSRBitRegClass);
            for(MachineInstr &def : MRI->def_instructions(I->getOperand(3).getReg())) {
              unsigned vstemp = MRI->createVirtualRegister(otherClass);
              // TODO: we could propogate this info the source folding this add with another operation perhaps
              MachineBasicBlock::iterator defI = def.getParent()->getFirstTerminator();
              if(defI == def.getParent()->end())
                defI = std::prev(defI);
              MachineInstrBuilder b;
              if(&def == defI) // only instruction is the def itself so put it at the end of the block
                b = BuildMI(def.getParent(), def.getDebugLoc(), TII->get(opcode), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(3).getReg());
              else
                b = BuildMI(*(def.getParent()), defI, def.getDebugLoc(), TII->get(opcode), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(3).getReg());
              b.addImm(0).addReg(defPredReg);
              I->getOperand(3).setReg(vstemp);
            }
            MRI->setRegClass(I->getOperand(0).getReg(), otherClass);
          }
          continue;
        case RISCV::ADD64 :
          vectorizeBinOp(I, defPredReg,
              RISCV::VADD_VVV, RISCV::VADD_VVS, RISCV::VADD_VSV,
              RISCV::VADD_VSS, RISCV::VADD_SSS);
          continue;
        case RISCV::SUB64 :
          vectorizeBinOp(I, defPredReg,
              RISCV::VSUB_VVV, RISCV::VSUB_VVS, RISCV::VSUB_VSV,
              RISCV::VSUB_VSS, RISCV::VSUB_SSS);
          continue;
        case RISCV::MUL64 :
          vectorizeBinOp(I, defPredReg,
              RISCV::VMUL_VVV, RISCV::VMUL_VVS, RISCV::VMUL_VSV,
              RISCV::VMUL_VSS, RISCV::VMUL_SSS);
          continue;
        case RISCV::SLT :
        case RISCV::SLT64 :
          vectorizeBinOp(I, defPredReg,
              RISCV::VSLT_VVV, RISCV::VSLT_VVS, RISCV::VSLT_VSV,
              RISCV::VSLT_VSS, RISCV::VSLT_SSS);
          continue;
        case RISCV::ADDW :
          vectorizeBinOp(I, defPredReg,
              RISCV::VADDW_VVV, RISCV::VADDW_VVS, RISCV::VADDW_VSV,
              RISCV::VADDW_VSS, RISCV::VADDW_SSS);
          continue;
        case RISCV::SUBW :
          vectorizeBinOp(I, defPredReg,
              RISCV::VSUBW_VVV, RISCV::VSUBW_VVS, RISCV::VSUBW_VSV,
              RISCV::VSUBW_VSS, RISCV::VSUBW_SSS);
          continue;
        case RISCV::MULW :
          vectorizeBinOp(I, defPredReg,
              RISCV::VMULW_VVV, RISCV::VMULW_VVS, RISCV::VMULW_VSV,
              RISCV::VMULW_VSS, RISCV::VMULW_SSS);
          continue;
        case RISCV::LI64:
        case RISCV::LI:
          {
          int64_t imm = I->getOperand(1).getImm();
          I->setDesc(TII->get(RISCV::VADDI));
          I->RemoveOperand(1);
          I->addOperand(MF, MachineOperand::CreateReg(RISCV::vs0, false));
          I->addOperand(MF, MachineOperand::CreateImm(imm));
          MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          }
          continue;
        case RISCV::LUI64:
        case RISCV::LUI:
          {
          I->setDesc(TII->get(RISCV::VLUI));
          MRI->setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          }
          continue;
        case RISCV::ADDI64 :
          vectorizeBinImmOp(I, defPredReg, RISCV::VADDI,
              RISCV::VADD_VVS, RISCV::VADD_SSS);
          continue;
        case RISCV::SLTI64 :
        case RISCV::SLTI:
          vectorizeBinImmOp(I, defPredReg, RISCV::VSLTI,
              RISCV::VSLT_VVS, RISCV::VSLT_SSS);
          continue;
        case RISCV::SLLIW :
        case RISCV::SLLIW64 :
          vectorizeBinImmOp(I, defPredReg, RISCV::VSLLIW,
              RISCV::VSLLW_VVS, RISCV::VSLLW_SSS);
          continue;
        case RISCV::SLLI :
        case RISCV::SLLI64 :
          vectorizeBinImmOp(I, defPredReg, RISCV::VSLLI,
              RISCV::VSLL_VVS, RISCV::VSLL_SSS);
          continue;
        case RISCV::SRLI64 :
          vectorizeBinImmOp(I, defPredReg, RISCV::VSRLI,
              RISCV::VSRL_VVS, RISCV::VSRL_SSS);
          continue;
        case RISCV::SRAI64 :
          vectorizeBinImmOp(I, defPredReg, RISCV::VSRAI,
              RISCV::VSRA_VVS, RISCV::VSRA_SSS);
          continue;
        case RISCV::ADDIW :
          vectorizeBinImmOp(I, defPredReg, RISCV::VADDIW,
              RISCV::VADDW_VVS, RISCV::VADDW_SSS);
          continue;
        case RISCV::SRAIW :
        case RISCV::SRAIW64 :
          vectorizeBinImmOp(I, defPredReg, RISCV::VSRAIW,
              RISCV::VSRAW_VVS, RISCV::VSRAW_SSS);
          continue;
        case RISCV::FLH64 :
          vectorizeLoadOp(I, &RISCV::VVHBitRegClass, defPredReg,
              RISCV::VLH_F, RISCV::VLXH_F, RISCV::VLSH_F);
          continue;
        case RISCV::FLW64 :
          vectorizeLoadOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VLW_F, RISCV::VLXW_F, RISCV::VLSW_F);
          continue;
        case RISCV::FLD64 :
          vectorizeLoadOp(I, &RISCV::VVRBitRegClass, defPredReg,
              RISCV::VLD_F, RISCV::VLXD_F, RISCV::VLSD_F);
          continue;
        case RISCV::LHU64 :
        case RISCV::LHU64_32 :
          vectorizeLoadOp(I, &RISCV::VVHBitRegClass, defPredReg,
              RISCV::VLHU, RISCV::VLXHU, RISCV::VLSHU);
          continue;
        case RISCV::LW64 :
        case RISCV::LW64_32 :
          vectorizeLoadOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VLW, RISCV::VLXW, RISCV::VLSW);
          continue;
        case RISCV::FSD64 :
          vectorizeStoreOp(I, defPredReg,
              RISCV::VSD_F, RISCV::VSXD_F);
          continue;
        case RISCV::FSW64 :
          vectorizeStoreOp(I, defPredReg,
              RISCV::VSW_F, RISCV::VSXW_F);
          continue;
        case RISCV::FSH64 :
          vectorizeStoreOp(I, defPredReg,
              RISCV::VSH_F, RISCV::VSXH_F);
          continue;
        case RISCV::SW64 :
          vectorizeStoreOp(I, defPredReg,
              RISCV::VSW, RISCV::VSXW);
          continue;
        case RISCV::FCVT_S_D_RDY :
          vectorizeCvtOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFCVT_S_D_RDY_VV, RISCV::VFCVT_S_D_RDY_VS,
              RISCV::VFCVT_S_D_RDY_SS);
          continue;
        case RISCV::FCVT_S_W_RDY :
          vectorizeIntCvtOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFCVT_S_W_RDY_VV, RISCV::VFCVT_S_W_RDY_VS,
              RISCV::VFCVT_S_W_RDY_SS);
          continue;
        case RISCV::FCVT_D_S_RDY :
          vectorizeCvtOp(I, &RISCV::VVRBitRegClass, defPredReg,
              RISCV::VFCVT_D_S_RDY_VV, RISCV::VFCVT_D_S_RDY_VS,
              RISCV::VFCVT_D_S_RDY_SS);
          continue;
        case RISCV::FCVT_H_S_RDY :
          vectorizeCvtOp(I, &RISCV::VVHBitRegClass, defPredReg,
              RISCV::VFCVT_H_S_RDY_VV, RISCV::VFCVT_H_S_RDY_VS,
              RISCV::VFCVT_H_S_RDY_SS);
          continue;
        case RISCV::FCVT_S_H_RDY :
          vectorizeCvtOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFCVT_S_H_RDY_VV, RISCV::VFCVT_S_H_RDY_VS,
              RISCV::VFCVT_S_H_RDY_SS);
          continue;
        case RISCV::FADD_D_RDY :
          vectorizeFPBinOp(I, &RISCV::VVRBitRegClass, defPredReg,
              RISCV::VFADD_D_RDY_VVV, RISCV::VFADD_D_RDY_VVS, RISCV::VFADD_D_RDY_VSV,
              RISCV::VFADD_D_RDY_VSS, RISCV::VFADD_D_RDY_SSS);
          continue;
        case RISCV::FSUB_D_RDY :
          vectorizeFPBinOp(I, &RISCV::VVRBitRegClass, defPredReg,
              RISCV::VFSUB_D_RDY_VVV, RISCV::VFSUB_D_RDY_VVS, RISCV::VFSUB_D_RDY_VSV,
              RISCV::VFSUB_D_RDY_VSS, RISCV::VFSUB_D_RDY_SSS);
          continue;
        case RISCV::FMUL_D_RDY :
          vectorizeFPBinOp(I, &RISCV::VVRBitRegClass, defPredReg,
              RISCV::VFMUL_D_RDY_VVV, RISCV::VFMUL_D_RDY_VVS, RISCV::VFMUL_D_RDY_VSV,
              RISCV::VFMUL_D_RDY_VSS, RISCV::VFMUL_D_RDY_SSS);
          continue;
        case RISCV::FADD_S_RDY :
          vectorizeFPBinOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFADD_S_RDY_VVV, RISCV::VFADD_S_RDY_VVS, RISCV::VFADD_S_RDY_VSV,
              RISCV::VFADD_S_RDY_VSS, RISCV::VFADD_S_RDY_SSS);
          continue;
        case RISCV::FSUB_S_RDY :
          vectorizeFPBinOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFSUB_S_RDY_VVV, RISCV::VFSUB_S_RDY_VVS, RISCV::VFSUB_S_RDY_VSV,
              RISCV::VFSUB_S_RDY_VSS, RISCV::VFSUB_S_RDY_SSS);
          continue;
        case RISCV::FMUL_S_RDY :
          vectorizeFPBinOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFMUL_S_RDY_VVV, RISCV::VFMUL_S_RDY_VVS, RISCV::VFMUL_S_RDY_VSV,
              RISCV::VFMUL_S_RDY_VSS, RISCV::VFMUL_S_RDY_SSS);
          continue;
        case RISCV::FDIV_S_RDY :
          vectorizeFPBinOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFDIV_S_RDY_VVV, RISCV::VFDIV_S_RDY_VVS, RISCV::VFDIV_S_RDY_VSV,
              RISCV::VFDIV_S_RDY_VSS, RISCV::VFDIV_S_RDY_SSS);
          continue;
        case RISCV::FMADD_S_RDY :
          vectorizeFPTriOp(I, &RISCV::VVWBitRegClass, defPredReg,
              RISCV::VFMADD_S_RDY_VVVV, RISCV::VFMADD_S_RDY_VVVS,
              RISCV::VFMADD_S_RDY_VVSV, RISCV::VFMADD_S_RDY_VVSS,
              RISCV::VFMADD_S_RDY_VSVV, RISCV::VFMADD_S_RDY_VSVS,
              RISCV::VFMADD_S_RDY_VSSV, RISCV::VFMADD_S_RDY_VSSS,
              RISCV::VFMADD_S_RDY_SSSS);
          continue;
        case RISCV::FMADD_D_RDY :
          vectorizeFPTriOp(I, &RISCV::VVRBitRegClass, defPredReg,
              RISCV::VFMADD_D_RDY_VVVV, RISCV::VFMADD_D_RDY_VVVS,
              RISCV::VFMADD_D_RDY_VVSV, RISCV::VFMADD_D_RDY_VVSS,
              RISCV::VFMADD_D_RDY_VSVV, RISCV::VFMADD_D_RDY_VSVS,
              RISCV::VFMADD_D_RDY_VSSV, RISCV::VFMADD_D_RDY_VSSS,
              RISCV::VFMADD_D_RDY_SSSS);
          continue;
        case RISCV::RET :
          I->setDesc(TII->get(RISCV::VSTOP));
          I->RemoveOperand(1);
          I->RemoveOperand(0);
          continue;
        // check that previously added vector copies for phi's are still correct
        case RISCV::VADD_VSS:
          if(I->getOperand(1).getReg() == RISCV::vs0) {
            if(MRI->getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
              I->setDesc(TII->get(RISCV::VADD_VSV));
            }
          }
        case RISCV::BEQ64:
        case RISCV::BEQ:
        case RISCV::BLT64:
        case RISCV::BLT:
        case RISCV::BLTU64:
        case RISCV::BLTU:
        case RISCV::BGT64:
        case RISCV::BGT:
        case RISCV::BGTU64:
        case RISCV::BGTU:
        case RISCV::BNE64:
        case RISCV::BNE:
        case RISCV::BGE64:
        case RISCV::BGE:
        case RISCV::BGEU64:
        case RISCV::BGEU:
        case RISCV::BLE64:
        case RISCV::BLE:
        case RISCV::BLEU64:
        case RISCV::BLEU:
          if(I->getOperand(1).getReg() == RISCV::zero ||
              I->getOperand(1).getReg() == RISCV::zero_64) {
            I->getOperand(1).setReg(RISCV::vs0);
          }
          if(I->getOperand(2).getReg() == RISCV::zero ||
              I->getOperand(2).getReg() == RISCV::zero_64) {
            I->getOperand(2).setReg(RISCV::vs0);
          }
          // VCMP will be inserted before each branch in a different pass
          // which will then convert the branch to a VCJAL
          continue;
        case RISCV::J:
        case RISCV::J64:
        case RISCV::JAL:
        case RISCV::JAL64:
          {
          // Insert VCJAL to be fixed up later
          BuildMI(I->getParent(), I->getDebugLoc(), TII->get(RISCV::VCJAL), RISCV::vs0).addMBB(I->getOperand(0).getMBB()).addImm(0).addReg(defPredReg);
          ++I;
          if (I != MFI->end())
            continue;
          else
            break;
          }
        default:
          printf("Unable to handle Opcode:%u in OpenCL kernel\n", I->getOpcode());
          I->dump();
          continue;
      }
      if(I == --MFI->end()) {// last instruction of bb has imp uses of vregs defined to hack around reg alloc
        // add all used registers in this machine Function as imp uses
        //for(unsigned r : vregs)
          //I->addOperand(MF,MachineOperand::CreateReg(r,false,true));
      }
      break;
    }
    //end of bb loop
  }
  MF.dump();
}

void RISCVVectorFetchMachOpt::convertToPredicates(MachineFunction &MF, unsigned defPredReg) {
  MF.dump();
  // pseudo algo
  // 1. turn terminators into predicates (keep track of bb->pred mapping)
  // 2. for each basic block look up cdg parent and use that predicate reg
  // 2a. This may require a negation of the predicate
  // 3. basic blocks with zero cds size just use vp0

  std::map<const MachineBasicBlock*, unsigned> bbToPred;
  std::map<const MachineBasicBlock*, unsigned> bbToNeg;
  // Terminator -> predication loop
  for (auto &MBB : MF) {
    unsigned opcode;
    unsigned predReg = MRI->createVirtualRegister(&RISCV::VPRBitRegClass);
    unsigned negate = 0;
    SmallVector<MachineInstr*, 1> deadBranches;
    for(auto &term: MBB) {
      if(!term.isConditionalBranch()) {
        switch(term.getOpcode()) {
          case RISCV::J:
          case RISCV::J64:
          case RISCV::JAL:
          case RISCV::JAL64:
            deadBranches.push_back(&term);
            break;
          case RISCV::VCJAL:
            if(MBB.succ_size() > 1) {
              // We should have a second VCJAL which we should update the predicate for
              term.getOperand(2).setImm(negate ^ 1);
              term.getOperand(3).setReg(predReg);
            }
        }
        continue; // only conditional terms needs change
      }
      // Synthesized branches via output negation
      // need to mark bb in data structure
      switch(term.getOpcode()) {
        case RISCV::BNE64:
        case RISCV::BNE:
          negate = 1;
        case RISCV::BEQ64:
        case RISCV::BEQ:
          opcode = getVectorCompareOp(&term, RISCV::VCMPEQ_VV, RISCV::VCMPEQ_VS, RISCV::VCMPEQ_SV, RISCV::VCMPEQ_SS);
          break;
        case RISCV::BGE64:
        case RISCV::BGE:
          negate = 1;
        case RISCV::BLT64:
        case RISCV::BLT:
          opcode = getVectorCompareOp(&term, RISCV::VCMPLT_VV, RISCV::VCMPLT_VS, RISCV::VCMPLT_SV, RISCV::VCMPLT_SS);
          break;
        case RISCV::BGEU64:
        case RISCV::BGEU:
          negate = 1;
        case RISCV::BLTU64:
        case RISCV::BLTU:
          opcode = getVectorCompareOp(&term, RISCV::VCMPLTU_VV, RISCV::VCMPLTU_VS, RISCV::VCMPLTU_SV, RISCV::VCMPLTU_SS);
          break;
        // Synthesized branches via lhs, rhs reversal
        case RISCV::BLE64:
        case RISCV::BLE:
          negate = 1;
        case RISCV::BGT64:
        case RISCV::BGT:
          opcode = getVectorCompareOp(&term, RISCV::VCMPGT_VV, RISCV::VCMPGT_VS, RISCV::VCMPGT_SV, RISCV::VCMPGT_SS);
          break;
        case RISCV::BLEU64:
        case RISCV::BLEU:
          negate = 1;
        case RISCV::BGTU64:
        case RISCV::BGTU:
          opcode = getVectorCompareOp(&term, RISCV::VCMPGTU_VV, RISCV::VCMPGTU_VS, RISCV::VCMPGTU_SV, RISCV::VCMPGTU_SS);
          break;
        default:
          llvm_unreachable("Invalid branch condition!");
      }
      bbToNeg.insert(std::make_pair(&MBB, negate));
      BuildMI(MBB, &term, term.getDebugLoc(), TII->get(opcode),predReg).addReg(term.getOperand(1).getReg()).addReg(term.getOperand(2).getReg()).addImm(0).addReg(defPredReg);
      // Convert to VCJAL
      BuildMI(MBB, &term, term.getDebugLoc(), TII->get(RISCV::VCJAL),RISCV::vs0).addOperand(term.getOperand(0)).addImm(negate).addReg(predReg);
      deadBranches.push_back(&term);
      // track result predicate reg
      bbToPred.insert(std::make_pair(&MBB, predReg));
    }
    for(auto dead: deadBranches)
      dead->eraseFromParent();
  }
  for (auto &MBB : MF) {
    MachinePDGNode *res = PDG->BBtoCDS.find(&MBB)->second;
    if(res->cds.size() > 0) {
      // This node has a predicate
      if(MBB.pred_size() > 1){
        // Merge predicates
        switch(MBB.pred_size()) {
          case 2: {
            auto cdsItr = res->cds.begin();
            unsigned predcds0 = bbToPred.find(cdsItr->first)->second;
            unsigned negcds0 = bbToNeg[cdsItr->first] ^ !(cdsItr->second) ? 1 : 0;
            ++cdsItr;
            unsigned predcds1 = bbToPred.find(cdsItr->first)->second;
            unsigned negcds1 = bbToNeg[cdsItr->first] ^ !(cdsItr->second) ? 1 : 0;
            auto pred0 = *(MBB.pred_begin());
            auto pred1 = *(++(MBB.pred_begin()));
            unsigned vptemp = MRI->createVirtualRegister(&RISCV::VPRBitRegClass);
            //TODO: need to generate the correct ands/ors based on the negation
            //Setup the loop mask with a vpset in the predecssor
            // The predecessor with fewer control dependences is correct TODO: prove this
            auto loopHeader = PDG->BBtoCDS.find(pred0)->second->cds.size() > PDG->BBtoCDS.find(pred0)->second->cds.size() ? pred1 : pred0;
            auto loopTail = PDG->BBtoCDS.find(pred0)->second->cds.size() > PDG->BBtoCDS.find(pred0)->second->cds.size() ? pred0 : pred1;
            unsigned mask = MRI->createVirtualRegister(&RISCV::VPRBitRegClass);
            BuildMI(loopHeader, loopHeader->getLastNonDebugInstr()->getDebugLoc(), TII->get(RISCV::VPSET), mask);
            unsigned myPred = bbToPred.find(&MBB)->second;
            //Insert a PHI node for this MBB's predreg
            unsigned vpPHI = MRI->createVirtualRegister(&RISCV::VPRBitRegClass);
            BuildMI(MBB, MBB.begin(), MBB.begin()->getDebugLoc(), TII->get(TargetOpcode::PHI), vpPHI).addReg(mask).addMBB(loopHeader).addReg(myPred).addMBB(loopTail);
            unsigned left = myPred == predcds0 ? vpPHI : predcds0;
            // pick the correct predRegs to merge
            unsigned right = myPred == predcds1 ? vpPHI : predcds1;
            unsigned negate = 0;
            unsigned ones = MRI->createVirtualRegister(&RISCV::VPRBitRegClass);
            if(negcds0) {
              if(negcds1) {
                // Both negative use or and negate result
                // demorgans
                BuildMI(MBB, MBB.getFirstNonPHI(), MBB.begin()->getDebugLoc(), TII->get(RISCV::VPOROR), vptemp).addReg(left).addReg(right).addReg(right);
                negate = 1;
              } else {
                // negate left and don't negate result
                BuildMI(MBB, MBB.getFirstNonPHI(), MBB.begin()->getDebugLoc(), TII->get(RISCV::VPXORAND), vptemp).addReg(left).addReg(ones).addReg(right);
                negate = 0;
              }
            } else {
              if(negcds1) {
                // negate right and don't negate result
                BuildMI(MBB, MBB.getFirstNonPHI(), MBB.begin()->getDebugLoc(), TII->get(RISCV::VPANDXOR), vptemp).addReg(left).addReg(right).addReg(ones);
                negate = 0;
              } else {
                // use and don't negate result
                BuildMI(MBB, MBB.getFirstNonPHI(), MBB.begin()->getDebugLoc(), TII->get(RISCV::VPANDAND), vptemp).addReg(left).addReg(right).addReg(right);
                negate = 0;
              }
            }
            BuildMI(MBB, MBB.getFirstNonPHI(), MBB.begin()->getDebugLoc(), TII->get(RISCV::VPSET), ones);
            for (auto &MI : MBB) {
              if(MI.isPredicable() &&
                  MI.getOpcode() != RISCV::VCJAL) {
                //The jumps are setup to use the correct predicate already
                MI.getOperand(MI.getNumOperands()-1).setReg(vptemp);
                MI.getOperand(MI.getNumOperands()-2).setImm(negate);
              }
            }
            break;
          }
          default:
            llvm_unreachable("Invalid branch condition!");
        }
      } else {
        // Just use the only predicate we have
        for(MachineProgramDependenceGraph::CDSet::iterator pdi = res->cds.begin(), pde = res->cds.end(); pdi != pde; ++pdi) {
          //loop over our parents children
          for(MachinePDGChildIterator ki = MachinePDGChildIterator(PDG->BBtoCDS.find(pdi->first)->second),
              ke = MachinePDGChildIterator(PDG->BBtoCDS.find(pdi->first)->second,true); ki != ke; ++ki) {
            if(res->bb == (*ki)->bb) {
              auto predItr = bbToPred.find(pdi->first);
              unsigned predReg = predItr->second;
              unsigned negate = bbToNeg[pdi->first] ^ !(pdi->second) ? 1 : 0;
              for (auto &MI : MBB) {
                if(MI.isPredicable()) {
                  MI.getOperand(MI.getNumOperands()-1).setReg(predReg);
                  MI.getOperand(MI.getNumOperands()-2).setImm(negate);
                }
              }
            }
          }
        }
      }
    }
  }
  MF.dump();
}

void RISCVVectorFetchRegFix::changeToPostRegAllocVecInst(MachineInstr &MI) {
  switch(MI.getOpcode()) {
    case RISCV::VFADD_S_RDY_VVV: MI.setDesc(TII->get(RISCV::VFADD_RAS_RDY_VVV)); break;
    case RISCV::VFADD_S_RDY_VVS: MI.setDesc(TII->get(RISCV::VFADD_RAS_RDY_VVS)); break;
    case RISCV::VFADD_S_RDY_VSV: MI.setDesc(TII->get(RISCV::VFADD_RAS_RDY_VSV)); break;
    case RISCV::VFADD_S_RDY_VSS: MI.setDesc(TII->get(RISCV::VFADD_RAS_RDY_VSS)); break;
    case RISCV::VFSUB_S_RDY_VVV: MI.setDesc(TII->get(RISCV::VFSUB_RAS_RDY_VVV)); break;
    case RISCV::VFSUB_S_RDY_VVS: MI.setDesc(TII->get(RISCV::VFSUB_RAS_RDY_VVS)); break;
    case RISCV::VFSUB_S_RDY_VSV: MI.setDesc(TII->get(RISCV::VFSUB_RAS_RDY_VSV)); break;
    case RISCV::VFSUB_S_RDY_VSS: MI.setDesc(TII->get(RISCV::VFSUB_RAS_RDY_VSS)); break;
    case RISCV::VFMUL_S_RDY_VVV: MI.setDesc(TII->get(RISCV::VFMUL_RAS_RDY_VVV)); break;
    case RISCV::VFMUL_S_RDY_VVS: MI.setDesc(TII->get(RISCV::VFMUL_RAS_RDY_VVS)); break;
    case RISCV::VFMUL_S_RDY_VSV: MI.setDesc(TII->get(RISCV::VFMUL_RAS_RDY_VSV)); break;
    case RISCV::VFMUL_S_RDY_VSS: MI.setDesc(TII->get(RISCV::VFMUL_RAS_RDY_VSS)); break;
    case RISCV::VFDIV_S_RDY_VVV: MI.setDesc(TII->get(RISCV::VFDIV_RAS_RDY_VVV)); break;
    case RISCV::VFDIV_S_RDY_VVS: MI.setDesc(TII->get(RISCV::VFDIV_RAS_RDY_VVS)); break;
    case RISCV::VFDIV_S_RDY_VSV: MI.setDesc(TII->get(RISCV::VFDIV_RAS_RDY_VSV)); break;
    case RISCV::VFDIV_S_RDY_VSS: MI.setDesc(TII->get(RISCV::VFDIV_RAS_RDY_VSS)); break;

    case RISCV::VSXW_F: MI.setDesc(TII->get(RISCV::VSXW_RAS_F)); break;
    case RISCV::VLXW_F: MI.setDesc(TII->get(RISCV::VLXW_RAS_F)); break;
  }
}

bool RISCVVectorFetchRegFix::runOnMachineFunction(MachineFunction &MF) {
  if(!isOpenCLKernelFunction(*(MF.getFunction())))
    return false;

  MachineRegisterInfo *MRI = &MF.getRegInfo();
  TII = MF.getSubtarget<RISCVSubtarget>().getInstrInfo();
  //We are changing vv*W and vv*H regs to vv*D regs respecting the register number ordering
  //We assume that vv*[D,W] regs used are consecutive starting at zero
  const TargetRegisterClass *vvD = &RISCV::VVRBitRegClass;
  const TargetRegisterClass *vvW = &RISCV::VVWBitRegClass;
  const TargetRegisterClass *vvH = &RISCV::VVHBitRegClass;
  unsigned wStart = 0;
  for(unsigned Reg : *vvD) {
    if(MRI->isPhysRegUsed(Reg)){
      wStart++;
    }
  }
  unsigned hStart = wStart;
  for(unsigned Reg : *vvW) {
    if(MRI->isPhysRegUsed(Reg)){
      hStart++;
    }
  }
  for (auto &MBB : MF) {
    auto firstMI = MBB.getFirstNonPHI();
    unsigned predReg = 0;
    unsigned negate = 0;
    // Remove dummy instruction
    if(firstMI->getOpcode() == RISCV::VCMPEQ_SS &&
        firstMI->getOperand(1).getReg() == RISCV::vs0 &&
        firstMI->getOperand(2).getReg() == RISCV::vs0 &&
        firstMI->getOperand(0).getReg() == firstMI->getOperand(4).getReg()){
      predReg = firstMI->getOperand(4).getReg();
      negate = firstMI->getOperand(3).getImm();
      firstMI->eraseFromParent();
    }
    for (MachineBasicBlock::iterator mi = MBB.begin(), me = MBB.end();
         mi != me;) {
      MachineInstr &MI = *mi;
      // Advance iterator here because MI may be erased.
      ++mi;
      bool changed = false;
      for (auto &MO : MI.operands()) {
        if(MO.isReg()) {
          // all register are physical now
          if(vvW->contains(MO.getReg())) {
            unsigned offset = MO.getReg()-vvW->getRegister(0);
            unsigned oldReg = MO.getReg();
            unsigned newReg = vvD->getRegister(wStart+offset);
            // change live ins in the sucessor BBs
            // TODO: do we need to follow through all successors?
            for(auto &succ : MBB.successors()) {
              if(succ->isLiveIn(oldReg)) {
                succ->removeLiveIn(oldReg);
                succ->addLiveIn(newReg);
                for(auto &succsucc : succ->successors()) {
                  if(succsucc->isLiveIn(oldReg)) {
                    succsucc->removeLiveIn(oldReg);
                    succsucc->addLiveIn(newReg);
                  }
                }
              }
            }
            //MRI->replaceRegWith(oldReg, newReg);
            MO.setReg(newReg);
            changed = true;
          }
          if(vvH->contains(MO.getReg())) {
            unsigned offset = MO.getReg()-vvH->getRegister(0);
            unsigned oldReg = MO.getReg();
            unsigned newReg = vvD->getRegister(hStart+offset);
            // change live ins in the sucessor BBs
            // TODO: do we need to follow through all successors?
            for(auto &succ : MBB.successors()) {
              if(succ->isLiveIn(oldReg)) {
                succ->removeLiveIn(oldReg);
                succ->addLiveIn(newReg);
                for(auto &succsucc : succ->successors()) {
                  if(succsucc->isLiveIn(oldReg)) {
                    succsucc->removeLiveIn(oldReg);
                    succsucc->addLiveIn(newReg);
                  }
                }
              }
            }
            //MRI->replaceRegWith(oldReg, newReg);
            MO.setReg(newReg);
            changed = true;
          }
        }
      }
      if(MI.getOpcode() == TargetOpcode::COPY) {
        // use predReg and negate to correctly predicate this copy
        TII->copyPhysReg(*MI.getParent(), &MI, MI.getDebugLoc(),
            MI.getOperand(0).getReg(), MI.getOperand(1).getReg(),
            MI.getOperand(1).isKill());
        auto newMI = MI.getPrevNode();
        newMI->getOperand(3).setImm(negate);
        newMI->getOperand(4).setReg(predReg);
        MI.eraseFromParent();
      }
      changeToPostRegAllocVecInst(MI);
    }
  }
  return true;
}

MachineFunctionPass *llvm::createRISCVVectorFetchRegFix() { return new RISCVVectorFetchRegFix(); }

bool RISCVVectorFetchPreEmitOpt::runOnMachineFunction(MachineFunction &MF) {
  if(!isOpenCLKernelFunction(*(MF.getFunction())))
    return false;

  MF.dump();
  TII = MF.getSubtarget<RISCVSubtarget>().getInstrInfo();
  for (auto &MBB : MF) {
    unsigned predReg = 0;
    unsigned negate = 0;
    for (MachineBasicBlock::iterator mi = MBB.begin(), me = MBB.end(); mi != me;) {
      MachineInstr &MI = *mi;
      // Advance iterator here because MI may be erased.
      ++mi;
      if(MI.isPredicable() && MI.getOpcode() != RISCV::VCJAL) {
        predReg = MI.getOperand(MI.getNumOperands()-1).getReg();
        negate = MI.getOperand(MI.getNumOperands()-2).getImm();
      }
      switch(MI.getOpcode()) {
        case RISCV::J:
        case RISCV::J64:
        case RISCV::JAL:
        case RISCV::JAL64:
          BuildMI(MBB, &MI, MI.getDebugLoc(), TII->get(RISCV::VCJAL), RISCV::vs0).addMBB(MI.getOperand(0).getMBB()).addImm(negate).addReg(predReg);
          MI.eraseFromParent();
          break;
      }
    }
  }
  return true;
}

MachineFunctionPass *llvm::createRISCVVectorFetchPreEmitOpt() { return new RISCVVectorFetchPreEmitOpt(); }
