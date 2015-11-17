//===- RISCVRegisterInfo.td - RISCV register definitions ---*- tablegen -*-===//
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
  def sub_32       : SubRegIndex<32>;
  def sub_32even   : SubRegIndex<32>;
  def sub_32odd    : SubRegIndex<32>;
  def sub_64even   : SubRegIndex<64>;
  def sub_64odd    : SubRegIndex<64>;
  def sub_fp32even : SubRegIndex<32>;
  def sub_fp32odd  : SubRegIndex<32>;
  def sub_fp64even : SubRegIndex<64>;
  def sub_fp64odd  : SubRegIndex<64>;
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
def sp   : GPR32<2, "x2">, DwarfRegNum<[2]>;
def gp   : GPR32<3, "x3">, DwarfRegNum<[3]>;
def tp   : GPR32<4, "x4">, DwarfRegNum<[4]>;
def t0   : GPR32<5, "x5">, DwarfRegNum<[5]>;
def t1   : GPR32<6, "x6">, DwarfRegNum<[6]>;
def t2   : GPR32<7, "x7">, DwarfRegNum<[7]>;
def fp   : GPR32<8, "x8">, DwarfRegNum<[8]>;
def s0   : GPR32<8, "x8">, DwarfRegNum<[8]>{
  let Aliases = [fp];
}
def s1   : GPR32<9, "x9">, DwarfRegNum<[9]>;
//return values
def a0   : GPR32<10,"x10">, DwarfRegNum<[10]>;
def a1   : GPR32<11,"x11">, DwarfRegNum<[11]>;
//function arguments
def a2   : GPR32<12,"x12">, DwarfRegNum<[12]>;
def a3   : GPR32<13,"x13">, DwarfRegNum<[13]>;
def a4   : GPR32<14,"x14">, DwarfRegNum<[14]>;
def a5   : GPR32<15,"x15">, DwarfRegNum<[15]>;
def a6   : GPR32<16,"x16">, DwarfRegNum<[16]>;
def a7   : GPR32<17,"x17">, DwarfRegNum<[17]>;
//saved registers
def s2   : GPR32<18,"x18">, DwarfRegNum<[18]>;
def s3   : GPR32<19,"x19">, DwarfRegNum<[19]>;
def s4   : GPR32<20,"x20">, DwarfRegNum<[20]>;
def s5   : GPR32<21,"x21">, DwarfRegNum<[21]>;
def s6   : GPR32<22,"x22">, DwarfRegNum<[22]>;
def s7   : GPR32<23,"x23">, DwarfRegNum<[23]>;
def s8   : GPR32<24,"x24">, DwarfRegNum<[24]>;
def s9   : GPR32<25,"x25">, DwarfRegNum<[25]>;
def s10  : GPR32<26,"x26">, DwarfRegNum<[26]>;
def s11  : GPR32<27,"x27">, DwarfRegNum<[27]>;
//temp registers
def t3   : GPR32<28,"x28">, DwarfRegNum<[28]>;
def t4   : GPR32<29,"x29">, DwarfRegNum<[29]>;
def t5   : GPR32<30,"x30">, DwarfRegNum<[30]>;
def t6   : GPR32<31,"x31">, DwarfRegNum<[31]>;

//All regs are 32bit
defm GR32 : RISCVRegClass<"GR32", i32, 32, (add
  zero, ra, sp, gp, tp,
  t0, t1, t2,
  fp, s0, s1,
  a0, a1, a2, a3, a4, a5, a6, a7, 
  s2, s3, s4, s5, s6, s7, s8, s9, s10, s11,
  t3, t4, t5, t6), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairGPR64<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_32even, sub_32odd];
  let CoveredBySubRegs = 1;
}

def a0_p64 : PairGPR64<0, "x10", [a0, a1]>;
def a1_p64 : PairGPR64<1, "x12", [a2, a3]>;
def a2_p64 : PairGPR64<2, "x14", [a4, a5]>;
def a3_p64 : PairGPR64<3, "x16", [a6, a7]>;

defm PairGR64 : RISCVRegClass<"PairGR64", i64, 64, (add
  a0_p64, a1_p64, a2_p64, a3_p64), 1>;

