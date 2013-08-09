//===-- RISCVFrameLowering.cpp - Frame lowering for RISCV -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVFrameLowering.h"
#include "RISCVCallingConv.h"
#include "RISCVInstrBuilder.h"
#include "RISCVMachineFunctionInfo.h"
#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Function.h"

using namespace llvm;

RISCVFrameLowering::RISCVFrameLowering(const RISCVTargetMachine &tm,
                                           const RISCVSubtarget &sti)
  : TargetFrameLowering(TargetFrameLowering::StackGrowsDown, 8,
                        -RISCVMC::CallFrameSize),
    TM(tm),
    STI(sti) {
  // The ABI-defined register save slots, relative to the incoming stack
  // pointer.
  // TODO: check that this is correct, specifically which regs should be in this table
  static const unsigned SpillOffsetTable[][2] = {
    { RISCV::fp,  0x10 },
    { RISCV::s1,  0x18 },
    { RISCV::s2,  0x20 },
    { RISCV::s3,  0x28 },
    { RISCV::s4,  0x30 },
    { RISCV::s5,  0x38 },
    { RISCV::s6,  0x40 },
    { RISCV::s7,  0x48 },
    { RISCV::s8,  0x50 },
    { RISCV::s9,  0x58 },
    { RISCV::s10, 0x60 },
    { RISCV::s11, 0x68 },
    { RISCV::sp,  0x70 },
    { RISCV::tp,  0x78 }
  };

  // Create a mapping from register number to save slot offset.
  RegSpillOffsets.grow(RISCV::NUM_TARGET_REGS);
  for (unsigned I = 0, E = array_lengthof(SpillOffsetTable); I != E; ++I)
    RegSpillOffsets[SpillOffsetTable[I][0]] = SpillOffsetTable[I][1];
}

void RISCVFrameLowering::
processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
                                     RegScavenger *RS) const {
  MachineFrameInfo *MFFrame = MF.getFrameInfo();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  //TODO:generates unused variable warning
  const TargetRegisterInfo *TRI = MF.getTarget().getRegisterInfo();
  bool HasFP = hasFP(MF);
  RISCVMachineFunctionInfo *MFI = MF.getInfo<RISCVMachineFunctionInfo>();
  bool IsVarArg = MF.getFunction()->isVarArg();

  // va_start stores incoming FPR varargs in the normal way, but delegates
  // the saving of incoming GPR varargs to spillCalleeSavedRegisters().
  // Record these pending uses, which typically include the call-saved
  // argument register R6D.
  if (IsVarArg)
    for (unsigned I = MFI->getVarArgsFirstGPR(); I < RISCV::NumArgGPRs; ++I)
      MRI.setPhysRegUsed(RISCV::ArgGPRs[I]);

  // If the function requires a frame pointer, record that the hard
  // frame pointer will be clobbered.
  if (HasFP)
    MRI.setPhysRegUsed(RISCV::fp);

  // If the function calls other functions, record that the return
  // address register will be clobbered.
  if (MFFrame->hasCalls())
    MRI.setPhysRegUsed(RISCV::ra);

}


