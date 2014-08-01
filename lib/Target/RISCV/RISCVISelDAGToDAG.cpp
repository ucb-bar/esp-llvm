//===-- RISCVISelDAGToDAG.cpp - A dag to dag inst selector for RISCV --===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the RISCV target.
//
//===----------------------------------------------------------------------===//

#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include <stdio.h>

using namespace llvm;

namespace {
// Used to build addressing modes.
struct RISCVAddressingMode {
  // The shape of the address.
  enum AddrForm {
    // base+offset
    FormBO
  };
  AddrForm Form;

  // The type of displacement. 
  enum OffRange {
    Off12Only
  };
  OffRange OffR;

  // The parts of the address.  The address is equivalent to:
  //
  //     Base + Offset + Index + (IncludesDynAlloc ? ADJDYNALLOC : 0)
  SDValue Base;
  int64_t Offset;

  RISCVAddressingMode(AddrForm form, OffRange offr)
    : Form(form), OffR(offr), Base(), Offset(0) {}

  void dump() {
    errs() << "RISCVAddressingMode " << this << '\n';

    errs() << " Base ";
    if (Base.getNode() != 0)
      Base.getNode()->dump();
    else
      errs() << "null\n";

    errs() << " Offset " << Offset;
  }
};

class RISCVDAGToDAGISel : public SelectionDAGISel {
  const RISCVTargetLowering &Lowering;
  const RISCVSubtarget &Subtarget;

  // Used by RISCVOperands.td to create integer constants.
  inline SDValue getImm(const SDNode *Node, uint64_t Imm) {
    return CurDAG->getTargetConstant(Imm, Node->getValueType(0));
  }
  /// getI32Imm - Return a target constant with the specified value, of type
  /// i32.
  SDValue getI32Imm(unsigned Imm) {
    return CurDAG->getTargetConstant(Imm, MVT::i32);
  }

  // Try to fold more of the base or index of AM into AM, where IsBase
  // selects between the base and index.
  bool expandAddress(RISCVAddressingMode &AM, bool IsBase);

  // Try to describe N in AM, returning true on success.
  bool selectAddress(SDValue N, RISCVAddressingMode &AM);

  // Extract individual target operands from matched address AM.
  void getAddressOperands(const RISCVAddressingMode &AM, EVT VT,
                          SDValue &Base, SDValue &Disp);
  void getAddressOperands(const RISCVAddressingMode &AM, EVT VT,
                          SDValue &Base, SDValue &Disp, SDValue &Index);

  //RISCV
  bool selectMemRegAddr(SDValue Addr, SDValue &Base, SDValue &Offset) {
      
    EVT ValTy = Addr.getValueType();

    // if Address is FI, get the TargetFrameIndex.
    if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
      Base   = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
      Offset = CurDAG->getTargetConstant(0, ValTy);
      return true;
    }

    if (TM.getRelocationModel() != Reloc::PIC_) {
      if ((Addr.getOpcode() == ISD::TargetExternalSymbol ||
          Addr.getOpcode() == ISD::TargetGlobalAddress))
        return false;
    }

    // Addresses of the form FI+const or FI|const
    if (CurDAG->isBaseWithConstantOffset(Addr)) {
      ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
      if (isInt<12>(CN->getSExtValue())) {
  
        // If the first operand is a FI, get the TargetFI Node
        if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>
                                    (Addr.getOperand(0)))
          Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
        else
          Base = Addr.getOperand(0);
  
        Offset = CurDAG->getTargetConstant(CN->getZExtValue(), ValTy);
        return true;
      }
    }

