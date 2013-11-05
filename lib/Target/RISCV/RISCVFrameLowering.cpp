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
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/Function.h"

using namespace llvm;

RISCVFrameLowering::RISCVFrameLowering(const RISCVTargetMachine &tm,
                                           const RISCVSubtarget &sti)
  : TargetFrameLowering(TargetFrameLowering::StackGrowsDown, 16, 0),
    TM(tm),
    STI(sti) {}
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

/*
uint64_t RISCVFrameLowering::estimateStackSize(const MachineFunction &MF) const {
  const MachineFrameInfo *MFI = MF.getFrameInfo();
  const TargetRegisterInfo &TRI = *MF.getTarget().getRegisterInfo();

  int64_t Offset = 0;

  // Iterate over fixed sized objects.
  for (int I = MFI->getObjectIndexBegin(); I != 0; ++I)
    Offset = std::max(Offset, -MFI->getObjectOffset(I));

  // Conservatively assume all callee-saved registers will be saved.
  for (const uint16_t *R = TRI.getCalleeSavedRegs(&MF); *R; ++R) {
    unsigned Size = TRI.getMinimalPhysRegClass(*R)->getSize();
    Offset = RoundUpToAlignment(Offset + Size, Size);
  }

  unsigned MaxAlign = MFI->getMaxAlignment();

  // Check that MaxAlign is not zero if there is a stack object that is not a
  // callee-saved spill.
  assert(!MFI->getObjectIndexEnd() || MaxAlign);

  // Iterate over other objects.
  for (unsigned I = 0, E = MFI->getObjectIndexEnd(); I != E; ++I)
    Offset = RoundUpToAlignment(Offset + MFI->getObjectSize(I), MaxAlign);

  // Call frame.
  if (MFI->adjustsStack() && hasReservedCallFrame(MF))
    Offset = RoundUpToAlignment(Offset + MFI->getMaxCallFrameSize(),
                                std::max(MaxAlign, getStackAlignment()));

  return RoundUpToAlignment(Offset, getStackAlignment());
}*/

//using namespace llvm;