//RV64 general purpose regs
class GPR64<bits<16> num, string n, list<Register> subregs> : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_32];
}

// General-purpose registers
//ABI Names
def zero_64 : GPR64<0, "x0",[zero]>, DwarfRegNum<[0]>;
def ra_64   : GPR64<1, "x1",[ra]  >, DwarfRegNum<[1]>;
def sp_64   : GPR64<2, "x2",[sp]  >, DwarfRegNum<[2]>;
def gp_64   : GPR64<3, "x3",[gp]  >, DwarfRegNum<[3]>;
def tp_64   : GPR64<4, "x4",[tp]  >, DwarfRegNum<[4]>;
def t0_64   : GPR64<5, "x5",[t0]  >, DwarfRegNum<[5]>;
def t1_64   : GPR64<6, "x6",[t1]  >, DwarfRegNum<[6]>;
def t2_64   : GPR64<7, "x7",[t2]  >, DwarfRegNum<[7]>;
def fp_64   : GPR64<8, "x8",[fp]  >, DwarfRegNum<[8]>;
def s0_64   : GPR64<8, "x8",[s0]  >, DwarfRegNum<[8]>{
  let Aliases = [fp_64];
}
def s1_64   : GPR64<9, "x9", [s1]  >, DwarfRegNum<[9]>;
//return values
def a0_64   : GPR64<10,"x10", [a0]  >, DwarfRegNum<[10]>;
def a1_64   : GPR64<11,"x11", [a1]  >, DwarfRegNum<[11]>;
//function arguments
def a2_64   : GPR64<12,"x12", [a2]  >, DwarfRegNum<[12]>;
def a3_64   : GPR64<13,"x13", [a3]  >, DwarfRegNum<[13]>;
def a4_64   : GPR64<14,"x14", [a4]  >, DwarfRegNum<[14]>;
def a5_64   : GPR64<15,"x15", [a5]  >, DwarfRegNum<[15]>;
def a6_64   : GPR64<16,"x16", [a6]  >, DwarfRegNum<[16]>;
def a7_64   : GPR64<17,"x17", [a7]  >, DwarfRegNum<[17]>;
//saved registers
def s2_64   : GPR64<18,"x18", [s2]  >, DwarfRegNum<[18]>;
def s3_64   : GPR64<19,"x19", [s3]  >, DwarfRegNum<[19]>;
def s4_64   : GPR64<20,"x20", [s4]  >, DwarfRegNum<[20]>;
def s5_64   : GPR64<21,"x21", [s5]  >, DwarfRegNum<[21]>;
def s6_64   : GPR64<22,"x22", [s6]  >, DwarfRegNum<[22]>;
def s7_64   : GPR64<23,"x23", [s7]  >, DwarfRegNum<[23]>;
def s8_64   : GPR64<24,"x24", [s8]  >, DwarfRegNum<[24]>;
def s9_64   : GPR64<25,"x25", [s9]  >, DwarfRegNum<[25]>;
def s10_64  : GPR64<26,"x26", [s10] >, DwarfRegNum<[26]>;
def s11_64  : GPR64<27,"x27", [s11] >, DwarfRegNum<[27]>;
//temp registers
def t3_64   : GPR64<28,"x28", [t3]  >, DwarfRegNum<[28]>;
def t4_64   : GPR64<29,"x29", [t4]  >, DwarfRegNum<[29]>;
def t5_64   : GPR64<30,"x30", [t5]  >, DwarfRegNum<[30]>;
def t6_64   : GPR64<31,"x31", [t6]  >, DwarfRegNum<[31]>;

//All regs are 32bit
defm GR64 : RISCVRegClass<"GR64", i64, 64, (add
  zero_64, ra_64, sp_64, gp_64, tp_64,
  t0_64, t1_64, t2_64,
  fp_64, s0_64, s1_64,
  a0_64, a1_64, a2_64, a3_64, a4_64, a5_64, a6_64, a7_64, 
  s2_64, s3_64, s4_64, s5_64, s6_64, s7_64, s8_64, s9_64, s10_64, s11_64,
  t3_64, t4_64, t5_64, t6_64), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairGPR128<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_64even, sub_64odd];
  let CoveredBySubRegs = 1;
}

