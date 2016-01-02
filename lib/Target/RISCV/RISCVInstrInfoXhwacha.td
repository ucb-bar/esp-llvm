//==- RISCVInstrInfoXhwacha.td - Vector RISCV Instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//V-Type, simple instr type for vector pseudo instrs
class InstV<dag outs, dag ins, string mnemonic, list<dag> pattern>
  : InstRISCV<4, outs, ins,
                mnemonic, pattern> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;

}

multiclass InstVR2<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VV : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, pred:$p),
    "@$p\t"#name#"\t$dst, $src1", [(set VVR:$dst, (op VVR:$src1))]>;
  def _VS : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, pred:$p),
    "@$p\t"#name#"\t$dst, $src1", [(set VVR:$dst, (op VSR:$src1))]>;
  def _SS : InstRISCV<4, (outs VSR:$dst), (ins VSR:$src1),
    name#"\t$dst, $src1", [(set VSR:$dst, (op VSR:$src1))]>;
  }
}

multiclass InstVR3<string name, SDPatternOperator op, RegisterOperand typ> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VVV : InstRISCV<4, (outs typ:$dst), (ins typ:$src1, typ:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set typ:$dst, (op typ:$src1, typ:$src2))]>;
  def _VVS : InstRISCV<4, (outs typ:$dst), (ins typ:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set typ:$dst, (op typ:$src1, VSR:$src2))]>;
  def _VSV : InstRISCV<4, (outs typ:$dst), (ins VSR:$src1, typ:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set typ:$dst, (op VSR:$src1, typ:$src2))]>;
  def _VSS : InstRISCV<4, (outs typ:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set typ:$dst, (op VSR:$src1, VSR:$src2))]>;
  def _SSS : InstRISCV<4, (outs VSR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"\t$dst, $src1, $src2", [(set VSR:$dst, (op VSR:$src1, VSR:$src2))]>;
  }
}

multiclass InstVR3Cmp<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VV : InstRISCV<4, (outs VPR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VVR:$src2)))))]>;
  def _VS : InstRISCV<4, (outs VPR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VSR:$src2)))))]>;
  def _SV : InstRISCV<4, (outs VPR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VVR:$src2)))))]>;
  def _SS : InstRISCV<4, (outs VPR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VSR:$src2)))))]>;
  }
}

multiclass InstVR3CmpSwitch<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VV : InstRISCV<4, (outs VPR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VVR:$src2)))))]>;
  def _VS : InstRISCV<4, (outs VPR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VVR:$src1), (i64 VSR:$src2)))))]>;
  def _SV : InstRISCV<4, (outs VPR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VVR:$src2)))))]>;
  def _SS : InstRISCV<4, (outs VPR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src2, $src1", [(set VPR:$dst, (trunc (i32 (op (i64 VSR:$src1), (i64 VSR:$src2)))))]>;
  }
}

multiclass InstVR3Int<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VVV : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VVR:$src1), (i64 VVR:$src2)))]>;
  def _VVS : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VVR:$src1), (i64 VSR:$src2)))]>;
  def _VSV : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VSR:$src1), (i64 VVR:$src2)))]>;
  def _VSS : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op (i64 VSR:$src1), (i64 VSR:$src2)))]>;
  def _SSS : InstRISCV<4, (outs VSR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"\t$dst, $src1, $src2", [(set VSR:$dst, (op (i64 VSR:$src1), (i64 VSR:$src2)))]>;
  }
}

