//==- RISCVInstrRV64.td - RISCV RV64I instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//Integer arithmetic register-register
def ADDW : InstR<"ADDW" , 0b0111011, 0b0000000000, add   , GR64, GR64>, Requires<[IsRV64]>;
def SUBW : InstR<"SUBW" , 0b0111011, 0b1000000000, sub   , GR64, GR64>, Requires<[IsRV64]>;
def SLLW : InstR<"SLLW" , 0b0111011, 0b1000000001, shl   , GR64, GR64>, Requires<[IsRV64]>;
def SRLW : InstR<"SRLW" , 0b0111011, 0b0000000101, srl   , GR64, GR64>, Requires<[IsRV64]>;
def SRAW : InstR<"SRAW" , 0b0111011, 0b1000000101, sra   , GR64, GR64>, Requires<[IsRV64]>;

//Integer arithmetic register-immediate
def ADDIW: InstI<"ADDIW", 0b0011011, 0b000       , add, GR32, imm32sx12>, Requires<[IsRV64]>;
//TODO: enforce constraints here or up on level?
def SLLIW: InstI<"SLLIW", 0b0011011, 0b001       , shl, GR32, imm32sx12>, Requires<[IsRV64]> {
  let IMM{11-5} = 0b0000000; 
  //trap if $imm{5}!=0 TODO:how to do this?
}
def SRLIW: InstI<"SRLIW", 0b0011011, 0b101       , srl, GR32, imm32sx12>, Requires<[IsRV64]> {
  let IMM{11-5} = 0b0000000; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SRAIW: InstI<"SRAIW", 0b0011011, 0b101       , sra, GR32, imm32sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b0000010; 
  //trap if $src{5}!=0 TODO:how to do this?
}

//Load/Store Instructions
let mayLoad = 1 in {
  def LWU : InstLoad <"LWU" , 0b0000011, 0b110, load,  GR64>, Requires<[IsRV64]>; 
  def LD  : InstLoad <"LD"  , 0b0000011, 0b011, load,  GR64>, Requires<[IsRV64]>; 
}

let mayStore = 1 in {
  def SD : InstStore <"SD"  , 0b0100011, 0b011, store, GR64>, Requires<[IsRV64]>;
}

//Synthesized set operators
/*
defm : SeteqPats<GR64, SLTIU, XOR, SLTU, zero>;
defm : SetlePats<GR64, SLT, SLTU>;
defm : SetgtPats<GR64, SLT, SLTU>;
defm : SetgePats<GR64, SLT, SLTU>;
*/