    //Last case
    Base = Addr;
    Offset = CurDAG->getTargetConstant(0, Addr.getValueType());
    return true;
  }

  bool selectRegAddr(SDValue Addr, SDValue &Base) {
    //always just register
    Base = Addr;
    //Offset = CurDAG->getTargetConstant(0, Addr.getValueType());
    return true;
  }

  bool replaceUsesWithZeroReg(MachineRegisterInfo *MRI,
                              const MachineInstr& MI) {
    unsigned DstReg = 0, ZeroReg = 0;
  
    // Check if MI is "addiu $dst, $zero, 0" or "daddiu $dst, $zero, 0".
    if ((MI.getOpcode() == RISCV::ADDI) &&
        (MI.getOperand(1).isReg()) && //avoid frame-index
        (MI.getOperand(1).getReg() == RISCV::zero) &&
        (MI.getOperand(2).getImm() == 0)) {
      DstReg = MI.getOperand(0).getReg();
      ZeroReg = RISCV::zero;
    } else if ((MI.getOpcode() == RISCV::ADDI64) &&
               (MI.getOperand(1).isReg()) && //avoid frame-index
               (MI.getOperand(1).getReg() == RISCV::zero_64) &&
               (MI.getOperand(2).getImm() == 0)) {
      DstReg = MI.getOperand(0).getReg();
      ZeroReg = RISCV::zero_64;
    } else if ((MI.getOpcode() == RISCV::ADDIW) &&
               (MI.getOperand(1).isReg()) && //avoid frame-index
               (MI.getOperand(1).getReg() == RISCV::zero_64) &&
               (MI.getOperand(2).getImm() == 0)) {
      DstReg = MI.getOperand(0).getReg();
      ZeroReg = RISCV::zero_64;
    }
  
    if (!DstReg)
      return false;
  
    // Replace uses with ZeroReg.
    for (MachineRegisterInfo::use_iterator U = MRI->use_begin(DstReg),
         E = MRI->use_end(); U != E;) {
      MachineOperand &MO = U.getOperand();
      unsigned OpNo = U.getOperandNo();
      MachineInstr *MI = MO.getParent();
      ++U;
  
      // Do not replace if it is a phi's operand or is tied to def operand.
      if (MI->isPHI() || MI->isRegTiedToDefOperand(OpNo) || MI->isPseudo())
        continue;
  
      MO.setReg(ZeroReg);
    }
  
    return true;
  }

  //End RISCV

  // PC-relative address matching routines used by RISCVOperands.td.
  bool selectPCRelAddress(SDValue Addr, SDValue &Target) {
    if (Addr.getOpcode() == RISCVISD::PCREL_WRAPPER) {
      Target = Addr.getOperand(0);
      return true;
    }
    return false;
  }

  // If Op0 is null, then Node is a constant that can be loaded using:
  //
  //   (Opcode UpperVal LowerVal)
  //
  // If Op0 is nonnull, then Node can be implemented using:
  //
  //   (Opcode (Opcode Op0 UpperVal) LowerVal)
  SDNode *splitLargeImmediate(unsigned Opcode, SDNode *Node, SDValue Op0,
                              uint64_t UpperVal, uint64_t LowerVal);
public:
  RISCVDAGToDAGISel(RISCVTargetMachine &TM, CodeGenOpt::Level OptLevel)
    : SelectionDAGISel(TM, OptLevel),
      Lowering(*TM.getTargetLowering()),
      Subtarget(*TM.getSubtargetImpl()) { }

  // Override MachineFunctionPass.
  virtual const char *getPassName() const LLVM_OVERRIDE {
    return "RISCV DAG->DAG Pattern Instruction Selection";
  }

  // Override SelectionDAGISel.
  virtual bool runOnMachineFunction(MachineFunction &MF);
  virtual SDNode *Select(SDNode *Node) LLVM_OVERRIDE;
  virtual void processFunctionAfterISel(MachineFunction &MF);
  virtual bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                            char ConstraintCode,
                                            std::vector<SDValue> &OutOps)
    LLVM_OVERRIDE;

  // Include the pieces autogenerated from the target description.
  #include "RISCVGenDAGISel.inc"
};
} // end anonymous namespace

bool RISCVDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  bool ret = SelectionDAGISel::runOnMachineFunction(MF);

  if(Subtarget.hasXHwacha()){
    //OpenCL -> vector fetch pass
    processFunctionAfterISel(MF);
  }

  return ret;
}

FunctionPass *llvm::createRISCVISelDag(RISCVTargetMachine &TM,
                                         CodeGenOpt::Level OptLevel) {
  return new RISCVDAGToDAGISel(TM, OptLevel);
}

// Return true if Val should be selected as a displacement for an address
// with range DR.  Here we're interested in the range of both the instruction
// described by DR and of any pairing instruction.
static bool selectOffset(RISCVAddressingMode::OffRange OffR, int64_t Val) {
  switch (OffR) {
  case RISCVAddressingMode::Off12Only:
    return isInt<12>(Val);
  }
  llvm_unreachable("Unhandled offset range");
}

