##===- lib/Target/RISCV/Makefile -------------------------*- Makefile -*-===##
#
#                     The LLVM Compiler Infrastructure
#
# This file is distributed under the University of Illinois Open Source
# License. See LICENSE.TXT for details.
#
##===----------------------------------------------------------------------===##

LEVEL = ../../..
LIBRARYNAME = LLVMRISCVCodeGen
TARGET = RISCV

# Make sure that tblgen is run, first thing.
BUILT_SOURCES = RISCVGenRegisterInfo.inc \
		RISCVGenAsmWriter.inc \
		RISCVGenAsmMatcher.inc \
		RISCVGenCodeEmitter.inc \
		RISCVGenInstrInfo.inc \
		RISCVGenDAGISel.inc \
		RISCVGenSubtargetInfo.inc \
		RISCVGenCallingConv.inc \
		RISCVGenMCCodeEmitter.inc

DIRS = InstPrinter AsmParser TargetInfo MCTargetDesc

include $(LEVEL)/Makefile.common