bool RISCVFrameLowering::
spillCalleeSavedRegisters(MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MBBI,
                          const std::vector<CalleeSavedInfo> &CSI,
                          const TargetRegisterInfo *TRI) const {
  if (CSI.empty())
    return false;

  MachineFunction &MF = *MBB.getParent();
  const TargetInstrInfo *TII = MF.getTarget().getInstrInfo();
  RISCVMachineFunctionInfo *ZFI = MF.getInfo<RISCVMachineFunctionInfo>();
  bool IsVarArg = MF.getFunction()->isVarArg();
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();

  // Scan the call-saved GPRs and find the bounds of the register spill area.
  unsigned SavedGPRFrameSize = 0;
  unsigned LowGPR = 0;
  unsigned HighGPR = RISCV::a13;
  unsigned StartOffset = -1U;
  for (unsigned I = 0, E = CSI.size(); I != E; ++I) {
    unsigned Reg = CSI[I].getReg();
  }

  // Save information about the range and location of the call-saved
  // registers, for use by the epilogue inserter.
  ZFI->setSavedGPRFrameSize(SavedGPRFrameSize);
  ZFI->setLowSavedGPR(LowGPR);
  ZFI->setHighSavedGPR(HighGPR);

  // Include the GPR varargs, if any.  R6D is call-saved, so would
  // be included by the loop above, but we also need to handle the
  // call-clobbered argument registers.
  if (IsVarArg) {
    unsigned FirstGPR = ZFI->getVarArgsFirstGPR();
    if (FirstGPR < RISCV::NumArgGPRs) {
      unsigned Reg = RISCV::ArgGPRs[FirstGPR];
      unsigned Offset = RegSpillOffsets[Reg];
      if (StartOffset > Offset) {
        LowGPR = Reg; StartOffset = Offset;
      }
    }
  }

  // Save GPRs
  if (LowGPR) {
    assert(LowGPR != HighGPR && "Should be saving %r15 and something else");

    /*TODO: no stmg or saving regs yet
    // Build an STMG instruction.
    MachineInstrBuilder MIB = BuildMI(MBB, MBBI, DL, TII->get(RISCV::STMG));

    // Add the explicit register operands.
    addSavedGPR(MBB, MIB, TM, LowGPR, false);
    addSavedGPR(MBB, MIB, TM, HighGPR, false);

    // Add the address.
    MIB.addReg(RISCV::R15D).addImm(StartOffset);

    // Make sure all call-saved GPRs are included as operands and are
    // marked as live on entry.
    for (unsigned I = 0, E = CSI.size(); I != E; ++I) {
      unsigned Reg = CSI[I].getReg();
      if (RISCV::GR64BitRegClass.contains(Reg))
        addSavedGPR(MBB, MIB, TM, Reg, true);
    }

    // ...likewise GPR varargs.
    if (IsVarArg)
      for (unsigned I = ZFI->getVarArgsFirstGPR(); I < RISCV::NumArgGPRs; ++I)
        addSavedGPR(MBB, MIB, TM, RISCV::ArgGPRs[I], true);
    */
  }

  // Save FPRs in the normal TargetInstrInfo way.
  for (unsigned I = 0, E = CSI.size(); I != E; ++I) {
    unsigned Reg = CSI[I].getReg();
    if (RISCV::FP32BitRegClass.contains(Reg)) {
      MBB.addLiveIn(Reg);
      TII->storeRegToStackSlot(MBB, MBBI, Reg, true, CSI[I].getFrameIdx(),
                               &RISCV::FP32BitRegClass, TRI);
    }
  }

  return true;
}

bool RISCVFrameLowering::
restoreCalleeSavedRegisters(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator MBBI,
                            const std::vector<CalleeSavedInfo> &CSI,
                            const TargetRegisterInfo *TRI) const {
  if (CSI.empty())
    return false;

  MachineFunction &MF = *MBB.getParent();
  const TargetInstrInfo *TII = MF.getTarget().getInstrInfo();
  RISCVMachineFunctionInfo *ZFI = MF.getInfo<RISCVMachineFunctionInfo>();
  bool HasFP = hasFP(MF);
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();

  // Restore FPRs in the normal TargetInstrInfo way.
  for (unsigned I = 0, E = CSI.size(); I != E; ++I) {
    unsigned Reg = CSI[I].getReg();
    if (RISCV::FP32BitRegClass.contains(Reg))
      TII->loadRegFromStackSlot(MBB, MBBI, Reg, CSI[I].getFrameIdx(),
                                &RISCV::FP32BitRegClass, TRI);
  }

  // Restore call-saved GPRs (but not call-clobbered varargs, which at
  // this point might hold return values).
  unsigned LowGPR = ZFI->getLowSavedGPR();
  unsigned HighGPR = ZFI->getHighSavedGPR();
  unsigned StartOffset = RegSpillOffsets[LowGPR];
  if (LowGPR) {
    // If we saved any of %r2-%r5 as varargs, we should also be saving
    // and restoring %r6.  If we're saving %r6 or above, we should be
    // restoring it too.
    assert(LowGPR != HighGPR && "Should be loading %r15 and something else");

    /*TODO: no LMG or loading from spill yet TODO
    // Build an LMG instruction.
    MachineInstrBuilder MIB = BuildMI(MBB, MBBI, DL, TII->get(RISCV::LMG));

    // Add the explicit register operands.
    MIB.addReg(LowGPR, RegState::Define);
    MIB.addReg(HighGPR, RegState::Define);

    // Add the address.
    MIB.addReg(HasFP ? RISCV::R11D : RISCV::R15D);
    MIB.addImm(StartOffset);

    // Do a second scan adding regs as being defined by instruction
    for (unsigned I = 0, E = CSI.size(); I != E; ++I) {
      unsigned Reg = CSI[I].getReg();
      if (Reg != LowGPR && Reg != HighGPR)
        MIB.addReg(Reg, RegState::ImplicitDefine);
    }
    */
  }

  return true;
}

