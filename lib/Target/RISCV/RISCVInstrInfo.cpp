//===-- RISCVInstrInfo.cpp - RISCV instruction information ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the RISCV implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "RISCVInstrInfo.h"
#include "RISCVInstrBuilder.h"

#define GET_INSTRINFO_CTOR
#define GET_INSTRMAP_INFO
#include "RISCVGenInstrInfo.inc"

using namespace llvm;

RISCVInstrInfo::RISCVInstrInfo(RISCVTargetMachine &tm)
  : RISCVGenInstrInfo(RISCV::ADJCALLSTACKDOWN, RISCV::ADJCALLSTACKUP),
    RI(tm, *this) {
}

// If MI is a simple load or store for a frame object, return the register
// it loads or stores and set FrameIndex to the index of the frame object.
// Return 0 otherwise.
//
// Flag is SimpleBDXLoad for loads and SimpleBDXStore for stores.
static int isSimpleMove(const MachineInstr *MI, int &FrameIndex, int Flag) {
  const MCInstrDesc &MCID = MI->getDesc();
  if ((MCID.TSFlags & Flag) &&
      MI->getOperand(1).isFI() &&
      MI->getOperand(2).getImm() == 0 &&
      MI->getOperand(3).getReg() == 0) {
    FrameIndex = MI->getOperand(1).getIndex();
    return MI->getOperand(0).getReg();
  }
  return 0;
}

unsigned RISCVInstrInfo::isLoadFromStackSlot(const MachineInstr *MI,
                                               int &FrameIndex) const {
  return isSimpleMove(MI, FrameIndex, RISCVII::SimpleBDXLoad);
}

unsigned RISCVInstrInfo::isStoreToStackSlot(const MachineInstr *MI,
                                              int &FrameIndex) const {
  return isSimpleMove(MI, FrameIndex, RISCVII::SimpleBDXStore);
}

bool RISCVInstrInfo::AnalyzeBranch(MachineBasicBlock &MBB,
                                     MachineBasicBlock *&TBB,
                                     MachineBasicBlock *&FBB,
                                     SmallVectorImpl<MachineOperand> &Cond,
                                     bool AllowModify) const {
  // Most of the code and comments here are boilerplate.

  // Start from the bottom of the block and work up, examining the
  // terminator instructions.
  MachineBasicBlock::iterator I = MBB.end();
  while (I != MBB.begin()) {
    --I;
    if (I->isDebugValue())
      continue;

    // Working from the bottom, when we see a non-terminator instruction, we're
    // done.
    if (!isUnpredicatedTerminator(I))
      break;

    // A terminator that isn't a branch can't easily be handled by this
    // analysis.
    unsigned ThisCond;
    const MachineOperand *ThisTarget;
    if (!isBranch(I, ThisCond, ThisTarget))
      return true;

    // Can't handle indirect branches.
    if (!ThisTarget->isMBB())
      return true;

    if (ThisCond == RISCV::CCMASK_ANY) {
      // Handle unconditional branches.
      if (!AllowModify) {
        TBB = ThisTarget->getMBB();
        continue;
      }

      // If the block has any instructions after a JMP, delete them.
      while (llvm::next(I) != MBB.end())
        llvm::next(I)->eraseFromParent();

      Cond.clear();
      FBB = 0;

      // Delete the JMP if it's equivalent to a fall-through.
      if (MBB.isLayoutSuccessor(ThisTarget->getMBB())) {
        TBB = 0;
        I->eraseFromParent();
        I = MBB.end();
        continue;
      }

      // TBB is used to indicate the unconditinal destination.
      TBB = ThisTarget->getMBB();
      continue;
    }

    // Working from the bottom, handle the first conditional branch.
    if (Cond.empty()) {
      // FIXME: add X86-style branch swap
      FBB = TBB;
      TBB = ThisTarget->getMBB();
      Cond.push_back(MachineOperand::CreateImm(ThisCond));
      continue;
    }

    // Handle subsequent conditional branches.
    assert(Cond.size() == 1);
    assert(TBB);

    // Only handle the case where all conditional branches branch to the same
    // destination.
    if (TBB != ThisTarget->getMBB())
      return true;

    // If the conditions are the same, we can leave them alone.
    unsigned OldCond = Cond[0].getImm();
    if (OldCond == ThisCond)
      continue;

    // FIXME: Try combining conditions like X86 does.  Should be easy on Z!
  }

  return false;
}

