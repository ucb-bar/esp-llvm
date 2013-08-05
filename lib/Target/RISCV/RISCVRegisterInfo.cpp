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
  : RISCVGenRegisterInfo(RISCV::X14), TM(tm), TII(tii) {}

const uint16_t*
RISCVRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  static const uint16_t CalleeSavedRegs[] = {
    RISCV::X2,  RISCV::X3,  RISCV::X4,  RISCV::X5,  RISCV::X6,
    RISCV::X7,  RISCV::X8,  RISCV::X9,  RISCV::X10, RISCV::X11,
    RISCV::X12, RISCV::X13, RISCV::X14, RISCV::X15,
    RISCV::F2,  RISCV::F3,  RISCV::F4,  RISCV::F5,  RISCV::F6,
    RISCV::F7,  RISCV::F8,  RISCV::F9,  RISCV::F10, RISCV::F11,
    RISCV::F12, RISCV::F13, RISCV::F14, RISCV::F15,
    0
  };

  return CalleeSavedRegs;
}

BitVector
RISCVRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();

  if (TFI->hasFP(MF)) {
    // R11D is the frame pointer.  Reserve all aliases.
    Reserved.set(RISCV::X2);
  }

  // R15D is the stack pointer.  Reserve all aliases.
  Reserved.set(RISCV::X15);
  return Reserved;
}

bool
RISCVRegisterInfo::saveScavengerRegister(MachineBasicBlock &MBB,
					   MachineBasicBlock::iterator SaveMBBI,
					   MachineBasicBlock::iterator &UseMBBI,
					   const TargetRegisterClass *RC,
					   unsigned Reg) const {
  MachineFunction &MF = *MBB.getParent();
  const RISCVFrameLowering *TFI =
    static_cast<const RISCVFrameLowering *>(TM.getFrameLowering());
  unsigned Base = getFrameRegister(MF);
  uint64_t Offset = TFI->getEmergencySpillSlotOffset(MF);
  DebugLoc DL;

  unsigned LoadOpcode, StoreOpcode;
  TII.getLoadStoreOpcodes(RC, LoadOpcode, StoreOpcode);

  // The offset must always be in range of a 12-bit unsigned displacement.
  BuildMI(MBB, SaveMBBI, DL, TII.get(StoreOpcode))
    .addReg(Reg, RegState::Kill).addReg(Base).addImm(Offset).addReg(0);
  BuildMI(MBB, UseMBBI, DL, TII.get(LoadOpcode), Reg)
    .addReg(Base).addImm(Offset).addReg(0);
  return true;
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
  return TFI->hasFP(MF) ? RISCV::X2 : RISCV::X15;
}
