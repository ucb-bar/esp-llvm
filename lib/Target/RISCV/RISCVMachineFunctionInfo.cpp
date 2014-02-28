//===-- RISCVMachineFunctionInfo.cpp - Private data used for RISCV ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVMachineFunctionInfo.h"
//#include "MCTargetDesc/RISCVBaseInfo.h"
#include "RISCVInstrInfo.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Function.h"

using namespace llvm;

void RISCVMachineFunctionInfo::createEhDataRegsFI() {
  //TODO: why is this a magic number
  for (int I = 0; I < 2; ++I) {
    const RISCVSubtarget &ST = MF.getTarget().getSubtarget<RISCVSubtarget>();
    const TargetRegisterClass *RC = ST.isRV64() ? &RISCV::GR64BitRegClass : &RISCV::GR32BitRegClass;

    EhDataRegFI[I] = MF.getFrameInfo()->CreateStackObject(RC->getSize(),
        RC->getAlignment(), false);
  }
}

bool RISCVMachineFunctionInfo::isEhDataRegFI(int FI) const {
  return CallsEhReturn && (FI == EhDataRegFI[0] || FI == EhDataRegFI[1]);
}