// Emit instructions before MBBI (in MBB) to add NumBytes to Reg.
static void emitIncrement(MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator &MBBI,
                          const DebugLoc &DL,
                          unsigned Reg, int64_t NumBytes,
                          const TargetInstrInfo *TII) {
}

void RISCVFrameLowering::emitPrologue(MachineFunction &MF) const {
  MachineBasicBlock &MBB = MF.front();
  MachineFrameInfo *MFFrame = MF.getFrameInfo();
  const RISCVInstrInfo *ZII =
    static_cast<const RISCVInstrInfo*>(MF.getTarget().getInstrInfo());
  RISCVMachineFunctionInfo *ZFI = MF.getInfo<RISCVMachineFunctionInfo>();
  MachineBasicBlock::iterator MBBI = MBB.begin();
  MachineModuleInfo &MMI = MF.getMMI();
  std::vector<MachineMove> &Moves = MMI.getFrameMoves();
  const std::vector<CalleeSavedInfo> &CSI = MFFrame->getCalleeSavedInfo();
  bool HasFP = hasFP(MF);
  DebugLoc DL = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();

  // The current offset of the stack pointer from the CFA.
  int64_t SPOffsetFromCFA = -RISCVMC::CFAOffsetFromInitialSP;

  if (ZFI->getLowSavedGPR()) {
    /*TODO no GPR saves yet
    // Skip over the GPR saves.
    if (MBBI != MBB.end() && MBBI->getOpcode() == RISCV::STMG)
      ++MBBI;
    else
      llvm_unreachable("Couldn't skip over GPR saves");

    // Add CFI for the GPR saves.
    MCSymbol *GPRSaveLabel = MMI.getContext().CreateTempSymbol();
    BuildMI(MBB, MBBI, DL,
            ZII->get(TargetOpcode::PROLOG_LABEL)).addSym(GPRSaveLabel);
    for (std::vector<CalleeSavedInfo>::const_iterator
           I = CSI.begin(), E = CSI.end(); I != E; ++I) {
      unsigned Reg = I->getReg();
      if (RISCV::GR64BitRegClass.contains(Reg)) {
        int64_t Offset = SPOffsetFromCFA + RegSpillOffsets[Reg];
        MachineLocation StackSlot(MachineLocation::VirtualFP, Offset);
        MachineLocation RegValue(Reg);
        Moves.push_back(MachineMove(GPRSaveLabel, StackSlot, RegValue));
      }
    }
    */
  }

  uint64_t StackSize = getAllocatedStackSize(MF);
  if (StackSize) {
    // Allocate StackSize bytes.
    int64_t Delta = -int64_t(StackSize);
    emitIncrement(MBB, MBBI, DL, RISCV::sp, Delta, ZII);

    // Add CFI for the allocation.
    MCSymbol *AdjustSPLabel = MMI.getContext().CreateTempSymbol();
    BuildMI(MBB, MBBI, DL, ZII->get(TargetOpcode::PROLOG_LABEL))
      .addSym(AdjustSPLabel);
    MachineLocation FPDest(MachineLocation::VirtualFP);
    MachineLocation FPSrc(MachineLocation::VirtualFP, SPOffsetFromCFA + Delta);
    Moves.push_back(MachineMove(AdjustSPLabel, FPDest, FPSrc));
    SPOffsetFromCFA += Delta;
  }

  if (HasFP) {

    // Add CFI for the new frame location.
    MCSymbol *SetFPLabel = MMI.getContext().CreateTempSymbol();
    BuildMI(MBB, MBBI, DL, ZII->get(TargetOpcode::PROLOG_LABEL))
      .addSym(SetFPLabel);
    MachineLocation HardFP(RISCV::fp);
    MachineLocation VirtualFP(MachineLocation::VirtualFP);
    Moves.push_back(MachineMove(SetFPLabel, HardFP, VirtualFP));

    // Mark the FramePtr as live at the beginning of every block except
    // the entry block.  (We'll have marked R11 as live on entry when
    // saving the GPRs.)
    for (MachineFunction::iterator
           I = llvm::next(MF.begin()), E = MF.end(); I != E; ++I)
      I->addLiveIn(RISCV::fp);
  }

  // Skip over the FPR saves.
  MCSymbol *FPRSaveLabel = 0;
  for (std::vector<CalleeSavedInfo>::const_iterator
         I = CSI.begin(), E = CSI.end(); I != E; ++I) {
    unsigned Reg = I->getReg();
    if (RISCV::FP32BitRegClass.contains(Reg)) {

      // Add CFI for the this save.
      if (!FPRSaveLabel)
        FPRSaveLabel = MMI.getContext().CreateTempSymbol();
      unsigned Reg = I->getReg();
      int64_t Offset = getFrameIndexOffset(MF, I->getFrameIdx());
      MachineLocation Slot(MachineLocation::VirtualFP,
                           SPOffsetFromCFA + Offset);
      MachineLocation RegValue(Reg);
      Moves.push_back(MachineMove(FPRSaveLabel, Slot, RegValue));
    }
  }
  // Complete the CFI for the FPR saves, modelling them as taking effect
  // after the last save.
  if (FPRSaveLabel)
    BuildMI(MBB, MBBI, DL, ZII->get(TargetOpcode::PROLOG_LABEL))
      .addSym(FPRSaveLabel);
}

