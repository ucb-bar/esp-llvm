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
    virtual void processOpenCLKernel(MachineFunction &MF);
    virtual void convertToPredicates(MachineFunction &MF);
  };

  char RISCVVectorFetchMachOpt::ID = 0;

} // end anonymous namespace

namespace {
  struct RISCVVectorFetchRegFix : public MachineFunctionPass {
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

  if(isOpenCLKernelFunction(*(MF.getFunction()))) {
    processOpenCLKernel(MF);
    convertToPredicates(MF);
  }

  return Changed;
}

void RISCVVectorFetchMachOpt::processOpenCLKernel(MachineFunction &MF) {
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const TargetInstrInfo &TII = *MF.getSubtarget().getInstrInfo();
  const TargetRegisterInfo &TRI = *MF.getSubtarget().getRegisterInfo();

  std::vector<unsigned> vregs;
  // add vpset vp0 at start of function
  MachineBasicBlock &entryBlock = MF.front();
  MachineBasicBlock::iterator entryBegin = entryBlock.begin();
  DebugLoc entryDL = entryBegin != entryBlock.end() ? entryBegin->getDebugLoc() : DebugLoc();
  unsigned defPredReg = MRI.createVirtualRegister(&RISCV::VPRBitRegClass);
  BuildMI(entryBlock, entryBegin, entryDL, TII.get(RISCV::VPSET), defPredReg);
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
          if(TRI.isPhysicalRegister(I->getOperand(1).getReg())) {
            if(RISCV::VARBitRegClass.contains(I->getOperand(1).getReg()))
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VARBitRegClass);
            if(I->getOperand(1).getReg() == RISCV::zero || I->getOperand(1).getReg() == RISCV::zero_64) {
              I->getOperand(1).setReg(RISCV::vs0);
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            }

            break;
          }
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass ||
             MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass ||
             MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
             MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
             MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass
              ) {
            MRI.setRegClass(I->getOperand(0).getReg(),
              MRI.getRegClass(I->getOperand(1).getReg()));
            I->getOperand(1).setSubReg(0); // v registers hold all values with no sub regs for now
          }
          break;
        case TargetOpcode::SUBREG_TO_REG :// v registers hold all values with no sub regs for now
          if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass ||
             MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VARBitRegClass ||
             MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass ||
             MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass ||
             MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass
              ) {
            //turn in into a copy
            unsigned srcReg = I->getOperand(2).getReg();
            MRI.setRegClass(I->getOperand(0).getReg(),
              MRI.getRegClass(I->getOperand(2).getReg()));
            I->RemoveOperand(3);
            I->RemoveOperand(2);
            I->RemoveOperand(1);
            I->addOperand(MachineOperand::CreateReg(srcReg, false));
            I->setDesc(TII.get(TargetOpcode::COPY));
          }
          break;
        case TargetOpcode::PHI :
          // Phi nodes may be muxing scalar and vector inputs so we need to move scalar values into vectors
          // But since Phi nodes need to be first in the basic block we should find
          // where this operand is defined, and insert the vadd there.
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass &&
             MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass){
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            break;
          } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass){
            assert(MRI.hasOneDef(I->getOperand(1).getReg()) && "vsreg has more than one def");
            for(MachineInstr &def : MRI.def_instructions(I->getOperand(1).getReg())) {
              unsigned vstemp = MRI.createVirtualRegister(MRI.getRegClass(I->getOperand(3).getReg()));
              // TODO: we could propogate this info the source folding this add with another operation perhaps
              MachineBasicBlock::iterator defI = def.getParent()->getFirstTerminator();
              if(defI == def.getParent()->end())
                defI = std::prev(defI);
              if(&def == defI) // only instruction is the def itself so put it at the end of the block
                BuildMI(def.getParent(), def.getDebugLoc(), TII.get(RISCV::VADD_VSS), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(1).getReg());
              else
                BuildMI(*(def.getParent()), defI, def.getDebugLoc(), TII.get(RISCV::VADD_VSS), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(1).getReg());

              I->getOperand(1).setReg(vstemp);
            }
            MRI.setRegClass(I->getOperand(0).getReg(),
              MRI.getRegClass(I->getOperand(3).getReg()));
          } else if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
            assert(MRI.hasOneDef(I->getOperand(3).getReg()) && "vsreg has more than one def");
            for(MachineInstr &def : MRI.def_instructions(I->getOperand(3).getReg())) {
              unsigned vstemp = MRI.createVirtualRegister(MRI.getRegClass(I->getOperand(1).getReg()));
              // TODO: we could propogate this info the source folding this add with another operation perhaps
              MachineBasicBlock::iterator defI = def.getParent()->getFirstTerminator();
              if(defI == def.getParent()->end())
                defI = std::prev(defI);
              if(&def == defI) // only instruction is the def itself so put it at the end of the block
                BuildMI(def.getParent(), def.getDebugLoc(), TII.get(RISCV::VADD_VSS), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(3).getReg());
              else
                BuildMI(*(def.getParent()), defI, def.getDebugLoc(), TII.get(RISCV::VADD_VSS), vstemp).addReg(RISCV::vs0).addReg(I->getOperand(3).getReg());

              I->getOperand(3).setReg(vstemp);
            }
            MRI.setRegClass(I->getOperand(0).getReg(),
              MRI.getRegClass(I->getOperand(1).getReg()));
          }
          break;
        case RISCV::ADD64 :
          //FIXME: if we can have phys regs here check for that first
          if(MS->invar[I]) {
            I->setDesc(TII.get(RISCV::VADD_SSS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VADD_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VADD_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VADD_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VADD_VVV));
              }
            }
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        case RISCV::SUB64 :
          //FIXME: if we can have phys regs here check for that first
          if(MS->invar[I]) {
            I->setDesc(TII.get(RISCV::VSUB_SSS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VSUB_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VSUB_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VSUB_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VSUB_VVV));
              }
            }
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        case RISCV::MUL64 :
          //FIXME: if we can have phys regs here check for that first
          if(MS->invar[I]) {
            I->setDesc(TII.get(RISCV::VMUL_SSS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VMUL_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VMUL_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VMUL_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VMUL_VVV));
              }
            }
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        case RISCV::SLT :
        case RISCV::SLT64 :
          if(TRI.isPhysicalRegister(I->getOperand(1).getReg())) {
            //Can only handle zero case
            assert((I->getOperand(1).getReg() == RISCV::zero ||
                    I->getOperand(1).getReg() == RISCV::zero_64) &&
                   "Cannot convert slt with phys reg arg that is non zero");
            I->getOperand(1).setReg(RISCV::vs0);
            if(MS->invar[I]) {
              I->setDesc(TII.get(RISCV::VSLT_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VSLT_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VSLT_VSV));
              }
              // Destination is always vector
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
              vregs.push_back(I->getOperand(0).getReg());
            }
          } else if(MS->invar[I]) {
            I->setDesc(TII.get(RISCV::VSLT_SSS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VSLT_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VSLT_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VSLT_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VSLT_VVV));
              }
            }
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        case RISCV::ADDW :
          //FIXME: if we can have phys regs here check for that first
          if(MS->invar[I]) {
            I->setDesc(TII.get(RISCV::VADDW_SSS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VADDW_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VADDW_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VADDW_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VADDW_VVV));
              }
            }
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        case RISCV::SUBW :
          //FIXME: if we can have phys regs here check for that first
          if(MS->invar[I]) {
            I->setDesc(TII.get(RISCV::VSUBW_SSS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VSUBW_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VSUBW_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VSUBW_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VSUBW_VVV));
              }
            }
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        case RISCV::MULW :
          //FIXME: if we can have phys regs here check for that first
          if(MS->invar[I]) {
            I->setDesc(TII.get(RISCV::VMULW_SSS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VMULW_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VMULW_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VMULW_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VMULW_VVV));
              }
            }
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        case RISCV::LI64:
        case RISCV::LI:
          {
          int64_t imm = I->getOperand(1).getImm();
          I->setDesc(TII.get(RISCV::VADDI));
          I->RemoveOperand(1);
          I->addOperand(MF, MachineOperand::CreateReg(RISCV::vs0, false));
          I->addOperand(MF, MachineOperand::CreateImm(imm));
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          }
          break;
        case RISCV::LUI64:
        case RISCV::LUI:
          {
          I->setDesc(TII.get(RISCV::VLUI));
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          }
          break;
        case RISCV::ADDI64 :
        {
          if(MS->invar[I]) {
            // Generate one instruction
            // vADDi vsdest, vssrc, imm
            I->setDesc(TII.get(RISCV::VADDI));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            // Generate two instructions
            // 1. vaddi vstemp, vs0, imm
            unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
            MachineOperand &imm = I->getOperand(2);
            BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
            // 1. vADD vvdest, vssrc, vstemp
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VADD_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              I->setDesc(TII.get(RISCV::VADD_VVS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            }
            I->getOperand(2).ChangeToRegister(vstemp, false);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        }
        case RISCV::SLTI64 :
        case RISCV::SLTI:
        {
          if(MS->invar[I]) {
            // Generate one instruction
            // vSLTi vsdest, vssrc, imm
            I->setDesc(TII.get(RISCV::VSLTI));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            // Generate two instructions
            // 1. vaddi vstemp, vs0, imm
            unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
            MachineOperand &imm = I->getOperand(2);
            BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
            // 1. vSLT vvdest, vssrc, vstemp
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VSLT_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              I->setDesc(TII.get(RISCV::VSLT_VVS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            }
            I->getOperand(2).ChangeToRegister(vstemp, false);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        }
        case RISCV::SLLI64 :
        {
          if(MS->invar[I]) {
            // Generate one instruction
            // vslli vsdest, vssrc, imm
            I->setDesc(TII.get(RISCV::VSLLI));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            // Generate two instructions
            // 1. vaddi vstemp, vs0, imm
            unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
            MachineOperand &imm = I->getOperand(2);
            BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
            // 1. vsll vvdest, vssrc, vstemp
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass){
              I->setDesc(TII.get(RISCV::VSLL_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              I->setDesc(TII.get(RISCV::VSLL_VVS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            }
            I->getOperand(2).ChangeToRegister(vstemp, false);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        }
        case RISCV::SRLI64 :
        {
          if(MS->invar[I]) {
            // Generate one instruction
            // vsrli vsdest, vssrc, imm
            I->setDesc(TII.get(RISCV::VSRLI));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            // Generate two instructions
            // 1. vaddi vstemp, vs0, imm
            unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
            MachineOperand &imm = I->getOperand(2);
            BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
            // 1. vsrl vvdest, vssrc, vstemp
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VSRL_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              I->setDesc(TII.get(RISCV::VSRL_VVS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            }
            I->getOperand(2).ChangeToRegister(vstemp, false);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        }
        case RISCV::SRAI64 :
        {
          if(MS->invar[I]) {
            // Generate one instruction
            // vsra vsdest, vssrc, imm
            I->setDesc(TII.get(RISCV::VSRAI));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            // Generate two instructions
            // 1. vaddi vstemp, vs0, imm
            unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
            MachineOperand &imm = I->getOperand(2);
            BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
            // 1. vSRA vvdest, vssrc, vstemp
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VSRA_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              I->setDesc(TII.get(RISCV::VSRA_VVS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            }
            I->getOperand(2).ChangeToRegister(vstemp, false);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        }
        case RISCV::ADDIW :
        {
          if(MS->invar[I]) {
            // Generate one instruction
            // vADDiW vsdest, vssrc, imm
            I->setDesc(TII.get(RISCV::VADDIW));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            // Generate two instructions
            // 1. vaddi vstemp, vs0, imm
            unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
            MachineOperand &imm = I->getOperand(2);
            BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDIW), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
            // 1. vADD vvdest, vssrc, vstemp
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VADD_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              I->setDesc(TII.get(RISCV::VADD_VVS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            }
            I->getOperand(2).ChangeToRegister(vstemp, false);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        }
        case RISCV::SRAIW :
        case RISCV::SRAIW64 :
        {
          if(MS->invar[I]) {
            // Generate one instruction
            // vsra vsdest, vssrc, imm
            I->setDesc(TII.get(RISCV::VSRAIW));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            // Generate two instructions
            // 1. vaddi vstemp, vs0, imm
            unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
            MachineOperand &imm = I->getOperand(2);
            BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
            // 1. vSRA vvdest, vssrc, vstemp
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VSRAW_SSS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            } else {
              I->setDesc(TII.get(RISCV::VSRAW_VVS));
              MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            }
            I->getOperand(2).ChangeToRegister(vstemp, false);
            vregs.push_back(I->getOperand(0).getReg());
          }
          break;
        }
        case RISCV::FLH64 :
          //TODO: support invariant memops becoming scalar memops
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
            I->setDesc(TII.get(RISCV::VLH_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVHBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
            I->setDesc(TII.get(RISCV::VLSH_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            I->setDesc(TII.get(RISCV::VLXH_F));
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVHBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
            // Shift vector portion to second src
            I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
            I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          }
          break;
        case RISCV::FLW64 :
          //TODO: support invariant memops becoming scalar memops
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
            I->setDesc(TII.get(RISCV::VLW_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVWBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
            I->setDesc(TII.get(RISCV::VLSW_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            I->setDesc(TII.get(RISCV::VLXW_F));
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVWBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
            // Shift vector portion to second src
            I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
            I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
            I->addOperand(MF, MachineOperand::CreateReg(defPredReg, false));
          }
          break;
        case RISCV::FLD64 :
          //TODO: support invariant memops becoming scalar memops
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
            I->setDesc(TII.get(RISCV::VLD_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
            I->setDesc(TII.get(RISCV::VLSD_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            I->setDesc(TII.get(RISCV::VLXD_F));
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
            // Shift vector portion to second src
            I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
            I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          }
          break;
        case RISCV::LHU64 :
        case RISCV::LHU64_32 :
          //TODO: support invariant memops becoming scalar memops
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
            I->setDesc(TII.get(RISCV::VLHU_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
          } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
            I->setDesc(TII.get(RISCV::VLSHU_F));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
          } else {
            I->setDesc(TII.get(RISCV::VLXHU_F));
            // Destination is always vector
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
            vregs.push_back(I->getOperand(0).getReg());
            // Shift vector portion to second src
            I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
            I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          }
          break;
        case RISCV::LW64 :
        //TODO: support invariant memops becoming scalar memops
          I->setDesc(TII.get(RISCV::VLXW));
          // Destination is always vector
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
          vregs.push_back(I->getOperand(0).getReg());
          // Shift vector portion to second src
          I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
          I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          break;
        case RISCV::FSD64 :
          //TODO: support invariant memops becoming scalar memops
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
            I->setDesc(TII.get(RISCV::VSD_F));
            I->RemoveOperand(2);
          } else {
            I->setDesc(TII.get(RISCV::VSXD_F));
            // Shift vector portion to second src
            I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
            I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          }
          break;
        case RISCV::FSW64 :
          //TODO: support invariant memops becoming scalar memops
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
            I->setDesc(TII.get(RISCV::VSW_F));
            I->RemoveOperand(2);
          } else {
            I->setDesc(TII.get(RISCV::VSXW_F));
            // Shift vector portion to second src
            I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
            I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          }
          break;
        case RISCV::FSH64 :
          //TODO: support invariant memops becoming scalar memops
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VARBitRegClass) {
            I->setDesc(TII.get(RISCV::VSH_F));
            I->RemoveOperand(2);
          } else {
            I->setDesc(TII.get(RISCV::VSXH_F));
            // Shift vector portion to second src
            I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
            I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          }
          break;
        case RISCV::SW64 :
        //TODO: support invariant memops becoming scalar memops
          I->setDesc(TII.get(RISCV::VSXW));
          // Shift vector portion to second src
          I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
          I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          break;
        case RISCV::FCVT_S_D_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVWBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVWBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFCVT_S_D_RDY_VS));
            } else {
              I->setDesc(TII.get(RISCV::VFCVT_S_D_RDY_VV));
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFCVT_S_D_RDY_SS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FCVT_S_W_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVWBitRegClass;
          if(TRI.isPhysicalRegister(I->getOperand(1).getReg())) {
            //handle cvt from zero specially
            assert((I->getOperand(1).getReg() == RISCV::zero) &&
                   "Cannot convert slt with phys reg arg that is non zero");
            I->setDesc(TII.get(RISCV::VFCVT_S_W_RDY_SS));
            MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VSRBitRegClass);
            I->getOperand(1).setReg(RISCV::vs0);
            break;
          } else if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVWBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFCVT_S_W_RDY_VS));
            } else {
              I->setDesc(TII.get(RISCV::VFCVT_S_W_RDY_VV));
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFCVT_S_W_RDY_SS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FCVT_D_S_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVRBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFCVT_D_S_RDY_VS));
            } else {
              I->setDesc(TII.get(RISCV::VFCVT_D_S_RDY_VV));
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFCVT_D_S_RDY_SS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FADD_D_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVRBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFADD_D_RDY_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VFADD_D_RDY_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFADD_D_RDY_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VFADD_D_RDY_VVV));
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFADD_D_RDY_SSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FSUB_D_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVRBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFSUB_D_RDY_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VFSUB_D_RDY_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFSUB_D_RDY_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VFSUB_D_RDY_VVV));
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFSUB_D_RDY_SSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FMUL_D_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVRBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFMUL_D_RDY_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VFMUL_D_RDY_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFMUL_D_RDY_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VFMUL_D_RDY_VVV));
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFMUL_D_RDY_SSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FCVT_H_S_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVHBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFCVT_H_S_RDY_VS));
            } else {
              I->setDesc(TII.get(RISCV::VFCVT_H_S_RDY_VV));
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFCVT_H_S_RDY_SS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FCVT_S_H_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVWBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVWBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFCVT_S_H_RDY_VS));
            } else {
              I->setDesc(TII.get(RISCV::VFCVT_S_H_RDY_VV));
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFCVT_S_H_RDY_SS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FADD_S_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVWBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFADD_S_RDY_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VFADD_S_RDY_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFADD_S_RDY_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VFADD_S_RDY_VVV));
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFADD_S_RDY_SSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FSUB_S_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVWBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFSUB_S_RDY_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VFSUB_S_RDY_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFSUB_S_RDY_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VFSUB_S_RDY_VVV));
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFSUB_S_RDY_SSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FMUL_S_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVWBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VSS));
              } else {
                I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VSV));
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VVS));
              } else {
                I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VVV));
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFMUL_S_RDY_SSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FMADD_S_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVWBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VSSS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VSSV));
                }
              } else {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VSVS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VSVV));
                }
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VVSS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VVSV));
                }
              } else {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VVVS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_S_RDY_VVVV));
                }
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFMADD_S_RDY_SSSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::FMADD_D_RDY :
          {
          const TargetRegisterClass *destClass = &RISCV::VVRBitRegClass;
          if(MS->invar[I]) {
            //if we were invariant but have a vector src it means there was a vector load
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVRBitRegClass ||
               MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VVRBitRegClass) {
              destClass = &RISCV::VVRBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVWBitRegClass ||
                      MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VVWBitRegClass) {
              destClass = &RISCV::VVWBitRegClass;
            } else if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VVHBitRegClass ||
                      MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VVHBitRegClass) {
              destClass = &RISCV::VVHBitRegClass;
            } else
              destClass = &RISCV::VSRBitRegClass;
          }
          if(destClass == &RISCV::VVRBitRegClass ||
             destClass == &RISCV::VVWBitRegClass ||
             destClass == &RISCV::VVHBitRegClass) {
            if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VSSS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VSSV));
                }
              } else {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VSVS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VSVV));
                }
              }
            } else {
              if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VVSS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VVSV));
                }
              } else {
                if(MRI.getRegClass(I->getOperand(3).getReg()) == &RISCV::VSRBitRegClass) {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VVVS));
                } else {
                  I->setDesc(TII.get(RISCV::VFMADD_D_RDY_VVVV));
                }
              }
            }
            // Destination is always vector
          } else {
            I->setDesc(TII.get(RISCV::VFMADD_D_RDY_SSSS));
          }
          MRI.setRegClass(I->getOperand(0).getReg(), destClass);
          vregs.push_back(I->getOperand(0).getReg());
          break;
          }
        case RISCV::RET :
          I->setDesc(TII.get(RISCV::VSTOP));
          I->RemoveOperand(1);
          I->RemoveOperand(0);
          break;
        default:
          printf("Unable to handle Opcode:%u in OpenCL kernel\n", I->getOpcode());
          I->dump();
      }
      if(I == --MFI->end()) {// last instruction of bb has imp uses of vregs defined to hack around reg alloc
        // add all used registers in this machine Function as imp uses
        //for(unsigned r : vregs)
          //I->addOperand(MF,MachineOperand::CreateReg(r,false,true));
      }
    }
    //end of bb loop
  }
  MF.dump();
}