def a0_p128 : PairGPR64<0, "x10", [a0_64, a1_64]>;
def a1_p128 : PairGPR64<1, "x12", [a2_64, a3_64]>;
def a2_p128 : PairGPR64<2, "x14", [a4_64, a5_64]>;
def a3_p128 : PairGPR64<3, "x16", [a6_64, a7_64]>;

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
//FP temporary registers
def ft0 : FPR32<0, "f0">, DwarfRegNum<[0]>;
def ft1 : FPR32<1, "f1">, DwarfRegNum<[1]>;
def ft2 : FPR32<2, "f2">, DwarfRegNum<[2]>;
def ft3 : FPR32<3, "f3">, DwarfRegNum<[3]>;
def ft4 : FPR32<4, "f4">, DwarfRegNum<[4]>;
def ft5 : FPR32<5, "f5">, DwarfRegNum<[5]>;
def ft6 : FPR32<6, "f6">, DwarfRegNum<[6]>;
def ft7 : FPR32<7, "f7">, DwarfRegNum<[7]>;

def fs0 : FPR32<8, "f8">, DwarfRegNum<[8]>;
def fs1 : FPR32<9, "f9">, DwarfRegNum<[9]>;
//FP arguments
def fa0 : FPR32<10,"f10">, DwarfRegNum<[10]>;
def fa1 : FPR32<11,"f11">, DwarfRegNum<[11]>;
def fa2 : FPR32<12,"f12">, DwarfRegNum<[12]>;
def fa3 : FPR32<13,"f13">, DwarfRegNum<[13]>;
def fa4 : FPR32<14,"f14">, DwarfRegNum<[14]>;
def fa5 : FPR32<15,"f15">, DwarfRegNum<[15]>;
def fa6 : FPR32<16,"f16">, DwarfRegNum<[16]>;
def fa7 : FPR32<17,"f17">, DwarfRegNum<[17]>;
//FP saved registers
def fs2  : FPR32<18,"f18">, DwarfRegNum<[18]>;
def fs3  : FPR32<19,"f19">, DwarfRegNum<[19]>;
def fs4  : FPR32<20,"f20">, DwarfRegNum<[20]>;
def fs5  : FPR32<21,"f21">, DwarfRegNum<[21]>;
def fs6  : FPR32<22,"f22">, DwarfRegNum<[22]>;
def fs7  : FPR32<23,"f23">, DwarfRegNum<[23]>;
def fs8  : FPR32<24,"f24">, DwarfRegNum<[24]>;
def fs9  : FPR32<25,"f25">, DwarfRegNum<[25]>;
def fs10 : FPR32<26,"f26">, DwarfRegNum<[26]>;
def fs11 : FPR32<27,"f27">, DwarfRegNum<[27]>;
//FP temp registers
def ft8 : FPR32<28,"f28">, DwarfRegNum<[28]>;
def ft9 : FPR32<29,"f29">, DwarfRegNum<[29]>;
def ft10: FPR32<30,"f30">, DwarfRegNum<[30]>;
def ft11: FPR32<31,"f31">, DwarfRegNum<[31]>;

//all fp regs are 32bit
defm FP32  : RISCVRegClass<"FP32", f32, 32, (add
  ft0, ft1, ft2, ft3, ft4, ft5, ft6, ft7,
  fs0, fs1, 
  fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7,
  fs2, fs3, fs4, fs5, fs6, fs7, fs8, fs9, fs10, fs11,
  ft8, ft9, ft10, ft11
  ), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairFPR64<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_fp32even, sub_fp32odd];
  let CoveredBySubRegs = 1;
}

def fa0_p64 : PairFPR64<0, "f10", [fa0, fa1]>;
def fa1_p64 : PairFPR64<1, "f12", [fa2, fa3]>;
def fa2_p64 : PairFPR64<2, "f14", [fa4, fa5]>;
def fa3_p64 : PairFPR64<3, "f16", [fa6, fa7]>;

