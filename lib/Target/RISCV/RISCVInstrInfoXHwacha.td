//==- RISCVInstrInfoXHwacha.td - Vector RISCV Instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//all bits in this file should be considered fake

//configure vector unit
let isCodeGenOnly = 1 in {
  def VSETCFG : InstV< (outs), (ins imm64:$xregs, imm64:$fregs),
                "vsetcfg\t$xregs,$fregs", []>, Requires<[HasXHwacha]>;//vsetcfg 32,0    #num_int_regs,num_float_regs
  def VSETVL  : InstV< (outs GR64:$res), (ins GR64:$goal), 
                "vsetvl\t$res,$goal", []>, Requires<[HasXHwacha]>;//vsetvl t0,t0    #reg,reg for how long we got and how long we wanted
}

//Vector Memory Ops
let mayLoad = 1 in {
  //def VLW : InstLoad<"vlw", 0b0000011, 0b011, load,  VR32, mem64>, Requires<[IsRV64]>;  //vlw vx2, x2
  //def VLD : InstLoad<"vld", 0b0000011, 0b011, load,  VR64, mem64>, Requires<[IsRV64, HasXHwacha]>; 
}
let mayStore = 1 in {
  //def VSW : InstStore <"vsw"  , 0b0100011, 0b011, store, VR32, mem64>, Requires<[IsRV64]>; //vsw vx2, x2
  //def VSD : InstStore <"vsd"  , 0b0100011, 0b011, store, VR64, mem64>, Requires<[IsRV64, HasXHwacha]>;
}

//Vector fetch
let isCodeGenOnly = 1 in {
  let isCall = 1, isTerminator = 1, isBarrier = 1  in {
    def VFetch : InstV< (outs), (ins mem64:$target), "vf\t$target", []>, Requires<[HasXHwacha]>;
  }
  let isReturn = 1, isTerminator = 1, isBarrier = 1 in {
    def STOP   : InstV<(outs), (ins), "stop",[]>,Requires<[HasXHwacha]>;
  }
  def UTIDX  : InstV<(outs GR64:$dest), (ins), "utidx\t$dest",[]>, Requires<[HasXHwacha]>;
}

//Moves
def VMSV64 : InstV<(outs GR64:$dest), (ins GR64:$src), "vmsv\tv$dest,$src",
                     //[(set VR64:$dest, (v4i64 (r_vmv GR64:$src)))]>, Requires<[HasXHwacha]>;
                     []>, Requires<[HasXHwacha]>;
def VMSV : InstV<(outs GR32:$dest), (ins GR32:$src), "vmsv\tv$dest,$src",
                     //[(set VR64:$dest, (v4i64 (r_vmv GR64:$src)))]>, Requires<[HasXHwacha]>;
                     []>, Requires<[HasXHwacha]>;


//Psuedo Instructions for scalar operations inside of vector fetch blocks
//To be expanded into vfetch blocks after register allocation and scheduling
let isPseudo = 1, usesCustomInserter = 1 in {
  //Integer arithmetic register-register
  //def VADD64 : InstR<"vadd" , ?, ?, add   , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VSUB64 : InstR<"vsub" , ?, ?, sub   , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VSLL64 : InstR<"vsll" , ?, ?, shl   , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VSLT64 : InstR<"slt" , ?, ?, setlt , VR32, VR64>, Requires<[HasXHwacha]>;
  //def VSLTU64: InstR<"sltu", ?, ?, setult, VR32, VR64>, Requires<[HasXHwacha]>;
  //def VXOR64 : InstR<"vxor" , ?, ?, xor   , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VSRL64 : InstR<"vsrl" , ?, ?, srl   , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VSRA64 : InstR<"vsra" , ?, ?, sra   , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VOR64  : InstR<"vor"  , ?, ?, or    , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VAND64 : InstR<"vand" , ?, ?, and   , VR64, VR64>, Requires<[HasXHwacha]>;
  //def VMUL64 : InstR<"vmul", ?, ?, mul   , VR64, VR64>, Requires<[HasXHwacha]>;
}
