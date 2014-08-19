//==- RISCVRegisterInfo.td - RISCV register definitions -*- tablegen -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Class definitions.
//===----------------------------------------------------------------------===//

class RISCVReg<string n> : Register<n> {
  let Namespace = "RISCV";
}

class RISCVRegWithSubRegs<string n, list<Register> subregs>
  : RegisterWithSubRegs<n, subregs> {
  let Namespace = "RISCV";
}

//Subreg defs
let Namespace = "RISCV" in {
  def sub_32       : SubRegIndex;
  def sub_32even   : SubRegIndex;
  def sub_32odd    : SubRegIndex;
  def sub_64even   : SubRegIndex;
  def sub_64odd    : SubRegIndex;
  def sub_fp32even : SubRegIndex;
  def sub_fp32odd  : SubRegIndex;
  def sub_fp64even : SubRegIndex;
  def sub_fp64odd  : SubRegIndex;
}


// Define a register class that contains values of type TYPE and an
// associated operand called NAME.  SIZE is the size and alignment
// of the registers and REGLIST is the list of individual registers.
multiclass RISCVRegClass<string name, ValueType type, int size, dag regList, bit allocatable> {
  def AsmOperand : AsmOperandClass {
    let Name = name;
    let ParserMethod = "parse"##name;
    let RenderMethod = "addRegOperands";
  }
  def Bit : RegisterClass<"RISCV", [type], size, regList> {
    let Size = size;
    let isAllocatable = allocatable;
  }
  def "" : RegisterOperand<!cast<RegisterClass>(name##"Bit")> {
    let ParserMatchClass = !cast<AsmOperandClass>(name##"AsmOperand");
  }
}

//===----------------------------------------------------------------------===//
// General-purpose registers
//===----------------------------------------------------------------------===//

//RV32 general purpose regs
class GPR32<bits<16> num, string n> : RISCVReg<n> {
  let HWEncoding = num;
}

// General-purpose registers
//ABI Names
def zero : GPR32<0, "x0">, DwarfRegNum<[0]>;
def ra   : GPR32<1, "x1">, DwarfRegNum<[1]>;
def fp   : GPR32<2, "x2">, DwarfRegNum<[2]>;
//saved registers note:s0 is alias for fp
def s0   : GPR32<2, "x2">, DwarfRegNum<[2]>{
  let Aliases = [fp];
}
def s1   : GPR32<3, "x3">, DwarfRegNum<[3]>;
def s2   : GPR32<4, "x4">, DwarfRegNum<[4]>;
def s3   : GPR32<5, "x5">, DwarfRegNum<[5]>;
def s4   : GPR32<6, "x6">, DwarfRegNum<[6]>;
def s5   : GPR32<7, "x7">, DwarfRegNum<[7]>;
def s6   : GPR32<8, "x8">, DwarfRegNum<[8]>;
def s7   : GPR32<9, "x9">, DwarfRegNum<[9]>;
def s8   : GPR32<10,"x10">, DwarfRegNum<[10]>;
def s9   : GPR32<11,"x11">, DwarfRegNum<[11]>;
def s10  : GPR32<12,"x12">, DwarfRegNum<[12]>;
def s11  : GPR32<13,"x13">, DwarfRegNum<[13]>;

def sp   : GPR32<14,"x14">, DwarfRegNum<[14]>;
def tp   : GPR32<15,"x15">, DwarfRegNum<[15]>;
//return values
def v0   : GPR32<16,"x16">, DwarfRegNum<[16]>;
def v1   : GPR32<17,"x17">, DwarfRegNum<[17]>;
//function arguments
def a0   : GPR32<18,"x18">, DwarfRegNum<[18]>;
def a1   : GPR32<19,"x19">, DwarfRegNum<[19]>;
def a2   : GPR32<20,"x20">, DwarfRegNum<[20]>;
def a3   : GPR32<21,"x21">, DwarfRegNum<[21]>;
def a4   : GPR32<22,"x22">, DwarfRegNum<[22]>;
def a5   : GPR32<23,"x23">, DwarfRegNum<[23]>;
def a6   : GPR32<24,"x24">, DwarfRegNum<[24]>;
def a7   : GPR32<25,"x25">, DwarfRegNum<[25]>;
//temp registers
def t0   : GPR32<26,"x26">, DwarfRegNum<[26]>;
def t1   : GPR32<27,"x27">, DwarfRegNum<[27]>;
def t2   : GPR32<28,"x28">, DwarfRegNum<[28]>;
def t3   : GPR32<29,"x29">, DwarfRegNum<[29]>;
def t4   : GPR32<30,"x30">, DwarfRegNum<[30]>;
def gp   : GPR32<31,"x31">, DwarfRegNum<[31]>;

//All regs are 32bit
defm GR32 : RISCVRegClass<"GR32", i32, 32, (add
  zero, ra, fp,
  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11,
  sp, tp,
  v0, v1,
  a0, a1, a2, a3, a4, a5, a6, a7, 
  t0, t1, t2, t3, t4, 
  gp), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairGPR64<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_32even, sub_32odd];
  let CoveredBySubRegs = 1;
}

