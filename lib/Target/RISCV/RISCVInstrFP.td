//==- RISCVInstrFP.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Move instructions
//===----------------------------------------------------------------------===//

// Load zero.
let neverHasSideEffects = 1, isAsCheapAsAMove = 1, isMoveImm = 1 in {
  def LZER : InherentRRE<"lzer", 0xB374, FP32,  (fpimm0)>;
}

// Moves between two floating-point registers.
let neverHasSideEffects = 1 in {
  def LER : UnaryRR <"ler", 0x38,   null_frag, FP32,  FP32>;
}

// fcopysign with an FP32 result.
let isCodeGenOnly = 1 in {
  def CPSDRss : BinaryRevRRF<"cpsdr", 0xB372, fcopysign, FP32, FP32>;
}

//===----------------------------------------------------------------------===//
// Unary arithmetic
//===----------------------------------------------------------------------===//

// Negation (Load Complement).
  def LCEBR : UnaryRRE<"lcebr", 0xB303, fneg, FP32,  FP32>;

// Absolute value (Load Positive).
  def LPEBR : UnaryRRE<"lpebr", 0xB300, fabs, FP32,  FP32>;

// Negative absolute value (Load Negative).
  def LNEBR : UnaryRRE<"lnebr", 0xB301, fnabs, FP32,  FP32>;

// Square root.
def SQEBR : UnaryRRE<"sqebr", 0xB314, fsqrt, FP32,  FP32>;


// Round to an integer, with the second operand (modifier M3) specifying
// the rounding mode.
//
// These forms always check for inexact conditions.  z196 added versions
// that allow this to suppressed (as for fnearbyint), but we don't yet
// support -march=z196.
  def FIEBR : UnaryRRF<"fiebr", 0xB357, FP32,  FP32>;

// frint rounds according to the current mode (modifier 0) and detects
// inexact conditions.
def : Pat<(frint FP32:$src),  (FIEBR FP32:$src,  0)>;

//===----------------------------------------------------------------------===//
// Binary arithmetic
//===----------------------------------------------------------------------===//

// Addition.
  let isCommutable = 1 in {
    def AEBR : BinaryRRE<"aebr", 0xB30A, fadd, FP32,  FP32>;
  }

// Subtraction.
  def SEBR : BinaryRRE<"sebr", 0xB30B, fsub, FP32,  FP32>;

// Multiplication.
let isCommutable = 1 in {
  def MEEBR : BinaryRRE<"meebr", 0xB317, fmul, FP32,  FP32>;
}

// Fused multiply-add.
def MAEBR : TernaryRRD<"maebr", 0xB30E, z_fma, FP32>;

// Fused multiply-subtract.
def MSEBR : TernaryRRD<"msebr", 0xB30F, z_fms, FP32>;

// Division.
def DEBR : BinaryRRE<"debr", 0xB30D, fdiv, FP32,  FP32>;

//===----------------------------------------------------------------------===//
// Comparisons
//===----------------------------------------------------------------------===//

  def CEBR : CompareRRE<"cebr", 0xB309, z_cmp, FP32,  FP32>;

//===----------------------------------------------------------------------===//
// Peepholes
//===----------------------------------------------------------------------===//

def : Pat<(f32  fpimmneg0), (LCEBR (LZER))>;
