//===-- RISCVOperands.td - RISCV instruction operands ----*- tblgen-*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Class definitions
//===----------------------------------------------------------------------===//

class ImmediateAsmOperand<string name>
  : AsmOperandClass {
  let Name = name;
  let RenderMethod = "addImmOperands";
}

// Constructs both a DAG pattern and instruction operand for an immediate
// of type VT.  PRED returns true if a node is acceptable and XFORM returns
// the operand value associated with the node.  ASMOP is the name of the
// associated asm operand, and also forms the basis of the asm print method.
class Immediate<ValueType vt, code pred, SDNodeXForm xform, string asmop>
  : PatLeaf<(vt imm), pred, xform>, Operand<vt> {
  let PrintMethod = "print"##asmop##"Operand";
  let ParserMatchClass = !cast<AsmOperandClass>(asmop);
}

// Constructs both a DAG pattern and instruction operand for a PC-relative
// address with address size VT.  SELF is the name of the operand.
class PCRelAddress<ValueType vt, string self>
  : ComplexPattern<vt, 1, "selectPCRelAddress", [z_pcrel_wrapper]>,
    Operand<vt> {
  let MIOperandInfo = (ops !cast<Operand>(self));
}

// Constructs an AsmOperandClass for addressing mode FORMAT, treating the
// registers as having BITSIZE bits and displacements as having DISPSIZE bits.
class AddressAsmOperand<string format, string bitsize, string dispsize>
  : AsmOperandClass {
  let Name = format##bitsize##"Disp"##dispsize;
  let ParserMethod = "parse"##format##bitsize;
  let RenderMethod = "add"##format##"Operands";
}

//===----------------------------------------------------------------------===//
// Extracting immediate operands from nodes
// These all create MVT::i64 nodes to ensure the value is not sign-extended
// when converted from an SDNode to a MachineOperand later on.
//===----------------------------------------------------------------------===//
//All these were changed to MVT::i32
// Bits 0-15 (counting from the lsb).
def LL16 : SDNodeXForm<imm, [{
  uint32_t Value = N->getZExtValue() & 0x0000FFFFUL;
  return CurDAG->getTargetConstant(Value, MVT::i32);
}]>;

// Bits 16-31 (counting from the lsb).
def LH16 : SDNodeXForm<imm, [{
  uint32_t Value = (N->getZExtValue() & 0xFFFF0000UL) >> 16;
  return CurDAG->getTargetConstant(Value, MVT::i32);
}]>;

// Low 32 bits.
def LF32 : SDNodeXForm<imm, [{
  uint32_t Value = N->getZExtValue() & 0xFFFFFFFFUL;
  return CurDAG->getTargetConstant(Value, MVT::i32);
}]>;


// Truncate an immediate to a 8-bit signed quantity.
def SIMM8 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(int8_t(N->getZExtValue()), MVT::i32);
}]>;

// Truncate an immediate to a 8-bit unsigned quantity.
def UIMM8 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(uint8_t(N->getZExtValue()), MVT::i32);
}]>;

// Truncate an immediate to a 16-bit signed quantity.
def SIMM16 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(int16_t(N->getZExtValue()), MVT::i32);
}]>;

// Truncate an immediate to a 16-bit unsigned quantity.
def UIMM16 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(uint16_t(N->getZExtValue()), MVT::i32);
}]>;

// Truncate an immediate to a 32-bit signed quantity.
def SIMM32 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(int32_t(N->getZExtValue()), MVT::i32);
}]>;

// Truncate an immediate to a 32-bit unsigned quantity.
def UIMM32 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(uint32_t(N->getZExtValue()), MVT::i32);
}]>;

// Negate and then truncate an immediate to a 32-bit unsigned quantity.
def NEGIMM32 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(uint32_t(-N->getZExtValue()), MVT::i32);
}]>;

//===----------------------------------------------------------------------===//
// Immediate asm operands.
//===----------------------------------------------------------------------===//

def U4Imm  : ImmediateAsmOperand<"U4Imm">;
def U6Imm  : ImmediateAsmOperand<"U6Imm">;
def S8Imm  : ImmediateAsmOperand<"S8Imm">;
def U8Imm  : ImmediateAsmOperand<"U8Imm">;
//RISCV asm op
def S12Imm : ImmediateAsmOperand<"S12Imm">;
def U12Imm : ImmediateAsmOperand<"U12Imm">;
def S20Imm : ImmediateAsmOperand<"S20Imm">;
def U20Imm : ImmediateAsmOperand<"U20Imm">;
//END RISCV
def S16Imm : ImmediateAsmOperand<"S16Imm">;
def U16Imm : ImmediateAsmOperand<"U16Imm">;
def S32Imm : ImmediateAsmOperand<"S32Imm">;
def U32Imm : ImmediateAsmOperand<"U32Imm">;

