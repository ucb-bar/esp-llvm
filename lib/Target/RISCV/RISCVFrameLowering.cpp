//===-- RISCVFrameLowering.cpp - Frame lowering for RISCV -------*- C++ -*-===//
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
#include "RISCVInstrInfo.h"
#include "RISCVMachineFunctionInfo.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/Function.h"

using namespace llvm;

RISCVFrameLowering::RISCVFrameLowering()
    : TargetFrameLowering(TargetFrameLowering::StackGrowsDown, 16, 0) {}
/*   RISCV stack frames look like:

    +-------------------------------+
    |  incoming stack arguments     |
    +-------------------------------+
  A |  caller-allocated save area   |
    |  for register arguments       |
    +-------------------------------+ <-- incoming stack pointer
  B |  callee-allocated save area   |
    |  for arguments that are       |
    |  split between registers and  |
    |  the stack                    |
    +-------------------------------+ <-- arg_pointer_rtx
  C |  callee-allocated save area   |
    |  for register varargs         |
    +-------------------------------+ <-- hard_frame_pointer_rtx;
    |                               |     stack_pointer_rtx + gp_sp_offset
    |  GPR save area                |       + UNITS_PER_WORD
    +-------------------------------+ <-- stack_pointer_rtx + fp_sp_offset
    |                               |       + UNITS_PER_HWVALUE
    |  FPR save area                |
    +-------------------------------+ <-- frame_pointer_rtx (virtual)
    |  local variables              |
  P +-------------------------------+
    |  outgoing stack arguments     |
    +-------------------------------+
    |  caller-allocated save area   |
    |  for register arguments       |
    +-------------------------------+ <-- stack_pointer_rtx

   At least two of A, B and C will be empty.

   Dynamic stack allocations such as alloca insert data at point P.
   They decrease stack_pointer_rtx but leave frame_pointer_rtx and
   hard_frame_pointer_rtx unchanged.  */


// hasFP - Return true if the specified function should have a dedicated frame
// pointer register.  This is true if the function has variable sized allocas or
// if frame pointer elimination is disabled.
bool RISCVFrameLowering::hasFP(const MachineFunction &MF) const {
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  return MF.getTarget().Options.DisableFramePointerElim(MF) ||
      MFI->hasVarSizedObjects() || MFI->isFrameAddressTaken();
}


unsigned RISCVFrameLowering::ehDataReg(unsigned I) const {
  static const unsigned EhDataReg[] = {
    RISCV::sup0, RISCV::sup1
  };

  return EhDataReg[I];
}