/*
namespace {
typedef MachineBasicBlock::iterator Iter;

/// Helper class to expand pseudos.
class ExpandPseudo {
public:
  ExpandPseudo(MachineFunction &MF);
  bool expand();

private:
  bool expandInstr(MachineBasicBlock &MBB, Iter I);
  void expandLoadCCond(MachineBasicBlock &MBB, Iter I);
  void expandStoreCCond(MachineBasicBlock &MBB, Iter I);
  void expandLoadACC(MachineBasicBlock &MBB, Iter I, unsigned RegSize);
  void expandStoreACC(MachineBasicBlock &MBB, Iter I, unsigned RegSize);
  bool expandCopy(MachineBasicBlock &MBB, Iter I);
  bool expandCopyACC(MachineBasicBlock &MBB, Iter I, unsigned Dst,
                     unsigned Src, unsigned RegSize);

  MachineFunction &MF;
  const RISCVInstrInfo &TII;
  const RISCVRegisterInfo &RegInfo;
  MachineRegisterInfo &MRI;
};
}

ExpandPseudo::ExpandPseudo(MachineFunction &MF_)
  : MF(MF_),
    TII(*static_cast<const RISCVInstrInfo*>(MF.getTarget().getInstrInfo())),
    RegInfo(TII.getRegisterInfo()), MRI(MF.getRegInfo()) {}

bool ExpandPseudo::expand() {
  bool Expanded = false;

  for (MachineFunction::iterator BB = MF.begin(), BBEnd = MF.end();
       BB != BBEnd; ++BB)
    for (Iter I = BB->begin(), End = BB->end(); I != End;)
      Expanded |= expandInstr(*BB, I++);

  return Expanded;
}

bool ExpandPseudo::expandInstr(MachineBasicBlock &MBB, Iter I) {
  switch(I->getOpcode()) {
  case RISCV::LOAD_CCOND_DSP:
  case RISCV::LOAD_CCOND_DSP_P8:
    expandLoadCCond(MBB, I);
    break;
  case RISCV::STORE_CCOND_DSP:
  case RISCV::STORE_CCOND_DSP_P8:
    expandStoreCCond(MBB, I);
    break;
  case RISCV::LOAD_AC64:
  case RISCV::LOAD_AC64_P8:
  case RISCV::LOAD_AC_DSP:
  case RISCV::LOAD_AC_DSP_P8:
    expandLoadACC(MBB, I, 4);
    break;
  case RISCV::LOAD_AC128:
  case RISCV::LOAD_AC128_P8:
    expandLoadACC(MBB, I, 8);
    break;
  case RISCV::STORE_AC64:
  case RISCV::STORE_AC64_P8:
  case RISCV::STORE_AC_DSP:
  case RISCV::STORE_AC_DSP_P8:
    expandStoreACC(MBB, I, 4);
    break;
  case RISCV::STORE_AC128:
  case RISCV::STORE_AC128_P8:
    expandStoreACC(MBB, I, 8);
    break;
  case TargetOpcode::COPY:
    if (!expandCopy(MBB, I))
      return false;
    break;
  default:
    return false;
  }

  MBB.erase(I);
  return true;
}

void ExpandPseudo::expandLoadCCond(MachineBasicBlock &MBB, Iter I) {
  //  load $vr, FI
  //  copy ccond, $vr

  assert(I->getOperand(0).isReg() && I->getOperand(1).isFI());

  const TargetRegisterClass *RC = RegInfo.intRegClass(4);
  unsigned VR = MRI.createVirtualRegister(RC);
  unsigned Dst = I->getOperand(0).getReg(), FI = I->getOperand(1).getIndex();

  TII.loadRegFromStack(MBB, I, VR, FI, RC, &RegInfo, 0);
  BuildMI(MBB, I, I->getDebugLoc(), TII.get(TargetOpcode::COPY), Dst)
    .addReg(VR, RegState::Kill);
}

void ExpandPseudo::expandStoreCCond(MachineBasicBlock &MBB, Iter I) {
  //  copy $vr, ccond
  //  store $vr, FI

  assert(I->getOperand(0).isReg() && I->getOperand(1).isFI());

  const TargetRegisterClass *RC = RegInfo.intRegClass(4);
  unsigned VR = MRI.createVirtualRegister(RC);
  unsigned Src = I->getOperand(0).getReg(), FI = I->getOperand(1).getIndex();

  BuildMI(MBB, I, I->getDebugLoc(), TII.get(TargetOpcode::COPY), VR)
    .addReg(Src, getKillRegState(I->getOperand(0).isKill()));
  TII.storeRegToStack(MBB, I, VR, true, FI, RC, &RegInfo, 0);
}

void ExpandPseudo::expandLoadACC(MachineBasicBlock &MBB, Iter I,
                                 unsigned RegSize) {
  //  load $vr0, FI
  //  copy lo, $vr0
  //  load $vr1, FI + 4
  //  copy hi, $vr1

  assert(I->getOperand(0).isReg() && I->getOperand(1).isFI());

  const TargetRegisterClass *RC = RegInfo.intRegClass(RegSize);
  unsigned VR0 = MRI.createVirtualRegister(RC);
  unsigned VR1 = MRI.createVirtualRegister(RC);
  unsigned Dst = I->getOperand(0).getReg(), FI = I->getOperand(1).getIndex();
  unsigned Lo = RegInfo.getSubReg(Dst, RISCV::sub_lo);
  unsigned Hi = RegInfo.getSubReg(Dst, RISCV::sub_hi);
  DebugLoc DL = I->getDebugLoc();
  const MCInstrDesc &Desc = TII.get(TargetOpcode::COPY);

  TII.loadRegFromStack(MBB, I, VR0, FI, RC, &RegInfo, 0);
  BuildMI(MBB, I, DL, Desc, Lo).addReg(VR0, RegState::Kill);
  TII.loadRegFromStack(MBB, I, VR1, FI, RC, &RegInfo, RegSize);
  BuildMI(MBB, I, DL, Desc, Hi).addReg(VR1, RegState::Kill);
}

void ExpandPseudo::expandStoreACC(MachineBasicBlock &MBB, Iter I,
                                  unsigned RegSize) {
  //  copy $vr0, lo
  //  store $vr0, FI
  //  copy $vr1, hi
  //  store $vr1, FI + 4

  assert(I->getOperand(0).isReg() && I->getOperand(1).isFI());

  const TargetRegisterClass *RC = RegInfo.intRegClass(RegSize);
  unsigned VR0 = MRI.createVirtualRegister(RC);
  unsigned VR1 = MRI.createVirtualRegister(RC);
  unsigned Src = I->getOperand(0).getReg(), FI = I->getOperand(1).getIndex();
  unsigned SrcKill = getKillRegState(I->getOperand(0).isKill());
  unsigned Lo = RegInfo.getSubReg(Src, RISCV::sub_lo);
  unsigned Hi = RegInfo.getSubReg(Src, RISCV::sub_hi);
  DebugLoc DL = I->getDebugLoc();

  BuildMI(MBB, I, DL, TII.get(TargetOpcode::COPY), VR0).addReg(Lo, SrcKill);
  TII.storeRegToStack(MBB, I, VR0, true, FI, RC, &RegInfo, 0);
  BuildMI(MBB, I, DL, TII.get(TargetOpcode::COPY), VR1).addReg(Hi, SrcKill);
  TII.storeRegToStack(MBB, I, VR1, true, FI, RC, &RegInfo, RegSize);
}

bool ExpandPseudo::expandCopy(MachineBasicBlock &MBB, Iter I) {
  unsigned Dst = I->getOperand(0).getReg(), Src = I->getOperand(1).getReg();

  if (RISCV::ACRegsDSPRegClass.contains(Dst, Src))
    return expandCopyACC(MBB, I, Dst, Src, 4);

  if (RISCV::ACRegs128RegClass.contains(Dst, Src))
    return expandCopyACC(MBB, I, Dst, Src, 8);

  return false;
}

bool ExpandPseudo::expandCopyACC(MachineBasicBlock &MBB, Iter I, unsigned Dst,
                                 unsigned Src, unsigned RegSize) {
  //  copy $vr0, src_lo
  //  copy dst_lo, $vr0
  //  copy $vr1, src_hi
  //  copy dst_hi, $vr1

  const TargetRegisterClass *RC = RegInfo.intRegClass(RegSize);
  unsigned VR0 = MRI.createVirtualRegister(RC);
  unsigned VR1 = MRI.createVirtualRegister(RC);
  unsigned SrcKill = getKillRegState(I->getOperand(1).isKill());
  unsigned DstLo = RegInfo.getSubReg(Dst, RISCV::sub_lo);
  unsigned DstHi = RegInfo.getSubReg(Dst, RISCV::sub_hi);
  unsigned SrcLo = RegInfo.getSubReg(Src, RISCV::sub_lo);
  unsigned SrcHi = RegInfo.getSubReg(Src, RISCV::sub_hi);
  DebugLoc DL = I->getDebugLoc();

  BuildMI(MBB, I, DL, TII.get(TargetOpcode::COPY), VR0).addReg(SrcLo, SrcKill);
  BuildMI(MBB, I, DL, TII.get(TargetOpcode::COPY), DstLo)
    .addReg(VR0, RegState::Kill);
  BuildMI(MBB, I, DL, TII.get(TargetOpcode::COPY), VR1).addReg(SrcHi, SrcKill);
  BuildMI(MBB, I, DL, TII.get(TargetOpcode::COPY), DstHi)
    .addReg(VR1, RegState::Kill);
  return true;
}
*/

