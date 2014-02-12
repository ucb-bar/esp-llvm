//==- RISCVInstrFP.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

let mayLoad = 1 in {
  def FLW : InstLoad <"flw" , 0b0000111, 0b010, loadf32,  FP32, mem>, Requires<[HasF,IsRV32]>; 
  def FLW64 : InstLoad <"flw" , 0b0000111, 0b010, loadf32,  FP32, mem64>, Requires<[HasF,IsRV64]>; 
}

let mayStore = 1 in {
  def FSW : InstStore <"fsw" , 0b0100111, 0b010, store, FP32, mem>, Requires<[HasF,IsRV32]>; 
  def FSW64 : InstStore <"fsw" , 0b0100111, 0b010, store, FP32, mem64>, Requires<[HasF,IsRV64]>; 
}

multiclass  FPBinOps<string name, SDPatternOperator op1, bits<5> funct5, bits<2> fmt> {
  def _RDY : InstR<name, 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,1,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
  let isAsmParserOnly = 1 in { //only use the dynamic version during instruction selection
    def _RNE : InstR<name#".rne", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def _RTZ : InstR<name#".rtz", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,0,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def _RDN : InstR<name#".rdn", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def _RUP : InstR<name#".rup", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},0,1,1,fmt{1},fmt{0}}, op1, FP32, FP32>;
    def _RMM : InstR<name#".rmm", 0b1010011, {funct5{4},funct5{3},funct5{2},funct5{1},funct5{0},1,0,0,fmt{1},fmt{0}}, op1, FP32, FP32>;
  }
}
//Single precision arithmetic
defm FADD_S : FPBinOps<"fadd.s", fadd, 0b00000, 0b00>, Requires<[HasF]>;
defm FSUB_S : FPBinOps<"fsub.s", fsub, 0b00001, 0b00>, Requires<[HasF]>;
defm FMUL_S : FPBinOps<"fmul.s", fmul, 0b00010, 0b00>, Requires<[HasF]>;
defm FDIV_S : FPBinOps<"fdiv.s", fdiv, 0b00011, 0b00>, Requires<[HasF]>;
//let RS2 = 0b00000 in {
  //defm FSQRT_S : FPOps<"fsqrt.s", fsqrt, 0b00100, 0b00>, Requires<[HasF]>;}

//TODO: implement min/max
//defm FMIN_S : FPOps<"fmin.s", fmin, 0b11000, 0b00>, Requires<[HasF]>;
//defm FMAX_S : FPOps<"fmax.s", fmax, 0b11001, 0b00>, Requires<[HasF]>;

//TODO: implement fma

//Move and Conversions
class InstConv<string mnemonic, string rmstr, bits<7> op, bits<5> funct5, bits<2> fmt, bits<3> rm,
               SDPatternOperator operator, RegisterOperand cls1, 
               RegisterOperand cls2>
  : InstRISCV<4, (outs cls1:$dst), (ins cls2:$src1), 
                mnemonic#"\t$dst, $src1"#rmstr, 
                [(set cls1:$dst, (operator cls2:$src1))]> {
  field bits<32> Inst;

  bits<5> RD;
  bits<5> RS1;

  let Inst{31-27} = funct5;
  let Inst{26-25} = fmt;
  let Inst{24-20} = 0b00000;
  let Inst{19-15} = RS1;
  let Inst{14-12} = rm;
  let Inst{11- 7} = RD;
  let Inst{6 - 0} = op;
}

multiclass  FPConvOps<string name, SDPatternOperator op1, RegisterOperand outCls, RegisterOperand inCls, bits<5> funct5, bits<2> fmt> {
  def _RDY : InstConv<name,"", 0b1010011, funct5, fmt, 0b111, op1, outCls, inCls>;
  let isAsmParserOnly = 1 in { //only use the dynamic version during instruction selection
    def _RNE : InstConv<name,",rne", 0b1010011, funct5, fmt, 0b000, op1, outCls, inCls>;
    def _RTZ : InstConv<name,",rtz", 0b1010011, funct5, fmt, 0b001, op1, outCls, inCls>;
    def _RDN : InstConv<name,",rdn", 0b1010011, funct5, fmt, 0b010, op1, outCls, inCls>;
    def _RUP : InstConv<name,",rup", 0b1010011, funct5, fmt, 0b011, op1, outCls, inCls>;
    def _RMM : InstConv<name,",rmm", 0b1010011, funct5, fmt, 0b100, op1, outCls, inCls>;
  }
}

