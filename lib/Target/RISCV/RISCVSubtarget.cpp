//===-- RISCVSubtarget.cpp - RISCV subtarget information --------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVSubtarget.h"
#include "RISCV.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "riscv-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "RISCVGenSubtargetInfo.inc"

using namespace llvm;

RISCVSubtarget &RISCVSubtarget::initializeSubtargetDependencies(StringRef CPU,
                                                                StringRef FS) {
  std::string CPUName = CPU;
  if (CPUName.empty()){
    //TODO:generate cpu name?
    CPUName = "";
  }

  // Parse features string.
  ParseSubtargetFeatures(CPUName, FS);
  return *this;
}

RISCVSubtarget::RISCVSubtarget(const Triple &TT, const std::string &CPU,
                               const std::string &FS, const TargetMachine &TM)
    : RISCVGenSubtargetInfo(TT, CPU, FS), RISCVArchVersion(RV32), HasM(false),
      HasA(false), HasF(false), HasD(false), TargetTriple(TT),
      InstrInfo(initializeSubtargetDependencies(CPU,FS)), TLInfo(TM, *this), TSInfo(), FrameLowering() {}

// Return true if GV binds locally under reloc model RM.
static bool bindsLocally(const GlobalValue *GV, Reloc::Model RM) {
  // For non-PIC, all symbols bind locally.
  if (RM == Reloc::Static)
    return true;

  return GV->hasLocalLinkage() || !GV->hasDefaultVisibility();
}

bool RISCVSubtarget::isPC32DBLSymbol(const GlobalValue *GV,
                                       Reloc::Model RM,
                                       CodeModel::Model CM) const {
  // PC32DBL accesses require the low bit to be clear.  Note that a zero
  // value selects the default alignment and is therefore OK.
  if (GV->getAlignment() == 1)
    return false;

  // For the small model, all locally-binding symbols are in range.
  if (CM == CodeModel::Small)
    return bindsLocally(GV, RM);

  // For Medium and above, assume that the symbol is not within the 4GB range.
  // Taking the address of locally-defined text would be OK, but that
  // case isn't easy to detect.
  return false;
}
