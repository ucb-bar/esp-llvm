//===-- RISCVPatterns.td - RISCV-specific pattern rules ---*- tblgen-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// Record that INSN performs a 64-bit version of unary operator OPERATOR
// in which the operand is sign-extended from 32 to 64 bits.
multiclass SXU<SDPatternOperator operator, Instruction insn> {
  def : Pat<(operator (sext (i32 GR32:$src))),
            (insn GR32:$src)>;
}

// Record that INSN performs a 64-bit version of binary operator OPERATOR
// in which the first operand has class CLS and which the second operand
// is sign-extended from a 32-bit register.
multiclass SXB<SDPatternOperator operator, RegisterOperand cls,
               Instruction insn> {
  def : Pat<(operator cls:$src1, (sext GR32:$src2)),
            (insn cls:$src1, GR32:$src2)>;
}

// Like SXB, but for zero extension.
multiclass ZXB<SDPatternOperator operator, RegisterOperand cls,
               Instruction insn> {
  def : Pat<(operator cls:$src1, (zext GR32:$src2)),
            (insn cls:$src1, GR32:$src2)>;
}