//===----------------------------------------------------------------------===//
// 8-bit immediates
//===----------------------------------------------------------------------===//

def uimm8zx4 : Immediate<i8, [{
  return isUInt<4>(N->getZExtValue());
}], NOOP_SDNodeXForm, "U4Imm">;

def uimm8zx6 : Immediate<i8, [{
  return isUInt<6>(N->getZExtValue());
}], NOOP_SDNodeXForm, "U6Imm">;

def simm8    : Immediate<i8, [{}], SIMM8, "S8Imm">;
def uimm8    : Immediate<i8, [{}], UIMM8, "U8Imm">;

//===----------------------------------------------------------------------===//
// i32 immediates
//===----------------------------------------------------------------------===//

//RISCV immediates
//sign-extended 12 bit immediate
def imm32sx12 : Immediate<i32, [{
  return isInt<12>(N->getSExtValue());
}], NOOP_SDNodeXForm, "S12Imm">;
def imm32sxu12 : Immediate<i32, [{
  return isUInt<12>(N->getSExtValue());
}], NOOP_SDNodeXForm, "U12Imm">;
//zero-extended 12 bit immediate
def imm32zx12 : Immediate<i32, [{
  return isUInt<12>(N->getZExtValue());
}], NOOP_SDNodeXForm, "U12Imm">;
//sign-extended 20 bit immediate
def imm32sx20 : Immediate<i32, [{
  return isInt<20>(N->getSExtValue());
}], NOOP_SDNodeXForm, "S20Imm">;
//zero-extended 20 bit immediate
def imm32zx20 : Immediate<i32, [{
  return isUInt<20>(N->getZExtValue());
}], NOOP_SDNodeXForm, "U20Imm">;

def simm32 : Immediate<i32, [{}], SIMM32, "S32Imm">;
def uimm32 : Immediate<i32, [{}], UIMM32, "U32Imm">;

def imm32 : ImmLeaf<i32, [{}]>;
//END RISCV


// Immediates for the lower and upper 16 bits of an i32, with the other
// bits of the i32 being zero.
def imm32ll16 : Immediate<i32, [{
  return RISCV::isImmLL(N->getZExtValue());
}], LL16, "U16Imm">;

def imm32lh16 : Immediate<i32, [{
  return RISCV::isImmLH(N->getZExtValue());
}], LH16, "U16Imm">;

// Immediates for the lower and upper 16 bits of an i32, with the other
// bits of the i32 being one.
def imm32ll16c : Immediate<i32, [{
  return RISCV::isImmLL(uint32_t(~N->getZExtValue()));
}], LL16, "U16Imm">;

def imm32lh16c : Immediate<i32, [{
  return RISCV::isImmLH(uint32_t(~N->getZExtValue()));
}], LH16, "U16Imm">;

// Short immediates
def imm32sx8 : Immediate<i32, [{
  return isInt<8>(N->getSExtValue());
}], SIMM8, "S8Imm">;

def imm32zx8 : Immediate<i32, [{
  return isUInt<8>(N->getZExtValue());
}], UIMM8, "U8Imm">;

def imm32zx8trunc : Immediate<i32, [{}], UIMM8, "U8Imm">;

def imm32sx16 : Immediate<i32, [{
  return isInt<16>(N->getSExtValue());
}], SIMM16, "S16Imm">;

def imm32zx16 : Immediate<i32, [{
  return isUInt<16>(N->getZExtValue());
}], UIMM16, "U16Imm">;

def imm32sx16trunc : Immediate<i32, [{}], SIMM16, "S16Imm">;

// Full 32-bit immediates.  we need both signed and unsigned versions
// because the assembler is picky.  E.g. AFI requires signed operands
// while NILF requires unsigned ones.

//===----------------------------------------------------------------------===//
// 64-bit immediates
//===----------------------------------------------------------------------===//

// Immediates for 16-bit chunks of an i64, with the other bits of the
// i32 being zero.
def imm64ll16 : Immediate<i64, [{
  return RISCV::isImmLL(N->getZExtValue());
}], LL16, "U16Imm">;

def imm64lh16 : Immediate<i64, [{
  return RISCV::isImmLH(N->getZExtValue());
}], LH16, "U16Imm">;

// Immediates for 16-bit chunks of an i64, with the other bits of the
// i32 being one.
def imm64ll16c : Immediate<i64, [{
  return RISCV::isImmLL(uint64_t(~N->getZExtValue()));
}], LL16, "U16Imm">;

