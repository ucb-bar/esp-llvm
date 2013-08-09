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
//TODO: how to write pc to register
let isCall = 1 in {
  let Defs = [ra] in {
    def JAL: InstJ<0b1101111, (outs), (ins pcrel32call:$target), "JAL\t$target", 
          [(z_call pcrel32call:$target)]>;
  }
}
let isCall = 1 in {
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
            //[(br_cc seteq, GR32:$src1, GR32:$src2, bb:$target)]>;
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

//===----------------------------------------------------------------------===//
// Control flow instructions
//===----------------------------------------------------------------------===//

// A return instruction.  R1 is the condition-code mask (all 1s)
// and R2 is the target address, which is always stored in %r14.
let isReturn = 1, isTerminator = 1, isBarrier = 1, hasCtrlDep = 1,
    R1 = 15, R2 = 14, isCodeGenOnly = 1 in {
  def RET : InstRR<0x07, (outs), (ins), "br\t%r14", [(z_retflag)]>;
}

// Unconditional branches.  R1 is the condition-code mask (all 1s).
let isBranch = 1, isTerminator = 1, isBarrier = 1, R1 = 15 in {

  // An assembler extended mnemonic for BRC.  Use a separate instruction for
  // the asm parser, so that we don't relax Js to external symbols into JGs.
  let isAsmParserOnly = 1 in
    def AsmJ : InstRI<0xA74, (outs), (ins brtarget16:$dst), "j\t$dst", []>;

  // An assembler extended mnemonic for BRCL.  (The extension is "G"
  // rather than "L" because "JL" is "Jump if Less".)
  def JG : InstRIL<0xC04, (outs), (ins brtarget32:$dst),
                   "jg\t$dst", [(br bb:$dst)]>;
}

// Conditional branches.  It's easier for LLVM to handle these branches
// in their raw BRC/BRCL form, with the 4-bit condition-code mask being
// the first operand.  It seems friendlier to use mnemonic forms like
// JE and JLH when writing out the assembly though.
multiclass CondBranches<Operand imm, string short, string long> {
  let isBranch = 1, isTerminator = 1 in {
    def "" : InstRI<0xA74, (outs), (ins imm:$cond, brtarget16:$dst), short, []>;
    def L  : InstRIL<0xC04, (outs), (ins imm:$cond, brtarget32:$dst), long, []>;
  }
}
let isAsmParserOnly = 1 in
  defm AsmBRC : CondBranches<uimm8zx4, "brc\t$cond, $dst", "brcl\t$cond, $dst">;


// Define AsmParser mnemonics for each condition code.
multiclass CondExtendedMnemonic<bits<4> Cond, string name> {
  let R1 = Cond in {
    def "" : InstRI<0xA74, (outs), (ins brtarget16:$dst),
                    "j"##name##"\t$dst", []>;
    def L  : InstRIL<0xC04, (outs), (ins brtarget32:$dst),
                    "jg"##name##"\t$dst", []>;
  }
}
let isAsmParserOnly = 1 in {
  defm AsmJO   : CondExtendedMnemonic<1,  "o">;
  defm AsmJH   : CondExtendedMnemonic<2,  "h">;
  defm AsmJNLE : CondExtendedMnemonic<3,  "nle">;
  defm AsmJL   : CondExtendedMnemonic<4,  "l">;
  defm AsmJNHE : CondExtendedMnemonic<5,  "nhe">;
  defm AsmJLH  : CondExtendedMnemonic<6,  "lh">;
  defm AsmJNE  : CondExtendedMnemonic<7,  "ne">;
  defm AsmJNLH : CondExtendedMnemonic<9,  "nlh">;
  defm AsmJHE  : CondExtendedMnemonic<10, "he">;
  defm AsmJNL  : CondExtendedMnemonic<11, "nl">;
  defm AsmJLE  : CondExtendedMnemonic<12, "le">;
  defm AsmJNH  : CondExtendedMnemonic<13, "nh">;
  defm AsmJNO  : CondExtendedMnemonic<14, "no">;
}


//===----------------------------------------------------------------------===//
// Call instructions
//===----------------------------------------------------------------------===//

// The definitions here are for the call-clobbered registers.
let isCall = 1, 
  Defs = [ra, v0, v1, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13,
     fv0, fv1, fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7, fa8, fa9, fa10, fa11, fa12, fa13],
    R1 = 14, isCodeGenOnly = 1 in {
  def BRAS  : InstRI<0xA75, (outs), (ins pcrel16call:$dst, variable_ops),
                     "bras\t%r14, $dst", []>;
  def BRASL : InstRIL<0xC05, (outs), (ins pcrel32call:$dst, variable_ops),
                      "brasl\t%r14, $dst", [(z_call pcrel32call:$dst)]>;
}

// Define the general form of the call instructions for the asm parser.
// These instructions don't hard-code %r14 as the return address register.
let isAsmParserOnly = 1 in {
}

//===----------------------------------------------------------------------===//
// Move instructions
//===----------------------------------------------------------------------===//

// Register moves.
let neverHasSideEffects = 1 in {
  def LR  : UnaryRR <"lr",  0x18,   null_frag, GR32, GR32>;
}

// Immediate moves.
let neverHasSideEffects = 1, isAsCheapAsAMove = 1, isMoveImm = 1 in {
  // 16-bit sign-extended immediates.
  def LHI  : UnaryRI<"lhi",  0xA78, bitconvert, GR32, imm32sx16>;

}

// Register loads.
let canFoldAsLoad = 1, SimpleBDXLoad = 1 in {
  def  LRL : UnaryRILPC<"lrl", 0xC4D, aligned_load, GR32>;

}

// Register stores.
let SimpleBDXStore = 1 in {
  let isCodeGenOnly = 1 in {
    def  STRL32 : StoreRILPC<"strl", 0xC4F, aligned_store, GR32>;
  }

}


//===----------------------------------------------------------------------===//
// Sign extensions
//===----------------------------------------------------------------------===//

// 32-bit extensions from registers.
let neverHasSideEffects = 1 in {
  def LBR : UnaryRRE<"lbr", 0xB926, sext8,  GR32, GR32>;
  def LHR : UnaryRRE<"lhr", 0xB927, sext16, GR32, GR32>;
}



// 32-bit extensions from memory.
def  LHRL : UnaryRILPC<"lhrl", 0xC45, aligned_sextloadi16, GR32>;



//===----------------------------------------------------------------------===//
// Zero extensions
//===----------------------------------------------------------------------===//

// 32-bit extensions from registers.
let neverHasSideEffects = 1 in {
  def LLCR : UnaryRRE<"llcr", 0xB994, zext8,  GR32, GR32>;
  def LLHR : UnaryRRE<"llhr", 0xB995, zext16, GR32, GR32>;
}



// 32-bit extensions from memory.
def LLHRL : UnaryRILPC<"llhrl", 0xC42, aligned_zextloadi16, GR32>;


//===----------------------------------------------------------------------===//
// Truncations
//===----------------------------------------------------------------------===//


// Truncations of 32-bit registers to memory.
let isCodeGenOnly = 1 in {
  def  STHRL32 : StoreRILPC<"sthrl", 0xC47, aligned_truncstorei16, GR32>;
}

//===----------------------------------------------------------------------===//
// Byte swaps
//===----------------------------------------------------------------------===//

// Byte-swapping register moves.
let neverHasSideEffects = 1 in {
  def LRVR  : UnaryRRE<"lrvr",  0xB91F, bswap, GR32, GR32>;
}

//===----------------------------------------------------------------------===//
// Insertion
//===----------------------------------------------------------------------===//

// Insertions of a 16-bit immediate, leaving other bits unaffected.
// We don't have or_as_insert equivalents of these operations because
// OI is available instead.
let isCodeGenOnly = 1 in {
  def IILL32 : BinaryRI<"iill", 0xA53, insertll, GR32, imm32ll16>;
  def IILH32 : BinaryRI<"iilh", 0xA52, insertlh, GR32, imm32lh16>;
}

// ...likewise for 32-bit immediates.  For GR32s this is a general
// full-width move.  (We use IILF rather than something like LLILF
// for 32-bit moves because IILF leaves the upper 32 bits of the
// GR64 unchanged.)
let isCodeGenOnly = 1 in {
  def IILF32 : UnaryRIL<"iilf", 0xC09, bitconvert, GR32, uimm32>;
}

//===----------------------------------------------------------------------===//
// Addition
//===----------------------------------------------------------------------===//

// Plain addition.
  // Addition of a register.
  let isCommutable = 1 in {
    def AR  : BinaryRR <"ar",  0x1A,   add, GR32, GR32>;
  }

  // Addition of signed 16-bit immediates.
  def AHI  : BinaryRI<"ahi",  0xA7A, add, GR32, imm32sx16>;

  // Addition of signed 32-bit immediates.
  def AFI  : BinaryRIL<"afi",  0xC29, add, GR32, simm32>;

  // Addition of memory.

// Addition producing a carry.
  // Addition of a register.
  let isCommutable = 1 in {
    def ALR  : BinaryRR <"alr",  0x1E,   addc, GR32, GR32>;
  }

  // Addition of unsigned 32-bit immediates.
  def ALFI  : BinaryRIL<"alfi",  0xC2B, addc, GR32, uimm32>;

// Addition producing and using a carry.
  // Addition of a register.
  def ALCR  : BinaryRRE<"alcr",  0xB998, adde, GR32, GR32>;

//===----------------------------------------------------------------------===//
// Subtraction
//===----------------------------------------------------------------------===//

// Plain substraction.  Although immediate forms exist, we use the
// add-immediate instruction instead.
  // Subtraction of a register.
  def SR   : BinaryRR <"sr",   0x1B,   sub,       GR32, GR32>;

// Subtraction producing a carry.
  // Subtraction of a register.
  def SLR   : BinaryRR <"slr",   0x1F,   subc,      GR32, GR32>;

  // Subtraction of unsigned 32-bit immediates.  These don't match
  // subc because we prefer addc for constants.
  def SLFI  : BinaryRIL<"slfi",  0xC25, null_frag, GR32, uimm32>;

// Subtraction producing and using a carry.
  // Subtraction of a register.
  def SLBR  : BinaryRRE<"slbr",  0xB999, sube, GR32, GR32>;

//===----------------------------------------------------------------------===//
// AND
//===----------------------------------------------------------------------===//

  // ANDs of a register.
  let isCommutable = 1 in {
    def NR  : BinaryRR <"nr",  0x14,   and, GR32, GR32>;
  }

  // ANDs of a 16-bit immediate, leaving other bits unaffected.
  let isCodeGenOnly = 1 in {
    def NILL32 : BinaryRI<"nill", 0xA57, and, GR32, imm32ll16c>;
    def NILH32 : BinaryRI<"nilh", 0xA56, and, GR32, imm32lh16c>;
  }

  // ANDs of a 32-bit immediate, leaving other bits unaffected.

//===----------------------------------------------------------------------===//
// OR
//===----------------------------------------------------------------------===//

  // ORs of a 32-bit immediate, leaving other bits unaffected.
  let isCodeGenOnly = 1 in
    def OILF32 : BinaryRIL<"oilf", 0xC0D, or, GR32, uimm32>;

//===----------------------------------------------------------------------===//
// XOR
//===----------------------------------------------------------------------===//

  // XORs of a register.
  let isCommutable = 1 in {
    def XR  : BinaryRR <"xr",  0x17,   xor, GR32, GR32>;
  }

//===----------------------------------------------------------------------===//
// Multiplication
//===----------------------------------------------------------------------===//

// Multiplication of a register.
let isCommutable = 1 in {
  def MSR  : BinaryRRE<"msr",  0xB252, mul, GR32, GR32>;
}

// Multiplication of a signed 16-bit immediate.
def MHI  : BinaryRI<"mhi",  0xA7C, mul, GR32, imm32sx16>;

// Multiplication of a signed 32-bit immediate.
def MSFI  : BinaryRIL<"msfi",  0xC21, mul, GR32, simm32>;

//===----------------------------------------------------------------------===//
// Shifts
//===----------------------------------------------------------------------===//

// Rotate left.
let neverHasSideEffects = 1 in {
  def RLL  : ShiftRSY<"rll",  0xEB1D, rotl, GR32, shift20only>;
}

// Rotate second operand left and inserted selected bits into first operand.
// These can act like 32-bit operands provided that the constant start and
// end bits (operands 2 and 3) are in the range [32, 64)
  let isCodeGenOnly = 1 in
    def RISBG32 : RotateSelectRIEf<"risbg",  0xEC55, GR32, GR32>;

//===----------------------------------------------------------------------===//
// Comparison
//===----------------------------------------------------------------------===//

// Signed comparisons.
  // Comparison with a register.
  def CR   : CompareRR <"cr",   0x19,   z_cmp,     GR32, GR32>;

  // Comparison with a signed 16-bit immediate.
  def CHI  : CompareRI<"chi",  0xA7E, z_cmp, GR32, imm32sx16>;

  // Comparison with a signed 32-bit immediate.
  def CFI  : CompareRIL<"cfi",  0xC2D, z_cmp, GR32, simm32>;

  // Comparison with memory.
  def  CHRL  : CompareRILPC<"chrl",  0xC65, z_cmp, GR32, aligned_sextloadi16>;
  def  CRL   : CompareRILPC<"crl",   0xC6D, z_cmp, GR32, aligned_load>;

// Unsigned comparisons.
  // Comparison with a register.
  def CLR   : CompareRR <"clr",   0x15,   z_ucmp,    GR32, GR32>;

  // Comparison with a signed 32-bit immediate.
  def CLFI  : CompareRIL<"clfi",  0xC2F, z_ucmp, GR32, uimm32>;

  // Comparison with memory.
  def  CLHRL  : CompareRILPC<"clhrl",  0xC67, z_ucmp, GR32,
                             aligned_zextloadi16>;
  def  CLRL   : CompareRILPC<"clrl",   0xC6F, z_ucmp, GR32,
                             aligned_load>;

//===----------------------------------------------------------------------===//
// Miscellaneous Instructions.
//===----------------------------------------------------------------------===//

// Read a 32-bit access register into a GR32.  As with all GR32 operations,
// the upper 32 bits of the enclosing GR64 remain unchanged, which is useful
// when a 64-bit address is stored in a pair of access registers.
def EAR : InstRRE<0xB24F, (outs GR32:$dst), (ins access_reg:$src),
                  "ear\t$dst, $src",
                  [(set GR32:$dst, (z_extract_access access_reg:$src))]>;
