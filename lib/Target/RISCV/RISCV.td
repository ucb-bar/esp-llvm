//===-- RISCV.td - Describe the RISCV target machine -----*- tblgen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Target-independent interfaces which we are implementing
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// RISCV subtarget features
//===----------------------------------------------------------------------===//

def FeatureM : SubtargetFeature<"m", "HasM", "true",
                                "Supports Integer Multiplication and Division.">;
def FeatureA : SubtargetFeature<"a", "HasA", "true",
                                "Supports Atomic Instructions.">;
def FeatureF : SubtargetFeature<"f", "HasF", "true",
                                "Supports Single-Precision Floating-Point.">;
def FeatureD : SubtargetFeature<"d", "HasD", "true",
                                "Supports Double-Precision Floating-Point.">;

def FeatureRV32 : SubtargetFeature<"rv32", "RISCVArchVersion", "RV32", 
                                   "RV32 ISA Support">;
def FeatureRV64 : SubtargetFeature<"rv64", "RISCVArchVersion", "RV64", 
                                   "RV64 ISA Support">;

//===----------------------------------------------------------------------===//
// RISCV supported processors
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"RV32I", [FeatureRV32]>;
def : Proc<"RV32IMAFD", [FeatureRV32,FeatureM,FeatureA,FeatureF,FeatureD]>;
def : Proc<"RV64I", [FeatureRV64]>;
def : Proc<"RV64IMAFD", [FeatureRV64,FeatureM,FeatureA,FeatureF,FeatureD]>;
def : Proc<"Rocket", [FeatureRV64,FeatureM,FeatureA,FeatureF,FeatureD]>;

//===----------------------------------------------------------------------===//
// Register file description
//===----------------------------------------------------------------------===//

include "RISCVRegisterInfo.td"

//===----------------------------------------------------------------------===//
// Calling convention description
//===----------------------------------------------------------------------===//

include "RISCVCallingConv.td"

//===----------------------------------------------------------------------===//
// Instruction descriptions
//===----------------------------------------------------------------------===//

include "RISCVOperators.td"
include "RISCVOperands.td"
include "RISCVInstrFormats.td"
include "RISCVInstrInfo.td"

def RISCVInstrInfo : InstrInfo {}

//===----------------------------------------------------------------------===//
// Assembly parser
//===----------------------------------------------------------------------===//

def RISCVAsmParser : AsmParser {
  let ShouldEmitMatchRegisterName = 0;
}

//===----------------------------------------------------------------------===//
// Assembly writer
//===----------------------------------------------------------------------===//

def RISCVAsmWriter : AsmWriter {
  string AsmWriterClassName = "InstPrinter";
  bit isMCAsmWriter = 1;
}

//===----------------------------------------------------------------------===//
// Top-level target declaration
//===----------------------------------------------------------------------===//

def RISCV : Target {
  let InstructionSet = RISCVInstrInfo;
  let AssemblyParsers = [RISCVAsmParser];
  let AssemblyWriters = [RISCVAsmWriter];
}