def imm64lh16c : Immediate<i64, [{
  return RISCV::isImmLH(uint64_t(~N->getZExtValue()));
}], LH16, "U16Imm">;


// Immediates for the lower and upper 32 bits of an i64, with the other
// bits of the i32 being zero.
def imm64lf32 : Immediate<i64, [{
  return RISCV::isImmLF(N->getZExtValue());
}], LF32, "U32Imm">;

// Immediates for the lower and upper 32 bits of an i64, with the other
// bits of the i32 being one.
def imm64lf32c : Immediate<i64, [{
  return RISCV::isImmLF(uint64_t(~N->getZExtValue()));
}], LF32, "U32Imm">;


// Short immediates.
def imm64sx8 : Immediate<i64, [{
  return isInt<8>(N->getSExtValue());
}], SIMM8, "S8Imm">;

def imm64sx16 : Immediate<i64, [{
  return isInt<16>(N->getSExtValue());
}], SIMM16, "S16Imm">;

def imm64zx16 : Immediate<i64, [{
  return isUInt<16>(N->getZExtValue());
}], UIMM16, "U16Imm">;

def imm64sx32 : Immediate<i64, [{
  return isInt<32>(N->getSExtValue());
}], SIMM32, "S32Imm">;

def imm64zx32 : Immediate<i64, [{
  return isUInt<32>(N->getZExtValue());
}], UIMM32, "U32Imm">;

def imm64zx32n : Immediate<i64, [{
  return isUInt<32>(-N->getSExtValue());
}], NEGIMM32, "U32Imm">;

def imm64 : ImmLeaf<i64, [{}]>;

//===----------------------------------------------------------------------===//
// Floating-point immediates
//===----------------------------------------------------------------------===//

// Floating-point zero.
def fpimm0 : PatLeaf<(fpimm), [{ return N->isExactlyValue(+0.0); }]>;

// Floating point negative zero.
def fpimmneg0 : PatLeaf<(fpimm), [{ return N->isExactlyValue(-0.0); }]>;

//===----------------------------------------------------------------------===//
// Symbolic address operands
//===----------------------------------------------------------------------===//

//RISCV symbolic address operands
def jumptarget : Operand<OtherVT> {
  let EncoderMethod = "getJumpTargetEncoding";
}

def brtarget : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
}

def pcimm : PCRelAddress<i32, "pcimm"> {
  let EncoderMethod = "getPCImmEncoding";
}
def pcrel32call : PCRelAddress<i32, "pcrel32call"> {
  let PrintMethod = "printCallOperand";
  let EncoderMethod = "getPLT32DBLEncoding";
}
//END RISCV

// PC-relative offsets of a basic block.  The offset is sign-extended
// and multiplied by 2.
def brtarget16 : Operand<OtherVT> {
  let EncoderMethod = "getPC16DBLEncoding";
}
def brtarget32 : Operand<OtherVT> {
  let EncoderMethod = "getPC32DBLEncoding";
}

// A PC-relative offset of a global value.  The offset is sign-extended
// and multiplied by 2.
def pcrel32 : PCRelAddress<i64, "pcrel32"> {
  let EncoderMethod = "getPC32DBLEncoding";
}

// A PC-relative offset of a global value when the value is used as a
// call target.  The offset is sign-extended and multiplied by 2.
def pcrel16call : PCRelAddress<i64, "pcrel16call"> {
  let PrintMethod = "printCallOperand";
  let EncoderMethod = "getPLT16DBLEncoding";
}

//===----------------------------------------------------------------------===//
// Addressing modes
//===----------------------------------------------------------------------===//

// 12-bit displacement operands.
def disp12imm32 : Operand<i32>;
def disp12imm64 : Operand<i64>;

// 20-bit displacement operands.
def disp20imm32 : Operand<i32>;
def disp20imm64 : Operand<i64>;

//===----------------------------------------------------------------------===//
// Miscellaneous
//===----------------------------------------------------------------------===//

// Access registers.  At present we just use them for accessing the thread
// pointer, so we don't expose them as register to LLVM.
def AccessReg : AsmOperandClass {
  let Name = "AccessReg";
  let ParserMethod = "parseAccessReg";
}
def access_reg : Immediate<i8, [{ return N->getZExtValue() < 16; }],
                           NOOP_SDNodeXForm, "AccessReg"> {
  let ParserMatchClass = AccessReg;
}

// A 4-bit condition-code mask.
def cond4 : PatLeaf<(i8 imm), [{ return (N->getZExtValue() < 16); }]>,
            Operand<i8> {
  let PrintMethod = "printCond4Operand";
}