// The base or index of AM is equivalent to Op0 + Op1, where IsBase selects
// between the base and index.  Try to fold Op1 into AM's displacement.
static bool expandOffset(RISCVAddressingMode &AM, bool IsBase,
                       SDValue Op0, ConstantSDNode *Op1) {
  // First try adjusting the displacement.
  int64_t TestOffset = AM.Offset + Op1->getSExtValue();
  if (selectOffset(AM.OffR, TestOffset)) {
    //changeComponent(AM, IsBase, Op0);
    AM.Base = Op0;
    AM.Offset = TestOffset;
    return true;
  }

  // We could consider forcing the displacement into a register and
  // using it as an index, but it would need to be carefully tuned.
  return false;
}

bool RISCVDAGToDAGISel::expandAddress(RISCVAddressingMode &AM,
                                        bool IsBase) {
  //SDValue N = IsBase ? AM.Base : AM.Index;
  SDValue N = AM.Base;
  unsigned Opcode = N.getOpcode();
  if (Opcode == ISD::TRUNCATE) {
    N = N.getOperand(0);
    Opcode = N.getOpcode();
  }
  if (Opcode == ISD::ADD || CurDAG->isBaseWithConstantOffset(N)) {
    SDValue Op0 = N.getOperand(0);
    SDValue Op1 = N.getOperand(1);

    unsigned Op0Code = Op0->getOpcode();
    unsigned Op1Code = Op1->getOpcode();

    if (Op0Code == ISD::Constant)
      return expandOffset(AM, IsBase, Op1, cast<ConstantSDNode>(Op0));
    if (Op1Code == ISD::Constant)
      return expandOffset(AM, IsBase, Op0, cast<ConstantSDNode>(Op1));

  }
  return false;
}

// Return true if an instruction with displacement range DR should be
// used for displacement value Val.  selectDisp(DR, Val) must already hold.
static bool isValidOffset(RISCVAddressingMode::OffRange OffR, int64_t Val) {
  assert(selectOffset(OffR, Val) && "Invalid displacement");
  switch (OffR) {
  case RISCVAddressingMode::Off12Only:
    return true;
  }
  llvm_unreachable("Unhandled displacement range");
}

// Return true if Addr is suitable for AM, updating AM if so.
bool RISCVDAGToDAGISel::selectAddress(SDValue Addr,
                                        RISCVAddressingMode &AM) {
  // Start out assuming that the address will need to be loaded separately,
  // then try to extend it as much as we can.
  AM.Base = Addr;

  // First try treating the address as a constant.
  if (Addr.getOpcode() == ISD::Constant &&
      expandOffset(AM, true, SDValue(), cast<ConstantSDNode>(Addr)))
  { }

  // Reject cases where the other instruction in a pair should be used.
  if (!isValidOffset(AM.OffR, AM.Offset))
    return false;

  DEBUG(AM.dump());
  return true;
}

// Insert a node into the DAG at least before Pos.  This will reposition
// the node as needed, and will assign it a node ID that is <= Pos's ID.
// Note that this does *not* preserve the uniqueness of node IDs!
// The selection DAG must no longer depend on their uniqueness when this
// function is used.
static void insertDAGNode(SelectionDAG *DAG, SDNode *Pos, SDValue N) {
  if (N.getNode()->getNodeId() == -1 ||
      N.getNode()->getNodeId() > Pos->getNodeId()) {
    DAG->RepositionNode(Pos, N.getNode());
    N.getNode()->setNodeId(Pos->getNodeId());
  }
}

