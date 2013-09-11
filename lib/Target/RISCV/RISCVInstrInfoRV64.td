//==- RISCVInstrRV64.td - RISCV RV64I instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//Standard instructions operating on 64bit values
//Integer arithmetic register-register
def ADD64 : InstR<"ADD" , 0b0110011, 0b0000000000, add   , GR64, GR64>, Requires<[IsRV64]>;
def SUB64 : InstR<"SUB" , 0b0110011, 0b1000000000, sub   , GR64, GR64>, Requires<[IsRV64]>;
def SLL64 : InstR<"SLL" , 0b0110011, 0b1000000001, shl   , GR64, GR64>, Requires<[IsRV64]>;
def SLT64 : InstR<"SLT" , 0b0110011, 0b0000000010, setlt , GR64, GR64>, Requires<[IsRV64]>;
def SLTU64: InstR<"SLTU", 0b0110011, 0b0000000011, setult, GR64, GR64>, Requires<[IsRV64]>;
def XOR64 : InstR<"XOR" , 0b0110011, 0b0000000100, xor   , GR64, GR64>, Requires<[IsRV64]>;
def SRL64 : InstR<"SRL" , 0b0110011, 0b0000000101, srl   , GR64, GR64>, Requires<[IsRV64]>;
def SRA64 : InstR<"SRA" , 0b0110011, 0b1000000101, sra   , GR64, GR64>, Requires<[IsRV64]>;
def OR64  : InstR<"OR"  , 0b0110011, 0b0000000110, or    , GR64, GR64>, Requires<[IsRV64]>;
def AND64 : InstR<"AND" , 0b0110011, 0b0000000111, and   , GR64, GR64>, Requires<[IsRV64]>;
//Integer arithmetic register-immediate
def ADDI64: InstI<"ADDI", 0b0010011, 0b000       , add, GR64, imm64sx12>, Requires<[IsRV64]>;
def XORI64: InstI<"XORI", 0b0010011, 0b100       , xor, GR64, imm64sx12>, Requires<[IsRV64]>;
def ORI64 : InstI<"ORI" , 0b0010011, 0b110       , or , GR64, imm64sx12>, Requires<[IsRV64]>;
def ANDI64: InstI<"ANDI", 0b0010011, 0b111       , and, GR64, imm64sx12>, Requires<[IsRV64]>;
//TODO: check 64bit shifr constraints
//TODO: enforce constraints here or up on level?
def SLLI64: InstI<"SLLI", 0b0010011, 0b001       , shl, GR64, imm64sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b000000; 
  //trap if $imm{5}!=0 TODO:how to do this?
}
def SRLI64: InstI<"SRLI", 0b0010011, 0b101       , srl, GR64, imm64sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b000000; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SRAI64: InstI<"SRAI", 0b0010011, 0b101       , sra, GR64, imm64sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b000001; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SLTI64 : InstI<"SLTI", 0b0010011, 0b010, setlt, GR64, imm64sx12>, Requires<[IsRV64]>;
def SLTIU64: InstI<"SLTIU",0b0010011, 0b011, setult,GR64, imm64sx12>, Requires<[IsRV64]>;

//Synthesized set operators
defm : SeteqPats<GR64, SLTIU64, XOR64, SLTU64, zero_64>, Requires<[IsRV64]>;
defm : SetlePats<GR64, SLT64, SLTU64, XORI64>, Requires<[IsRV64]>;
defm : SetgtPats<GR64, SLT64, SLTU64>, Requires<[IsRV64]>;
defm : SetgePats<GR64, SLT64, SLTU64, XORI64>, Requires<[IsRV64]>;

//Unconditional Jumps
let isCall = 1 in {
  let Defs = [ra, v0, v1] in { //after call return addr and values are defined
    def JAL64: InstJ<0b1101111, (outs), (ins pcrel64call:$target), "JAL\t$target", 
          [(z_call pcrel64call:$target)]>, Requires<[IsRV64]>;
  }
}
let isCall = 1 in {
  //TODO: fix jalr and write test
    def JALR64: InstRISCV<4, (outs GR64:$ra), (ins mem:$target), "JALR\t$target", 
          //[(set GR32:$ra, (z_call addr:$target))]>{
          []>{
            field bits<32> Inst;

            bits<5> RD;
            bits<5> RS1;
            bits<12> IMM;

            let Inst{31-27} = RD;
            let Inst{26-22} = RS1;
            let Inst{21-17} = IMM{11-7};
            let Inst{16-10} = IMM{6 -0};
            let Inst{9 - 7} = 0b000;
            let Inst{6 - 0} = 0b1101011;
          }
}
 