defm PairFP64 : RISCVRegClass<"PairFP64", f64, 64, (add
  fa0_p64, fa1_p64, fa2_p64, fa3_p64), 1>;

// Lower 32 bits of one of the 16 64-bit floating-point registers
class FPR64<bits<16> num, string n, list<Register> subregs> : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_32];
}


// Floating-point registers
//ABI Names
//FP temporary registers
def ft0_64 : FPR64<0, "f0" , [ft0] >, DwarfRegNum<[0]>;
def ft1_64 : FPR64<1, "f1" , [ft1] >, DwarfRegNum<[1]>;
def ft2_64 : FPR64<2, "f2" , [ft2] >, DwarfRegNum<[2]>;
def ft3_64 : FPR64<3, "f3" , [ft3] >, DwarfRegNum<[3]>;
def ft4_64 : FPR64<4, "f4" , [ft4] >, DwarfRegNum<[4]>;
def ft5_64 : FPR64<5, "f5" , [ft5] >, DwarfRegNum<[5]>;
def ft6_64 : FPR64<6, "f6" , [ft6] >, DwarfRegNum<[6]>;
def ft7_64 : FPR64<7, "f7" , [ft7] >, DwarfRegNum<[7]>;

def fs0_64 : FPR64<8, "f8" , [fs0] >, DwarfRegNum<[8]>;
def fs1_64 : FPR64<9, "f9" , [fs1] >, DwarfRegNum<[9]>;
//FP arguments
def fa0_64 : FPR64<10,"f10", [fa0] >, DwarfRegNum<[10]>;
def fa1_64 : FPR64<11,"f11", [fa1] >, DwarfRegNum<[11]>;
def fa2_64 : FPR64<12,"f12", [fa2] >, DwarfRegNum<[12]>;
def fa3_64 : FPR64<13,"f13", [fa3] >, DwarfRegNum<[13]>;
def fa4_64 : FPR64<14,"f14", [fa4] >, DwarfRegNum<[14]>;
def fa5_64 : FPR64<15,"f15", [fa5] >, DwarfRegNum<[15]>;
def fa6_64 : FPR64<16,"f16", [fa6] >, DwarfRegNum<[16]>;
def fa7_64 : FPR64<17,"f17", [fa7] >, DwarfRegNum<[17]>;
//FP saved registers
def fs2_64 : FPR64<18,"f18", [fs2] >, DwarfRegNum<[18]>;
def fs3_64 : FPR64<19,"f19", [fs3] >, DwarfRegNum<[19]>;
def fs4_64 : FPR64<20,"f20", [fs4] >, DwarfRegNum<[20]>;
def fs5_64 : FPR64<21,"f21", [fs5] >, DwarfRegNum<[21]>;
def fs6_64 : FPR64<22,"f22", [fs6] >, DwarfRegNum<[22]>;
def fs7_64 : FPR64<23,"f23", [fs7] >, DwarfRegNum<[23]>;
def fs8_64 : FPR64<24,"f24", [fs8] >, DwarfRegNum<[24]>;
def fs9_64 : FPR64<25,"f25", [fs9] >, DwarfRegNum<[25]>;
def fs10_64: FPR64<26,"f26", [fs10] >, DwarfRegNum<[26]>;
def fs11_64: FPR64<27,"f27", [fs11] >, DwarfRegNum<[27]>;
//FP temp registers
def ft8_64 : FPR64<28,"f28", [ft8] >, DwarfRegNum<[28]>;
def ft9_64 : FPR64<29,"f29", [ft9] >, DwarfRegNum<[29]>;
def ft10_64: FPR64<30,"f30", [ft10] >, DwarfRegNum<[30]>;
def ft11_64: FPR64<31,"f31", [ft11] >, DwarfRegNum<[31]>;

//all fp regs are 32bit
defm FP64  : RISCVRegClass<"FP64", f64, 64, (add
  ft0_64, ft1_64, ft2_64, ft3_64, ft4_64, ft5_64, ft6_64, ft7_64,
  fs0_64, fs1_64, 
  fa0_64, fa1_64, fa2_64, fa3_64, fa4_64, fa5_64, fa6_64, fa7_64,
  fs2_64, fs3_64, fs4_64, fs5_64, fs6_64, fs7_64, fs8_64, fs9_64, fs10_64, fs11_64,
  ft8_64, ft9_64, ft10_64, ft11_64
  ), 1>;