void RISCVFrameLowering::emitEpilogue(MachineFunction &MF,
                                        MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  const RISCVInstrInfo *ZII =
    static_cast<const RISCVInstrInfo*>(MF.getTarget().getInstrInfo());
  RISCVMachineFunctionInfo *ZFI = MF.getInfo<RISCVMachineFunctionInfo>();

  // Skip the return instruction.
  assert(MBBI->getOpcode() == RISCV::RET &&
         "Can only insert epilogue into returning blocks");

  uint64_t StackSize = getAllocatedStackSize(MF);
  if (ZFI->getLowSavedGPR()) {
    --MBBI;
    unsigned Opcode = MBBI->getOpcode();
    /*TODO: no LMG or restore from spills yet
    if (Opcode != RISCV::LMG)
      llvm_unreachable("Expected to see callee-save register restore code");
    */

    unsigned AddrOpNo = 2;
    DebugLoc DL = MBBI->getDebugLoc();
    uint64_t Offset = StackSize + MBBI->getOperand(AddrOpNo + 1).getImm();
    unsigned NewOpcode = ZII->getOpcodeForOffset(Opcode, Offset);

    // If the offset is too large, use the largest stack-aligned offset
    // and add the rest to the base register (the stack or frame pointer).
    if (!NewOpcode) {
      uint64_t NumBytes = Offset - 0x7fff8;
      emitIncrement(MBB, MBBI, DL, MBBI->getOperand(AddrOpNo).getReg(),
                    NumBytes, ZII);
      Offset -= NumBytes;
      NewOpcode = ZII->getOpcodeForOffset(Opcode, Offset);
      assert(NewOpcode && "No restore instruction available");
    }

    MBBI->setDesc(ZII->get(NewOpcode));
    MBBI->getOperand(AddrOpNo + 1).ChangeToImmediate(Offset);
  } else if (StackSize) {
    DebugLoc DL = MBBI->getDebugLoc();
    emitIncrement(MBB, MBBI, DL, RISCV::sp, StackSize, ZII);
  }
}

