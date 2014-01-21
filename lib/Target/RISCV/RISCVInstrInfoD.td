//==- RISCVInstrFP.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

let mayLoad = 1 in {
  def FLD : InstLoad <"fld" , 0b0000111, 0b011, loadf64,  FP64, mem>, Requires<[HasD,IsRV32]>; 
  def FLD64 : InstLoad <"fld" , 0b0000111, 0b011, loadf64,  FP64, mem64>, Requires<[HasD,IsRV64]>; 
}

let mayStore = 1 in {
  def FSD : InstStore <"fsd" , 0b0100111, 0b011, store, FP64, mem>, Requires<[HasD,IsRV32]>; 
  def FSD64 : InstStore <"fsd" , 0b0100111, 0b011, store, FP64, mem64>, Requires<[HasD,IsRV64]>; 
}

multiclass  FPBinOps64<string name, SDPatternOperator op1, bits<5> funct5, bits<2> fmt> {
  def _RDY : InstR<name, 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,1,1,fmt{1},fmt{0}}, op1, FP64, FP64>;
  let isAsmParserOnly = 1 in { //only use the dynamic version during instruction selection
    def _RNE : InstR<name#".rne", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,0,fmt{1},fmt{0}}, op1, FP64, FP64>;
    def _RTZ : InstR<name#".rtz", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,1,fmt{1},fmt{0}}, op1, FP64, FP64>;
    def _RDN : InstR<name#".rdn", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,0,fmt{1},fmt{0}}, op1, FP64, FP64>;
    def _RUP : InstR<name#".rup", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,1,fmt{1},fmt{0}}, op1, FP64, FP64>;
    def _RMM : InstR<name#".rmm", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,0,0,fmt{1},fmt{0}}, op1, FP64, FP64>;
  }
}
//Single precision arithmetic
defm FADD_D : FPBinOps64<"fadd.d", fadd, 0b00000, 0b01>, Requires<[HasD]>;
defm FSUB_D : FPBinOps64<"fsub.d", fsub, 0b00001, 0b01>, Requires<[HasD]>;
defm FMUL_D : FPBinOps64<"fmul.d", fmul, 0b00010, 0b01>, Requires<[HasD]>;
defm FDIV_D : FPBinOps64<"fdiv.d", fdiv, 0b00011, 0b01>, Requires<[HasD]>;
//let RS2 = 0b00000 in {
  //defm FSQRT_S : FPOps<"fsqrt.s", fsqrt, 0b00100, 0b00>, Requires<[HasD]>;}

//TODO: implement min/max
//defm FMIN_S : FPOps<"fmin.s", fmin, 0b11000, 0b00>, Requires<[HasD]>;
//defm FMAX_S : FPOps<"fmax.s", fmax, 0b11001, 0b00>, Requires<[HasD]>;

//TODO: implement fma

//Move and Conversions
defm FCVT_W_D  : FPConvOps<"fcvt.w.d",  fp_to_sint, GR32, FP64, 0b01010, 0b01>, Requires<[HasD]>;
defm FCVT_WU_D : FPConvOps<"fcvt.wu.d", fp_to_uint, GR32, FP64, 0b01011, 0b01>, Requires<[HasD]>;
defm FCVT_D_W  : FPConvOps<"fcvt.d.w",  sint_to_fp, FP64, GR32, 0b01110, 0b01>, Requires<[HasD]>;
defm FCVT_D_WU : FPConvOps<"fcvt.d.wu", uint_to_fp, FP64, GR32, 0b01111, 0b01>, Requires<[HasD]>;
//RV64F
defm FCVT_L_D  : FPConvOps<"fcvt.l.d",  fp_to_sint, GR64, FP64, 0b01000, 0b01>, Requires<[HasD,IsRV64]>;
defm FCVT_LU_D : FPConvOps<"fcvt.lu.d", fp_to_uint, GR64, FP64, 0b01001, 0b01>, Requires<[HasD,IsRV64]>;
defm FCVT_D_L  : FPConvOps<"fcvt.d.l",  sint_to_fp, FP64, GR64, 0b01100, 0b01>, Requires<[HasD,IsRV64]>;
defm FCVT_D_LU : FPConvOps<"fcvt.d.lu", uint_to_fp, FP64, GR64, 0b01101, 0b01>, Requires<[HasD,IsRV64]>;
//Single <-> Double
defm FCVT_S_D  : FPConvOps<"fcvt.s.d",  fround , FP32, FP64, 0b10001, 0b00>, Requires<[HasD]>;
defm FCVT_D_S  : FPConvOps<"fcvt.d.s",  fextend, FP64, FP32, 0b10000, 0b01>, Requires<[HasD]>;

