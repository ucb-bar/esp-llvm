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
#include "llvm/CodeGen/TargetInstrInfo.h"
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

    StringRef getPassName() const override { return "RISCV Vector Fetch IROpt"; }

    void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.addRequired<CallGraphWrapperPass>();
      AU.addRequired<Scalarization>();
      AU.addRequired<ScalarEvolutionWrapperPass>();
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

    StringRef getPassName() const override { return "RISCV Vector Fetch MachOpt"; }

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

    StringRef getPassName() const override { return "RISCV Vector Fetch RegFix"; }

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

    StringRef getPassName() const override { return "RISCV Vector Fetch PreEmitOpt"; }

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
INITIALIZE_PASS_DEPENDENCY(ScalarEvolutionWrapperPass)
INITIALIZE_PASS_END(RISCVVectorFetchIROpt, "vfiropt",
                    "RISCV Vector Fetch IROpt", false, false)

ModulePass *llvm::createRISCVVectorFetchIROpt() {
  return new RISCVVectorFetchIROpt();
}
bool RISCVVectorFetchIROpt::runOnModule(Module &M) {
    M.dump();
    CallGraph& cg = getAnalysis<CallGraphWrapperPass>().getCallGraph();

    scc_iterator<CallGraph*> cgSccIter = scc_begin(&cg);
    CallGraphSCC curSCC(cg, &cgSccIter);
    while (!cgSccIter.isAtEnd())
    {
        const std::vector<CallGraphNode*>& nodeVec = *cgSccIter;
        curSCC.initialize(ArrayRef<CallGraphNode*>(nodeVec));
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
  if(F->empty()) return nullptr;
  MS = &getAnalysis<Scalarization>(*F);
  SE = &getAnalysis<ScalarEvolutionWrapperPass>(*F).getSE();

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
  }
  
  return SE->getCouldNotCompute();
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
            addrs.insert(std::make_pair(&*MII, newSCEV));
            printf("HOISTED ADDR\n");fflush(stdout);fflush(stderr);
          } else { // entirely scalar memop so we hoist it differently
            // TODO: Hoisting scalar stores requires checking that all values
            // in SCEV are known at the call site
            scalars.insert(std::make_pair(&*MII, newSCEV));
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
            addrs.insert(std::make_pair(&*MII, newSCEV));
            printf("HOISTED ADDR\n");fflush(stdout);fflush(stderr);
          } else { // entirely scalar memop so we hoist it differently
            scalars.insert(std::make_pair(&*MII, newSCEV));
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

  F->getParent()->getFunctionList().insert(F->getIterator(), NF);
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

  while (!F->use_empty()) {
    CallSite CS(F->user_back());
    assert(CS.getCalledFunction() == F);
    Instruction *Call = CS.getInstruction();
    const AttributeList &CallPAL = CS.getAttributes();

    // Add any return attributes.

    auto retAttributes = AttributeSet();
    auto fnAttributes = AttributeSet(); 

    if (CallPAL.hasAttributes(AttributeList::ReturnIndex)) {
      retAttributes = CallPAL.getRetAttributes();
      fnAttributes = CallPAL.getFnAttributes();
    }

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
        argMap[&*I] = *AI;
      }
    }
    AttributeList aregAttrs();
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
    cast<CallInst>(New)->setAttributes(AttributeList::get(New->getContext(),
                                                        fnAttributes, retAttributes, ArrayRef<AttributeSet>()));
    for(unsigned i = 0;i < addrs.size(); i++) {
      cast<CallInst>(New)->addAttribute(ArgIndex+i, Attribute::ByVal);
    }
    if (cast<CallInst>(Call)->isTailCall())
      cast<CallInst>(New)->setTailCall();

    New->setDebugLoc(Call->getDebugLoc());
    Args.clear();

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
    (&*I)->replaceAllUsesWith(&*I2);
    (&*I2)->takeName(&*I);
    ++I2;
    continue;
  }
  // Loop over the remaining args createing new loads to use the
  for(std::map<Instruction *, const SCEV *>::iterator it = addrs.begin(); it != addrs.end(); ++it) {

    Instruction *newMemOp;
    if(isa<LoadInst>(it->first)) {
      newMemOp = new LoadInst(&*I2, "vec_addr_base", it->first);
    }
    if(isa<StoreInst>(it->first)) {
      newMemOp = new StoreInst(it->first->getOperand(0), &*I2, "vec_addr_base", it->first);
    }
    it->first->replaceAllUsesWith(newMemOp);
    newMemOp->takeName(it->first);
    it->first->eraseFromParent();
    ++I2;
  }
  for(std::map<Instruction *, const SCEV *>::iterator it = scalars.begin(); it != scalars.end(); ++it) {
    Instruction *newMemOp;
    if(isa<LoadInst>(it->first)) {
      newMemOp = new LoadInst(&*I2, "vec_addr_base", it->first);
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

