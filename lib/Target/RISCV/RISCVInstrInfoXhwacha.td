//==- RISCVInstrInfoXhwacha.td - Vector RISCV Instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//


def imm64sx32 : Operand<i64>, ImmLeaf<i64, [{return isInt<32>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<32>;
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeSImmOperand<32>";
}

def imm64 : Operand<i64>;

// Transformation Function - get the lower 32 bits.
def LO32 : SDNodeXForm<imm, [{
    return getImm(N, N->getZExtValue() & 0xFFFFFFFF);
}]>;

// Transformation Function - get the higher 32 bits for large immediate loading
def HI32 : SDNodeXForm<imm, [{
    uint64_t value = N->getZExtValue() & 0x0000080000000 ? 
                     (N->getZExtValue() >> 32)+1:
                     (N->getZExtValue() >> 32);
    return getImm(N, value);
}]>;

//V-Type, simple instr type for vector pseudo instrs
class InstV<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern>
  : RVInst<outs, ins,
                opcodestr, argstr, pattern, InstFormatOther> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}

//TODO CHANGE OPCODE
class InstI<string mnemonic, bits<7> op, bits<3> funct3,
            SDPatternOperator operator, RegisterClass cls1, RegisterClass cls2>
  : RVInstI<funct3, RISCVOpcode<0b0000000>, (outs cls1:$dst), (ins cls2:$src1, imm64sx32:$src2),
                mnemonic, "$dst, $src1, $src2"> {
}


// Custom Operands
def imm1 : ImmLeaf<i1, [{}]>, Operand<i1>;

def pred : PredicateOperand<i1, (ops imm1, VPR), (ops (i1 0), vp0)> {
  let PrintMethod = "printPredOperand";
}

//TODO NAMESPACE to riscv_

def SDT_RISCVSETCFG            : SDTypeProfile<1, 4,[SDTCisVT<0, i64>,
                                                  SDTCisVT<1, i64>,
                                                  SDTCisVT<2, i64>,
                                                  SDTCisVT<3, i64>,
                                                  SDTCisVT<4, i64>]>;
def SDT_RISCVSETVL             : SDTypeProfile<1, 1,[SDTCisVT<0, i64>,
                                                  SDTCisVT<1, i64>]>;

def SDT_RISCVVCall               : SDTypeProfile<0, -1, [SDTCisPtrTy<0>]>;

def r_vsetcfg           : SDNode<"RISCVISD::VSETCFG", SDT_RISCVSETCFG, [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue, SDNPSideEffect]>;
def r_vsetvl            : SDNode<"RISCVISD::VSETVL", SDT_RISCVSETVL, [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue, SDNPSideEffect]>;


def r_callv  : SDNode<"RISCVISD::CALLV", SDT_RISCVVCall,
                 [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue,
                  SDNPVariadic]>;



def regaddr : ComplexPattern<iPTR, 1, "selectRegAddr">;

multiclass InstVR2<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1, mayStore = 0, mayLoad = 0, hasSideEffects = 0 in {
  def _VV : RVInst<(outs VVR:$dst), (ins VVR:$src1, pred:$p),
    "@$p\t"#name#"", "$dst, $src1", [], InstFormatOther>;
  def _VS : RVInst<(outs VVR:$dst), (ins VSR:$src1, pred:$p),
    "@$p\t"#name#"", "$dst, $src1", [], InstFormatOther>;
  def _SS : RVInst<(outs VSR:$dst), (ins VSR:$src1),
    name#"", "$dst, $src1", [], InstFormatOther>;
  }
}

