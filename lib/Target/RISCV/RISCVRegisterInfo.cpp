//===-- RISCVRegisterInfo.cpp - RISCV register information ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVRegisterInfo.h"
#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

#define GET_REGINFO_TARGET_DESC
#include "RISCVGenRegisterInfo.inc"

using namespace llvm;

RISCVRegisterInfo::RISCVRegisterInfo(RISCVTargetMachine &tm,
                                         const RISCVInstrInfo &tii)
  : RISCVGenRegisterInfo(RISCV::ra), TM(tm), TII(tii) {}

const uint16_t*
RISCVRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  static const uint16_t CalleeSavedRegs[] = {
    RISCV::s0  , RISCV::s1  , RISCV::s2  , RISCV::s3  , RISCV::s4,
    RISCV::s5  , RISCV::s6  , RISCV::s7  , RISCV::s8  , RISCV::s9,
    RISCV::s10 , RISCV::s11 , RISCV::sp  , RISCV::tp  ,
    RISCV::fs0 , RISCV::fs1 , RISCV::fs2 , RISCV::fs3 , RISCV::fs4,
    RISCV::fs5 , RISCV::fs6 , RISCV::fs7 , RISCV::fs8 , RISCV::fs9,
    RISCV::fs10, RISCV::fs11, RISCV::fs12, RISCV::fs13, RISCV::fs14, 
    RISCV::fs15,
    0
  };

  return CalleeSavedRegs;
}

BitVector
RISCVRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();

  // zero is reserved so llvm doesn't store things there
  Reserved.set(RISCV::zero);

  if (TFI->hasFP(MF)) {
    // fp is the frame pointer.  Reserve all aliases.
    Reserved.set(RISCV::fp);
  }

  // sp is the stack pointer.  Reserve all aliases.
  Reserved.set(RISCV::sp);
  return Reserved;
}

void
RISCVRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator MI,
                                         int SPAdj, unsigned FIOperandNum,
                                         RegScavenger *RS) const {
  assert(SPAdj == 0 && "Outgoing arguments should be part of the frame");

  MachineBasicBlock &MBB = *MI->getParent();
  MachineFunction &MF = *MBB.getParent();
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();
  //TODO: warning unused
  DebugLoc DL = MI->getDebugLoc();

  // Decompose the frame index into a base and offset.
  int FrameIndex = MI->getOperand(FIOperandNum).getIndex();
  unsigned BasePtr = getFrameRegister(MF);
  int64_t Offset = (TFI->getFrameIndexOffset(MF, FrameIndex) +
                    MI->getOperand(FIOperandNum + 1).getImm());

  // Special handling of dbg_value instructions.
  if (MI->isDebugValue()) {
    MI->getOperand(FIOperandNum).ChangeToRegister(BasePtr, /*isDef*/ false);
    MI->getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
    return;
  }

  // See if the offset is in range, or if an equivalent instruction that
  // accepts the offset exists.
  unsigned Opcode = MI->getOpcode();
  unsigned OpcodeForOffset = TII.getOpcodeForOffset(Opcode, Offset);
  if (OpcodeForOffset)
    MI->getOperand(FIOperandNum).ChangeToRegister(BasePtr, false);
  else {
    // Create an anchor point that is in range.  Start at 0xffff so that
    // can use LLILH to load the immediate.
    int64_t OldOffset = Offset;
    int64_t Mask = 0xffff;
    do {
      Offset = OldOffset & Mask;
      OpcodeForOffset = TII.getOpcodeForOffset(Opcode, Offset);
      Mask >>= 1;
      assert(Mask && "One offset must be OK");
    } while (!OpcodeForOffset);

    unsigned ScratchReg =
      MF.getRegInfo().createVirtualRegister(&RISCV::ADDR32BitRegClass);
    int64_t HighOffset = OldOffset - Offset;

    if (MI->getDesc().TSFlags & RISCVII::HasIndex
        && MI->getOperand(FIOperandNum + 2).getReg() == 0) {
      // Load the offset into the scratch register and use it as an index.
      // The scratch register then dies here.
      TII.loadImmediate(MBB, MI, ScratchReg, HighOffset);
      MI->getOperand(FIOperandNum).ChangeToRegister(BasePtr, false);
      MI->getOperand(FIOperandNum + 2).ChangeToRegister(ScratchReg,
                                                        false, false, true);
    } else {

      // Use the scratch register as the base.  It then dies here.
      MI->getOperand(FIOperandNum).ChangeToRegister(ScratchReg,
                                                    false, false, true);
    }
  }
  MI->setDesc(TII.get(OpcodeForOffset));
  MI->getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
}

unsigned
RISCVRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();
  return TFI->hasFP(MF) ? RISCV::fp : RISCV::sp;
}
