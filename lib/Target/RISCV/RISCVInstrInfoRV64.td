//==- RISCVInstrRV64.td - RISCV RV64I instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//special 64bit instructions
def ADDW : InstR<"addw" , 0b0111011, 0b0000000000, add   , GR64, GR64>, Requires<[IsRV64]>;
def SUBW : InstR<"subw" , 0b0111011, 0b1000000000, sub   , GR64, GR64>, Requires<[IsRV64]>;
def SLLW : InstR<"sllw" , 0b0111011, 0b1000000001, shl   , GR64, GR64>, Requires<[IsRV64]>;
def SRLW : InstR<"srlw" , 0b0111011, 0b0000000101, srl   , GR64, GR64>, Requires<[IsRV64]>;
def SRAW : InstR<"sraw" , 0b0111011, 0b1000000101, sra   , GR64, GR64>, Requires<[IsRV64]>;

//Integer arithmetic register-immediate
def ADDIW: InstI<"addiw", 0b0011011, 0b000       , add, GR32, imm32sx12>, Requires<[IsRV64]>;
//TODO: enforce constraints here or up on level?
def SLLIW: InstI<"slliw", 0b0011011, 0b001       , shl, GR32, imm32sx12>, Requires<[IsRV64]> {
  let IMM{11-5} = 0b0000000; 
  //trap if $imm{5}!=0 TODO:how to do this?
}
def SRLIW: InstI<"srliw", 0b0011011, 0b101       , srl, GR32, imm32sx12>, Requires<[IsRV64]> {
  let IMM{11-5} = 0b0000000; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SRAIW: InstI<"sraiw", 0b0011011, 0b101       , sra, GR32, imm32sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b0000010; 
  //trap if $src{5}!=0 TODO:how to do this?
}

//Load/Store Instructions
let mayLoad = 1 in {
  def LWU : InstLoad <"lwu" , 0b0000011, 0b110, zextloadi32,  GR64, mem64>, Requires<[IsRV64]>; 
  def LD  : InstLoad <"ld"  , 0b0000011, 0b011, load,  GR64, mem64>, Requires<[IsRV64]>; 
}

let mayStore = 1 in {
  def SD : InstStore <"sd"  , 0b0100011, 0b011, store, GR64, mem64>, Requires<[IsRV64]>;
}

//Standard instructions operating on 64bit values
//Integer arithmetic register-register
def ADD64 : InstR<"add" , 0b0110011, 0b0000000000, add   , GR64, GR64>, Requires<[IsRV64]>;
def SUB64 : InstR<"sub" , 0b0110011, 0b1000000000, sub   , GR64, GR64>, Requires<[IsRV64]>;
def SLL64 : InstR<"sll" , 0b0110011, 0b1000000001, shl   , GR64, GR64>, Requires<[IsRV64]>;
def SLT64 : InstR<"slt" , 0b0110011, 0b0000000010, setlt , GR64, GR64>, Requires<[IsRV64]>;
def SLTU64: InstR<"sltu", 0b0110011, 0b0000000011, setult, GR64, GR64>, Requires<[IsRV64]>;
def XOR64 : InstR<"xor" , 0b0110011, 0b0000000100, xor   , GR64, GR64>, Requires<[IsRV64]>;
def SRL64 : InstR<"srl" , 0b0110011, 0b0000000101, srl   , GR64, GR64>, Requires<[IsRV64]>;
def SRA64 : InstR<"sra" , 0b0110011, 0b1000000101, sra   , GR64, GR64>, Requires<[IsRV64]>;
def OR64  : InstR<"or"  , 0b0110011, 0b0000000110, or    , GR64, GR64>, Requires<[IsRV64]>;
def AND64 : InstR<"and" , 0b0110011, 0b0000000111, and   , GR64, GR64>, Requires<[IsRV64]>;
//Integer arithmetic register-immediate
def ADDI64: InstI<"addi", 0b0010011, 0b000       , add, GR64, imm64sx12>, Requires<[IsRV64]>;
def XORI64: InstI<"xori", 0b0010011, 0b100       , xor, GR64, imm64sx12>, Requires<[IsRV64]>;
def ORI64 : InstI<"ori" , 0b0010011, 0b110       , or , GR64, imm64sx12>, Requires<[IsRV64]>;
def ANDI64: InstI<"andi", 0b0010011, 0b111       , and, GR64, imm64sx12>, Requires<[IsRV64]>;
//TODO: check 64bit shifr constraints
//TODO: enforce constraints here or up on level?
def SLLI64: InstI<"slli", 0b0010011, 0b001       , shl, GR64, imm64sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b000000; 
  //trap if $imm{5}!=0 TODO:how to do this?
}
def SRLI64: InstI<"srli", 0b0010011, 0b101       , srl, GR64, imm64sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b000000; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SRAI64: InstI<"srai", 0b0010011, 0b101       , sra, GR64, imm64sx12>, Requires<[IsRV64]> {
  let IMM{11-6} = 0b000001; 
  //trap if $src{5}!=0 TODO:how to do this?
}
def SLTI64 : InstI<"slti", 0b0010011, 0b010, setlt, GR64, imm64sx12>, Requires<[IsRV64]>;
def SLTIU64: InstI<"sltiu",0b0010011, 0b011, setult,GR64, imm64sx12>, Requires<[IsRV64]>;

