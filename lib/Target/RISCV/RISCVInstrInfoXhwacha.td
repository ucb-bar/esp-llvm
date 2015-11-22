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
  def _VV : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1),
    name#"\t$dst, $src1", [(set VVR:$dst, (op VVR:$src1))]>;
  def _VS : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1),
    name#"\t$dst, $src1", [(set VVR:$dst, (op VSR:$src1))]>;
  def _SS : InstRISCV<4, (outs VSR:$dst), (ins VSR:$src1),
    name#"\t$dst, $src1", [(set VSR:$dst, (op VSR:$src1))]>;
  }
}

multiclass InstVR3<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1 in {
  def _VVV : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VVR:$src2),
    name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op VVR:$src1, VVR:$src2))]>;
  def _VVS : InstRISCV<4, (outs VVR:$dst), (ins VVR:$src1, VSR:$src2),
    name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op VVR:$src1, VSR:$src2))]>;
  def _VSV : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VVR:$src2),
    name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op VSR:$src1, VVR:$src2))]>;
  def _VSS : InstRISCV<4, (outs VVR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"\t$dst, $src1, $src2", [(set VVR:$dst, (op VSR:$src1, VSR:$src2))]>;
  def _SSS : InstRISCV<4, (outs VSR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"\t$dst, $src1, $src2", [(set VSR:$dst, (op VSR:$src1, VSR:$src2))]>;
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
  def VLXW : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2), 
             "vlxw\t$dest, $src1, $src2", [(set VVR:$dest, (i64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXW_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2), 
             "vlxw\t$dest, $src1, $src2", [(set VVR:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXH_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2), 
             "vlxh\t$dest, $src1, $src2", [(set VVR:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VLSW : InstV<(outs VSR:$dest), (ins VSR:$src1), 
             "vlsw\t$dest, $src1", [(set VSR:$dest, (i64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSW_F : InstV<(outs VSR:$dest), (ins VSR:$src1), 
             "vlsw\t$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSH_F : InstV<(outs VSR:$dest), (ins VSR:$src1), 
             "vlsh\t$dest, $src1", [(set VSR:$dest, (f64 (load VSR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  let isVariant = 1 in {
    def VLW : InstV<(outs VVR:$dest), (ins VAR:$src1), 
               "vlw\t$dest, $src1", [(set VVR:$dest, (i64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLW_F : InstV<(outs VVR:$dest), (ins VAR:$src1), 
               "vlw\t$dest, $src1", [(set VVR:$dest, (f64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLH_F : InstV<(outs VVR:$dest), (ins VAR:$src1), 
               "vlh\t$dest, $src1", [(set VVR:$dest, (f64 (load VAR:$src1)))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  }
}
let mayStore = 1 in {
  def VSXW : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3), 
             "vsxw\t $src1, $src2, $src3", [(store (i64 VVR:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXW_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3), 
             "vsxw\t $src1, $src2, $src3", [(store (f64 VVR:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXH_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3), 
             "vsxh\t $src1, $src2, $src3", [(store (f64 VVR:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VSSW : InstV<(outs), (ins VSR:$src1, VSR:$src2), 
             "vssw\t $src1, $src2", [(store (i64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSW_F : InstV<(outs), (ins VSR:$src1, VSR:$src2), 
             "vssw\t $src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSH_F : InstV<(outs), (ins VSR:$src1, VSR:$src2), 
             "vssh\t $src1, $src2", [(store (f64 VSR:$src1), VSR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  let isVariant = 1 in {
    def VSW : InstV<(outs), (ins VVR:$src1, VAR:$src2), 
               "vsw\t $src1, $src2", [(store (i64 VVR:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSW_F : InstV<(outs), (ins VVR:$src1, VAR:$src2), 
               "vsw\t $src1, $src2", [(store (f64 VVR:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSH_F : InstV<(outs), (ins VVR:$src1, VAR:$src2), 
               "vsh\t $src1, $src2", [(store (f64 VVR:$src1), VAR:$src2)]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
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
  defm VADD : InstVR3<"vadd", add>, Requires<[HasXhwacha]>;
  defm VSLL : InstVR3<"vsll", shl>, Requires<[HasXhwacha]>;
  //def VSUB64 : InstR<"vsub" , ?, ?, sub   , VR64, VR64>, Requires<[HasXhwacha]>;
  def VSLLI: InstI<"vslli" , ?, ?, shl, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  def VADDI: InstI<"vaddi" , ?, ?, add, VSR, VSR, imm64sx32>, Requires<[HasXhwacha]>;
  //def VSLT64 : InstR<"slt" , ?, ?, setlt , VR32, VR64>, Requires<[HasXhwacha]>;
  //def VSLTU64: InstR<"sltu", ?, ?, setult, VR32, VR64>, Requires<[HasXhwacha]>;
  //def VXOR64 : InstR<"vxor" , ?, ?, xor   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VSRL64 : InstR<"vsrl" , ?, ?, srl   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VSRA64 : InstR<"vsra" , ?, ?, sra   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VOR64  : InstR<"vor"  , ?, ?, or    , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VAND64 : InstR<"vand" , ?, ?, and   , VR64, VR64>, Requires<[HasXhwacha]>;
  //def VMUL64 : InstR<"vmul", ?, ?, mul   , VR64, VR64>, Requires<[HasXhwacha]>;
  defm VFMUL_S_RDY : InstVR3<"vfmul.s", fmul>, Requires<[HasXhwacha]>;
  defm VFADD_S_RDY : InstVR3<"vfadd.s", fadd>, Requires<[HasXhwacha]>;
  defm VFMUL_D_RDY : InstVR3<"vfmul.d", fmul>, Requires<[HasXhwacha]>;
  defm VFADD_D_RDY : InstVR3<"vfadd.d", fadd>, Requires<[HasXhwacha]>;

  defm VFCVT_S_H_RDY : InstVR2<"vfcvt.s.h", fsqrt>, Requires<[HasXhwacha]>;
  defm VFCVT_H_S_RDY : InstVR2<"vfcvt.h.s", fsqrt>, Requires<[HasXhwacha]>;
  defm VFCVT_D_S_RDY : InstVR2<"vfcvt.d.s", fsqrt>, Requires<[HasXhwacha]>;
  defm VFCVT_S_D_RDY : InstVR2<"vfcvt.s.d", fsqrt>, Requires<[HasXhwacha]>;

  //Predicate Instructions
  def VPSET  : InstV<(outs VPR:$dest), (ins), "vpset\t$dest",[(set VPR:$dest, (i1 1))]>, Requires<[HasXhwacha]>;
}