//Sign injection
def FSGNJ_D : InstSign<"fsgnj.d", 0b1010011, 0b00101, 0b01, 0b000,
                        fcopysign, FP64, FP64>, Requires<[HasD]>;
def FSGNJN_D : InstSign<"fsgnj.d", 0b1010011, 0b00101, 0b01, 0b000,
                        fcopysign, FP64, FP64>, Requires<[HasD]> {
                          let Pattern =
                          [(set FP64:$dst, (fcopysign FP64:$src1, (fneg FP64:$src2)))];
                        }

//TODO: implement FSGNJX using pattern (maybe ask andrew what he thinks a good sequence would be)

//Move instruction (bitcasts)
def FMV_X_D : InstConv<"fmv.x.d", 0b1010011, 0b11100, 0b01, 0b000, bitconvert, GR64, FP64>, Requires<[HasD, IsRV64]>;
def FMV_D_X : InstConv<"fmv.d.x", 0b1010011, 0b11110, 0b01, 0b000, bitconvert, FP64, GR64>, Requires<[HasD, IsRV64]>;

//Floating point comparisons
def FEQ_D : InstSign<"feq.d", 0b1010011, 0b10101, 0b01, 0b000, seteq, GR32, FP64>, Requires<[HasD]>;
def FLT_D : InstSign<"flt.d", 0b1010011, 0b10110, 0b01, 0b000, setlt, GR32, FP64>, Requires<[HasD]>;
def FLE_D : InstSign<"fle.d", 0b1010011, 0b10111, 0b01, 0b000, setle, GR32, FP64>, Requires<[HasD]>;
//RV64D
def FEQ_D64 : InstSign<"feq.d", 0b1010011, 0b10101, 0b01, 0b000, setoeq, GR64, FP64>, Requires<[HasD,IsRV64]>;
def FLT_D64 : InstSign<"flt.d", 0b1010011, 0b10110, 0b01, 0b000, setolt, GR64, FP64>, Requires<[HasD,IsRV64]>;
def FLE_D64 : InstSign<"fle.d", 0b1010011, 0b10111, 0b01, 0b000, setole, GR64, FP64>, Requires<[HasD,IsRV64]>;
def FUEQ_D64 : InstSign<"feq.d", 0b1010011, 0b10101, 0b01, 0b000, setueq, GR64, FP64>, Requires<[HasD,IsRV64]>;
def FULT_D64 : InstSign<"flt.d", 0b1010011, 0b10110, 0b01, 0b000, setult, GR64, FP64>, Requires<[HasD,IsRV64]>;
def FULE_D64 : InstSign<"fle.d", 0b1010011, 0b10111, 0b01, 0b000, setule, GR64, FP64>, Requires<[HasD,IsRV64]>;
//synthesized set operators
multiclass FPCmpPats<RegisterOperand RC, Instruction FLTOp, Instruction FLTUOp,
                     Instruction FLEOp, Instruction FLEUOp> {
  //lhs > rhs ==> rhs < lhs
  def : Pat<(setogt RC:$lhs, RC:$rhs), (FLTOp RC:$rhs, RC:$lhs)>;
  def : Pat<(setugt RC:$lhs, RC:$rhs), (FLTUOp RC:$rhs, RC:$lhs)>;
  //lhs >= rhs ==> rhs =< lhs
  def : Pat<(setoge RC:$lhs, RC:$rhs), (FLEOp RC:$rhs, RC:$lhs)>;
  def : Pat<(setuge RC:$lhs, RC:$rhs), (FLEUOp RC:$rhs, RC:$lhs)>;
  //lhs != rhs ==> !(lhs == rhs)
}

defm : FPCmpPats<FP64, FLT_D, FLT_D, FLE_D, FLE_D>;
defm : FPCmpPats<FP64, FLT_D64, FULT_D64, FLE_D64, FULE_D64>;

//extloads
def : Pat<(extloadf32 addr:$addr), (FCVT_D_S_RDY (FLW addr:$addr))>, Requires<[HasD,IsRV32]>;
def : Pat<(extloadf32 addr:$addr), (FCVT_D_S_RDY (FLW64 addr:$addr))>, Requires<[HasD,IsRV64]>;

//fp imm
def :Pat<(fpimm0), (FCVT_D_W_RDY zero)>;