//Synthesized set operators
defm : SeteqPats<GR64, SLTIU64, XOR64, SLTU64, zero_64>, Requires<[IsRV64]>;
defm : SetlePats<GR64, SLT64, SLTU64, XORI64>, Requires<[IsRV64]>;
defm : SetgtPats<GR64, SLT64, SLTU64>, Requires<[IsRV64]>;
defm : SetgePats<GR64, SLT64, SLTU64, XORI64>, Requires<[IsRV64]>;

//Unconditional Jumps
let isCall = 1 in {
  let Defs = [ra_64, v0_64, v1_64] in { //after call return addr and values are defined
  //let Defs = [ra_64] in { //after call return addr and values are defined
    def JAL64: InstJ<0b1101111, (outs), (ins pcrel64call:$target), "jal\t$target", 
          [(z_call pcrel64call:$target)]>, Requires<[IsRV64]>;
  }
}
let isCall = 1 in {
  //TODO: fix jalr and write test
  let Defs = [ra_64, v0_64, v1_64] in {
    def JALR64: InstRISCV<4, (outs), (ins jalrmem64:$target), "jalr\t$target", 
          [(z_call addr:$target)]>, Requires<[IsRV64]>{
            field bits<32> Inst;

            //bits<5> RD;
            bits<5> RS1;
            bits<12> IMM;

            let Inst{31-27} = 0b00001;
            let Inst{26-22} = RS1;
            let Inst{21-17} = IMM{11-7};
            let Inst{16-10} = IMM{6 -0};
            let Inst{9 - 7} = 0b000;
            let Inst{6 - 0} = 0b1101011;
          }
  }
}
 

