//===-- RISCVInstrInfo.td - General RISCV instructions ----*- tblgen-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

/*******************
*RISCV Instructions
********************/
//Integer arithmetic register-register
def ADD : InstR<"ADD" , 0b0110011, 0b0000000000, add   , GR32, GR32>;
def SUB : InstR<"SUB" , 0b0110011, 0b1000000000, sub   , GR32, GR32>;
def SLL : InstR<"SLL" , 0b0110011, 0b1000000001, shl   , GR32, GR32>;
def SLT : InstR<"SLT" , 0b0110011, 0b0000000010, setlt , GR32, GR32>;
def SLTU: InstR<"SLTU", 0b0110011, 0b0000000011, setult, GR32, GR32>;
def XOR : InstR<"XOR" , 0b0110011, 0b0000000100, xor   , GR32, GR32>;
def SRL : InstR<"SRL" , 0b0110011, 0b0000000101, srl   , GR32, GR32>;
def SRA : InstR<"SRA" , 0b0110011, 0b1000000101, sra   , GR32, GR32>;
def OR  : InstR<"OR"  , 0b0110011, 0b0000000110, or    , GR32, GR32>;
def AND : InstR<"AND" , 0b0110011, 0b0000000111, and   , GR32, GR32>;
//Integer arithmetic register-immediate
def ADDI: InstI<"ADDI", 0b0010011, 0b000       , add, GR32, imm32sx12>;
def XORI: InstI<"XORI", 0b0010011, 0b100       , xor, GR32, imm32sx12>;
def ORI : InstI<"ORI" , 0b0010011, 0b110       , or , GR32, imm32sx12>;
//simple immediate loading
def : Pat<(i32 imm32sx12:$imm), (ORI zero, imm32sx12:$imm)>;
def ANDI: InstI<"ANDI", 0b0010011, 0b111       , and, GR32, imm32sx12>;
//TODO: enforce constraints here or up on level?
def SLLI: InstI<"SLLI", 0b0010011, 0b001       , shl, GR32, imm32sx12> {
  let IMM{11-6} = 0b000000; 
  //trap if $imm{5}!=0 TODO:how to do this?
}
def SRLI: InstI<"SRLI", 0b0010011, 0b101       , srl, GR32, imm32sx12> {
  let IMM{11-6} = 0b000000; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SRAI: InstI<"SRAI", 0b0010011, 0b101       , sra, GR32, imm32sx12> {
  let IMM{11-6} = 0b000001; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SLTI : InstI<"SLTI", 0b0010011, 0b010, setlt, GR32, imm32sx12>;
def SLTIU: InstI<"SLTIU",0b0010011, 0b011, setult,GR32, imm32sx12>;

//Unconditional Jumps
let isBranch = 1, isTerminator = 1, isBarrier = 1 in {
  def J  : InstJ<0b1100111, (outs), (ins jumptarget:$target), "J\t$target", 
          [(br bb:$target)]>;
}
let isCall = 1 in {
  let Defs = [ra] in {
    def JAL: InstJ<0b1101111, (outs), (ins pcrel32call:$target), "JAL\t$target", 
          [(z_call pcrel32call:$target)]>;
  }
}
let isCall = 1 in {
  //TODO: fix jalr and write test
    def JALR: InstRISCV<4, (outs GR32:$ra), (ins mem:$target), "JALR\t$target", 
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
            "BEQ\t$src1, $src2, $target", 
            [(brcond (i32 (seteq GR32:$src1,  GR32:$src2)), bb:$target)]>;
  def BNE : InstB<0b1100011, 0b001, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "BNE\t$src1, $src2, $target", 
            [(brcond (i32 (setne GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BLT : InstB<0b1100011, 0b100, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "BLT\t$src1, $src2, $target", 
            [(brcond (i32 (setlt GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BGE : InstB<0b1100011, 0b101, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "BGE\t$src1, $src2, $target", 
            [(brcond (i32 (setge GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BLTU: InstB<0b1100011, 0b110, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "BLTU\t$src1, $src2, $target", 
            [(brcond (i32 (setult GR32:$src1, GR32:$src2)), bb:$target)]>;
  def BGEU: InstB<0b1100011, 0b111, (outs), 
            (ins brtarget:$target, GR32:$src2, GR32:$src1), 
            "BGEU\t$src1, $src2, $target", 
            [(brcond (i32 (setuge GR32:$src1, GR32:$src2)), bb:$target)]>;
}

//Load/Store Instructions
let mayLoad = 1 in {
  def LW : InstLoad <"LW" , 0b0000011, 0b010, load, GR32>; 
  def LH : InstLoad <"LH" , 0b0000011, 0b001, sextloadi16, GR32>; 
  def LHU: InstLoad <"LHU", 0b0000011, 0b101, zextloadi16, GR32>; 
  def LB : InstLoad <"LB" , 0b0000011, 0b000, sextloadi8, GR32>; 
  def LBU: InstLoad <"LBU", 0b0000011, 0b100, zextloadi8, GR32>; 
}
let mayStore = 1 in {
  def SW : InstStore<"SW" , 0b0100011, 0b010, store        , GR32>;
  def SH : InstStore<"SH" , 0b0100011, 0b001, truncstorei16, GR32>; 
  def SB : InstStore<"SB" , 0b0100011, 0b000, truncstorei8 , GR32>; 
}

//Upper Immediate
def LUI: InstU<0b0110111, (outs GR32:$dst), (ins imm32sx20:$imm),
               "LUI\t$dst, $imm",
               [(set GR32:$dst, (shl imm32sx20:$imm, 12))]>;

def AUIPC: InstU<0b0110111, (outs GR32:$dst), (ins pcimm:$target),
               "AUIPC\t$dst, $target",
               [(set GR32:$dst, (z_pcrel_wrapper tglobaladdr:$target))]>;


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
  def RET : InstRISCV<4, (outs), (ins), "RET", 
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