unsigned RISCVInstrInfo::RemoveBranch(MachineBasicBlock &MBB) const {
  // Most of the code and comments here are boilerplate.
  MachineBasicBlock::iterator I = MBB.end();
  unsigned Count = 0;

  while (I != MBB.begin()) {
    --I;
    if (I->isDebugValue())
      continue;
    unsigned Cond;
    const MachineOperand *Target;
    if (!isBranch(I, Cond, Target))
      break;
    if (!Target->isMBB())
      break;
    // Remove the branch.
    I->eraseFromParent();
    I = MBB.end();
    ++Count;
  }

  return Count;
}

unsigned
RISCVInstrInfo::InsertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                               MachineBasicBlock *FBB,
                               const SmallVectorImpl<MachineOperand> &Cond,
                               DebugLoc DL) const {
  // In this function we output 32-bit branches, which should always
  // have enough range.  They can be shortened and relaxed by later code
  // in the pipeline, if desired.

  // Shouldn't be a fall through.
  assert(TBB && "InsertBranch must not be told to insert a fallthrough");
  assert((Cond.size() == 1 || Cond.size() == 0) &&
         "RISCV branch conditions have one component!");

  if (Cond.empty()) {
    // Unconditional branch?
    assert(!FBB && "Unconditional branch with multiple successors!");
    BuildMI(&MBB, DL, get(RISCV::J)).addMBB(TBB);
    return 1;
  }

  // Conditional branch.
  unsigned Count = 0;
  unsigned CC = Cond[0].getImm();
  /*TODO: no more BRCL
  BuildMI(&MBB, DL, get(RISCV::BRCL)).addImm(CC).addMBB(TBB);
  */
  ++Count;

  if (FBB) {
    // Two-way Conditional branch. Insert the second branch.
    //BuildMI(&MBB, DL, get(RISCV::JG)).addMBB(FBB);
    ++Count;
  }
  return Count;
}

void
RISCVInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
			      MachineBasicBlock::iterator MBBI, DebugLoc DL,
			      unsigned DestReg, unsigned SrcReg,
			      bool KillSrc) const {

  // Everything else needs only one instruction.
  unsigned Opcode;
  if (RISCV::GR32BitRegClass.contains(DestReg, SrcReg))
    Opcode = RISCV::ORI;
  else if (RISCV::FP32BitRegClass.contains(DestReg, SrcReg))
    Opcode = RISCV::LER;
  else
    llvm_unreachable("Impossible reg-to-reg copy");

  BuildMI(MBB, MBBI, DL, get(Opcode), DestReg)
    .addReg(SrcReg, getKillRegState(KillSrc))
    .addImm(0);
}

void
RISCVInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
				      MachineBasicBlock::iterator MBBI,
				      unsigned SrcReg, bool isKill,
				      int FrameIdx,
				      const TargetRegisterClass *RC,
				      const TargetRegisterInfo *TRI) const {
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();

  // Callers may expect a single instruction, so keep 128-bit moves
  // together for now and lower them after register allocation.
  unsigned LoadOpcode, StoreOpcode;
  getLoadStoreOpcodes(RC, LoadOpcode, StoreOpcode);
  addFrameReference(BuildMI(MBB, MBBI, DL, get(StoreOpcode))
		    .addReg(SrcReg, getKillRegState(isKill)), FrameIdx);
}

void
RISCVInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
				       MachineBasicBlock::iterator MBBI,
				       unsigned DestReg, int FrameIdx,
				       const TargetRegisterClass *RC,
				       const TargetRegisterInfo *TRI) const {
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();

  // Callers may expect a single instruction, so keep 128-bit moves
  // together for now and lower them after register allocation.
  unsigned LoadOpcode, StoreOpcode;
  getLoadStoreOpcodes(RC, LoadOpcode, StoreOpcode);
  addFrameReference(BuildMI(MBB, MBBI, DL, get(LoadOpcode), DestReg),
                    FrameIdx);
}

bool
RISCVInstrInfo::expandPostRAPseudo(MachineBasicBlock::iterator MI) const {
  switch (MI->getOpcode()) {

  default:
    return false;
  }
}

bool RISCVInstrInfo::
ReverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const {
  assert(Cond.size() == 1 && "Invalid branch condition!");
  Cond[0].setImm(Cond[0].getImm() ^ RISCV::CCMASK_ANY);
  return false;
}

