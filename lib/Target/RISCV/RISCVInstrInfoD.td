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
//The float to int conversions do nothing because fp_to_uint means RTZ specifically
defm FCVT_W_D  : FPConvOps<"fcvt.w.d",  null_frag, GR32, FP64, 0b01010, 0b01>, Requires<[HasD]>;
defm FCVT_WU_D : FPConvOps<"fcvt.wu.d", null_frag, GR32, FP64, 0b01011, 0b01>, Requires<[HasD]>;
defm FCVT_D_W  : FPConvOps<"fcvt.d.w",  sint_to_fp, FP64, GR32, 0b01110, 0b01>, Requires<[HasD]>;
defm FCVT_D_WU : FPConvOps<"fcvt.d.wu", uint_to_fp, FP64, GR32, 0b01111, 0b01>, Requires<[HasD]>;
//make sure we get the right rounding mode
def :Pat<(i32 (fp_to_uint FP64:$src)), (FCVT_WU_D_RTZ FP64:$src)>;
def :Pat<(i32 (fp_to_sint FP64:$src)), (FCVT_W_D_RTZ FP64:$src)>;
//RV64F
defm FCVT_L_D  : FPConvOps<"fcvt.l.d",  null_frag, GR64, FP64, 0b01000, 0b01>, Requires<[HasD,IsRV64]>;
defm FCVT_LU_D : FPConvOps<"fcvt.lu.d", null_frag, GR64, FP64, 0b01001, 0b01>, Requires<[HasD,IsRV64]>;
defm FCVT_D_L  : FPConvOps<"fcvt.d.l",  sint_to_fp, FP64, GR64, 0b01100, 0b01>, Requires<[HasD,IsRV64]>;
defm FCVT_D_LU : FPConvOps<"fcvt.d.lu", uint_to_fp, FP64, GR64, 0b01101, 0b01>, Requires<[HasD,IsRV64]>;
//make sure we get the right rounding mode
def :Pat<(i64 (fp_to_uint FP64:$src)), (FCVT_LU_D_RTZ FP64:$src)>;
def :Pat<(i64 (fp_to_sint FP64:$src)), (FCVT_L_D_RTZ FP64:$src)>;
//Single <-> Double
defm FCVT_S_D  : FPConvOps<"fcvt.s.d",  fround , FP32, FP64, 0b10001, 0b00>, Requires<[HasD]>;
defm FCVT_D_S  : FPConvOps<"fcvt.d.s",  fextend, FP64, FP32, 0b10000, 0b01>, Requires<[HasD]>;

//Sign injection
def FSGNJ_D : InstSign<"fsgnj.d", 0b1010011, 0b00101, 0b01, 0b000,
                        fcopysign, FP64, FP64>, Requires<[HasD]>;
def FSGNJN_D : InstSign<"fsgnjn.d", 0b1010011, 0b00110, 0b01, 0b000,
                        fcopysign, FP64, FP64>, Requires<[HasD]> {
                          let Pattern =
                          [(set FP64:$dst, (fcopysign FP64:$src1, (fneg FP64:$src2)))];
                        }
//pattern is
//if signs are equal copysign from abs(src2)
//otherwise copysign from fabs( fneg (src2))
def FSGNJX_D : InstSign<"fsgnjx.d", 0b1010011, 0b00111, 0b01, 0b000,
    fcopysign, FP64, FP64>, Requires<[HasD]> {
      let Pattern =
      [(set FP64:$dst, (select 
      (i32 (seteq (i32 (fgetsign FP64:$src1)), (i32 (fgetsign FP64:$src2)))),
        (fcopysign FP64:$src1, (fabs FP64:$src2)),
        (fcopysign FP64:$src1, (fneg (fabs FP64:$src2)))
      ))];
      }

//llvm cant select fneq itsels so help it out
def : Pat<(fneg FP64:$src), (FSGNJN_D FP64:$src, FP64:$src)>, Requires<[HasD]>;
def : Pat<(fabs FP64:$src), (FSGNJX_D FP64:$src, FP64:$src)>, Requires<[HasD]>;
//llvm also can't select f32 = fcopysign f32,f64
def : Pat<(fcopysign FP32:$src1, FP64:$src2), (FSGNJ_S FP32:$src1, (FCVT_S_D_RDY FP64:$src2))>;

//Move instruction (bitcasts)
def FMV_X_D : InstConv<"fmv.x.d", "", 0b1010011, 0b11100, 0b01, 0b000, bitconvert, GR64, FP64>, Requires<[HasD, IsRV64]>;
def FMV_D_X : InstConv<"fmv.d.x", "", 0b1010011, 0b11110, 0b01, 0b000, bitconvert, FP64, GR64>, Requires<[HasD, IsRV64]>;

//Floating point comparisons
def FEQ_D : InstSign<"feq.d", 0b1010011, 0b10101, 0b01, 0b000, setoeq, GR32, FP64>, Requires<[HasD]>;
def FLT_D : InstSign<"flt.d", 0b1010011, 0b10110, 0b01, 0b000, setolt, GR32, FP64>, Requires<[HasD]>;
def FLE_D : InstSign<"fle.d", 0b1010011, 0b10111, 0b01, 0b000, setole, GR32, FP64>, Requires<[HasD]>;
def FUEQ_D : InstSign<"feq.d", 0b1010011, 0b10101, 0b01, 0b000, setueq, GR32, FP64>, Requires<[HasD]>;
def FULT_D : InstSign<"flt.d", 0b1010011, 0b10110, 0b01, 0b000, setult, GR32, FP64>, Requires<[HasD]>;
def FULE_D : InstSign<"fle.d", 0b1010011, 0b10111, 0b01, 0b000, setule, GR32, FP64>, Requires<[HasD]>;
//synthesized set operators

defm : FPCmpPats<FP64, FEQ_D, FUEQ_D, FLT_D, FULT_D, FLE_D, FULE_D>;

//extloads
def : Pat<(extloadf32 addr:$addr), (FCVT_D_S_RDY (FLW addr:$addr))>, Requires<[HasD,IsRV32]>;
def : Pat<(extloadf32 addr:$addr), (FCVT_D_S_RDY (FLW64 addr:$addr))>, Requires<[HasD,IsRV64]>;

//fp imm
def :Pat<(fpimm0), (FCVT_D_W_RDY zero)>;

//fp select
let usesCustomInserter = 1 in {
  def FSELECT_CC_D : Pseudo<(outs FP64:$dst),
                              (ins GR32:$cond, FP64:$T, FP64:$F),
                              [(set FP64:$dst,
                                 (select GR32:$cond, FP64:$T, FP64:$F))]>, Requires<[HasD]>;
}