multiclass InstVR4<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VVVV : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VVR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VVR:$src2, VVR:$src3))]>;
  def _VVSV : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VSR:$src2, VVR:$src3))]>;
  def _VSVV : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VVR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VVR:$src2, VVR:$src3))]>;
  def _VSSV : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VSR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VSR:$src2, VVR:$src3))]>;
  def _VVVS: InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VVR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VVR:$src2, VSR:$src3))]>;
  def _VVSS: InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VSR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VVR:$src1, VSR:$src2, VSR:$src3))]>;
  def _VSVS: InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VVR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VVR:$src2, VSR:$src3))]>;
  def _VSSS: InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VSR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"\t$dst, $src1, $src2, $src3", [(set VVR:$dst, (op VSR:$src1, VSR:$src2, VSR:$src3))]>;
  def _SSSS : InstRISCV<4, (outs VSR:$dst), (ins VSR:$src1, VSR:$src2, VSR:$src3),
    name#"\t$dst, $src1, $src2, $src3", [(set VSR:$dst, (op VSR:$src1, VSR:$src2, VSR:$src3))]>;
  }
}

 def HasXhwacha :Predicate<"Subtarget.hasXhwacha()">,
                 AssemblerPredicate<"FeatureXhwacha">;

//all bits in this file should be considered fake

// Control Thread Instructions

//configure vector unit
let isCodeGenOnly = 1, isPseudo = 1 in {
  def VSETCFG : InstV< (outs), (ins imm64:$xregs, imm64:$pregs),
                "vsetcfg\t$xregs,$pregs", [(r_vsetcfg imm64:$xregs, imm64:$pregs)]>, Requires<[HasXhwacha]>;//vsetcfg 32,0    #num_int_regs,num_pred_regs
  def VSETVL  : InstV< (outs GR64:$res), (ins GR64:$goal),
                "vsetvl\t$res,$goal", [(set GR64:$res, (r_vsetvl GR64:$goal))]>, Requires<[HasXhwacha]>;//vsetvl t0,t0    #reg,reg for how long we got and how long we wanted
}

let isCall = 1, isCodeGenOnly = 1 in {
    def VFetch : InstV< (outs), (ins memreg64:$target), "vf\t$target", [(r_callv regaddr:$target)]>, Requires<[HasXhwacha]>;
  }

//Moves
def VMSS_X : InstV<(outs VSR:$dest), (ins GR64:$src), "vmss\t$dest,$src",
                     //[(set VSR:$dest, (COPY_TO_REG_CLASS GR64:$src, VSR))]
                     []>, Requires<[HasXhwacha]>;

def VMSA : InstV<(outs VAR:$dest), (ins GR64:$src), "vmsa\t$dest,$src",
                     //[(set VAR:$dest, (COPY_TO_REG_CLASS GR64:$src, VAR))]
                     []>, Requires<[HasXhwacha]>;

