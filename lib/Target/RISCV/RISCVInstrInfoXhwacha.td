//==- RISCVInstrInfoXhwacha.td - Vector RISCV Instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//V-Type, simple instr type for vector pseudo instrs
class InstV<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern>
  : RVInst<outs, ins,
                opcodestr, argstr, pattern, InstFormatOther> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}

// Custom Operands
def imm1 : ImmLeaf<i1, [{}]>, Operand<i1>;

def pred : PredicateOperand<i1, (ops imm1, VPR), (ops (i1 0), vp0)> {
  let PrintMethod = "printPredOperand";
}

// TODO, REWRITE THESE TO USE THE ImmAsmOperand template defined in RISCVInstrInfo

//sign-extended 12 bit immediate
def imm64sx12 : Immediate<i64, [{
  return isInt<12>(N->getSExtValue());
}], NOOP_SDNodeXForm, "S12Imm">;
def imm64sxu12 : Immediate<i64, [{
  return isUInt<12>(N->getSExtValue());
}], NOOP_SDNodeXForm, "U12Imm">;
//zero-extended 12 bit immediate
def imm64zx12 : Immediate<i64, [{
  return isUInt<12>(N->getZExtValue());
}], NOOP_SDNodeXForm, "U12Imm">;
//sign-extended 20 bit immediate
def imm64sx20 : Immediate<i64, [{
  return isInt<20>(N->getSExtValue());
}], NOOP_SDNodeXForm, "S20Imm">;
def imm64sxu20 : Immediate<i64, [{
  return isUInt<20>(N->getSExtValue());
}], NOOP_SDNodeXForm, "U20Imm">;
//zero-extended 20 bit immediate
def imm64zx20 : Immediate<i64, [{
  return isUInt<20>(N->getZExtValue());
}], NOOP_SDNodeXForm, "U20Imm">;
//sign-extended 32bit immediate for LUI/ADDI max load size
def imm64sxu32 : Immediate<i64, [{
  return isUInt<32>(N->getSExtValue());
}], NOOP_SDNodeXForm, "U32Imm">;
//sign-extended 32bit immediate for vector instructions
def imm64sx32 : Immediate<i64, [{
  return isInt<32>(N->getSExtValue());
}], NOOP_SDNodeXForm, "S32Imm">;

def simm64 : Immediate<i64, [{}], SIMM64, "S64Imm">;
def uimm64 : Immediate<i64, [{}], UIMM64, "U64Imm">;

def imm64 : ImmLeaf<i64, [{}]>, Operand<i64>;

multiclass InstVR2<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VV : RVInst<(outs VVR:$dst), (ins VVR:$src1, pred:$p),
    "@$p\t"#name#"", "$dst, $src1", [(set VVR:$dst, (op VVR:$src1))], InstFormatOther>;
  def _VS : RVInst<(outs VVR:$dst), (ins VSR:$src1, pred:$p),
    "@$p\t"#name#"", "$dst, $src1", [(set VVR:$dst, (op VSR:$src1))], InstFormatOther>;
  def _SS : RVInst<(outs VSR:$dst), (ins VSR:$src1),
    name#"", "$dst, $src1", [(set VSR:$dst, (op VSR:$src1))], InstFormatOther>;
  }
}

multiclass InstVR3<string name, SDPatternOperator op, RegisterOperand typ> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VVV : RVInst<(outs typ:$dst), (ins typ:$src1, typ:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set typ:$dst, (op typ:$src1, typ:$src2))], InstFormatOther>;
  def _VVS : RVInst<(outs typ:$dst), (ins typ:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set typ:$dst, (op typ:$src1, VSR:$src2))], InstFormatOther>;
  def _VSV : RVInst<(outs typ:$dst), (ins VSR:$src1, typ:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set typ:$dst, (op VSR:$src1, typ:$src2))], InstFormatOther>;
  def _VSS : RVInst<(outs typ:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set typ:$dst, (op VSR:$src1, VSR:$src2))], InstFormatOther>;
  def _SSS : RVInst<(outs VSR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"", "$dst, $src1, $src2", [(set VSR:$dst, (op VSR:$src1, VSR:$src2))], InstFormatOther>;
  }
}

multiclass InstVR3Cmp<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VV : RVInst<(outs VPR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VVR:$src2)))))], InstFormatOther>;
  def _VS : RVInst<(outs VPR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VSR:$src2)))))], InstFormatOther>;
  def _SV : RVInst<(outs VPR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VVR:$src2)))))], InstFormatOther>;
  def _SS : RVInst<(outs VPR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VSR:$src2)))))], InstFormatOther>;
  }
}