def a0_p64 : PairGPR64<0, "x18", [a0, a1]>;
def a1_p64 : PairGPR64<1, "x20", [a2, a3]>;
def a2_p64 : PairGPR64<2, "x22", [a4, a5]>;
def a3_p64 : PairGPR64<3, "x24", [a6, a7]>;

defm PairGR64 : RISCVRegClass<"PairGR64", i64, 64, (add
  a0_p64, a1_p64, a2_p64, a3_p64), 1>;

//RV64 general purpose regs
class GPR64<bits<16> num, string n, list<Register> subregs> : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_32];
}

// General-purpose registers
//ABI Names
def zero_64 : GPR64<0, "x0", [zero]>, DwarfRegNum<[0]>;
def ra_64   : GPR64<1, "x1", [ra]>, DwarfRegNum<[1]>;
def fp_64   : GPR64<2, "x2", [ra]>, DwarfRegNum<[2]>;
//saved registers note:s0 is alias for fp
def s0_64   : GPR64<2, "x2", [s0]>, DwarfRegNum<[2]>{
  let Aliases = [fp_64];
}
def s1_64   : GPR64<3, "x3", [s1]>, DwarfRegNum<[3]>;
def s2_64   : GPR64<4, "x4", [s2]>, DwarfRegNum<[4]>;
def s3_64   : GPR64<5, "x5", [s3]>, DwarfRegNum<[5]>;
def s4_64   : GPR64<6, "x6", [s4]>, DwarfRegNum<[6]>;
def s5_64   : GPR64<7, "x7", [s5]>, DwarfRegNum<[7]>;
def s6_64   : GPR64<8, "x8", [s6]>, DwarfRegNum<[8]>;
def s7_64   : GPR64<9, "x9", [s7]>, DwarfRegNum<[9]>;
def s8_64   : GPR64<10,"x10", [s8]>, DwarfRegNum<[10]>;
def s9_64   : GPR64<11,"x11", [s9]>, DwarfRegNum<[11]>;
def s10_64  : GPR64<12,"x12", [s10]>, DwarfRegNum<[12]>;
def s11_64  : GPR64<13,"x13", [s11]>, DwarfRegNum<[13]>;

def sp_64   : GPR64<14,"x14", [sp]>, DwarfRegNum<[14]>;
def tp_64   : GPR64<15,"x15", [tp]>, DwarfRegNum<[15]>;
//return value
def v0_64   : GPR64<16,"x16", [v0]>, DwarfRegNum<[16]>;
def v1_64   : GPR64<17,"x17", [v1]>, DwarfRegNum<[17]>;
//function arguments
def a0_64   : GPR64<18,"x18", [a0]>, DwarfRegNum<[18]>;
def a1_64   : GPR64<19,"x19", [a1]>, DwarfRegNum<[19]>;
def a2_64   : GPR64<20,"x20", [a2]>, DwarfRegNum<[20]>;
def a3_64   : GPR64<21,"x21", [a3]>, DwarfRegNum<[21]>;
def a4_64   : GPR64<22,"x22", [a4]>, DwarfRegNum<[22]>;
def a5_64   : GPR64<23,"x23", [a5]>, DwarfRegNum<[23]>;
def a6_64   : GPR64<24,"x24", [a6]>, DwarfRegNum<[24]>;
def a7_64   : GPR64<25,"x25", [a7]>, DwarfRegNum<[25]>;
//temp registers
def t0_64   : GPR64<26,"x26", [t0]>, DwarfRegNum<[26]>;
def t1_64   : GPR64<27,"x27", [t1]>, DwarfRegNum<[27]>;
def t2_64   : GPR64<28,"x28", [t2]>, DwarfRegNum<[28]>;
def t3_64   : GPR64<29,"x29", [t3]>, DwarfRegNum<[29]>;
def t4_64   : GPR64<30,"x30", [t4]>, DwarfRegNum<[30]>;
def gp_64   : GPR64<31,"x31", [gp]>, DwarfRegNum<[31]>;