void RISCVDAGToDAGISel::getAddressOperands(const RISCVAddressingMode &AM,
                                             EVT VT, SDValue &Base,
                                             SDValue &Offset) {
  Base = AM.Base;
  if (!Base.getNode())
    // Register 0 means "no base".  This is mostly useful for shifts.
    Base = CurDAG->getRegister(0, VT);
  else if (Base.getOpcode() == ISD::FrameIndex) {
    // Lower a FrameIndex to a TargetFrameIndex.
    int64_t FrameIndex = cast<FrameIndexSDNode>(Base)->getIndex();
    Base = CurDAG->getTargetFrameIndex(FrameIndex, VT);
  } else if (Base.getValueType() != VT) {
    // Truncate values from i64 to i32, for shifts.
    assert(VT == MVT::i32 && Base.getValueType() == MVT::i64 &&
           "Unexpected truncation");
    DebugLoc DL = Base.getDebugLoc();
    SDValue Trunc = CurDAG->getNode(ISD::TRUNCATE, DL, VT, Base);
    insertDAGNode(CurDAG, Base.getNode(), Trunc);
    Base = Trunc;
  }

  // Lower the displacement to a TargetConstant.
  Offset = CurDAG->getTargetConstant(AM.Offset, VT);
}


SDNode *RISCVDAGToDAGISel::splitLargeImmediate(unsigned Opcode, SDNode *Node,
                                                 SDValue Op0, uint64_t UpperVal,
                                                 uint64_t LowerVal) {
  EVT VT = Node->getValueType(0);
  DebugLoc DL = Node->getDebugLoc();
  SDValue Upper = CurDAG->getConstant(UpperVal, VT);
  if (Op0.getNode())
    Upper = CurDAG->getNode(Opcode, DL, VT, Op0, Upper);
  Upper = SDValue(Select(Upper.getNode()), 0);

  SDValue Lower = CurDAG->getConstant(LowerVal, VT);
  SDValue Or = CurDAG->getNode(Opcode, DL, VT, Upper, Lower);
  return Or.getNode();
}

SDNode *RISCVDAGToDAGISel::Select(SDNode *Node) {
  DebugLoc DL = Node->getDebugLoc();
  // Dump information about the Node being selected
  DEBUG(errs() << "Selecting: "; Node->dump(CurDAG); errs() << "\n");

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");
    return 0;
  }

  unsigned Opcode = Node->getOpcode();
  switch (Opcode) {
  case ISD::FrameIndex: {
    SDValue imm = CurDAG->getTargetConstant(0, Subtarget.isRV64() ? MVT::i64 : MVT::i32);
    int FI = cast<FrameIndexSDNode>(Node)->getIndex();
    SDValue TFI = CurDAG->getTargetFrameIndex(FI, TLI.getPointerTy());
    unsigned Opc = Subtarget.isRV64() ? RISCV::ADDI64 : RISCV::ADDI;
    EVT VT = Subtarget.isRV64() ? MVT::i64 : MVT::i32;
    
    if(Node->hasOneUse()) //don't create a new node just morph this one
      return CurDAG->SelectNodeTo(Node, Opc, VT, TFI, imm);
    return CurDAG->getMachineNode(Opc, DL, VT, TFI, imm);
  }
  }//end special selections

  // Select the default instruction
  SDNode *ResNode = SelectCode(Node);

  DEBUG(errs() << "=> ";
        if (ResNode == NULL || ResNode == Node)
          Node->dump(CurDAG);
        else
          ResNode->dump(CurDAG);
        errs() << "\n";
        );
  return ResNode;
}

bool RISCVDAGToDAGISel::
SelectInlineAsmMemoryOperand(const SDValue &Op,
                             char ConstraintCode,
                             std::vector<SDValue> &OutOps) {
  assert(ConstraintCode == 'm' && "Unexpected constraint code");

  SDValue Base, Offset;
  selectMemRegAddr(Op, Base, Offset);
  OutOps.push_back(Base);
  OutOps.push_back(Offset);
  return false;
}

