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
  const RISCVSubtarget &Subtarget = TM.getSubtarget<RISCVSubtarget>();
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
RISCVRegisterInfo::getCallPreservedMask(CallingConv::ID) const {
  const RISCVSubtarget &Subtarget = TM.getSubtarget<RISCVSubtarget>();
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
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();

  // zero is reserved so llvm doesn't store things there
  Reserved.set(RISCV::zero);
  Reserved.set(RISCV::zero_64);
  Reserved.set(RISCV::ra);
  Reserved.set(RISCV::ra_64);

  if (TFI->hasFP(MF)) {
    // fp is the frame pointer.  Reserve all aliases.
    Reserved.set(RISCV::fp);
    Reserved.set(RISCV::fp_64);
  }

  // sp is the stack pointer.  Reserve all aliases.
  Reserved.set(RISCV::sp);
  Reserved.set(RISCV::sp_64);
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

    /*
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
    }*/
  }
  MI->setDesc(TII.get(OpcodeForOffset));
  MI->getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
}

unsigned
RISCVRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getTarget().getFrameLowering();
  return TFI->hasFP(MF) ? RISCV::fp : RISCV::sp;
}