//Vector Memory Ops
let mayLoad = 1 in {
  def VLXW : InstV<(outs VVW:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw\t$dest, $src1, $src2", [(set VVW:$dest, (i64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXH : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxh\t$dest, $src1, $src2", [(set VVH:$dest, (i64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXHU : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxhu\t$dest, $src1, $src2", [(set VVH:$dest, (i64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXD_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxd\t$dest, $src1, $src2", [(set VVR:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXW_F : InstV<(outs VVW:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw\t$dest, $src1, $src2", [(set VVW:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXH_F : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxh\t$dest, $src1, $src2", [(set VVH:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXHU_F : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxhu\t$dest, $src1, $src2", [(set VVH:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VLSW : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsw\t$dest, $src1", [(set VSR:$dest, (i64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSH : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsh\t$dest, $src1", [(set VSR:$dest, (i64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSHU : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlshu\t$dest, $src1", [(set VSR:$dest, (i64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSD_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsd\t$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSW_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsw\t$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSH_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsh\t$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSHU_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlshu\t$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  let isVariant = 1 in {
    def VLD : InstV<(outs VVR:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvld\t$dest, $src1", [(set VVR:$dest, (i64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLW : InstV<(outs VVW:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlw\t$dest, $src1", [(set VVW:$dest, (i64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLH : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlh\t$dest, $src1", [(set VVH:$dest, (i64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLHU : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlhu\t$dest, $src1", [(set VVH:$dest, (i64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLD_F : InstV<(outs VVR:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvld\t$dest, $src1", [(set VVR:$dest, (f64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLW_F : InstV<(outs VVW:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlw\t$dest, $src1", [(set VVW:$dest, (f64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLH_F : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlh\t$dest, $src1", [(set VVH:$dest, (f64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLHU_F : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlhu\t$dest, $src1", [(set VVH:$dest, (f64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  }
}
let mayStore = 1 in {
  def VSXW : InstV<(outs), (ins VVW:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw\t $src1, $src2, $src3", [(store (i64 VVW:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXD_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxd\t $src1, $src2, $src3", [(store (f64 VVR:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXW_F : InstV<(outs), (ins VVW:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw\t $src1, $src2, $src3", [(store (f64 VVW:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXH_F : InstV<(outs), (ins VVH:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxh\t $src1, $src2, $src3", [(store (f64 VVH:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VSSW : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssw\t $src1, $src2", [(store (i64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSD_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssd\t $src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSW_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssw\t $src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSH_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssh\t $src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  let isVariant = 1 in {
    def VSW : InstV<(outs), (ins VVW:$src1, VAR:$src2, pred:$p),
               "@$p\tvsw\t $src1, $src2", [(store (i64 VVW:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSD_F : InstV<(outs), (ins VVR:$src1, VAR:$src2, pred:$p),
               "@$p\tvsd\t $src1, $src2", [(store (f64 VVR:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSW_F : InstV<(outs), (ins VVW:$src1, VAR:$src2, pred:$p),
               "@$p\tvsw\t $src1, $src2", [(store (f64 VVW:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSH_F : InstV<(outs), (ins VVH:$src1, VAR:$src2, pred:$p),
               "@$p\tvsh\t $src1, $src2", [(store (f64 VVH:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
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
    def VEIDX  : InstV<(outs VVR:$dest), (ins), "veidx\t$dest",[(set VVR:$dest, (int_hwacha_veidx))]>, Requires<[HasXhwacha]>;
  }
}

//Psuedo Instructions for scalar operations inside of vector fetch blocks
//To be expanded into vfetch blocks after register allocation and scheduling
let isPseudo = 1 in {
  //Integer arithmetic register-register
  defm VADD : InstVR3<"vadd", add, VVR>, Requires<[HasXhwacha]>;
  defm VSUB : InstVR3<"vsub", sub, VVR>, Requires<[HasXhwacha]>;
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
  def VSLTI: InstI<"vslti" , ?, ?, setlt, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VLUI : InstV<(outs VSR:$dest), (ins imm64sx32:$imm), "vlui\t$dest, $imm",
    [(set VSR:$dest, (shl imm64sx32:$imm, (i64 32)))]>, Requires<[HasXhwacha]>;

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
  defm VFADD_RAS_RDY : InstVR3<"vfadd.s", fadd, VVR>, Requires<[HasXhwacha]>;
  defm VFSUB_RAS_RDY : InstVR3<"vfsub.s", fsub, VVR>, Requires<[HasXhwacha]>;
  def VSXW_RAS_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw\t $src1, $src2, $src3", [(store (f64 VVR:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXW_RAS_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw\t$dest, $src1, $src2", [(set VVR:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  //Predicate Instructions
  def VPSET  : InstV<(outs VPR:$dest), (ins), "vpset\t$dest",[(set VPR:$dest, (i1 1))]>, Requires<[HasXhwacha]>;
  def VPCLEAR  : InstV<(outs VPR:$dest), (ins), "vpclear\t$dest",[(set VPR:$dest, (i1 0))]>, Requires<[HasXhwacha]>;
  def VPANDAND  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vpandand\t$dest, $in1, $in2, $in3",[(set VPR:$dest, (and VPR:$in1, (and VPR:$in2, VPR:$in3)))]>, Requires<[HasXhwacha]>;

  //compare instructions
  defm VCMPEQ  : InstVR3Cmp<"vcmpeq",  seteq>;
  defm VCMPLT  : InstVR3Cmp<"vcmplt",  setlt>;
  defm VCMPLTU : InstVR3Cmp<"vcmpltu", setult>;
  defm VCMPGT  : InstVR3CmpSwitch<"vcmplt",  setgt>;
  defm VCMPGTU : InstVR3CmpSwitch<"vcmpltu", setugt>;
}


