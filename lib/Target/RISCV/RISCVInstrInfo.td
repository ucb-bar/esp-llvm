//===-- RISCVInstrInfo.td - General RISCV instructions ----*- tblgen-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

/*
 * Predicates for Subtargets
 */

 def IsRV32 :    Predicate<"Subtarget.isRV32()">,
                 AssemblerPredicate<"FeatureRV32">; 
 def IsRV64 :    Predicate<"Subtarget.isRV64()">,
                 AssemblerPredicate<"FeatureRV64">; 
 def HasM   :    Predicate<"Subtarget.hasM()">,
                 AssemblerPredicate<"FeatureM">; 
 def HasF   :    Predicate<"Subtarget.hasF()">,
                 AssemblerPredicate<"FeatureF">; 
 def HasD   :    Predicate<"Subtarget.hasD()">,
                 AssemblerPredicate<"FeatureD">; 
 def HasA   :    Predicate<"Subtarget.hasA()">,
                 AssemblerPredicate<"FeatureA">; 

/*******************
*RISCV Instructions
********************/
//Integer arithmetic register-register
def ADD : InstR<"add" , 0b0110011, 0b0000000000, add   , GR32, GR32>;
def SUB : InstR<"sub" , 0b0110011, 0b1000000000, sub   , GR32, GR32>;
def SLL : InstR<"sll" , 0b0110011, 0b1000000001, shl   , GR32, GR32>;
def SLT : InstR<"slt" , 0b0110011, 0b0000000010, setlt , GR32, GR32>;
def SLTU: InstR<"sltu", 0b0110011, 0b0000000011, setult, GR32, GR32>;
def XOR : InstR<"xor" , 0b0110011, 0b0000000100, xor   , GR32, GR32>;
def SRL : InstR<"srl" , 0b0110011, 0b0000000101, srl   , GR32, GR32>;
def SRA : InstR<"sra" , 0b0110011, 0b1000000101, sra   , GR32, GR32>;
def OR  : InstR<"or"  , 0b0110011, 0b0000000110, or    , GR32, GR32>;
def AND : InstR<"and" , 0b0110011, 0b0000000111, and   , GR32, GR32>;
//Integer arithmetic register-immediate
def ADDI: InstI<"addi", 0b0010011, 0b000       , add, GR32, imm32sx12>;
def XORI: InstI<"xori", 0b0010011, 0b100       , xor, GR32, imm32sx12>;
def ORI : InstI<"ori" , 0b0010011, 0b110       , or , GR32, imm32sx12>;
def ANDI: InstI<"andi", 0b0010011, 0b111       , and, GR32, imm32sx12>;
//TODO: enforce constraints here or up on level?
def SLLI: InstI<"slli", 0b0010011, 0b001       , shl, GR32, imm32sx12> {
  let IMM{11-6} = 0b000000; 
  //trap if $imm{5}!=0 TODO:how to do this?
}
def SRLI: InstI<"srli", 0b0010011, 0b101       , srl, GR32, imm32sx12> {
  let IMM{11-6} = 0b000000; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SRAI: InstI<"srai", 0b0010011, 0b101       , sra, GR32, imm32sx12> {
  let IMM{11-6} = 0b000001; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SLTI : InstI<"slti", 0b0010011, 0b010, setlt, GR32, imm32sx12>;
def SLTIU: InstI<"sltiu",0b0010011, 0b011, setult,GR32, imm32sx12>;

//Synthesized set operators
//patterns to be used for 32 and 64bit
multiclass SeteqPats<RegisterOperand RC, Instruction SLTiuOp, Instruction XOROp,
                     Instruction SLTuOp, Register ZEROReg> {
  def : Pat<(seteq RC:$lhs, RC:$rhs),
            (SLTiuOp (XOROp RC:$lhs, RC:$rhs), 1)>;
  def : Pat<(setne RC:$lhs, RC:$rhs),
            (SLTuOp ZEROReg, (XOROp RC:$lhs, RC:$rhs))>;
}

multiclass SetlePats<RegisterOperand RC, Instruction SLTOp, Instruction SLTuOp, Instruction XORIOp> {
  def : Pat<(setle RC:$lhs, RC:$rhs),
            (XORIOp (SLTOp RC:$rhs, RC:$lhs), 1)>;
  def : Pat<(setule RC:$lhs, RC:$rhs),
            (XORIOp (SLTuOp RC:$rhs, RC:$lhs), 1)>;
}

multiclass SetgtPats<RegisterOperand RC, Instruction SLTOp, Instruction SLTuOp> {
  def : Pat<(setgt RC:$lhs, RC:$rhs),
            (SLTOp RC:$rhs, RC:$lhs)>;
  def : Pat<(setugt RC:$lhs, RC:$rhs),
            (SLTuOp RC:$rhs, RC:$lhs)>;
}

multiclass SetgePats<RegisterOperand RC, Instruction SLTOp, Instruction SLTuOp, Instruction XORIOp> {
  def : Pat<(setge RC:$lhs, RC:$rhs),
            (XORIOp (SLTOp RC:$lhs, RC:$rhs), 1)>;
  def : Pat<(setuge RC:$lhs, RC:$rhs),
            (XORIOp (SLTuOp RC:$lhs, RC:$rhs), 1)>;
}

defm : SeteqPats<GR32, SLTIU, XOR, SLTU, zero>;
defm : SetlePats<GR32, SLT, SLTU, XORI>;
defm : SetgtPats<GR32, SLT, SLTU>;
defm : SetgePats<GR32, SLT, SLTU, XORI>;

//Unconditional Jumps
let isBranch = 1, isTerminator = 1, isBarrier = 1 in {
  def J  : InstJ<0b1100111, (outs), (ins jumptarget:$target), "j\t$target", 
          [(br bb:$target)]>;
}
let isCall = 1 in {
  let Defs = [ra, v0, v1] in { //after call return addr and values are defined
    def JAL: InstJ<0b1101111, (outs), (ins pcrel32call:$target), "jal\t$target", 
          [(z_call pcrel32call:$target)]>;
  }
}
let isCall = 1 in {
  //TODO: fix jalr and write test
  //TODO: JALR can be implemented at brind in llvm since brind is unconditional
    def JALR: InstRISCV<4, (outs GR32:$ra), (ins mem:$target), "jalr\t$target", 
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
  def BEQ : InstB<0b1100011, 0b000, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "beq\t$src1, $src2, $target", 
            [(brcond (i32 (seteq GR32:$src1,  GR32:$src2)), bb:$target)]>;
  def BNE : InstB<0b1100011, 0b001, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "bne\t$src1, $src2, $target", 
            [(brcond (i32 (setne GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BLT : InstB<0b1100011, 0b100, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "blt\t$src1, $src2, $target", 
            [(brcond (i32 (setlt GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BGE : InstB<0b1100011, 0b101, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "bge\t$src1, $src2, $target", 
            [(brcond (i32 (setge GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BLTU: InstB<0b1100011, 0b110, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "bltu\t$src1, $src2, $target", 
            [(brcond (i32 (setult GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BGEU: InstB<0b1100011, 0b111, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "bgeu\t$src1, $src2, $target", 
            [(brcond (i32 (setuge GR32:$src1, GR32:$src2)), bb:$target)]>;

//Synthesize remaining condition codes by reverseing operands
  def BGT : InstB<0b1100011, 0b100, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "blt\t$src2, $src1, $target", 
            [(brcond (i32 (setgt GR32:$src2, GR32:$src1)), bb:$target)]>;
  def BGTU: InstB<0b1100011, 0b110, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "bltu\t$src2, $src1, $target", 
            [(brcond (i32 (setugt GR32:$src2, GR32:$src1)), bb:$target)]>;
  def BLE : InstB<0b1100011, 0b101, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "bge\t$src2, $src1, $target", 
            [(brcond (i32 (setle GR32:$src2, GR32:$src1)), bb:$target)]>;
  def BLEU: InstB<0b1100011, 0b111, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "bgeu\t$src2, $src1, $target", 
            [(brcond (i32 (setule GR32:$src2, GR32:$src1)), bb:$target)]>;
}
//constant branches (e.g. br 1 $label or br 0 $label)
def : Pat<(brcond GR32Bit:$cond, bb:$target),
          (BNE bb:$target, GR32Bit:$cond, zero)>;  
//Conditional moves
// SELECT_CC_* - Used to implement the SELECT_CC DAG operation.  Expanded after
// instruction selection into a branch sequence.
let usesCustomInserter = 1 in {
  def SELECT_CC : Pseudo<(outs GR32:$dst),
                              (ins GR32:$cond, GR32:$T, GR32:$F),
                              [(set GR32:$dst,
                                 (select GR32:$cond, GR32:$T, GR32:$F))]>;
}
def : Pat<(select (i32 (setne GR32:$lhs, 0)), GR32:$T, GR32:$F),
        (SELECT_CC GR32:$lhs, GR32:$T, GR32:$F)>;

def : Pat<(select (i32 (seteq GR32:$lhs, 0)), GR32:$T, GR32:$F),
        (SELECT_CC GR32:$lhs, GR32:$F, GR32:$T)>;

//Load/Store Instructions
let mayLoad = 1 in {
  def LW : InstLoad <"lw" , 0b0000011, 0b010, load, GR32, mem>; 
  def LH : InstLoad <"lh" , 0b0000011, 0b001, sextloadi16, GR32, mem>; 
  def LHU: InstLoad <"lhu", 0b0000011, 0b101, zextloadi16, GR32, mem>; 
  def LB : InstLoad <"lb" , 0b0000011, 0b000, sextloadi8, GR32, mem>; 
  def LBU: InstLoad <"lbu", 0b0000011, 0b100, zextloadi8, GR32, mem>; 
}
//extended loads
def : Pat<(i32 (extloadi1  addr:$addr)), (LBU addr:$addr)>;
def : Pat<(i32 (extloadi8  addr:$addr)), (LBU addr:$addr)>;
def : Pat<(i32 (extloadi16 addr:$addr)), (LHU addr:$addr)>;

let mayStore = 1 in {
  def SW : InstStore<"sw" , 0b0100011, 0b010, store        , GR32, mem>;
  def SH : InstStore<"sh" , 0b0100011, 0b001, truncstorei16, GR32, mem>; 
  def SB : InstStore<"sb" , 0b0100011, 0b000, truncstorei8 , GR32, mem>; 
}

//Upper Immediate
def LUI: InstU<0b0110111, (outs GR32:$dst), (ins imm32sxu20:$imm),
               "lui\t$dst, $imm",
               [(set GR32:$dst, (shl imm32sx20:$imm, (i32 12)))]>;

def AUIPC: InstU<0b0110111, (outs GR32:$dst), (ins pcimm:$target),
               "auipc\t$dst, $target",
               [(set GR32:$dst, (z_pcrel_wrapper tglobaladdr:$target))]>;

//simple immediate loading
def : Pat<(i32 imm32sx12:$imm), (ORI zero, imm32sx12:$imm)>; 
// Transformation Function - get the lower 12 bits.
def LO12 : SDNodeXForm<imm, [{
    return getImm(N, N->getZExtValue() & 0xFFF);
}]>;

// Transformation Function - get the higher 20 bits for large immediate loading
def HI20 : SDNodeXForm<imm, [{
    uint32_t value = N->getZExtValue() & 0x00000800 ? 
                     (N->getZExtValue() >> 12)+1:
                     (N->getZExtValue() >> 12);
    return getI32Imm(value % 20);
}]>;

//psuedo load low imm instruction to print operands better
def LLI : InstI<"addi", 0b0010011, 0b000       , add, GR32, imm32sxu12>;
def : Pat<(i32 imm32:$imm), (LLI (LUI (HI20 imm32:$imm)), (LO12 imm32:$imm))>;
//global addr loading
def : Pat<(i32 tglobaladdr:$g), (LLI (LUI (HI20 tglobaladdr:$g)), (LO12 tglobaladdr:$g))>;

//===----------------------------------------------------------------------===//
// Stack allocation
//===----------------------------------------------------------------------===//

def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i64imm:$amt),
                              [(callseq_start timm:$amt)]>;
def ADJCALLSTACKUP   : Pseudo<(outs), (ins i64imm:$amt1, i64imm:$amt2),
                              [(callseq_end timm:$amt1, timm:$amt2)]>;

//hardcoded JALR to be return
let isReturn = 1, isTerminator = 1, isBarrier = 1, hasCtrlDep = 1,
    isCodeGenOnly = 1, Defs = [v0, v1] in {
  def RET : InstRISCV<4, (outs), (ins), "ret", 
          []>{
            field bits<32> Inst;
            
            let Inst{31-27} = 0;// destination zero
            let Inst{26-22} = 1;// target ra
            let Inst{21-17} = 0;// imm 0
            let Inst{16-10} = 0;// imm 0
            let Inst{9 - 7} = 0b000;
            let Inst{6 - 0} = 0b1101011;
          }
   }
  def : Pat<(z_retflag), (RET)>;

//===----------------------------------------------------------------------===//
// Subtarget features
//===----------------------------------------------------------------------===//

include "RISCVInstrInfoRV64.td"
include "RISCVInstrInfoM.td"
include "RISCVInstrInfoF.td"
//include "RISCVInstrInfoA.td"
//include "RISCVInstrInfoD.td"

