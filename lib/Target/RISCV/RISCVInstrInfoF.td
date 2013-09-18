//==- RISCVInstrFP.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

let mayLoad = 1 in {
  def FLW : InstLoad <"FLW" , 0b0000111, 0b010, load,  GR32, mem>, Requires<[HasF]>; 
}

let mayStore = 1 in {
  def FSW : InstStore <"FSW" , 0b0100111, 0b010, store, GR32, mem>, Requires<[HasF]>; 
}

multiclass  FPOps<string name, SDPatternOperator op1, bits<5> funct5, bits<2> fmt> {
  def RNE : InstR<name#"RNE", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
  def RTZ : InstR<name#"RTZ", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
  def RDN : InstR<name#"RDN", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
  def RUP : InstR<name#"RUP", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
  def RMM : InstR<name#"RMM", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,0,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
  def RDY : InstR<name#"RDY", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,1,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
}
//Single precision arithmetic
defm FADD_S : FPOps<"FADD.S", fadd, 0b00000, 0b00>, Requires<[HasF]>;
defm FSUB_S : FPOps<"FSUB.S", fsub, 0b00001, 0b00>, Requires<[HasF]>;
defm FMUL_S : FPOps<"FMUL.S", fmul, 0b00010, 0b00>, Requires<[HasF]>;
defm FDIV_S : FPOps<"FDIV.S", fdiv, 0b00011, 0b00>, Requires<[HasF]>;
//let RS2 = 0b00000 in {
  //defm FSQRT_S : FPOps<"FSQRT.S", fsqrt, 0b00100, 0b00>, Requires<[HasF]>;}

//TODO: implement min/max
//defm FMIN_S : FPOps<"FMIN.S", fmin, 0b11000, 0b00>, Requires<[HasF]>;
//defm FMAX_S : FPOps<"FMAX.S", fmax, 0b11001, 0b00>, Requires<[HasF]>;