defm FCVT_W_S  : FPConvOps<"fcvt.w.s",  null_frag, GR32, FP32, 0b01010, 0b00>, Requires<[HasF]>;
defm FCVT_WU_S : FPConvOps<"fcvt.wu.s", null_frag, GR32, FP32, 0b01011, 0b00>, Requires<[HasF]>;
defm FCVT_S_W  : FPConvOps<"fcvt.s.w",  sint_to_fp, FP32, GR32, 0b01110, 0b00>, Requires<[HasF]>;
defm FCVT_S_WU : FPConvOps<"fcvt.s.wu", uint_to_fp, FP32, GR32, 0b01111, 0b00>, Requires<[HasF]>;
//make sure we get the right rounding mode
def :Pat<(i32 (fp_to_uint FP32:$src)), (FCVT_WU_S_RTZ FP32:$src)>;
def :Pat<(i32 (fp_to_sint FP32:$src)), (FCVT_W_S_RTZ FP32:$src)>;

//RV64F
defm FCVT_L_S  : FPConvOps<"fcvt.l.s",  null_frag, GR64, FP32, 0b01000, 0b00>, Requires<[HasF,IsRV64]>;
defm FCVT_LU_S : FPConvOps<"fcvt.lu.s", null_frag, GR64, FP32, 0b01001, 0b00>, Requires<[HasF,IsRV64]>;
defm FCVT_S_L  : FPConvOps<"fcvt.s.l",  sint_to_fp, FP32, GR64, 0b01100, 0b00>, Requires<[HasF,IsRV64]>;
defm FCVT_S_LU : FPConvOps<"fcvt.s.lu", uint_to_fp, FP32, GR64, 0b01101, 0b00>, Requires<[HasF,IsRV64]>;
//make sure we get the right rounding mode
def :Pat<(i64 (fp_to_uint FP32:$src)), (FCVT_LU_S_RTZ FP32:$src)>;
def :Pat<(i64 (fp_to_sint FP32:$src)), (FCVT_L_S_RTZ FP32:$src)>;

//Sign injection
class InstSign<string mnemonic, bits<7> op, bits<5> funct5, bits<2> fmt, bits<3> rm,
               SDPatternOperator operator, RegisterOperand cls1, 
               RegisterOperand cls2>
  : InstRISCV<4, (outs cls1:$dst), (ins cls2:$src2, cls2:$src1), 
                mnemonic#"\t$dst, $src1, $src2", 
                [(set cls1:$dst, (operator cls2:$src1, cls2:$src2))]> {
  field bits<32> Inst;

  bits<5> RD;
  bits<5> RS1;
  bits<5> RS2;

  let Inst{31-27} = funct5;
  let Inst{26-25} = fmt;
  let Inst{24-20} = RS2;
  let Inst{19-15} = RS1;
  let Inst{14-12} = rm;
  let Inst{11- 7} = RD;
  let Inst{6 - 0} = op;
}
def FSGNJ_S : InstSign<"fsgnj.s", 0b1010011, 0b00101, 0b00, 0b000,
                        fcopysign, FP32, FP32>, Requires<[HasF]>;
def FSGNJN_S : InstSign<"fsgnjn.s", 0b1010011, 0b00110, 0b00, 0b000,
                        fcopysign, FP32, FP32>, Requires<[HasF]> {
                          let Pattern =
                          [(set FP32:$dst, (fcopysign FP32:$src1, (fneg FP32:$src2)))];
                        }
//pattern is
//if signs are equal copysign from abs(src2)
//otherwise copysign from fabs( fneg (src2))
def FSGNJX_S : InstSign<"fsgnjx.s", 0b1010011, 0b00111, 0b00, 0b000,
    fcopysign, FP32, FP32>, Requires<[HasF]> {
      let Pattern =
      [(set FP32:$dst, (select 
      (i32 (seteq (i32 (fgetsign FP32:$src1)), (i32 (fgetsign FP32:$src2)))),
        (fcopysign FP32:$src1, (fabs FP32:$src2)),
        (fcopysign FP32:$src1, (fneg (fabs FP32:$src2)))
      ))];
      }