//TODO:this pass should be done much more systematically. In its current
//state it is an adhoc unfinished class project. Fixes pending
void RISCVDAGToDAGISel::processFunctionAfterISel(MachineFunction &MF) {

  const TargetInstrInfo *TII = MF.getTarget().getInstrInfo();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  MachineBasicBlock *prevBB;
  MachineBasicBlock::iterator vecLength;
  for (MachineFunction::iterator MFI = MF.begin(), MFE = MF.end(); MFI != MFE;
       ++MFI){
    if(MFI->getName().startswith("pregion_for_entry")){
        //we assume this is a parallel region defined by pocl
        //TODO:use instruction metadata like "!llvm.loop.parallel"
      MachineBasicBlock::iterator vfFallThrough;
      for (MachineBasicBlock::iterator I = MFI->begin(); I != MFI->end(); ++I) {
        //We are going to move all the vector fetch instructions to the end of this function
        if(I->isPHI()){
          //If we are still looking for the first phi which selects the induction variable
          //check if this phi reads the last conditional
          MachineOperand *inductionVar;
          if(I->getOperand(2).isMBB() && I->getOperand(2).getMBB() == MFI){
            //Operand(1) holds the reg we are looking for in the last branch
            inductionVar = &I->getOperand(1);
            //and the other MBB is where we need to insert the VF
            prevBB = I->getOperand(4).getMBB();
          }else if(I->getOperand(4).isMBB() && I->getOperand(4).getMBB() == MFI){
            //Operand(3) holds the reg we are looking for in the last branch
            inductionVar = &I->getOperand(3);
            //and the other MBB is where we need to insert the VF
            prevBB = I->getOperand(2).getMBB();
          }
          MachineBasicBlock::iterator term = MFI->getFirstTerminator();
          while(!term->isConditionalBranch() && !(term->getOperand(0).isMBB() && term->getOperand(0).getMBB() == MFI)) {

            term++;
          }
          //term contains the exit condition of the loop
          MachineOperand exitCond = term->getOperand(1).getReg() == inductionVar->getReg() ?
                                term->getOperand(2) : term->getOperand(1);
          MachineOperand condVar = term->getOperand(1).isReg() ?
                                term->getOperand(1) : term->getOperand(2);

          MachineBasicBlock::iterator defs = term;
          while(defs->findRegisterDefOperandIdx(inductionVar->getReg())==-1){
            if(defs->findRegisterDefOperandIdx(exitCond.getReg())!=-1){
              //this instr defines the exit condition so we will pull it out
              //to use as the vector length
              vecLength = defs;
            }
            defs--;
          }
          //if we still haven't found the vecLength instr keep going
          if(!vecLength){
            vecLength = defs;
            while(vecLength->findRegisterDefOperandIdx(exitCond.getReg())==-1){
              vecLength--;
            }
          }
          //We need to remove the instructions the def its two reg operands
          //i.e. vecLength and defs
          MFI->remove(vecLength);
          MFI->remove(defs);

          //Then we replace term with a stop instruction
            //create stop instruction inserted before term
          BuildMI(*I->getParent(), term, term->getDebugLoc(), TII->get(RISCV::STOP));
          vfFallThrough = MFI->erase(term);

          //Finally we need to have the fall through of this branch placed after the VF
          //TODO:do above to deal with end of vf block

          //After fixing the end we replace this phi with a utidx to a new VirtReg of type VR64
          unsigned VReg = MRI.createVirtualRegister(MRI.getRegClass(I->getOperand(0).getReg()));
          BuildMI(*I->getParent(), I, I->getDebugLoc(), TII->get(RISCV::UTIDX), VReg);

          //We replace uses of the old VirtReg the Phi def'd with the new VirtReg
          MF.getRegInfo().replaceRegWith(I->getOperand(0).getReg(), VReg);
          MFI->erase(I);
          break;
        }
      }
      //After finding and dealing with the phi and branch we need to adjust the CFG
      //and add the vcfg vsetvl and vmsv
      //CFG should be updated last

      //All these instructions are added in place of the original branch to this BB
      //first we find that
      MachineBasicBlock::iterator vfInsert = prevBB->getFirstTerminator();
      //only serach for a terminator if there was one
      if(vfInsert != prevBB->end()){
        //all RISCV terminators have the BB as their first operand
        while(vfInsert->getOperand(0).getMBB() != MFI){ vfInsert++; }
      }
      //First add vsetcfg #live ins,0 (its not just #live ins!)
      //TODO:optimize this, maybe by custom emitting it so we can look at the postRA code
      BuildMI(*prevBB, vfInsert, vfInsert->getDebugLoc(), TII->get(RISCV::VSETCFG)).addImm(32).addImm(32);
      //Next add vsetvl (term's non inductionVar operand)
      prevBB->insert(vfInsert, vecLength);
      BuildMI(*prevBB, vfInsert, vfInsert->getDebugLoc(), TII->get(RISCV::VSETVL),
          MRI.createVirtualRegister(
            MRI.getRegClass(vecLength->getOperand(0).getReg())))
        .addReg(vecLength->getOperand(0).getReg());
      //Then put vmsv's from each live in to new VirtReg's and replace the liveins in this BB with their respective new VirtRegs
      std::vector<unsigned> defs;
      for(MachineBasicBlock::iterator liveins = MFI->begin(); liveins != MFI->end(); liveins++){
        if(liveins->getNumOperands() > 0 && liveins->getOperand(0).isReg() && liveins->getOperand(0).isDef()){
            defs.push_back(liveins->getOperand(0).getReg());
        }
        for(unsigned opIdx = 1; opIdx < liveins->getNumOperands(); opIdx++){
          if(liveins->getOperand(opIdx).isReg() && liveins->getOperand(opIdx).isDef()){
            defs.push_back(liveins->getOperand(opIdx).getReg());
          }
          if(liveins->getOperand(opIdx).isReg() && liveins->getOperand(opIdx).isUse()){
            bool livein = true;
            for(std::vector<unsigned>::iterator ds = defs.begin(); ds != defs.end(); ds++){
              if(*ds == liveins->getOperand(opIdx).getReg()) livein = false;
            }
            if(livein){
              const TargetRegisterClass *RC = MRI.getRegClass(liveins->getOperand(opIdx).getReg());
              unsigned VReg = MRI.createVirtualRegister(RC);
              BuildMI(*prevBB, vfInsert, vfInsert->getDebugLoc(), TII->get(RC == &RISCV::GR64BitRegClass ? RISCV::VMSV64 : RISCV::VMSV),
                  VReg).addReg(liveins->getOperand(opIdx).getReg());
              MachineRegisterInfo::use_iterator users = MRI.use_begin(liveins->getOperand(opIdx).getReg());
              for(;users != MF.getRegInfo().use_end(); users++){
                if(users->getParent() == MFI)
                  users->substituteRegister(liveins->getOperand(opIdx).getReg(), VReg, 0, *MF.getTarget().getRegisterInfo());
              }
            }
          }
        }
      }
      //Next add VF to this BB (which now needs a label)
      unsigned vfAddrReg = MRI.createVirtualRegister(&RISCV::GR64BitRegClass);
      //BuildMI(*prevBB, vfInsert, vfInsert->getDebugLoc(), TII->get(RISCV::LUI64),vfAddrReg).addMBB(MFI, RISCVII::MO_ABS_HI);
      BuildMI(*prevBB, vfInsert, vfInsert->getDebugLoc(), TII->get(RISCV::VFetch)).addMBB(MFI).addReg(vfAddrReg, RegState::Define);
      
      //create a basic block after the vfetch return
      const BasicBlock *retBB = prevBB->getBasicBlock();//->splitBasicBlock(--vfInsert);
      MachineBasicBlock *retMBB = MF.CreateMachineBasicBlock(retBB);
      MachineFunction::iterator MFitr = prevBB;
      MF.insert(++MFitr, retMBB);
      //Put a fence after VF
      BuildMI(retMBB, vfInsert->getDebugLoc(), TII->get(RISCV::FENCE)).addImm(15).addImm(15);
      //Finally update the CFG by taking whatever was after term in this BB and appending it after the fence
      retMBB->splice(retMBB->end(), MFI, vfFallThrough);


      //Disallow rearrangement of MBBs by setting the hot path
      //The BB containing the vf instr should be followed by the fence&ret BB not the vfectch block
      prevBB->addSuccessor(retMBB, 100);
      prevBB->addSuccessor(MFI, 1);

      //The vfetch block is no longer a loop, and returns to the fence&ret BB
      //infrequently so it is not moved after the vfetch block, the falltrhough
      //BB is the hot path here
      MFI->removeSuccessor(MFI);
      MFI->removeSuccessor(vfFallThrough->getOperand(0).getMBB());
      MFI->addSuccessor(retMBB, 1);
      MFI->addSuccessor(vfFallThrough->getOperand(0).getMBB(),100);

      //The fence&ret BB only goes to the fallthrough
      retMBB->addSuccessor(vfFallThrough->getOperand(0).getMBB());
    }
  }
}
