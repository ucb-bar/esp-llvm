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


// Define a register class that contains values of type TYPE and an
// associated operand called NAME.  SIZE is the size and alignment
// of the registers and REGLIST is the list of individual registers.
multiclass RISCVRegClass<string name, ValueType type, int size, dag regList> {
  def AsmOperand : AsmOperandClass {
    let Name = name;
    let ParserMethod = "parse"##name;
    let RenderMethod = "addRegOperands";
  }
  def Bit : RegisterClass<"RISCV", [type], size, regList> {
    let Size = size;
  }
  def "" : RegisterOperand<!cast<RegisterClass>(name##"Bit")> {
    let ParserMatchClass = !cast<AsmOperandClass>(name##"AsmOperand");
  }
}

//===----------------------------------------------------------------------===//
// General-purpose registers
//===----------------------------------------------------------------------===//

// Lower 32 bits of one of the 16 64-bit general-purpose registers
class GPR32<bits<16> num, string n> : RISCVReg<n> {
  let HWEncoding = num;
}

// General-purpose registers
foreach I = 0-31 in {
  def X#I : GPR32<I, "x"#I>;
}

//ABI Names
//TODO: not the way to do this: but would be a nice thing to have
/*
def zero : GPR32<0, "x0">;
def ra   : GPR32<1, "x1">;
def fp   : GPR32<2, "x2">;
//saved registers
def s0   : GPR32<2, "x2">;
def s1   : GPR32<3, "x3">;
def s2   : GPR32<4, "x4">;
def s3   : GPR32<5, "x5">;
def s4   : GPR32<6, "x6">;
def s5   : GPR32<7, "x7">;
def s6   : GPR32<8, "x8">;
def s7   : GPR32<9, "x9">;
def s8   : GPR32<10,"x10">;
def s9   : GPR32<11,"x11">;
def s10  : GPR32<12,"x12">;
def s11  : GPR32<13,"x13">;

def sp   : GPR32<14,"x14">;
def tp   : GPR32<15,"x15">;
//return values
def v0   : GPR32<16,"x16">;
def v1   : GPR32<17,"x17">;
//function arguments
def a0   : GPR32<18,"x18">;
def a1   : GPR32<19,"x19">;
def a2   : GPR32<20,"x20">;
def a3   : GPR32<21,"x21">;
def a4   : GPR32<22,"x22">;
def a5   : GPR32<23,"x23">;
def a6   : GPR32<24,"x24">;
def a7   : GPR32<25,"x25">;
def a8   : GPR32<26,"x26">;
def a9   : GPR32<27,"x27">;
def a10  : GPR32<28,"x28">;
def a11  : GPR32<29,"x29">;
def a12  : GPR32<30,"x30">;
def a13  : GPR32<31,"x31">;
*/

/// Allocate the callee-saved R6-R13 backwards. That way they can be saved
/// together with R14 and R15 in one prolog instruction.

//All regs are 32bit
defm GR32 : RISCVRegClass<"GR32", i32, 32, (sequence "X%u",  0, 31)>;

// Base and index registers.  Everything except R0, which in an address
// context evaluates as 0.
defm ADDR32 : RISCVRegClass<"ADDR32", i32, 32, (sub GR32Bit, X0)>;

//===----------------------------------------------------------------------===//
// Floating-point registers
//===----------------------------------------------------------------------===//

// Lower 32 bits of one of the 16 64-bit floating-point registers
class FPR32<bits<16> num, string n> : RISCVReg<n> {
  let HWEncoding = num;
}


// Floating-point registers
foreach I = 0-31 in {
  def F#I : FPR32<I, "f"#I>;
}

//ABI Names
//TODO: not the way to do this: but would be nice to have
/*
//FP saved registers
def fs0 : FPR32<0, "f0">;
def fs1 : FPR32<1, "f1">;
def fs2 : FPR32<2, "f2">;
def fs3 : FPR32<3, "f3">;
def fs4 : FPR32<4, "f4">;
def fs5 : FPR32<5, "f5">;
def fs6 : FPR32<6, "f6">;
def fs7 : FPR32<7, "f7">;
def fs8 : FPR32<8, "f8">;
def fs9 : FPR32<9, "f9">;
def fs10: FPR32<10,"f10">;
def fs11: FPR32<11,"f11">;
def fs12: FPR32<12,"f12">;
def fs13: FPR32<13,"f13">;
def fs14: FPR32<14,"f14">;
def fs15: FPR32<15,"f15">;
//FP return values
def fv0 : FPR32<16,"f16">;
def fv1 : FPR32<17,"f17">;
//FP arguments
def fa0 : FPR32<18,"f18">;
def fa1 : FPR32<19,"f19">;
def fa2 : FPR32<20,"f20">;
def fa3 : FPR32<21,"f21">;
def fa4 : FPR32<22,"f22">;
def fa5 : FPR32<23,"f23">;
def fa6 : FPR32<24,"f24">;
def fa7 : FPR32<25,"f25">;
def fa8 : FPR32<26,"f26">;
def fa9 : FPR32<27,"f27">;
def fa10 : FPR32<28,"f28">;
def fa11 : FPR32<29,"f29">;
def fa12 : FPR32<30,"f30">;
def fa13 : FPR32<31,"f31">;
*/

//all fp regs are 32bit
defm FP32  : RISCVRegClass<"FP32", f32, 32, (sequence "F%u", 0, 31)>;

//===----------------------------------------------------------------------===//
// Other registers
//===----------------------------------------------------------------------===//

// PC register
def PC : RISCVReg<"pc">;
defm PCReg : RISCVRegClass<"PCReg", i32, 32,(add PC)>;
//FP status register
def FSR : RISCVReg<"fsr">;