//All regs are 32bit
defm GR64 : RISCVRegClass<"GR64", i64, 64, (add
  zero_64, ra_64, fp_64,
  s0_64, s1_64, s2_64, s3_64, s4_64, s5_64, s6_64, s7_64, s8_64, s9_64, s10_64, s11_64,
  sp_64, tp_64,
  v0_64, v1_64,
  a0_64, a1_64, a2_64, a3_64, a4_64, a5_64, a6_64, a7_64, 
  t0_64, t1_64, t2_64, t3_64, t4_64, 
  gp_64), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairGPR128<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_64even, sub_64odd];
  let CoveredBySubRegs = 1;
}

def a0_p128 : PairGPR64<0, "x18", [a0_64, a1_64]>;
def a1_p128 : PairGPR64<1, "x20", [a2_64, a3_64]>;
def a2_p128 : PairGPR64<2, "x22", [a4_64, a5_64]>;
def a3_p128 : PairGPR64<3, "x24", [a6_64, a7_64]>;

defm PairGR128 : RISCVRegClass<"PairGR128", i128, 128, (add
  a0_p128, a1_p128, a2_p128, a3_p128), 1>;

//===----------------------------------------------------------------------===//
// Floating-point registers
//===----------------------------------------------------------------------===//

// Lower 32 bits of one of the 16 64-bit floating-point registers
class FPR32<bits<16> num, string n> : RISCVReg<n> {
  let HWEncoding = num;
}


// Floating-point registers
//ABI Names
//FP saved registers
def fs0 : FPR32<0, "f0">, DwarfRegNum<[0]>;
def fs1 : FPR32<1, "f1">, DwarfRegNum<[1]>;
def fs2 : FPR32<2, "f2">, DwarfRegNum<[2]>;
def fs3 : FPR32<3, "f3">, DwarfRegNum<[3]>;
def fs4 : FPR32<4, "f4">, DwarfRegNum<[4]>;
def fs5 : FPR32<5, "f5">, DwarfRegNum<[5]>;
def fs6 : FPR32<6, "f6">, DwarfRegNum<[6]>;
def fs7 : FPR32<7, "f7">, DwarfRegNum<[7]>;
def fs8 : FPR32<8, "f8">, DwarfRegNum<[8]>;
def fs9 : FPR32<9, "f9">, DwarfRegNum<[9]>;
def fs10: FPR32<10,"f10">, DwarfRegNum<[10]>;
def fs11: FPR32<11,"f11">, DwarfRegNum<[11]>;
def fs12: FPR32<12,"f12">, DwarfRegNum<[11]>;
def fs13: FPR32<13,"f13">, DwarfRegNum<[12]>;
def fs14: FPR32<14,"f14">, DwarfRegNum<[13]>;
def fs15: FPR32<15,"f15">, DwarfRegNum<[15]>;
//FP return values
def fv0 : FPR32<16,"f16">, DwarfRegNum<[16]>;
def fv1 : FPR32<17,"f17">, DwarfRegNum<[17]>;
//FP arguments
def fa0 : FPR32<18,"f18">, DwarfRegNum<[18]>;
def fa1 : FPR32<19,"f19">, DwarfRegNum<[19]>;
def fa2 : FPR32<20,"f20">, DwarfRegNum<[20]>;
def fa3 : FPR32<21,"f21">, DwarfRegNum<[21]>;
def fa4 : FPR32<22,"f22">, DwarfRegNum<[22]>;
def fa5 : FPR32<23,"f23">, DwarfRegNum<[23]>;
def fa6 : FPR32<24,"f24">, DwarfRegNum<[24]>;
def fa7 : FPR32<25,"f25">, DwarfRegNum<[25]>;
//FP temp registers
def ft0 : FPR32<26,"f26">, DwarfRegNum<[26]>;
def ft1 : FPR32<27,"f27">, DwarfRegNum<[27]>;
def ft2 : FPR32<28,"f28">, DwarfRegNum<[28]>;
def ft3 : FPR32<29,"f29">, DwarfRegNum<[29]>;
def ft4 : FPR32<30,"f30">, DwarfRegNum<[30]>;
def ft5 : FPR32<31,"f31">, DwarfRegNum<[31]>;