void RISCVFrameLowering::emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const {
  assert(&MBB == &MF.front() && "Shrink-wrapping not yet implemented");
  MachineFrameInfo *MFI    = MF.getFrameInfo();
  RISCVFunctionInfo *RISCVFI = MF.getInfo<RISCVFunctionInfo>();
  const RISCVRegisterInfo *RegInfo =
    static_cast<const RISCVRegisterInfo*>(MF.getSubtarget().getRegisterInfo());
  const RISCVInstrInfo &TII =
    *static_cast<const RISCVInstrInfo*>(MF.getSubtarget().getInstrInfo());
  MachineBasicBlock::iterator MBBI = MBB.begin();
  DebugLoc dl = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
  const RISCVSubtarget &STI = MF.getSubtarget<RISCVSubtarget>();
  unsigned SP = STI.isRV64() ? RISCV::sp_64 : RISCV::sp;
  unsigned FP = STI.isRV64() ? RISCV::fp_64 : RISCV::fp;
  unsigned ZERO = STI.isRV64() ? RISCV::zero_64 : RISCV::zero;
  unsigned ADDu = STI.isRV64() ? RISCV::ADD64 : RISCV::ADD;

  // First, compute final stack size.
  uint64_t StackSize = MFI->getStackSize();

  // No need to allocate space on the stack.
  if (StackSize == 0 && !MFI->adjustsStack()) return;

  MachineModuleInfo &MMI = MF.getMMI();
  const MCRegisterInfo *MRI = MMI.getContext().getRegisterInfo();
  MachineLocation DstML, SrcML;

  // Adjust stack.
  TII.adjustStackPtr(SP, -StackSize, MBB, MBBI);

  // emit ".cfi_def_cfa_offset StackSize"
  unsigned CFIIndex = MMI.addFrameInst(
      MCCFIInstruction::createDefCfaOffset(nullptr, -StackSize));
  BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
      .addCFIIndex(CFIIndex);

  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();

  if (CSI.size()) {
    // Find the instruction past the last instruction that saves a callee-saved
    // register to the stack.
    for (unsigned i = 0; i < CSI.size(); ++i)
      ++MBBI;

    // Iterate over list of callee-saved registers and emit .cfi_offset
    // directives.
    for (const auto &I: CSI) {
      int64_t Offset = MFI->getObjectOffset(I.getFrameIdx());
      unsigned Reg = I.getReg();

      // Reg is either in CPURegs or FGR32.
      unsigned CFIIndex = MMI.addFrameInst(MCCFIInstruction::createOffset(
          nullptr, MRI->getDwarfRegNum(Reg, 1), Offset));
      BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(CFIIndex);
    }
  }

  if (RISCVFI->getCallsEhReturn()) {
    const TargetRegisterClass *RC = &RISCV::GR32BitRegClass;

    // Insert instructions that spill eh data registers.
    for (int I = 0; I < 4; ++I) {
      if (!MBB.isLiveIn(ehDataReg(I)))
        MBB.addLiveIn(ehDataReg(I));
      TII.storeRegToStackSlot(MBB, MBBI, ehDataReg(I), false,
                              RISCVFI->getEhDataRegFI(I), RC, RegInfo);
    }

    // Emit .cfi_offset directives for eh data registers.
    for (int I = 0; I < 4; ++I) {
      int64_t Offset = MFI->getObjectOffset(RISCVFI->getEhDataRegFI(I));
      unsigned Reg = MRI->getDwarfRegNum(ehDataReg(I), true);
      unsigned CFIIndex = MMI.addFrameInst(
          MCCFIInstruction::createOffset(nullptr, Reg, Offset));
      BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(CFIIndex);
    }
  }

  // if framepointer enabled, set it to point to the stack pointer.
  if (hasFP(MF)) {
    // Insert instruction "move $fp, $sp" at this location.
    BuildMI(MBB, MBBI, dl, TII.get(ADDu), FP)
        .addReg(SP)
        .addReg(ZERO)
        .setMIFlag(MachineInstr::FrameSetup);

    // emit ".cfi_def_cfa_register $fp"
    unsigned CFIIndex = MMI.addFrameInst(MCCFIInstruction::createDefCfaRegister(
        nullptr, MRI->getDwarfRegNum(FP, true)));
    BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
        .addCFIIndex(CFIIndex);
  }
}

void RISCVFrameLowering::emitEpilogue(MachineFunction &MF,
                                       MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  MachineFrameInfo *MFI            = MF.getFrameInfo();
  RISCVFunctionInfo *RISCVFI = MF.getInfo<RISCVFunctionInfo>();
  const RISCVRegisterInfo *RegInfo =
    static_cast<const RISCVRegisterInfo*>(MF.getSubtarget().getRegisterInfo());
  const RISCVInstrInfo &TII =
    *static_cast<const RISCVInstrInfo*>(MF.getSubtarget().getInstrInfo());
  DebugLoc dl = MBBI->getDebugLoc();
  const RISCVSubtarget &STI = MF.getSubtarget<RISCVSubtarget>();
  unsigned SP   = STI.isRV64() ? RISCV::sp_64 : RISCV::sp;
  unsigned FP   = STI.isRV64() ? RISCV::fp_64 : RISCV::fp;
  unsigned ZERO = STI.isRV64() ? RISCV::zero_64 : RISCV::zero;
  unsigned ADDu = STI.isRV64() ? RISCV::ADD64 : RISCV::ADD;

  // if framepointer enabled, restore the stack pointer.
  if (hasFP(MF)) {
    // Find the first instruction that restores a callee-saved register.
    MachineBasicBlock::iterator I = MBBI;

    for (unsigned i = 0; i < MFI->getCalleeSavedInfo().size(); ++i)
      --I;

    // Insert instruction "move $sp, $fp" at this location.
    BuildMI(MBB, I, dl, TII.get(ADDu), SP).addReg(FP).addReg(ZERO);
  }

  if (RISCVFI->getCallsEhReturn()) {
    const TargetRegisterClass *RC = &RISCV::GR32BitRegClass;

    // Find first instruction that restores a callee-saved register.
    MachineBasicBlock::iterator I = MBBI;
    for (unsigned i = 0; i < MFI->getCalleeSavedInfo().size(); ++i)
      --I;

    // Insert instructions that restore eh data registers.
    for (int J = 0; J < 4; ++J) {
      TII.loadRegFromStackSlot(MBB, I, ehDataReg(J), RISCVFI->getEhDataRegFI(J),
                               RC, RegInfo);
    }
  }

  // Get the number of bytes from FrameInfo
  uint64_t StackSize = MFI->getStackSize();

  if (!StackSize)
    return;

  // Adjust stack.
  TII.adjustStackPtr(SP, StackSize, MBB, MBBI);
}

