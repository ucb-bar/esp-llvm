//===-- RISCVMCTargetDesc.cpp - RISCV target descriptions -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "RISCVMCTargetDesc.h"
#include "InstPrinter/RISCVInstPrinter.h"
#include "RISCVMCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "RISCVGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "RISCVGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "RISCVGenRegisterInfo.inc"

using namespace llvm;

static MCAsmInfo *createRISCVMCAsmInfo(const MCRegisterInfo &MRI,
                                       const Triple &TT) {
  MCAsmInfo *MAI = new RISCVMCAsmInfo();
  MCCFIInstruction Inst = MCCFIInstruction::createDefCfa(
      nullptr, MRI.getDwarfRegNum(RISCV::sp, true),
      RISCVMC::CFAOffsetFromInitialSP);
  MAI->addInitialFrameState(Inst);
  return MAI;
}

static MCInstrInfo *createRISCVMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitRISCVMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createRISCVMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitRISCVMCRegisterInfo(X, RISCV::sp);
  return X;
}

static MCSubtargetInfo *createRISCVMCSubtargetInfo(const Triple &TT,
                                                     StringRef CPU,
                                                     StringRef FS) {
  return createRISCVMCSubtargetInfoImpl(TT, CPU, FS);
}

static MCInstPrinter *createRISCVMCInstPrinter(const Triple &TT,
                                                 unsigned SyntaxVariant,
                                                 const MCAsmInfo &MAI,
                                                 const MCInstrInfo &MII,
                                                 const MCRegisterInfo &MRI) {
  return new RISCVInstPrinter(MAI, MII, MRI);
}

static MCStreamer *
createRISCVMCObjectStreamer(const Triple &TT, MCContext &Ctx,
                            MCAsmBackend &MAB, raw_pwrite_stream &OS,
                            MCCodeEmitter *Emitter, bool RelaxAll) {
  return createELFStreamer(Ctx, MAB, OS, Emitter, RelaxAll);
}

extern "C" void LLVMInitializeRISCVTargetMC() {
  // Register the MCAsmInfo.
  TargetRegistry::RegisterMCAsmInfo(TheRISCVTarget,
                                    createRISCVMCAsmInfo);
  TargetRegistry::RegisterMCAsmInfo(TheRISCV64Target,
                                    createRISCVMCAsmInfo);

  // Register the MCCodeEmitter.
  TargetRegistry::RegisterMCCodeEmitter(TheRISCVTarget,
					createRISCVMCCodeEmitter);
  TargetRegistry::RegisterMCCodeEmitter(TheRISCV64Target,
					createRISCVMCCodeEmitter);

  // Register the MCInstrInfo.
  TargetRegistry::RegisterMCInstrInfo(TheRISCVTarget,
                                      createRISCVMCInstrInfo);
  TargetRegistry::RegisterMCInstrInfo(TheRISCV64Target,
                                      createRISCVMCInstrInfo);

  // Register the MCRegisterInfo.
  TargetRegistry::RegisterMCRegInfo(TheRISCVTarget,
                                    createRISCVMCRegisterInfo);
  TargetRegistry::RegisterMCRegInfo(TheRISCV64Target,
                                    createRISCVMCRegisterInfo);

  // Register the MCSubtargetInfo.
  TargetRegistry::RegisterMCSubtargetInfo(TheRISCVTarget,
                                          createRISCVMCSubtargetInfo);
  TargetRegistry::RegisterMCSubtargetInfo(TheRISCV64Target,
                                          createRISCVMCSubtargetInfo);

  // Register the MCAsmBackend.
  TargetRegistry::RegisterMCAsmBackend(TheRISCVTarget,
                                       createRISCVMCAsmBackend);
  TargetRegistry::RegisterMCAsmBackend(TheRISCV64Target,
                                       createRISCVMCAsmBackend);

  // Register the MCInstPrinter.
  TargetRegistry::RegisterMCInstPrinter(TheRISCVTarget,
                                        createRISCVMCInstPrinter);
  TargetRegistry::RegisterMCInstPrinter(TheRISCV64Target,
                                        createRISCVMCInstPrinter);

  // Register the MCObjectStreamer;
  TargetRegistry::RegisterELFStreamer(TheRISCVTarget,
                                           createRISCVMCObjectStreamer);
  TargetRegistry::RegisterELFStreamer(TheRISCV64Target,
                                           createRISCVMCObjectStreamer);
}