//Conditional Branches
//TODO:refactor to class
let isBranch = 1, isTerminator = 1, isBarrier = 1 in {
  def BEQ64 : InstB<0b1100011, 0b000, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BEQ\t$src1, $src2, $target", 
              [(brcond (i64 (seteq GR64:$src1,  GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BNE64 : InstB<0b1100011, 0b001, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BNE\t$src1, $src2, $target", 
              [(brcond (i64 (setne GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BLT64 : InstB<0b1100011, 0b100, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BLT\t$src1, $src2, $target", 
              [(brcond (i64 (setlt GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BGE64 : InstB<0b1100011, 0b101, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BGE\t$src1, $src2, $target", 
              [(brcond (i64 (setge GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BLTU64: InstB<0b1100011, 0b110, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BLTU\t$src1, $src2, $target", 
              [(brcond (i64 (setult GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BGEU64: InstB<0b1100011, 0b111, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BGEU\t$src1, $src2, $target", 
              [(brcond (i64 (setuge GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;

//Synthesize remaining condition codes by reverseing operands
  def BGT64 : InstB<0b1100011, 0b100, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BLT\t$src2, $src1, $target", 
              [(brcond (i64 (setgt GR64:$src2, GR64:$src1)), bb:$target)]>, Requires<[IsRV64]>;
  def BGTU64: InstB<0b1100011, 0b110, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BLTU\t$src2, $src1, $target", 
              [(brcond (i64 (setugt GR64:$src2, GR64:$src1)), bb:$target)]>, Requires<[IsRV64]>;
  def BLE64 : InstB<0b1100011, 0b101, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BGE\t$src2, $src1, $target", 
              [(brcond (i64 (setle GR64:$src2, GR64:$src1)), bb:$target)]>, Requires<[IsRV64]>;
  def BLEU64: InstB<0b1100011, 0b111, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "BGEU\t$src2, $src1, $target", 
              [(brcond (i64 (setule GR64:$src2, GR64:$src1)), bb:$target)]>, Requires<[IsRV64]>;
}
//constant branches (e.g. br 1 $label or br 0 $label)
def : Pat<(brcond GR64Bit:$cond, bb:$target),
          (BNE64 bb:$target, GR64Bit:$cond, zero_64)>;  
//Conditional moves
// SELECT_CC_* - Used to implement the SELECT_CC DAG operation.  Expanded after
// instruction selection into a branch sequence.
let usesCustomInserter = 1 in {
  def SELECT_CC64 : Pseudo<(outs GR64:$dst),
                              (ins GR64:$cond, GR64:$T, GR64:$F),
                              [(set GR64:$dst,
                                 (select GR64:$cond, GR64:$T, GR64:$F))]>, Requires<[IsRV64]>;
}
def : Pat<(select (i64 (setne GR64:$lhs, 0)), GR64:$T, GR64:$F),
        (SELECT_CC64 GR64:$lhs, GR64:$T, GR64:$F)>;

def : Pat<(select (i64 (seteq GR64:$lhs, 0)), GR64:$T, GR64:$F),
        (SELECT_CC64 GR64:$lhs, GR64:$F, GR64:$T)>;

//Load/Store Instructions
let mayLoad = 1 in {
  def LW64 : InstLoad <"LW" , 0b0000011, 0b010, load, GR64>, Requires<[IsRV64]>; 
  def LH64 : InstLoad <"LH" , 0b0000011, 0b001, sextloadi16, GR64>, Requires<[IsRV64]>; 
  def LHU64: InstLoad <"LHU", 0b0000011, 0b101, zextloadi16, GR64>, Requires<[IsRV64]>; 
  def LB64 : InstLoad <"LB" , 0b0000011, 0b000, sextloadi8, GR64>, Requires<[IsRV64]>; 
  def LBU64: InstLoad <"LBU", 0b0000011, 0b100, zextloadi8, GR64>, Requires<[IsRV64]>; 
}
//extended loads
def : Pat<(i64 (extloadi1  addr:$addr)), (LBU64 addr:$addr)>;
def : Pat<(i64 (extloadi8  addr:$addr)), (LBU64 addr:$addr)>;
def : Pat<(i64 (extloadi16 addr:$addr)), (LHU64 addr:$addr)>;

let mayStore = 1 in {
  def SW64 : InstStore<"SW" , 0b0100011, 0b010, store        , GR64>, Requires<[IsRV64]>;
  def SH64 : InstStore<"SH" , 0b0100011, 0b001, truncstorei16, GR64>, Requires<[IsRV64]>; 
  def SB64 : InstStore<"SB" , 0b0100011, 0b000, truncstorei8 , GR64>, Requires<[IsRV64]>; 
}

//Upper Immediate
def LUI64: InstU<0b0110111, (outs GR64:$dst), (ins imm64sxu20:$imm),
                 "LUI\t$dst, $imm",
                 [(set GR64:$dst, (shl imm64sx20:$imm, (i64 12)))]>;

def AUIPC64: InstU<0b0110111, (outs GR64:$dst), (ins pcimm64:$target),
                   "AUIPC\t$dst, $target",
                   [(set GR64:$dst, (z_pcrel_wrapper tglobaladdr:$target))]>;

//simple immediate loading
def : Pat<(i64 imm64sx12:$imm), (ORI64 zero_64, imm64sx12:$imm)>; 

//psuedo load low imm instruction to print operands better
def LLI64 : InstI<"ADDI", 0b0010011, 0b000       , add, GR64, imm64sxu12>;
def : Pat<(i64 imm64:$imm), (LLI64 (LUI64 (HI20 imm64:$imm)), (LO12 imm64:$imm))>;



//special 64bit instructions
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

//===----------------------------------------------------------------------===//
// Subtarget features
//===----------------------------------------------------------------------===//

include "RISCVInstrInfoRV64M.td"
//include "RISCVInstrInfoRV64F.td"
//include "RISCVInstrInfoRV64A.td"
//include "RISCVInstrInfoRV64D.td"

