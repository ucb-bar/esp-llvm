//===-- RISCVRegisterInfo.cpp - RISCV register information ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVRegisterInfo.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#define DEBUG_TYPE "riscv-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "RISCVGenRegisterInfo.inc"

using namespace llvm;

RISCVRegisterInfo::RISCVRegisterInfo(const RISCVSubtarget &STI)
    : RISCVGenRegisterInfo(RISCV::ra), Subtarget(STI) {}

const uint16_t*
RISCVRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  if(Subtarget.isRV64())
    if(Subtarget.hasD())
      return CSR_RV64D_SaveList;
    else if(Subtarget.hasF())
      return CSR_RV64F_SaveList;
    else
      return CSR_RV64_SaveList;
  else
    if(Subtarget.hasD())
      return CSR_RV32D_SaveList;
    else if(Subtarget.hasF())
      return CSR_RV32F_SaveList;
    else
      return CSR_RV32_SaveList;
}

const uint32_t*
RISCVRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
    CallingConv::ID) const {
  if(Subtarget.isRV64())
    if(Subtarget.hasD())
      return CSR_RV64D_RegMask;
    else if(Subtarget.hasF())
      return CSR_RV64F_RegMask;
    else
      return CSR_RV64_RegMask;
  else
    if(Subtarget.hasD())
      return CSR_RV32D_RegMask;
    else if(Subtarget.hasF())
      return CSR_RV32F_RegMask;
    else
      return CSR_RV32_RegMask;

}

BitVector
RISCVRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();

  // zero is reserved so llvm doesn't store things there
  Reserved.set(RISCV::zero);
  Reserved.set(RISCV::zero_64);

  if (TFI->hasFP(MF)) {
    // fp is the frame pointer.  Reserve all aliases.
    Reserved.set(RISCV::fp);
    Reserved.set(RISCV::s0);
    Reserved.set(RISCV::fp_64);
    Reserved.set(RISCV::s0_64);
  }

  // sp is the stack pointer.  Reserve all aliases.
  Reserved.set(RISCV::sp);
  Reserved.set(RISCV::sp_64);
  // tp is the thread pointer.  Reserve all aliases.
  Reserved.set(RISCV::tp);
  Reserved.set(RISCV::tp_64);
  // gp shouldn't be used eitehr
  Reserved.set(RISCV::gp);
  Reserved.set(RISCV::gp_64);
  return Reserved;
}

void RISCVRegisterInfo::eliminateFI(MachineBasicBlock::iterator II,
                                     unsigned OpNo, int FrameIndex,
                                     uint64_t StackSize,
                                     int64_t SPOffset) const {
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  RISCVFunctionInfo *RISCVFI = MF.getInfo<RISCVFunctionInfo>();

  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();
  int MinCSFI = 0;
  int MaxCSFI = -1;

  if (CSI.size()) {
    MinCSFI = CSI[0].getFrameIdx();
    MaxCSFI = CSI[CSI.size() - 1].getFrameIdx();
  }

  bool EhDataRegFI = RISCVFI->isEhDataRegFI(FrameIndex);

  // The following stack frame objects are always referenced relative to $sp:
  //  1. Outgoing arguments.
  //  2. Pointer to dynamically allocated stack space.
  //  3. Locations for callee-saved registers.
  //  4. Locations for eh data registers.
  // Everything else is referenced relative to whatever register
  // getFrameRegister() returns.
  unsigned FrameReg;

  if ((FrameIndex >= MinCSFI && FrameIndex <= MaxCSFI) || EhDataRegFI)
    FrameReg = Subtarget.isRV64() ? RISCV::sp_64 : RISCV::sp;
  else
    FrameReg = getFrameRegister(MF);

  // Calculate final offset.
  // - There is no need to change the offset if the frame object is one of the
  //   following: an outgoing argument, pointer to a dynamically allocated
  //   stack space or a $gp restore location,
  // - If the frame object is any of the following, its offset must be adjusted
  //   by adding the size of the stack:
  //   incoming argument, callee-saved register location or local variable.
  bool IsKill = false;
  int64_t Offset;

  Offset = SPOffset + (int64_t)StackSize;
  // loads and stores have the immediate before the FI
  // FIXME: this is a bit hacky
  if(MI.mayLoadOrStore())
    Offset += MI.getOperand(OpNo - 1).getImm();
  else
    Offset += MI.getOperand(OpNo + 1).getImm();

  DEBUG(errs() << "Offset     : " << Offset << "\n" << "<--------->\n");

  // If MI is not a debug value, make sure Offset fits in the 16-bit immediate
  // field.
  if (!MI.isDebugValue() && !isInt<12>(Offset)) {
    MachineBasicBlock &MBB = *MI.getParent();
    DebugLoc DL = II->getDebugLoc();
    unsigned ADD = Subtarget.isRV64() ? RISCV::ADD64 : RISCV::ADD;
    unsigned Reg;
    const RISCVInstrInfo &TII =
        *static_cast<const RISCVInstrInfo *>(
            MBB.getParent()->getSubtarget().getInstrInfo());

    TII.loadImmediate(MBB, II, &Reg, Offset);
    BuildMI(MBB, II, DL, TII.get(ADD), Reg).addReg(FrameReg)
      .addReg(Reg, RegState::Kill);

    FrameReg = Reg;
    Offset = SignExtend64<12>(0);
    IsKill = true;
  }

  MI.getOperand(OpNo).ChangeToRegister(FrameReg, false, false, IsKill);
  // loads and stores have the immediate before the FI
  // FIXME: this is a bit hacky
  if(MI.mayLoadOrStore())
    MI.getOperand(OpNo - 1).ChangeToImmediate(Offset);
  else
    MI.getOperand(OpNo + 1).ChangeToImmediate(Offset);
}

void
RISCVRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                         int SPAdj, unsigned FIOperandNum,
                                         RegScavenger *RS) const {
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();

  DEBUG(errs() << "\nFunction : " << MF.getName() << "\n";
        errs() << "<--------->\n" << MI);

  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  uint64_t stackSize = MF.getFrameInfo()->getStackSize();
  int64_t spOffset = MF.getFrameInfo()->getObjectOffset(FrameIndex);

  DEBUG(errs() << "FrameIndex : " << FrameIndex << "\n"
               << "spOffset   : " << spOffset << "\n"
               << "stackSize  : " << stackSize << "\n");

  eliminateFI(MI, FIOperandNum, FrameIndex, stackSize, spOffset);
}

unsigned
RISCVRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();
  return TFI->hasFP(MF) ? 
      (Subtarget.isRV64() ? RISCV::fp_64 : RISCV::fp) : 
      (Subtarget.isRV64() ? RISCV::sp_64 : RISCV::sp);
}