bool RISCVFrameLowering::
spillCalleeSavedRegisters(MachineBasicBlock &MBB,
                          MachineBasicBlock::iterator MI,
                          const std::vector<CalleeSavedInfo> &CSI,
                          const TargetRegisterInfo *TRI) const {
  MachineFunction *MF = MBB.getParent();
  MachineBasicBlock &EntryBlock = *(MF->begin());
  const TargetInstrInfo &TII = *MF->getSubtarget().getInstrInfo();

  for (unsigned i = 0, e = CSI.size(); i != e; ++i) {
    // Add the callee-saved register as live-in. Do not add if the register is
    // RA and return address is taken, because it has already been added in
    // method RISCVTargetLowering::LowerRETURNADDR.
    // It's killed at the spill, unless the register is RA and return address
    // is taken.
    unsigned Reg = CSI[i].getReg();
    bool IsRAAndRetAddrIsTaken = (Reg == RISCV::ra || Reg == RISCV::ra_64)
        && MF->getFrameInfo()->isReturnAddressTaken();
    if (!IsRAAndRetAddrIsTaken)
      EntryBlock.addLiveIn(Reg);

    // Insert the spill to the stack frame.
    bool IsKill = !IsRAAndRetAddrIsTaken;
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);
    TII.storeRegToStackSlot(EntryBlock, MI, Reg, IsKill,
                            CSI[i].getFrameIdx(), RC, TRI);
  }

  return true;
}

bool
RISCVFrameLowering::hasReservedCallFrame(const MachineFunction &MF) const {
  const MachineFrameInfo *MFI = MF.getFrameInfo();

  // Reserve call frame if the size of the maximum call frame fits into 16-bit
  // immediate field and there are no variable sized objects on the stack.
  // Make sure the second register scavenger spill slot can be accessed with one
  // instruction.
  return isInt<12>(MFI->getMaxCallFrameSize() + getStackAlignment()) &&
    !MFI->hasVarSizedObjects();
}

// Eliminate ADJCALLSTACKDOWN, ADJCALLSTACKUP pseudo instructions
void RISCVFrameLowering::
eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                              MachineBasicBlock::iterator I) const {
  const RISCVInstrInfo &TII =
    *static_cast<const RISCVInstrInfo*>(MF.getSubtarget().getInstrInfo());
  const RISCVSubtarget &STI = MF.getSubtarget<RISCVSubtarget>();

  if (!hasReservedCallFrame(MF)) {
    int64_t Amount = I->getOperand(0).getImm();

    if (I->getOpcode() == RISCV::ADJCALLSTACKDOWN)
      Amount = -Amount;

    unsigned SP = STI.isRV64() ? RISCV::sp_64 : RISCV::sp;
    TII.adjustStackPtr(SP, Amount, MBB, I);
  }

  MBB.erase(I);
}

void RISCVFrameLowering::determineCalleeSaves(MachineFunction &MF, BitVector &SavedRegs,
                                     RegScavenger *RS) const {
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);
  MachineFrameInfo *MFI = MF.getFrameInfo();
  RISCVFunctionInfo *RISCVFI = MF.getInfo<RISCVFunctionInfo>();
  const RISCVSubtarget &STI = MF.getSubtarget<RISCVSubtarget>();
  unsigned FP = STI.isRV64() ? RISCV::fp_64 : RISCV::fp;

  // Mark $fp as used if function has dedicated frame pointer.
  if (hasFP(MF))
    SavedRegs.set(FP);

  // Create spill slots for eh data registers if function calls eh_return.
  if (RISCVFI->getCallsEhReturn())
    RISCVFI->createEhDataRegsFI();

  // Set scavenging frame index if necessary.
  uint64_t MaxSPOffset = MF.getInfo<RISCVFunctionInfo>()->getIncomingArgSize() +
    MFI->estimateStackSize(MF);

  if (isInt<12>(MaxSPOffset))
    return;

  const TargetRegisterClass *RC = &RISCV::GR32BitRegClass;
  int FI = MF.getFrameInfo()->CreateStackObject(RC->getSize(),
                                                RC->getAlignment(), false);
  RS->addScavengingFrameIndex(FI);
}
