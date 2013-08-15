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
// RISCV supported processors
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"Rocket", []>;

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
include "RISCVPatterns.td"
include "RISCVInstrFormats.td"
include "RISCVInstrInfo.td"
//include "RISCVInstrFP.td"

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