void RISCVVectorFetchMachOpt::convertToPredicates(MachineFunction &MF) {
  MF.dump();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  // pseudo algo
  // 1. turn terminators into predicates (keep track of bb->pred mapping)
  // 2. for each basic block look up cdg parent and use that predicate reg
  // 2a. This may require a negation of the predicate
  // 3. basic blocks with zero cds size just use vp0

  std::map<const MachineBasicBlock*, unsigned> bbToPred;
  // Terminator -> predication loop
  for (auto &MBB : MF) {
    auto term = MBB.getFirstTerminator();
    if(term == MBB.end())
      continue; // pure fall through bb needs no change
    if(!term->isConditionalBranch())
      continue; // only conditional terms needs change
    unsigned opcode;
    switch(term->getOpcode()) {
      case RISCV::BEQ64:
      case RISCV::BEQ:
        opcode = RISCV::VCMPEQ_VV;
        break;
      case RISCV::BLT64:
      case RISCV::BLT:
        opcode = RISCV::VCMPLT_VV;
        break;
      case RISCV::BLTU64:
      case RISCV::BLTU:
        opcode = RISCV::VCMPLTU_VV;
        break;
      // Synthesized branches via lhs, rhs reversal
      case RISCV::BGT64:
      case RISCV::BGT:
        opcode = RISCV::VCMPGT_VV;
        break;
      case RISCV::BGTU64:
      case RISCV::BGTU:
        opcode = RISCV::VCMPGTU_VV;
        break;
      // Synthesized branches via output negation
      default:
        continue;
    }
    unsigned predReg = MRI.createVirtualRegister(&RISCV::VPRBitRegClass);
    BuildMI(MBB, term, term->getDebugLoc(), TII->get(opcode),predReg).addReg(term->getOperand(1).getReg()).addReg(term->getOperand(2).getReg());
    // track result predicate reg
    bbToPred.insert(std::make_pair(&MBB, predReg));
  }
  for (auto &MBB : MF) {
    MachinePDGNode *res = PDG->BBtoCDS.find(&MBB)->second;
    if(res->cds.size() > 0) {
      // This node has a predicate
      for(MachineProgramDependenceGraph::CDSet::iterator pdi =
           res->cds.begin(), pde =
           res->cds.end(); pdi != pde; ++pdi){
        auto predItr = bbToPred.find(pdi->first);
        if(predItr == bbToPred.end())
          continue;// TODO: this shouldn't happen once all terminators are handled
        unsigned predReg = predItr->second;
        unsigned destReg = MRI.createVirtualRegister(&RISCV::VPRBitRegClass);
        if(pdi->second)
          BuildMI(MBB, MBB.getFirstNonPHI(),DebugLoc(),TII->get(RISCV::VPANDAND),destReg).addReg(predReg).addReg(predReg).addReg(predReg);
        else
          BuildMI(MBB, MBB.getFirstNonPHI(),DebugLoc(),TII->get(RISCV::VPANDAND),destReg).addReg(predReg).addReg(predReg).addReg(predReg);
      }
    }
  }
  MF.dump();
}