bool RISCVFrameLowering::hasFP(const MachineFunction &MF) const {
  return (MF.getTarget().Options.DisableFramePointerElim(MF) ||
          MF.getFrameInfo()->hasVarSizedObjects() ||
          MF.getInfo<RISCVMachineFunctionInfo>()->getManipulatesSP());
}

int RISCVFrameLowering::getFrameIndexOffset(const MachineFunction &MF,
                                              int FI) const {
  const MachineFrameInfo *MFFrame = MF.getFrameInfo();

  // Start with the offset of FI from the top of the caller-allocated frame
  // (i.e. the top of the 160 bytes allocated by the caller).  This initial
  // offset is therefore negative.
  int64_t Offset = (MFFrame->getObjectOffset(FI) +
                    MFFrame->getOffsetAdjustment());
  if (FI >= 0)
    // Non-fixed objects are allocated below the incoming stack pointer.
    // Account for the space at the top of the frame that we choose not
    // to allocate.
    Offset += getUnallocatedTopBytes(MF);

  // Make the offset relative to the incoming stack pointer.
  Offset -= getOffsetOfLocalArea();

  // Make the offset relative to the bottom of the frame.
  Offset += getAllocatedStackSize(MF);

  return Offset;
}

uint64_t RISCVFrameLowering::
getUnallocatedTopBytes(const MachineFunction &MF) const {
  return MF.getInfo<RISCVMachineFunctionInfo>()->getSavedGPRFrameSize();
}

uint64_t RISCVFrameLowering::
getAllocatedStackSize(const MachineFunction &MF) const {
  const MachineFrameInfo *MFFrame = MF.getFrameInfo();

  // Start with the size of the local variables and spill slots.
  uint64_t StackSize = MFFrame->getStackSize();

  // Remove any bytes that we choose not to allocate.
  StackSize -= getUnallocatedTopBytes(MF);

  // Include space for an emergency spill slot, if one might be needed.
  StackSize += getEmergencySpillSlotSize(MF);

  // We need to allocate the ABI-defined 160-byte base area whenever
  // we allocate stack space for our own use and whenever we call another
  // function.
  if (StackSize || MFFrame->hasVarSizedObjects() || MFFrame->hasCalls())
    StackSize += RISCVMC::CallFrameSize;

  return StackSize;
}

unsigned RISCVFrameLowering::
getEmergencySpillSlotSize(const MachineFunction &MF) const {
  const MachineFrameInfo *MFFrame = MF.getFrameInfo();
  uint64_t MaxReach = MFFrame->getStackSize() + RISCVMC::CallFrameSize * 2;
  return isUInt<12>(MaxReach) ? 0 : 8;
}

unsigned RISCVFrameLowering::
getEmergencySpillSlotOffset(const MachineFunction &MF) const {
  assert(getEmergencySpillSlotSize(MF) && "No emergency spill slot");
  return RISCVMC::CallFrameSize;
}

bool
RISCVFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  // The ABI requires us to allocate 160 bytes of stack space for the callee,
  // with any outgoing stack arguments being placed above that.  It seems
  // better to make that area a permanent feature of the frame even if
  // we're using a frame pointer.
  return true;
}

void RISCVFrameLowering::
eliminateCallFramePseudoInstr(MachineFunction &MF,
                              MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator MI) const {
  switch (MI->getOpcode()) {
  case RISCV::ADJCALLSTACKDOWN:
  case RISCV::ADJCALLSTACKUP:
    assert(hasReservedCallFrame(MF) &&
           "ADJSTACKDOWN and ADJSTACKUP should be no-ops");
    MBB.erase(MI);
    break;

  default:
    llvm_unreachable("Unexpected call frame instruction");
  }
}