unsigned RISCVFrameLowering::ehDataReg(unsigned I) const {
  static const unsigned EhDataReg[] = {
    RISCV::sup0, RISCV::sup1
  };

  return EhDataReg[I];
}

void RISCVFrameLowering::emitPrologue(MachineFunction &MF) const {
  MachineBasicBlock &MBB   = MF.front();
  MachineFrameInfo *MFI    = MF.getFrameInfo();
  RISCVMachineFunctionInfo *RISCVFI = MF.getInfo<RISCVMachineFunctionInfo>();
  const RISCVRegisterInfo *RegInfo =
    static_cast<const RISCVRegisterInfo*>(MF.getTarget().getRegisterInfo());
  const RISCVInstrInfo &TII =
    *static_cast<const RISCVInstrInfo*>(MF.getTarget().getInstrInfo());
  MachineBasicBlock::iterator MBBI = MBB.begin();
  DebugLoc dl = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
  //TODO:switch based on subtarget
  unsigned SP = STI.isRV64() ? RISCV::sp_64 : RISCV::sp;
  unsigned FP = STI.isRV64() ? RISCV::fp_64 : RISCV::fp;
  unsigned ZERO = STI.isRV64() ? RISCV::zero_64 : RISCV::zero;
  unsigned ADDu = STI.isRV64() ? RISCV::ADD64 : RISCV::ADD;

  // First, compute final stack size.
  uint64_t StackSize = MFI->getStackSize();

  // No need to allocate space on the stack.
  if (StackSize == 0 && !MFI->adjustsStack()) return;

  MachineModuleInfo &MMI = MF.getMMI();
  std::vector<MachineMove> &Moves = MMI.getFrameMoves();
  MachineLocation DstML, SrcML;

  // Adjust stack.
  TII.adjustStackPtr(SP, -StackSize, MBB, MBBI);

  // emit ".cfi_def_cfa_offset StackSize"
  MCSymbol *AdjustSPLabel = MMI.getContext().CreateTempSymbol();
  BuildMI(MBB, MBBI, dl,
          TII.get(TargetOpcode::PROLOG_LABEL)).addSym(AdjustSPLabel);
  DstML = MachineLocation(MachineLocation::VirtualFP);
  SrcML = MachineLocation(MachineLocation::VirtualFP, -StackSize);
  Moves.push_back(MachineMove(AdjustSPLabel, DstML, SrcML));

  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();

  if (CSI.size()) {
    // Find the instruction past the last instruction that saves a callee-saved
    // register to the stack.
    for (unsigned i = 0; i < CSI.size(); ++i)
      ++MBBI;

    // Iterate over list of callee-saved registers and emit .cfi_offset
    // directives.
    MCSymbol *CSLabel = MMI.getContext().CreateTempSymbol();
    BuildMI(MBB, MBBI, dl,
            TII.get(TargetOpcode::PROLOG_LABEL)).addSym(CSLabel);

    for (std::vector<CalleeSavedInfo>::const_iterator I = CSI.begin(),
           E = CSI.end(); I != E; ++I) {
      int64_t Offset = MFI->getObjectOffset(I->getFrameIdx());
      unsigned Reg = I->getReg();

      /* No double precision yet
      // If Reg is a double precision register, emit two cfa_offsets,
      // one for each of the paired single precision registers.
      if (RISCV::AFGR64RegClass.contains(Reg)) {
        MachineLocation DstML0(MachineLocation::VirtualFP, Offset);
        MachineLocation DstML1(MachineLocation::VirtualFP, Offset + 4);
        MachineLocation SrcML0(RegInfo->getSubReg(Reg, RISCV::sub_fpeven));
        MachineLocation SrcML1(RegInfo->getSubReg(Reg, RISCV::sub_fpodd));

        if (!STI.isLittle())
          std::swap(SrcML0, SrcML1);

        Moves.push_back(MachineMove(CSLabel, DstML0, SrcML0));
        Moves.push_back(MachineMove(CSLabel, DstML1, SrcML1));
      } else {
      */
        // Reg is either in CPURegs or FGR32.
        DstML = MachineLocation(MachineLocation::VirtualFP, Offset);
        SrcML = MachineLocation(Reg);
        Moves.push_back(MachineMove(CSLabel, DstML, SrcML));
    //  }
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
    MCSymbol *CSLabel2 = MMI.getContext().CreateTempSymbol();
    BuildMI(MBB, MBBI, dl,
            TII.get(TargetOpcode::PROLOG_LABEL)).addSym(CSLabel2);
    for (int I = 0; I < 4; ++I) {
      int64_t Offset = MFI->getObjectOffset(RISCVFI->getEhDataRegFI(I));
      DstML = MachineLocation(MachineLocation::VirtualFP, Offset);
      SrcML = MachineLocation(ehDataReg(I));
      Moves.push_back(MachineMove(CSLabel2, DstML, SrcML));
    }
  }

  // if framepointer enabled, set it to point to the stack pointer.
  if (hasFP(MF)) {
    // Insert instruction "move $fp, $sp" at this location.
    BuildMI(MBB, MBBI, dl, TII.get(ADDu), FP).addReg(SP).addReg(ZERO);

    // emit ".cfi_def_cfa_register $fp"
    MCSymbol *SetFPLabel = MMI.getContext().CreateTempSymbol();
    BuildMI(MBB, MBBI, dl,
            TII.get(TargetOpcode::PROLOG_LABEL)).addSym(SetFPLabel);
    DstML = MachineLocation(FP);
    SrcML = MachineLocation(MachineLocation::VirtualFP);
    Moves.push_back(MachineMove(SetFPLabel, DstML, SrcML));
  }
}

void RISCVFrameLowering::emitEpilogue(MachineFunction &MF,
                                       MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  MachineFrameInfo *MFI            = MF.getFrameInfo();
  RISCVMachineFunctionInfo *RISCVFI = MF.getInfo<RISCVMachineFunctionInfo>();
  const RISCVRegisterInfo *RegInfo =
    static_cast<const RISCVRegisterInfo*>(MF.getTarget().getRegisterInfo());
  const RISCVInstrInfo &TII =
    *static_cast<const RISCVInstrInfo*>(MF.getTarget().getInstrInfo());
  DebugLoc dl = MBBI->getDebugLoc();
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
  MachineBasicBlock *EntryBlock = MF->begin();
  const TargetInstrInfo &TII = *MF->getTarget().getInstrInfo();

  for (unsigned i = 0, e = CSI.size(); i != e; ++i) {
    // Add the callee-saved register as live-in. Do not add if the register is
    // RA and return address is taken, because it has already been added in
    // method RISCVTargetLowering::LowerRETURNADDR.
    // It's killed at the spill, unless the register is RA and return address
    // is taken.
    unsigned Reg = CSI[i].getReg();
    bool IsRAAndRetAddrIsTaken = Reg == RISCV::ra
        && MF->getFrameInfo()->isReturnAddressTaken();
    if (!IsRAAndRetAddrIsTaken)
      EntryBlock->addLiveIn(Reg);

    // Insert the spill to the stack frame.
    bool IsKill = !IsRAAndRetAddrIsTaken;
    const TargetRegisterClass *RC = TRI->getMinimalPhysRegClass(Reg);
    TII.storeRegToStackSlot(*EntryBlock, MI, Reg, IsKill,
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
    *static_cast<const RISCVInstrInfo*>(MF.getTarget().getInstrInfo());

  if (!hasReservedCallFrame(MF)) {
    int64_t Amount = I->getOperand(0).getImm();

    if (I->getOpcode() == RISCV::ADJCALLSTACKDOWN)
      Amount = -Amount;

    unsigned SP = STI.isRV64() ? RISCV::sp_64 : RISCV::sp;
    TII.adjustStackPtr(SP, Amount, MBB, I);
  }

  MBB.erase(I);
}

void RISCVFrameLowering::
processFunctionBeforeCalleeSavedScan(MachineFunction &MF,
                                     RegScavenger *RS) const {
  MachineRegisterInfo &MRI = MF.getRegInfo();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  RISCVMachineFunctionInfo *RISCVFI = MF.getInfo<RISCVMachineFunctionInfo>();
  unsigned FP = STI.isRV64() ? RISCV::fp_64 : RISCV::fp;

  // Mark $fp as used if function has dedicated frame pointer.
  if (hasFP(MF))
    MRI.setPhysRegUsed(FP);

  // Create spill slots for eh data registers if function calls eh_return.
  if (RISCVFI->getCallsEhReturn())
    RISCVFI->createEhDataRegsFI();

  /*
  // Expand pseudo instructions which load, store or copy accumulators.
  // Add an emergency spill slot if a pseudo was expanded.
  if (ExpandPseudo(MF).expand()) {
    // The spill slot should be half the size of the accumulator. If target is
    // riscv64, it should be 64-bit, otherwise it should be 32-bt.
    const TargetRegisterClass *RC = STI.hasRISCV64() ?
      &RISCV::CPU64RegsRegClass : &RISCV::CPURegsRegClass;
    int FI = MF.getFrameInfo()->CreateStackObject(RC->getSize(),
                                                  RC->getAlignment(), false);
    RS->addScavengingFrameIndex(FI);
  }
  */

  // Set scavenging frame index if necessary.
  uint64_t MaxSPOffset = MF.getInfo<RISCVMachineFunctionInfo>()->getIncomingArgSize() +
    MFI->estimateStackSize(MF);

  if (isInt<12>(MaxSPOffset))
    return;

  const TargetRegisterClass *RC = &RISCV::GR32BitRegClass;
  int FI = MF.getFrameInfo()->CreateStackObject(RC->getSize(),
                                                RC->getAlignment(), false);
  RS->addScavengingFrameIndex(FI);
}