//all fp regs are 32bit
defm FP32  : RISCVRegClass<"FP32", f32, 32, (add
  fs0, fs1, fs2, fs3, fs4, fs5, fs6, fs7, fs8, fs9, fs10, fs11, fs12, fs13, fs14, fs15,
  fv0, fv1,
  fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7,
  ft0, ft1, ft2, ft3, ft4, ft5), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairFPR64<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_fp32even, sub_fp32odd];
  let CoveredBySubRegs = 1;
}

def fa0_p64 : PairFPR64<0, "f18", [fa0, fa1]>;
def fa1_p64 : PairFPR64<1, "f20", [fa2, fa3]>;
def fa2_p64 : PairFPR64<2, "f22", [fa4, fa5]>;
def fa3_p64 : PairFPR64<3, "f24", [fa6, fa7]>;
def fv0_p64 : PairFPR64<4, "f16", [fv0, fv1]>;

defm PairFP64 : RISCVRegClass<"PairFP64", f64, 64, (add
  fa0_p64, fa1_p64, fa2_p64, fa3_p64, fv0_p64), 1>;

// Lower 32 bits of one of the 16 64-bit floating-point registers
class FPR64<bits<16> num, string n, list<Register> subregs> : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_32];
}


// Floating-point registers
//ABI Names
//FP saved registers
def fs0_64 : FPR64<0, "f0", [fs0]>, DwarfRegNum<[0]>;
def fs1_64 : FPR64<1, "f1", [fs1]>, DwarfRegNum<[1]>;
def fs2_64 : FPR64<2, "f2", [fs2]>, DwarfRegNum<[2]>;
def fs3_64 : FPR64<3, "f3", [fs3]>, DwarfRegNum<[3]>;
def fs4_64 : FPR64<4, "f4", [fs4]>, DwarfRegNum<[4]>;
def fs5_64 : FPR64<5, "f5", [fs5]>, DwarfRegNum<[5]>;
def fs6_64 : FPR64<6, "f6", [fs6]>, DwarfRegNum<[6]>;
def fs7_64 : FPR64<7, "f7", [fs7]>, DwarfRegNum<[7]>;
def fs8_64 : FPR64<8, "f8", [fs8]>, DwarfRegNum<[8]>;
def fs9_64 : FPR64<9, "f9", [fs9]>, DwarfRegNum<[9]>;
def fs10_64: FPR64<10,"f10", [fs10]>, DwarfRegNum<[10]>;
def fs11_64: FPR64<11,"f11", [fs11]>, DwarfRegNum<[11]>;
def fs12_64: FPR64<12,"f12", [fs12]>, DwarfRegNum<[11]>;
def fs13_64: FPR64<13,"f13", [fs13]>, DwarfRegNum<[12]>;
def fs14_64: FPR64<14,"f14", [fs14]>, DwarfRegNum<[13]>;
def fs15_64: FPR64<15,"f15", [fs15]>, DwarfRegNum<[15]>;
//FP return values
def fv0_64 : FPR64<16,"f16", [fv0]>, DwarfRegNum<[16]>;
def fv1_64 : FPR64<17,"f17", [fv1]>, DwarfRegNum<[17]>;
//FP arguments
def fa0_64 : FPR64<18,"f18", [fa0]>, DwarfRegNum<[18]>;
def fa1_64 : FPR64<19,"f19", [fa1]>, DwarfRegNum<[19]>;
def fa2_64 : FPR64<20,"f20", [fa2]>, DwarfRegNum<[20]>;
def fa3_64 : FPR64<21,"f21", [fa3]>, DwarfRegNum<[21]>;
def fa4_64 : FPR64<22,"f22", [fa4]>, DwarfRegNum<[22]>;
def fa5_64 : FPR64<23,"f23", [fa5]>, DwarfRegNum<[23]>;
def fa6_64 : FPR64<24,"f24", [fa6]>, DwarfRegNum<[24]>;
def fa7_64 : FPR64<25,"f25", [fa7]>, DwarfRegNum<[25]>;
//FP temp registers
def ft0_64 : FPR64<26,"f26", [ft0]>, DwarfRegNum<[26]>;
def ft1_64 : FPR64<27,"f27", [ft1]>, DwarfRegNum<[27]>;
def ft2_64 : FPR64<28,"f28", [ft2]>, DwarfRegNum<[28]>;
def ft3_64 : FPR64<29,"f29", [ft3]>, DwarfRegNum<[29]>;
def ft4_64 : FPR64<30,"f30", [ft4]>, DwarfRegNum<[30]>;
def ft5_64 : FPR64<31,"f31", [ft5]>, DwarfRegNum<[31]>;

