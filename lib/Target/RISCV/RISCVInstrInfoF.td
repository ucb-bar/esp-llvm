//==- RISCVInstrFP.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

let mayLoad = 1 in {
  def FLW : InstLoad <"flw" , 0b0000111, 0b010, load,  GR32, mem>, Requires<[HasF]>; 
}

let mayStore = 1 in {
  def FSW : InstStore <"fsw" , 0b0100111, 0b010, store, GR32, mem>, Requires<[HasF]>; 
}

multiclass  FPOps<string name, SDPatternOperator op1, bits<5> funct5, bits<2> fmt> {
  let AddedComplexity = 10 in { //only use the dynamic version during instruction selection
    def RNE : InstR<name#"rne", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def RTZ : InstR<name#"rtz", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def RDN : InstR<name#"rdn", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def RUP : InstR<name#"rup", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def RMM : InstR<name#"rmm", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,0,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
  }
  def RDY : InstR<name, 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,1,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
}
//Single precision arithmetic
defm FADD_S : FPOps<"fadd.s", fadd, 0b00000, 0b00>, Requires<[HasF]>;
defm FSUB_S : FPOps<"fsub.s", fsub, 0b00001, 0b00>, Requires<[HasF]>;
defm FMUL_S : FPOps<"fmul.s", fmul, 0b00010, 0b00>, Requires<[HasF]>;
defm FDIV_S : FPOps<"fdiv.s", fdiv, 0b00011, 0b00>, Requires<[HasF]>;
//let RS2 = 0b00000 in {
  //defm FSQRT_S : FPOps<"fsqrt.s", fsqrt, 0b00100, 0b00>, Requires<[HasF]>;}

//TODO: implement min/max
//defm FMIN_S : FPOps<"fmin.s", fmin, 0b11000, 0b00>, Requires<[HasF]>;
//defm FMAX_S : FPOps<"fmax.s", fmax, 0b11001, 0b00>, Requires<[HasF]>;