//llvm cant select fneg itsels so help it out
def : Pat<(fneg FP32:$src), (FSGNJN_S FP32:$src, FP32:$src)>, Requires<[HasF]>;
def : Pat<(fabs FP32:$src), (FSGNJX_S FP32:$src, FP32:$src)>, Requires<[HasF]>;

//Move instruction (bitcasts)
def FMV_X_S : InstConv<"fmv.x.s", "", 0b1010011, 0b11100, 0b00, 0b000, bitconvert, GR32, FP32>, Requires<[HasF]>;
def FMV_S_X : InstConv<"fmv.s.x", "", 0b1010011, 0b11110, 0b00, 0b000, bitconvert, FP32, GR32>, Requires<[HasF]>;
def FMV_X_S64 : InstConv<"fmv.x.s", "", 0b1010011, 0b11100, 0b00, 0b000, bitconvert, GR64, FP32>, Requires<[HasF, IsRV64]>;
def FMV_S_X64 : InstConv<"fmv.s.x", "", 0b1010011, 0b11110, 0b00, 0b000, bitconvert, FP32, GR64>, Requires<[HasF, IsRV64]>;

//Floating point comparisons
def FEQ_S : InstSign<"feq.s", 0b1010011, 0b10101, 0b00, 0b000, setoeq, GR32, FP32>, Requires<[HasF]>;
def FLT_S : InstSign<"flt.s", 0b1010011, 0b10110, 0b00, 0b000, setolt, GR32, FP32>, Requires<[HasF]>;
def FLE_S : InstSign<"fle.s", 0b1010011, 0b10111, 0b00, 0b000, setole, GR32, FP32>, Requires<[HasF]>;
def FUEQ_S : InstSign<"feq.s", 0b1010011, 0b10101, 0b00, 0b000, setueq, GR32, FP32>, Requires<[HasF]>;
def FULT_S : InstSign<"flt.s", 0b1010011, 0b10110, 0b00, 0b000, setult, GR32, FP32>, Requires<[HasF]>;
def FULE_S : InstSign<"fle.s", 0b1010011, 0b10111, 0b00, 0b000, setule, GR32, FP32>, Requires<[HasF]>;
//synthesized set operators
multiclass FPCmpPats<RegisterOperand RC, Instruction FEQOp, Instruction FEQUOp,
                     Instruction FLTOp, Instruction FLTUOp,
                     Instruction FLEOp, Instruction FLEUOp> {
                //RISC-V operands go in reverse order
  //lhs > rhs ==> rhs < lhs
  def : Pat<(setogt RC:$lhs, RC:$rhs), (FLTOp RC:$lhs, RC:$rhs)>;
  def : Pat<(setugt RC:$lhs, RC:$rhs), (FLTUOp RC:$lhs, RC:$rhs)>;
  //lhs >= rhs ==> rhs =< lhs
  def : Pat<(setoge RC:$lhs, RC:$rhs), (FLEOp RC:$lhs, RC:$rhs)>;
  def : Pat<(setuge RC:$lhs, RC:$rhs), (FLEUOp RC:$lhs, RC:$rhs)>;
  //lhs != rhs ==> !(lhs == rhs) using seqz 
  def : Pat<(setone RC:$lhs, RC:$rhs), (SLTIU (FEQOp RC:$rhs, RC:$lhs), 1)>;
  def : Pat<(setune RC:$lhs, RC:$rhs), (SLTIU (FEQUOp RC:$rhs, RC:$lhs), 1)>;
}
defm : FPCmpPats<FP32, FEQ_S, FUEQ_S, FLT_S, FULT_S, FLE_S, FULE_S>;

//fp imm
def :Pat<(fpimm0), (FCVT_S_W_RDY zero)>;

//fp select
let usesCustomInserter = 1 in {
  def FSELECT_CC_F : Pseudo<(outs FP32:$dst),
                              (ins GR32:$cond, FP32:$T, FP32:$F),
                              [(set FP32:$dst,
                                 (select GR32:$cond, FP32:$T, FP32:$F))]>, Requires<[HasF]>;
}