//all fp regs are 32bit
defm FP64  : RISCVRegClass<"FP64", f64, 64, (add
  fs0_64, fs1_64, fs2_64, fs3_64, fs4_64, fs5_64, fs6_64, fs7_64, fs8_64, fs9_64, fs10_64, fs11_64, fs12_64, fs13_64, fs14_64, fs15_64,
  fv0_64, fv1_64,
  fa0_64, fa1_64, fa2_64, fa3_64, fa4_64, fa5_64, fa6_64, fa7_64,
  ft0_64, ft1_64, ft2_64, ft3_64, ft4_64, ft5_64), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairFPR128<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_fp64even, sub_fp64odd];
  let CoveredBySubRegs = 1;
}

def fa0_p128 : PairFPR128<0, "f18", [fa0_64, fa1_64]>;
def fa1_p128 : PairFPR128<1, "f20", [fa2_64, fa3_64]>;
def fa2_p128 : PairFPR128<2, "f22", [fa4_64, fa5_64]>;
def fa3_p128 : PairFPR128<3, "f24", [fa6_64, fa7_64]>;

defm PairFP128 : RISCVRegClass<"PairFP128", f128, 128, (add
  fa0_p128, fa1_p128, fa2_p128, fa3_p128), 1>;

//===----------------------------------------------------------------------===//
// PCR registers (supervisor)
//===----------------------------------------------------------------------===//
class PCR<bits<16> num, string n> : RISCVReg<n> {
  let HWEncoding = num;
}
//Scratch register for exception handlers
def sup0     : PCR<0,"cr0">;
//Scratch register for exception handlers
def sup1     : PCR<1,"cr1">;
//exception program counter
def epc      : PCR<2, "cr2">;
//Bad virtual address
def badvaddr : PCR<3, "cr3">;
//Page table base register
def ptbr     : PCR<4, "cr4">;
//Address space ID
def asid     : PCR<5, "cr5">;
//Cycle counter for timer
def count    : PCR<6, "cr6">;
//Timer compare value
def compare  : PCR<7, "cr7">;
//Exception handler address
def evec     : PCR<8, "cr8">;
//Cause of exception
def cause    : PCR<9, "cr9">;
//status reg
def status   : PCR<10, "cr10">;
//Hart ID
def hartid   : PCR<11,"cr11">;
//Implementation ID
def impl     : PCR<12,"cr12">;
//Flush address translation cache
def fatc     : PCR<13, "cr13">;
//Send inter-processor interrupt
def send_ipi : PCR<14,"cr14">;
//Clear inter-processor interrupt
def clear_ipi: PCR<15,"cr15">;
//Reserved 
def pr0      : PCR<16,"cr16">;
def pr1      : PCR<17,"cr17">;
def pr2      : PCR<18,"cr18">;
def pr3      : PCR<19,"cr19">;
def pr4      : PCR<20,"cr20">;
def pr5      : PCR<21,"cr21">;
def pr6      : PCR<22,"cr22">;
def pr7      : PCR<23,"cr23">;
def pr8      : PCR<24,"cr24">;
def pr9      : PCR<25,"cr25">;
def pr10     : PCR<26,"cr26">;
def pr11     : PCR<27,"cr27">;
def pr12     : PCR<28,"cr28">;
def pr13     : PCR<29,"cr29">;
//Test output register
def tohost   : PCR<30,"cr30">;
//Test input register
def fromhost : PCR<31,"cr31">;

//PCRs 
defm PCRReg : RISCVRegClass<"PCRReg", i32, 32, (add
  //read/write
  status, epc, evec, ptbr, asid, count, compare, sup0, sup1, tohost, fromhost,
  //read only
  badvaddr, cause, hartid, impl, 
  //write only
  fatc,  send_ipi, clear_ipi), 0>;


//===----------------------------------------------------------------------===//
// Other registers
//===----------------------------------------------------------------------===//

// PC register
def PC : RISCVReg<"pc">;
defm PCReg : RISCVRegClass<"PCReg", i32, 32,(add PC), 0>;
//FP status register
def FCSR : RISCVReg<"fcsr">;