void RISCVVectorFetchRegFix::changeToPostRegAllocVecInst(MachineInstr &MI) {
  const TargetInstrInfo &TII = *MI.getParent()->getParent()->getSubtarget().getInstrInfo();
  switch(MI.getOpcode()) {
    case RISCV::VFADD_S_RDY_VVV: MI.setDesc(TII.get(RISCV::VFADD_RAS_RDY_VVV)); break;
    case RISCV::VFADD_S_RDY_VVS: MI.setDesc(TII.get(RISCV::VFADD_RAS_RDY_VVS)); break;
    case RISCV::VFADD_S_RDY_VSV: MI.setDesc(TII.get(RISCV::VFADD_RAS_RDY_VSV)); break;
    case RISCV::VFADD_S_RDY_VSS: MI.setDesc(TII.get(RISCV::VFADD_RAS_RDY_VSS)); break;
    case RISCV::VFSUB_S_RDY_VVV: MI.setDesc(TII.get(RISCV::VFSUB_RAS_RDY_VVV)); break;
    case RISCV::VFSUB_S_RDY_VVS: MI.setDesc(TII.get(RISCV::VFSUB_RAS_RDY_VVS)); break;
    case RISCV::VFSUB_S_RDY_VSV: MI.setDesc(TII.get(RISCV::VFSUB_RAS_RDY_VSV)); break;
    case RISCV::VFSUB_S_RDY_VSS: MI.setDesc(TII.get(RISCV::VFSUB_RAS_RDY_VSS)); break;
    case RISCV::VFMUL_S_RDY_VVV: MI.setDesc(TII.get(RISCV::VFMUL_RAS_RDY_VVV)); break;
    case RISCV::VFMUL_S_RDY_VVS: MI.setDesc(TII.get(RISCV::VFMUL_RAS_RDY_VVS)); break;
    case RISCV::VFMUL_S_RDY_VSV: MI.setDesc(TII.get(RISCV::VFMUL_RAS_RDY_VSV)); break;
    case RISCV::VFMUL_S_RDY_VSS: MI.setDesc(TII.get(RISCV::VFMUL_RAS_RDY_VSS)); break;

    case RISCV::VSXW_F: MI.setDesc(TII.get(RISCV::VSXW_RAS_F)); break;
    case RISCV::VLXW_F: MI.setDesc(TII.get(RISCV::VLXW_RAS_F)); break;
  }
}