multiclass InstVR3<string name, SDPatternOperator op, RegisterOperand typ> {
  let isPseudo = 1, isCodeGenOnly = 1, mayStore = 0, mayLoad = 0, hasSideEffects = 0 in {
  def _VVV : RVInst<(outs typ:$dst), (ins typ:$src1, typ:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _VVS : RVInst<(outs typ:$dst), (ins typ:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _VSV : RVInst<(outs typ:$dst), (ins VSR:$src1, typ:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _VSS : RVInst<(outs typ:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _SSS : RVInst<(outs VSR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  }
}

multiclass InstVR3Cmp<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1, mayStore = 0, mayLoad = 0, hasSideEffects = 0  in {
  def _VV : RVInst<(outs VPR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _VS : RVInst<(outs VPR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _SV : RVInst<(outs VPR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _SS : RVInst<(outs VPR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  }
}

multiclass InstVR3CmpSwitch<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1, mayStore = 0, mayLoad = 0, hasSideEffects = 0  in {
  def _VV : RVInst<(outs VPR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [], InstFormatOther>;
  def _VS : RVInst<(outs VPR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [], InstFormatOther>;
  def _SV : RVInst<(outs VPR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [], InstFormatOther>;
  def _SS : RVInst<(outs VPR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src2, $src1", [], InstFormatOther>;
  }
}

multiclass InstVR3Int<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1, mayStore = 0, mayLoad = 0, hasSideEffects = 0  in {
  def _VVV : RVInst<(outs VVR:$dst), (ins VVR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _VVS : RVInst<(outs VVR:$dst), (ins VVR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _VSV : RVInst<(outs VVR:$dst), (ins VSR:$src1, VVR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _VSS : RVInst<(outs VVR:$dst), (ins VSR:$src1, VSR:$src2, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  def _SSS : RVInst<(outs VSR:$dst), (ins VSR:$src1, VSR:$src2),
    name#"", "$dst, $src1, $src2", [], InstFormatOther>;
  }
}

multiclass InstVR4<string name, SDPatternOperator op> {
  let isPseudo = 1, isCodeGenOnly = 1, mayStore = 0, mayLoad = 0, hasSideEffects = 0  in {
  def _VVVV : RVInst<(outs VVR:$dst), (ins VVR:$src1, VVR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _VVSV : RVInst<(outs VVR:$dst), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _VSVV : RVInst<(outs VVR:$dst), (ins VSR:$src1, VVR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _VSSV : RVInst<(outs VVR:$dst), (ins VSR:$src1, VSR:$src2, VVR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _VVVS: RVInst<(outs VVR:$dst), (ins VVR:$src1, VVR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _VVSS: RVInst<(outs VVR:$dst), (ins VVR:$src1, VSR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _VSVS: RVInst<(outs VVR:$dst), (ins VSR:$src1, VVR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _VSSS: RVInst<(outs VVR:$dst), (ins VSR:$src1, VSR:$src2, VSR:$src3, pred:$p),
    "@$p\t"#name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  def _SSSS : RVInst<(outs VSR:$dst), (ins VSR:$src1, VSR:$src2, VSR:$src3),
    name#"", "$dst, $src1, $src2, $src3", [], InstFormatOther>;
  }
}

//all bits in this file should be considered fake

// Control Thread Instructions

//configure vector unit
let isCodeGenOnly = 1, isPseudo = 1 in {
  def VSETCFG : InstV<(outs GPR:$cfg), (ins imm64:$dregs, imm64:$wregs, imm64:$hregs, imm64:$pregs),
                "vsetcfg", "$cfg,$dregs,$wregs,$hregs,$pregs", []>, Requires<[HasXhwacha]>;//vsetcfg 32,0    #num_int_regs,num_pred_regs
  def VSETVL  : InstV<(outs GPR:$res), (ins GPR:$goal), "vsetvl", "$res,$goal", []>, Requires<[HasXhwacha]>;//vsetvl t0,t0    #reg,reg for how long we got and how long we wanted
}

def: Pat<(r_vsetvl GPR:$goal), (VSETVL GPR:$goal)>;
def: Pat<(r_vsetcfg i64:$dregs, i64:$wregs, i64:$hregs, i64:$pregsl), (VSETCFG imm64:$dregs, imm64:$wregs, imm64:$hregs, imm64:$pregsl)>;

let isCall = 1, isCodeGenOnly = 1 in {
    def VFetch : InstV< (outs), (ins GPR:$target), "vf", "$target", [(r_callv regaddr:$target)]>, Requires<[HasXhwacha]>;
  }

//Moves

let mayStore = 0, mayLoad = 0, hasSideEffects = 0 in {
  def VMSS_X : InstV<(outs VSR:$dest), (ins GPR:$src), "vmcs", "$dest,$src",
                     //[(set VSR:$dest, (COPY_TO_REG_CLASS GPR:$src, VSR))]
                     []>, Requires<[HasXhwacha]>;

  def VMSA : InstV<(outs VAR:$dest), (ins GPR:$src), "vmca", "$dest,$src",
                     //[(set VAR:$dest, (COPY_TO_REG_CLASS GPR:$src, VAR))]
                     []>, Requires<[HasXhwacha]>;
}



//Vector Memory Ops
let mayLoad = 1, mayStore = 0, hasSideEffects = 0 in {
  def VLXW : InstV<(outs VVW:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw", "$dest, $src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXH : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxh", "$dest, $src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXHU : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxhu", "$dest, $src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXD_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxd", "$dest, $src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXW_F : InstV<(outs VVW:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw", "$dest, $src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXH_F : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxh", "$dest, $src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLXHU_F : InstV<(outs VVH:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxhu", "$dest, $src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VLSW : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsw", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSH : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsh", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSHU : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlshu", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSD_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsd", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSW_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsw", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSH_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlsh", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VLSHU_F : InstV<(outs VSR:$dest), (ins VSR:$src1),
             "vlshu", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  let isVariant = 1 in {
    def VLD : InstV<(outs VVR:$dest), (ins VAR:$src1, pred:$p),
             "@$p\tvld", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLW : InstV<(outs VVW:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlw", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLH : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlh", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLHU : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlhu", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLD_F : InstV<(outs VVR:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvld", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLW_F : InstV<(outs VVW:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlw", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLH_F : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlh", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VLHU_F : InstV<(outs VVH:$dest), (ins VAR:$src1, pred:$p),
               "@$p\tvlhu", "$dest, $src1", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  }
}

let mayStore = 1, mayLoad = 0, hasSideEffects = 0 in {
  def VSXW : InstV<(outs), (ins VVW:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw", "$src1, $src2, $src3", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXD_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxd", "$src1, $src2, $src3", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXW_F : InstV<(outs), (ins VVW:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw", "$src1, $src2, $src3", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSXH_F : InstV<(outs), (ins VVH:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxh", "$src1, $src2, $src3", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  def VSSW : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssw", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSD_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssd", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSW_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssw", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  def VSSH_F : InstV<(outs), (ins VSR:$src1, VSR:$src2),
             "vssh", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1


  let isVariant = 1 in {
    def VSW : InstV<(outs), (ins VVW:$src1, VAR:$src2, pred:$p),
               "@$p\tvsw", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSD_F : InstV<(outs), (ins VVR:$src1, VAR:$src2, pred:$p),
               "@$p\tvsd", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSW_F : InstV<(outs), (ins VVW:$src1, VAR:$src2, pred:$p),
               "@$p\tvsw", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
    def VSH_F : InstV<(outs), (ins VVH:$src1, VAR:$src2, pred:$p),
               "@$p\tvsh", "$src1, $src2", []>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  }
  //def VSW : InstStore <"vsw"  , 0b0100011, 0b011, store, VR32, mem64>, Requires<[IsRV64]>; //vsw vx2, x2
  //def VSD : InstStore <"vsd"  , 0b0100011, 0b011, store, VR64, mem64>, Requires<[IsRV64, HasXhwacha]>;
}

//Vector fetch
let isCodeGenOnly = 1 in {
  let isReturn = 1, isTerminator = 1, isBarrier = 1, hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
    def VSTOP   : InstV<(outs), (ins), "vstop", "", []>,Requires<[HasXhwacha]>;
  }

  let isVariant = 1 in {
    def VEIDX  : InstV<(outs VVR:$dest), (ins), "veidx", "$dest", []>, Requires<[HasXhwacha]>;
  }
}

 def: Pat<(int_hwacha_veidx), (VEIDX)>;

//Psuedo Instructions for scalar operations inside of vector fetch blocks
//To be expanded into vfetch blocks after register allocation and scheduling
let isPseudo = 1 in {
  let mayLoad = 0, mayStore = 0, hasSideEffects = 0 in {
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

    def VSLLI: InstI<"vslli" , ?, ?, shl, VSR, VSR>, Requires<[HasXhwacha]>;
    def VSRLI: InstI<"vsrli" , ?, ?, srl, VSR, VSR>, Requires<[HasXhwacha]>;
    def VSRAI: InstI<"vsrai" , ?, ?, sra, VSR, VSR>, Requires<[HasXhwacha]>;
    def VADDI: InstI<"vaddi" , ?, ?, add, VSR, VSR>, Requires<[HasXhwacha]>;
    def VORI: InstI<"vori" , ?, ?, or, VSR, VSR>, Requires<[HasXhwacha]>;
    def VSLTI: InstI<"vslti" , ?, ?, setlt, VSR, VSR>, Requires<[HasXhwacha]>;
    def VLUI : InstV<(outs VSR:$dest), (ins imm64sx32:$imm), "vlui", "$dest, $imm",
      [(set VSR:$dest, (shl imm64sx32:$imm, (i64 32)))]>, Requires<[HasXhwacha]>;

    def VSLLIW: InstI<"vslliw" , ?, ?, shl, VSR, VSR>, Requires<[HasXhwacha]>;
    def VSRLIW: InstI<"vsrliw" , ?, ?, srl, VSR, VSR>, Requires<[HasXhwacha]>;
    def VSRAIW: InstI<"vsraiw" , ?, ?, sra, VSR, VSR>, Requires<[HasXhwacha]>;
    def VADDIW: InstI<"vaddiw" , ?, ?, add, VSR, VSR>, Requires<[HasXhwacha]>;
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

  }
  
  let mayStore = 1, mayLoad = 0 in {
     def VSXW_RAS_F : InstV<(outs), (ins VVR:$src1, VSR:$src2, VVR:$src3, pred:$p),
             "@$p\tvsxw", "$src1, $src2, $src3", [(store (f64 VVR:$src1), (add VSR:$src2, VVR:$src3))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1
  }
 
  let mayLoad = 1, mayStore = 0 in {
      def VLXW_RAS_F : InstV<(outs VVR:$dest), (ins VSR:$src1, VVR:$src2, pred:$p),
             "@$p\tvlxw", "$dest, $src1, $src2", [(set VVR:$dest, (f64 (load (add VSR:$src1, VVR:$src2))))]>, Requires<[HasXhwacha]>;  //vlxw vv2, vs1, vv1

  }

 let mayStore = 0 in {
    //Predicate Instructions
    def VPSET  : InstV<(outs VPR:$dest), (ins), "vpset", "$dest",[(set VPR:$dest, (i1 1))]>, Requires<[HasXhwacha]>;
    def VPCLEAR  : InstV<(outs VPR:$dest), (ins), "vpclear", "$dest",[(set VPR:$dest, (i1 0))]>, Requires<[HasXhwacha]>;
 }

  let mayLoad = 0, mayStore = 0, hasSideEffects = 0 in {

    def VPANDAND  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vpandand", "$dest, $in1, $in2, $in3",[]>, Requires<[HasXhwacha]>;
    def VPOROR  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vporor", "$dest, $in1, $in2, $in3",[]>, Requires<[HasXhwacha]>;
    def VPANDXOR  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vpandxor", "$dest, $in1, $in2, $in3",[]>, Requires<[HasXhwacha]>;
    def VPXORAND  : InstV<(outs VPR:$dest), (ins VPR:$in1, VPR:$in2, VPR:$in3), "vpxorand", "$dest, $in1, $in2, $in3",[]>, Requires<[HasXhwacha]>;

    //compare instructions
    defm VCMPEQ  : InstVR3Cmp<"vcmpeq",  seteq>;
    defm VCMPLT  : InstVR3Cmp<"vcmplt",  setlt>;
    defm VCMPLTU : InstVR3Cmp<"vcmpltu", setult>;
    defm VCMPGT  : InstVR3CmpSwitch<"vcmplt",  setgt>;
    defm VCMPGTU : InstVR3CmpSwitch<"vcmpltu", setugt>;
  }

}
// Control-flow Instructions
let isBranch = 1, isTerminator = 1, isBarrier = 1, mayLoad = 0, mayStore = 0, hasSideEffects = 0 in{
  def VCJAL: InstV<(outs VSR:$ret), (ins simm21_lsb0_jal:$target, pred:$p),
    "@$p\tvcjal", "1, $ret, $target", []>, Requires<[HasXhwacha]>;
        }

def r_vli      : SDNode<"RISCVISD::VLI", SDTIntUnaryOp>;
// load immediate patterns
def : Pat<(r_vli imm64sx32:$imm), (VADDI (i64 vs0), imm64sx32:$imm)>;
//TODO: 64bit immediate pattern