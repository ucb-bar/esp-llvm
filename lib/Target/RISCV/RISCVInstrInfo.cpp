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
// Flag is SimpleLoad for loads and SimpleStore for stores.
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
  return isSimpleMove(MI, FrameIndex, RISCVII::SimpleLoad);
}

unsigned RISCVInstrInfo::isStoreToStackSlot(const MachineInstr *MI,
                                              int &FrameIndex) const {
  return isSimpleMove(MI, FrameIndex, RISCVII::SimpleStore);
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

    // FIXME: Try combining conditions like X86 does.
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
  // Shouldn't be a fall through.
  assert(TBB && "InsertBranch must not be told to insert a fallthrough");
  assert((Cond.size() == 1 || Cond.size() == 0) &&
         "RISCV branch conditions have one component!");

  if (Cond.empty()) {
    // Unconditional branch
    assert(!FBB && "Unconditional branch with multiple successors!");
    BuildMI(&MBB, DL, get(RISCV::J)).addMBB(TBB);
    return 1;
  }

  // Conditional branch.
  unsigned Count = 0;
  unsigned CC = Cond[0].getImm();
  switch(CC) {
    case RISCV::CCMASK_CMP_EQ:
      BuildMI(&MBB, DL, get(RISCV::BEQ)).addImm(CC).addMBB(TBB);//TODO: Should there be an addImm
      break;
    case RISCV::CCMASK_CMP_NE:
      BuildMI(&MBB, DL, get(RISCV::BNE)).addImm(CC).addMBB(TBB);//TODO: Should there be an addImm
      break;
    case RISCV::CCMASK_CMP_LT:
      BuildMI(&MBB, DL, get(RISCV::BLT)).addImm(CC).addMBB(TBB);//TODO: Should there be an addImm
      break;
    case (RISCV::CCMASK_CMP_LT | RISCV::CCMASK_CMP_UO):
      BuildMI(&MBB, DL, get(RISCV::BLTU)).addImm(CC).addMBB(TBB);//TODO: Should there be an addImm
      break;
    case RISCV::CCMASK_CMP_GE:
      BuildMI(&MBB, DL, get(RISCV::BGE)).addImm(CC).addMBB(TBB);//TODO: Should there be an addImm
      break;
    case (RISCV::CCMASK_CMP_GE | RISCV::CCMASK_CMP_UO):
      BuildMI(&MBB, DL, get(RISCV::BGEU)).addImm(CC).addMBB(TBB);//TODO: Should there be an addImm
      break;
    default:
      llvm_unreachable("Invalid branch condition code!");
  }
  ++Count;

  //TODO: does RISCV have any two way branches (assume not)
  if (FBB) {
    ++Count;
    llvm_unreachable("Can not insert two-way branch!");
  }
  return Count;
}

void
RISCVInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
			      MachineBasicBlock::iterator MBBI, DebugLoc DL,
			      unsigned DestReg, unsigned SrcReg,
			      bool KillSrc) const {

  unsigned Opcode;
  if (RISCV::GR32BitRegClass.contains(DestReg, SrcReg))
    Opcode = RISCV::ORI;
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
    Cond = RISCV::CCMASK_CMP_LT;
    Target = &MI->getOperand(2);
    return true;
  case RISCV::BLTU:
    Cond = RISCV::CCMASK_CMP_LT | RISCV::CCMASK_CMP_UO;
    Target = &MI->getOperand(2);
    return true;
  case RISCV::BGE:
    Cond = RISCV::CCMASK_CMP_GE;
    Target = &MI->getOperand(2);
    return true;
  case RISCV::BGEU:
    Cond = RISCV::CCMASK_CMP_GE | RISCV::CCMASK_CMP_UO;
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
  if (RC == &RISCV::GR32BitRegClass || RC == &RISCV::ADDR32BitRegClass) {
    LoadOpcode = RISCV::LW;
    StoreOpcode = RISCV::SW;
  } else
    llvm_unreachable("Unsupported regclass to load or store");
}

unsigned RISCVInstrInfo::getOpcodeForOffset(unsigned Opcode,
                                              int64_t Offset) const {
  const MCInstrDesc &MCID = get(Opcode);
  //int64_t Offset2 = (MCID.TSFlags & RISCVII::Is128Bit ? Offset + 8 : Offset);
  int64_t Offset2 = Offset;
  if (isUInt<12>(Offset) && isUInt<12>(Offset2)) {
    return Opcode;
  }
  if (isInt<20>(Offset) && isInt<20>(Offset2)) {
      return Opcode;
  }
  return 0;
}

void RISCVInstrInfo::loadImmediate(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator MBBI,
                                     unsigned Reg, uint64_t Value) const {
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
  unsigned Opcode;
  if (isInt<12>(Value)){
    Opcode = RISCV::ORI;
    BuildMI(MBB, MBBI, DL, get(Opcode), Reg).addReg(RISCV::zero).addImm(Value);
  } else {
    assert(isInt<32>(Value) && "Huge values not handled yet");
    uint64_t upper20 = 0x00000000000FFFFF & (Value >> 12);
    uint64_t lower12 = 0x0000000000000FFF & (Value);
    Opcode = RISCV::LUI;
    BuildMI(MBB, MBBI, DL, get(Opcode), Reg).addImm(upper20);
    Opcode = RISCV::ORI;
    BuildMI(MBB, MBBI, DL, get(Opcode), Reg).addReg(RISCV::zero).addImm(lower12);
  }
}