//Conditional Branches
//TODO:refactor to class
let isBranch = 1, isTerminator = 1, isBarrier = 1 in {
  def BEQ64 : InstB<0b1100011, 0b000, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "beq\t$src1, $src2, $target", 
              [(brcond (i64 (seteq GR64:$src1,  GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BNE64 : InstB<0b1100011, 0b001, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "bne\t$src1, $src2, $target", 
              [(brcond (i64 (setne GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BLT64 : InstB<0b1100011, 0b100, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "blt\t$src1, $src2, $target", 
              [(brcond (i64 (setlt GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BGE64 : InstB<0b1100011, 0b101, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "bge\t$src1, $src2, $target", 
              [(brcond (i64 (setge GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BLTU64: InstB<0b1100011, 0b110, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "bltu\t$src1, $src2, $target", 
              [(brcond (i64 (setult GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;
  def BGEU64: InstB<0b1100011, 0b111, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "bgeu\t$src1, $src2, $target", 
              [(brcond (i64 (setuge GR64:$src1, GR64:$src2)), bb:$target)]>, Requires<[IsRV64]>;

//Synthesize remaining condition codes by reverseing operands
  def BGT64 : InstB<0b1100011, 0b100, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "blt\t$src2, $src1, $target", 
              [(brcond (i64 (setgt GR64:$src2, GR64:$src1)), bb:$target)]>, Requires<[IsRV64]>;
  def BGTU64: InstB<0b1100011, 0b110, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "bltu\t$src2, $src1, $target", 
              [(brcond (i64 (setugt GR64:$src2, GR64:$src1)), bb:$target)]>, Requires<[IsRV64]>;
  def BLE64 : InstB<0b1100011, 0b101, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "bge\t$src2, $src1, $target", 
              [(brcond (i64 (setle GR64:$src2, GR64:$src1)), bb:$target)]>, Requires<[IsRV64]>;
  def BLEU64: InstB<0b1100011, 0b111, (outs), 
              (ins brtarget:$target, GR64:$src2, GR64:$src1), 
              "bgeu\t$src2, $src1, $target", 
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
  def LW64 : InstLoad <"lw" , 0b0000011, 0b010, sextloadi32, GR64, mem64>, Requires<[IsRV64]>; 
  def LH64 : InstLoad <"lh" , 0b0000011, 0b001, sextloadi16, GR64, mem64>, Requires<[IsRV64]>; 
  def LHU64: InstLoad <"lhu", 0b0000011, 0b101, zextloadi16, GR64, mem64>, Requires<[IsRV64]>; 
  def LB64 : InstLoad <"lb" , 0b0000011, 0b000, sextloadi8, GR64, mem64>, Requires<[IsRV64]>; 
  def LBU64: InstLoad <"lbu", 0b0000011, 0b100, zextloadi8, GR64, mem64>, Requires<[IsRV64]>; 
}
//extended loads
def : Pat<(i64 (extloadi1  addr:$addr)), (LBU64 addr:$addr)>;
def : Pat<(extloadi1  addr:$addr), (LBU64 addr:$addr)>;
def : Pat<(i64 (extloadi8  addr:$addr)), (LBU64 addr:$addr)>;
def : Pat<(extloadi8  addr:$addr), (LBU64 addr:$addr)>;
def : Pat<(i64 (extloadi16 addr:$addr)), (LHU64 addr:$addr)>;
def : Pat<(extloadi16 addr:$addr), (LHU64 addr:$addr)>;
def : Pat<(i64 (extloadi32 addr:$addr)), (LWU   addr:$addr)>;
def : Pat<(extloadi32 addr:$addr), (LWU   addr:$addr)>;

let mayStore = 1 in {
  def SW64 : InstStore<"sw" , 0b0100011, 0b010, truncstorei32, GR64, mem64>, Requires<[IsRV64]>;
  def SH64 : InstStore<"sh" , 0b0100011, 0b001, truncstorei16, GR64, mem64>, Requires<[IsRV64]>; 
  def SB64 : InstStore<"sb" , 0b0100011, 0b000, truncstorei8 , GR64, mem64>, Requires<[IsRV64]>; 
}

//Upper Immediate
def LUI64: InstU<0b0110111, (outs GR64:$dst), (ins imm64sxu20:$imm),
                 "lui\t$dst, $imm",
                 [(set GR64:$dst, (shl imm64sx20:$imm, (i64 12)))]>;

def AUIPC64: InstU<0b0110111, (outs GR64:$dst), (ins pcimm64:$target),
                   "auipc\t$dst, $target",
                   [(set GR64:$dst, (z_pcrel_wrapper tglobaladdr:$target))]>;

//simple immediate loading
def : Pat<(i64 imm64sx12:$imm), (ORI64 zero_64, imm64sx12:$imm)>; 

//psuedo load low imm instruction to print operands better
def LLI64 : InstI<"addi", 0b0010011, 0b000       , add, GR64, imm64sxu12>;
def L32I : Pat<(i64 imm64sxu32:$imm), (LLI64 (LUI64 (HI20 imm64:$imm)), (LO12 imm64:$imm))>;

///64 bit immediate loading
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
def : Pat<(i64 imm64:$imm), (ADD64 
                        (LLI64 (LUI64 (HI20 (i64 (LO32 $imm)))), (LO12 (i64 (LO32 $imm)))), 
                        (SLL64 (i64 32), 
                        (LLI64 (LUI64 (HI20 (i64 (HI32 $imm)))), (LO12 (i64 (HI32 $imm))))))>;

//call
def : Pat<(z_call (i64 texternalsym:$in)), (JAL64 texternalsym:$in)>;
def : Pat<(z_call (i64 tglobaladdr:$in)), (JAL64 tglobaladdr:$in)>;
//global addr loading
def : Pat<(RISCVHi tglobaladdr:$in), (LUI64 tglobaladdr:$in)>;
def : Pat<(RISCVHi tblockaddress:$in), (LUI64 tblockaddress:$in)>;
def : Pat<(RISCVHi tjumptable:$in), (LUI64 tjumptable:$in)>;
def : Pat<(RISCVHi tconstpool:$in), (LUI64 tconstpool:$in)>;
def : Pat<(RISCVHi tglobaltlsaddr:$in), (LUI64 tglobaltlsaddr:$in)>;
def : Pat<(RISCVHi texternalsym:$in), (LUI64 texternalsym:$in)>;

def : Pat<(RISCVLo tglobaladdr:$in), (ADDI64 zero_64, tglobaladdr:$in)>;
def : Pat<(RISCVLo tblockaddress:$in), (ADDI64 zero_64, tblockaddress:$in)>;
def : Pat<(RISCVLo tjumptable:$in), (ADDI64 zero_64, tjumptable:$in)>;
def : Pat<(RISCVLo tconstpool:$in), (ADDI64 zero_64, tconstpool:$in)>;
def : Pat<(RISCVLo tglobaltlsaddr:$in),
          (ADDI64 zero_64, tglobaltlsaddr:$in)>;
def : Pat<(RISCVLo texternalsym:$in), (ADDI64 zero_64, texternalsym:$in)>;

def : Pat<(add GR64:$hi, (RISCVLo tglobaladdr:$lo)),
          (ADDI64 GR64:$hi, tglobaladdr:$lo)>;
def : Pat<(add GR64:$hi, (RISCVLo tblockaddress:$lo)),
          (ADDI64 GR64:$hi, tblockaddress:$lo)>;
def : Pat<(add GR64:$hi, (RISCVLo tjumptable:$lo)),
          (ADDI64 GR64:$hi, tjumptable:$lo)>;
def : Pat<(add GR64:$hi, (RISCVLo tconstpool:$lo)),
          (ADDI64 GR64:$hi, tconstpool:$lo)>;
def : Pat<(add GR64:$hi, (RISCVLo tglobaltlsaddr:$lo)),
          (ADDI64 GR64:$hi, tglobaltlsaddr:$lo)>;

//Fence
def FENCE64: InstRISCV<4, (outs), (ins fenceImm64:$pred, fenceImm64:$succ), "fence", 
      [(z_fence64 fenceImm64:$pred, fenceImm64:$succ)]>, Requires<[IsRV64]>{
        field bits<32> Inst;

        bits<4> pred;
        bits<4> succ;

        let Inst{31-28} = 0b0000;
        let Inst{27   } = pred{3};//PI;
        let Inst{26   } = pred{2};//PO;
        let Inst{25   } = pred{1};//PR;
        let Inst{24   } = pred{0};//PW;
        let Inst{23   } = succ{3};//SI;
        let Inst{22   } = succ{2};//SO;
        let Inst{21   } = succ{1};//SR;
        let Inst{20   } = succ{0};//SW;
        let Inst{19-15} = 0b00000;
        let Inst{14-12} = 0b000;
        let Inst{11- 7} = 0b00000;
        let Inst{6 - 0} = 0b0001111;
      }



//===----------------------------------------------------------------------===//
// Subtarget features
//===----------------------------------------------------------------------===//

include "RISCVInstrInfoRV64M.td"
//include "RISCVInstrInfoRV64F.td"
include "RISCVInstrInfoRV64A.td"
//include "RISCVInstrInfoRV64D.td"