bool RISCVInstrInfo::isBranch(const MachineInstr *MI, unsigned &Cond,
                                const MachineOperand *&Target) const {
  switch (MI->getOpcode()) {
  case RISCV::J:
  case RISCV::JAL:
  case RISCV::JALR:
    Cond = RISCV::CCMASK_ANY;
    Target = &MI->getOperand(0);
    return true;
  case RISCV::BEQ:
    Cond = RISCV::CCMASK_CMP_EQ;
    Target = &MI->getOperand(2);
    return true;
  case RISCV::BNE:
    Cond = RISCV::CCMASK_CMP_NE;
    Target = &MI->getOperand(2);
    return true;
  case RISCV::BLT:
  case RISCV::BLTU:
    Cond = RISCV::CCMASK_CMP_LT;
    Target = &MI->getOperand(2);
    return true;
  case RISCV::BGE:
  case RISCV::BGEU:
    Cond = RISCV::CCMASK_CMP_GE;
    Target = &MI->getOperand(2);
    return true;

  default:
    assert(!MI->getDesc().isBranch() && "Unknown branch opcode");
    return false;
  }
}

void RISCVInstrInfo::getLoadStoreOpcodes(const TargetRegisterClass *RC,
                                           unsigned &LoadOpcode,
                                           unsigned &StoreOpcode) const {
    /*TODO: no load stores for now
  if (RC == &RISCV::GR32BitRegClass || RC == &RISCV::ADDR32BitRegClass) {
    LoadOpcode = RISCV::L;
    StoreOpcode = RISCV::ST32;
  } else if (RC == &RISCV::GR64BitRegClass ||
             RC == &RISCV::ADDR64BitRegClass) {
    LoadOpcode = RISCV::LG;
    StoreOpcode = RISCV::STG;
  } else if (RC == &RISCV::GR128BitRegClass ||
             RC == &RISCV::ADDR128BitRegClass) {
    LoadOpcode = RISCV::L128;
    StoreOpcode = RISCV::ST128;
  } else if (RC == &RISCV::FP32BitRegClass) {
    LoadOpcode = RISCV::LE;
    StoreOpcode = RISCV::STE;
  } else if (RC == &RISCV::FP64BitRegClass) {
    LoadOpcode = RISCV::LD;
    StoreOpcode = RISCV::STD;
  } else if (RC == &RISCV::FP128BitRegClass) {
    LoadOpcode = RISCV::LX;
    StoreOpcode = RISCV::STX;
  } else
    llvm_unreachable("Unsupported regclass to load or store");
    */
}

unsigned RISCVInstrInfo::getOpcodeForOffset(unsigned Opcode,
                                              int64_t Offset) const {
  const MCInstrDesc &MCID = get(Opcode);
  int64_t Offset2 = (MCID.TSFlags & RISCVII::Is128Bit ? Offset + 8 : Offset);
  if (isUInt<12>(Offset) && isUInt<12>(Offset2)) {
    // Get the instruction to use for unsigned 12-bit displacements.
    int Disp12Opcode = RISCV::getDisp12Opcode(Opcode);
    if (Disp12Opcode >= 0)
      return Disp12Opcode;

    // All address-related instructions can use unsigned 12-bit
    // displacements.
    return Opcode;
  }
  if (isInt<20>(Offset) && isInt<20>(Offset2)) {
    // Get the instruction to use for signed 20-bit displacements.
    int Disp20Opcode = RISCV::getDisp20Opcode(Opcode);
    if (Disp20Opcode >= 0)
      return Disp20Opcode;

    // Check whether Opcode allows signed 20-bit displacements.
    if (MCID.TSFlags & RISCVII::Has20BitOffset)
      return Opcode;
  }
  return 0;
}

void RISCVInstrInfo::loadImmediate(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator MBBI,
                                     unsigned Reg, uint64_t Value) const {
  /*TODO no valid instrs here
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
  unsigned Opcode;
  if (isInt<16>(Value))
    Opcode = RISCV::LGHI;
  else if (RISCV::isImmLL(Value))
    Opcode = RISCV::LLILL;
  else if (RISCV::isImmLH(Value)) {
    Opcode = RISCV::LLILH;
    Value >>= 16;
  } else {
    assert(isInt<32>(Value) && "Huge values not handled yet");
    Opcode = RISCV::LGFI;
  }
  BuildMI(MBB, MBBI, DL, get(Opcode), Reg).addImm(Value);
  */
}