bool RISCVVectorFetchRegFix::runOnMachineFunction(MachineFunction &MF) {
  if(!isOpenCLKernelFunction(*(MF.getFunction())))
    return false;

  MachineRegisterInfo &MRI = MF.getRegInfo();
  //We are changing vv*W and vv*H regs to vv*D regs respecting the register number ordering
  //We assume that vv*[D,W] regs used are consecutive starting at zero
  const TargetRegisterClass *vvD = &RISCV::VVRBitRegClass;
  const TargetRegisterClass *vvW = &RISCV::VVWBitRegClass;
  const TargetRegisterClass *vvH = &RISCV::VVHBitRegClass;
  unsigned wStart = 0;
  for(unsigned Reg : *vvD) {
    if(MRI.isPhysRegUsed(Reg)){
      wStart++;
    }
  }
  unsigned hStart = wStart;
  for(unsigned Reg : *vvW) {
    if(MRI.isPhysRegUsed(Reg)){
      hStart++;
    }
  }
  for (auto &MBB : MF) {
    for (auto &MI : MBB) {
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
              }
            }
            //MRI.replaceRegWith(oldReg, newReg);
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
              }
            }
            //MRI.replaceRegWith(oldReg, newReg);
            MO.setReg(newReg);
            changed = true;
          }
        }
      }
      changeToPostRegAllocVecInst(MI);
    }
  }
  return true;
}

MachineFunctionPass *llvm::createRISCVVectorFetchRegFix() { return new RISCVVectorFetchRegFix(); }