//Pairs of int arg regs can be used to store double-pointer word args
class PairFPR128<bits<16> num, string n, list<Register> subregs>
  : RISCVRegWithSubRegs<n, subregs> {
  let HWEncoding = num;
  let SubRegIndices = [sub_fp64even, sub_fp64odd];
  let CoveredBySubRegs = 1;
}

def fa0_p128 : PairFPR128<0, "f10", [fa0_64, fa1_64]>;
def fa1_p128 : PairFPR128<1, "f12", [fa2_64, fa3_64]>;
def fa2_p128 : PairFPR128<2, "f14", [fa4_64, fa5_64]>;
def fa3_p128 : PairFPR128<3, "f16", [fa6_64, fa7_64]>;

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

class PCR64<bits<16> num, string n> : RISCVReg<n> {
  let HWEncoding = num;
}
//Scratch register for exception handlers
def sup0_64     : PCR64<0,"cr0">;
//Scratch register for exception handlers
def sup1_64     : PCR64<1,"cr1">;
//exception program counter
def epc_64      : PCR64<2, "cr2">;
//Bad virtual address
def badvaddr_64 : PCR64<3, "cr3">;
//Page table base register
def ptbr_64     : PCR64<4, "cr4">;
//Address space ID
def asid_64     : PCR64<5, "cr5">;
//Cycle counter for timer
def count_64    : PCR64<6, "cr6">;
//Timer compare value
def compare_64  : PCR64<7, "cr7">;
//Exception handler address
def evec_64     : PCR64<8, "cr8">;
//Cause of exception
def cause_64    : PCR64<9, "cr9">;
//status reg
def status_64   : PCR64<10, "cr10">;
//Hart ID
def hartid_64   : PCR64<11,"cr11">;
//Implementation ID
def impl_64     : PCR64<12,"cr12">;
//Flush address translation cache
def fatc_64     : PCR64<13, "cr13">;
//Send inter-processor interrupt
def send_ipi_64 : PCR64<14,"cr14">;
//Clear inter-processor interrupt
def clear_ipi_64: PCR64<15,"cr15">;
//Reserved 
def pr0_64      : PCR64<16,"cr16">;
def pr1_64      : PCR64<17,"cr17">;
def pr2_64      : PCR64<18,"cr18">;
def pr3_64      : PCR64<19,"cr19">;
def pr4_64      : PCR64<20,"cr20">;
def pr5_64      : PCR64<21,"cr21">;
def pr6_64      : PCR64<22,"cr22">;
def pr7_64      : PCR64<23,"cr23">;
def pr8_64      : PCR64<24,"cr24">;
def pr9_64      : PCR64<25,"cr25">;
def pr10_64     : PCR64<26,"cr26">;
def pr11_64     : PCR64<27,"cr27">;
def pr12_64     : PCR64<28,"cr28">;
def pr13_64     : PCR64<29,"cr29">;
//Test output register
def tohost_64   : PCR64<30,"cr30">;
//Test input register
def fromhost_64 : PCR64<31,"cr31">;

//PCRs (64-bit)
defm PCR64Reg : RISCVRegClass<"PCR64Reg", i64, 64, (add
  //read/write
  status_64, epc_64, evec_64, ptbr_64, asid_64, count_64, compare_64, 
  sup0_64, sup1_64, tohost_64, fromhost_64,
  //read only
  badvaddr_64, cause_64, hartid_64, impl_64, 
  //write only
  fatc_64,  send_ipi_64, clear_ipi_64), 0>;


//===----------------------------------------------------------------------===//
// Other registers
//===----------------------------------------------------------------------===//

// PC register
def PC : RISCVReg<"pc">;
defm PCReg : RISCVRegClass<"PCReg", i32, 32,(add PC), 0>;
//FP status register
def FCSR : RISCVReg<"fcsr">;