multiclass InstVR3CmpSwitch<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VV : RVInst<(outs VPR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VVR:$src2)))))], InstFormatOther>;
  def _VS : RVInst<(outs VPR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VSR:$src2)))))], InstFormatOther>;
  def _SV : RVInst<(outs VPR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VVR:$src2)))))], InstFormatOther>;
  def _SS : RVInst<(outs VPR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VSR:$src2)))))], InstFormatOther>;
  }
}

multiclass InstVR3Int<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VVV : RVInst<(outs VVR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VVR:$src1), (i64 VVR:$src2)))], InstFormatOther>;
  def _VVS : RVInst<(outs VVR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VVR:$src1), (i64 VSR:$src2)))], InstFormatOther>;
  def _VSV : RVInst<(outs VVR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VSR:$src1), (i64 VVR:$src2)))], InstFormatOther>;
  def _VSS : RVInst<(outs VVR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VSR:$src1), (i64 VSR:$src2)))], InstFormatOther>;
  def _SSS : RVInst<(outs VSR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"", "$dst, $src1, $src2", [(set VSR:$dst, (op (i64 VSR:$src1), (i64 VSR:$src2)))], InstFormatOther>;
  }
}

multiclass InstVR4<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VVVV : RVInst<(outs VVR:$dst), (ins VVR:$src1, VVR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VVR:$src2, VVR:$src3))], InstFormatOther>;
  def _VVSV : RVInst<(outs VVR:$dst), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VSR:$src2, VVR:$src3))], InstFormatOther>;
  def _VSVV : RVInst<(outs VVR:$dst), (ins VSR:$src1, VVR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VVR:$src2, VVR:$src3))], InstFormatOther>;
  def _VSSV : RVInst<(outs VVR:$dst), (ins VSR:$src1, VSR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VSR:$src2, VVR:$src3))], InstFormatOther>;
  def _VVVS: RVInst<(outs VVR:$dst), (ins VVR:$src1, VVR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VVR:$src2, VSR:$src3))], InstFormatOther>;
  def _VVSS: RVInst<(outs VVR:$dst), (ins VVR:$src1, VSR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VSR:$src2, VSR:$src3))], InstFormatOther>;
  def _VSVS: RVInst<(outs VVR:$dst), (ins VSR:$src1, VVR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VVR:$src2, VSR:$src3))], InstFormatOther>;
  def _VSSS: RVInst<(outs VVR:$dst), (ins VSR:$src1, VSR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VSR:$src2, VSR:$src3))], InstFormatOther>;
  def _SSSS : RVInst<(outs VSR:$dst), (ins VSR:$src1, VSR:$src2, VSR:$src3),
    name#"", "$dst, $src1, $src2, $src3", [(set VSR:$dst, (op VSR:$src1, VSR:$src2, VSR:$src3))], InstFormatOther>;
  }
}

 def HasXhwacha :Predicate<"Subtarget.hasXhwacha()">,
                 AssemblerPredicate<"FeatureXhwacha">;

//all bits in this file should be considered fake

// Control Thread Instructions

//configure vector unit
let isCodeGenOnly = 1, isPseudo = 1 in {
  def VSETCFG : InstV< (outs GPR:$cfg), (ins imm64:$dregs, imm64:$wregs, imm64:$hregs, imm64:$pregs),
                "vsetcfg", "$cfg,$dregs,$wregs,$hregs,$pregs", [(set GPR:$cfg, (r_vsetcfg imm64:$dregs, imm64:$wregs, imm64:$hregs, imm64:$pregs))]>, Requires<[HasXhwacha]>;//vsetcfg 32,0    #num_int_regs,num_pred_regs
  def VSETVL  : InstV< (outs GPR:$res), (ins GPR:$goal),
                "vsetvl", "$res,$goal", [(set GPR:$res, (r_vsetvl GPR:$goal))]>, Requires<[HasXhwacha]>;//vsetvl t0,t0    #reg,reg for how long we got and how long we wanted
}

let isCall = 1, isCodeGenOnly = 1 in {
    def VFetch : InstV< (outs), (ins memreg64:$target), "vf", "$target", [(r_callv regaddr:$target)]>, Requires<[HasXhwacha]>;
  }

//Moves
def VMSS_X : InstV<(outs VSR:$dest), (ins GPR:$src), "vmcs", "$dest,$src",
                     //[(set VSR:$dest, (COPY_TO_REG_CLASS GPR:$src, VSR))]
                     []>, Requires<[HasXhwacha]>;

def VMSA : InstV<(outs VAR:$dest), (ins GPR:$src), "vmca", "$dest,$src",
                     //[(set VAR:$dest, (COPY_TO_REG_CLASS GPR:$src, VAR))]
                     []>, Requires<[HasXhwacha]>;

//Vector Memory Ops
let mayLoad = 1 in {
  def VLXW : InstV<(outs VVW:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw", "$dest, $src1, $src2", [(set VVW:$dest, (i64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXH : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxh", "$dest, $src1, $src2", [(set VVH:$dest, (i64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXHU : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxhu", "$dest, $src1, $src2", [(set VVH:$dest, (i64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXD_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxd", "$dest, $src1, $src2", [(set VVR:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXW_F : InstV<(outs VVW:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw", "$dest, $src1, $src2", [(set VVW:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXH_F : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxh", "$dest, $src1, $src2", [(set VVH:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXHU_F : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxhu", "$dest, $src1, $src2", [(set VVH:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VLSW : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsw", "$dest, $src1", [(set VSR:$dest, (i64 (load VSR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSH : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsh", "$dest, $src1", [(set VSR:$dest, (i64 (load VSR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSHU : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlshu", "$dest, $src1", [(set VSR:$dest, (i64 (load VSR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSD_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsd", "$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSW_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsw", "$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSH_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsh", "$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSHU_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlshu", "$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  let isVariant = 1 in {
    def VLD : InstV<(outs VVR:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvld", "$dest, $src1", [(set VVR:$dest, (i64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLW : InstV<(outs VVW:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlw", "$dest, $src1", [(set VVW:$dest, (i64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLH : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlh", "$dest, $src1", [(set VVH:$dest, (i64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLHU : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlhu", "$dest, $src1", [(set VVH:$dest, (i64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLD_F : InstV<(outs VVR:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvld", "$dest, $src1", [(set VVR:$dest, (f64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLW_F : InstV<(outs VVW:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlw", "$dest, $src1", [(set VVW:$dest, (f64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLH_F : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlh", "$dest, $src1", [(set VVH:$dest, (f64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLHU_F : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlhu", "$dest, $src1", [(set VVH:$dest, (f64 (load VAR:$src1)))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  }
}
let mayStore = 1 in {
  def VSXW : InstV<(outs), (ins VVW:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw", "$src1, $src2, $src3", [(store (i64 VVW:$src1), (add VSR:$src2, VVR:$src3))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXD_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxd", "$src1, $src2, $src3", [(store (f64 VVR:$src1), (add VSR:$src2, VVR:$src3))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXW_F : InstV<(outs), (ins VVW:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw", "$src1, $src2, $src3", [(store (f64 VVW:$src1), (add VSR:$src2, VVR:$src3))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXH_F : InstV<(outs), (ins VVH:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxh", "$src1, $src2, $src3", [(store (f64 VVH:$src1), (add VSR:$src2, VVR:$src3))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VSSW : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssw", "$src1, $src2", [(store (i64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSD_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssd", "$src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSW_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssw", "$src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSH_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssh", "$src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  let isVariant = 1 in {
    def VSW : InstV<(outs), (ins VVW:$src1, VAR:$src2, pred:$p),
               "@$p\tvsw", "$src1, $src2", [(store (i64 VVW:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSD_F : InstV<(outs), (ins VVR:$src1, VAR:$src2, pred:$p),
               "@$p\tvsd", "$src1, $src2", [(store (f64 VVR:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSW_F : InstV<(outs), (ins VVW:$src1, VAR:$src2, pred:$p),
               "@$p\tvsw", "$src1, $src2", [(store (f64 VVW:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSH_F : InstV<(outs), (ins VVH:$src1, VAR:$src2, pred:$p),
               "@$p\tvsh", "$src1, $src2", [(store (f64 VVH:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  }
  //def VSW : InstStore <"vsw"  , 0b0100011, 0b011, store, VR32, mem64>, Requires<[IsRV64]>; //vsw vx2, x2
  //def VSD : InstStore <"vsd"  , 0b0100011, 0b011, store, VR64, mem64>, Requires<[IsRV64, HasXhwacha]>;
}

//Vector fetch
let isCodeGenOnly = 1 in {
  let isReturn = 1, isTerminator = 1, isBarrier = 1 in {
    def VSTOP   : InstV<(outs), (ins), "vstop",[]>,Requires<[HasXhwacha]>;
  }
  let isVariant = 1 in {
    def VEIDX  : InstV<(outs VVR:$dest), (ins), "veidx", "$dest",[(set VVR:$dest, (int_hwacha_veidx))]>, Requires<[HasXhwacha]>;
  }
}

//Psuedo Instructions for scalar operations inside of vector fetch blocks
//To be expanded into vfetch blocks after register allocation and scheduling
let isPseudo = 1 in {
  //Integer arithmetic register-register
  defm VADD : InstVR3<"vadd", add, VVR>, Requires<[HasXhwacha]>;
  defm VSUB : InstVR3<"vsub", sub, VVR>, Requires<[HasXhwacha]>;
  defm VOR : InstVR3<"vor", or, VVR>, Requires<[HasXhwacha]>;
  defm VSLL : InstVR3<"vsll", shl, VVR>, Requires<[HasXhwacha]>;
  defm VSRL : InstVR3<"vsrl", srl, VVR>, Requires<[HasXhwacha]>;
  defm VSRA : InstVR3<"vsra", sra, VVR>, Requires<[HasXhwacha]>;
  defm VMUL : InstVR3<"vmul", mul, VVR>, Requires<[HasXhwacha]>;
  defm VSLT : InstVR3Int<"vslt", setlt>, Requires<[HasXhwacha]>;

  defm VADDW : InstVR3<"vaddw", add, VVR>, Requires<[HasXhwacha]>;
  defm VSUBW : InstVR3<"vsubw", sub, VVR>, Requires<[HasXhwacha]>;
  defm VSLLW : InstVR3<"vsllw", shl, VVR>, Requires<[HasXhwacha]>;
  defm VSRLW : InstVR3<"vsrlw", srl, VVR>, Requires<[HasXhwacha]>;
  defm VSRAW : InstVR3<"vsraw", sra, VVR>, Requires<[HasXhwacha]>;
  defm VMULW : InstVR3<"vmulw", mul, VVR>, Requires<[HasXhwacha]>;

  def VSLLI: InstI<"vslli" , ?, ?, shl, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VSRLI: InstI<"vsrli" , ?, ?, srl, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VSRAI: InstI<"vsrai" , ?, ?, sra, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VADDI: InstI<"vaddi" , ?, ?, add, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VORI: InstI<"vori" , ?, ?, or, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VSLTI: InstI<"vslti" , ?, ?, setlt, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VLUI : InstV<(outs VSR:$dest), (ins imm64sx32:$imm), "vlui", "$dest, $imm",
    [(set VSR:$dest, (shl imm64sx32:$imm, (i64 32)))], InstFormatOther>, Requires<[HasXhwacha]>;

  def VSLLIW: InstI<"vslliw" , ?, ?, shl, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VSRLIW: InstI<"vsrliw" , ?, ?, srl, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VSRAIW: InstI<"vsraiw" , ?, ?, sra, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VADDIW: InstI<"vaddiw" , ?, ?, add, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  //def VSLT64 : InstR<"slt" , ?, ?, setlt , VR32, VR64>, Requires<[HasXhwacha]>;
  //def VSLTU64: InstR<"sltu", ?, ?, setult, VR32, VR64>, Requires<[HasXhwacha]>;
  //def VXOR64 : InstR<"vxor" , ?, ?, xor   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VSRL64 : InstR<"vsrl" , ?, ?, srl   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VSRA64 : InstR<"vsra" , ?, ?, sra   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VOR64  : InstR<"vor"  , ?, ?, or    , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VAND64 : InstR<"vand" , ?, ?, and   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VMUL64 : InstR<"vmul", ?, ?, mul   , VR64, VR64>, Requires<[HasXhwacha]>;
  defm VFMUL_S_RDY : InstVR3<"vfmul.s", fmul, VVW>, Requires<[HasXhwacha]>;
  defm VFDIV_S_RDY : InstVR3<"vfdiv.s", fdiv, VVW>, Requires<[HasXhwacha]>;
  defm VFADD_S_RDY : InstVR3<"vfadd.s", fadd, VVW>, Requires<[HasXhwacha]>;
  defm VFSUB_S_RDY : InstVR3<"vfsub.s", fsub, VVW>, Requires<[HasXhwacha]>;
  defm VFMUL_D_RDY : InstVR3<"vfmul.d", fmul, VVR>, Requires<[HasXhwacha]>;
  defm VFADD_D_RDY : InstVR3<"vfadd.d", fadd, VVR>, Requires<[HasXhwacha]>;
  defm VFSUB_D_RDY : InstVR3<"vfsub.d", fsub, VVR>, Requires<[HasXhwacha]>;

  defm VFMADD_S_RDY : InstVR4<"vfmadd.s", fma>, Requires<[HasXhwacha]>;
  defm VFMADD_D_RDY : InstVR4<"vfmadd.d", fma>, Requires<[HasXhwacha]>;
  defm VFMADD_H_RDY : InstVR4<"vfmadd.h", fma>, Requires<[HasXhwacha]>;

  defm VFCVT_S_H_RDY : InstVR2<"vfcvt.s.h", fsqrt>, Requires<[HasXhwacha]>;
  defm VFCVT_H_S_RDY : InstVR2<"vfcvt.h.s", fsqrt>, Requires<[HasXhwacha]>;
  defm VFCVT_D_S_RDY : InstVR2<"vfcvt.d.s", fsqrt>, Requires<[HasXhwacha]>;
  defm VFCVT_S_D_RDY : InstVR2<"vfcvt.s.d", fsqrt>, Requires<[HasXhwacha]>;

  defm VFCVT_S_W_RDY : InstVR2<"vfcvt.s.w", fsqrt>, Requires<[HasXhwacha]>;

  //FIXME: These instructions are for S and H operations that after regalloc
  // are post processed to be D regs. S and H in the names are replaced with RAS and RAH (RegAlloc)
  defm VFMUL_RAS_RDY : InstVR3<"vfmul.s", fmul, VVR>, Requires<[HasXhwacha]>;
  defm VFDIV_RAS_RDY : InstVR3<"vfdiv.s", fdiv, VVR>, Requires<[HasXhwacha]>;
  defm VFADD_RAS_RDY : InstVR3<"vfadd.s", fadd, VVR>, Requires<[HasXhwacha]>;
  defm VFSUB_RAS_RDY : InstVR3<"vfsub.s", fsub, VVR>, Requires<[HasXhwacha]>;
  def VSXW_RAS_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw", "$src1, $src2, $src3", [(store (f64 VVR:$src1), (add VSR:$src2, VVR:$src3))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXW_RAS_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw", "$dest, $src1, $src2", [(set VVR:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))], InstFormatOther>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  //Predicate Instructions
  def VPSET  : InstV<(outs VPR:$dest), (ins), "vpset", "$dest",[(set VPR:$dest, (i1 1))]>, Requires<[HasXhwacha]>;
  def VPCLEAR  : InstV<(outs VPR:$dest), (ins), "vpclear", "$dest",[(set VPR:$dest, (i1 0))]>, Requires<[HasXhwacha]>;
  def VPANDAND  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vpandand", "$dest, $in1, $in2, $in3",[(set VPR:$dest, (and VPR:$in1, (and VPR:$in2, VPR:$in3)))], InstFormatOther>, Requires<[HasXhwacha]>;
  def VPOROR  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vporor", "$dest, $in1, $in2, $in3",[(set VPR:$dest, (or VPR:$in1, (or VPR:$in2, VPR:$in3)))], InstFormatOther>, Requires<[HasXhwacha]>;
  def VPANDXOR  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vpandxor", "$dest, $in1, $in2, $in3",[(set VPR:$dest, (and VPR:$in1, (xor VPR:$in2, VPR:$in3)))], InstFormatOther>, Requires<[HasXhwacha]>;
  def VPXORAND  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vpxorand", "$dest, $in1, $in2, $in3",[(set VPR:$dest, (xor VPR:$in1, (and VPR:$in2, VPR:$in3)))], InstFormatOther>, Requires<[HasXhwacha]>;

  //compare instructions
  defm VCMPEQ  : InstVR3Cmp<"vcmpeq",  seteq>;
  defm VCMPLT  : InstVR3Cmp<"vcmplt",  setlt>;
  defm VCMPLTU : InstVR3Cmp<"vcmpltu", setult>;
  defm VCMPGT  : InstVR3CmpSwitch<"vcmplt",  setgt>;
  defm VCMPGTU : InstVR3CmpSwitch<"vcmpltu", setugt>;
}
// Control-flow Instructions
let isBranch = 1, isTerminator = 1, isBarrier = 1 in{
  def VCJAL: InstV<(outs VSR:$ret), (ins pcrel64call:$target, pred:$p),
    "@$p\tvcjal", "1, $ret, $target",
        [(set VSR:$ret, (r_jal pcrel64call:$target))]>, Requires<[HasXhwacha]>;
        }

// load immediate patterns
def : Pat<(r_vli imm64sx32:$imm), (VADDI (i64 vs0), imm64sx32:$imm)>;
//TODO: 64bit immediate pattern