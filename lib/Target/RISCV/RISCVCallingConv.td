//=- RISCVCallingConv.td - Calling conventions for RISCV -*- tablegen -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// This describes the calling conventions for the RISCV ABI.
//===----------------------------------------------------------------------===//

class CCIfExtend<CCAction A>
  : CCIf<"ArgFlags.isSExt() || ArgFlags.isZExt()", A>;

/// CCIfSubtarget - Match if the current subtarget has a feature F.
class CCIfSubtarget<string F, CCAction A>:
  CCIf<!strconcat("State.getTarget().getSubtarget<RISCVSubtarget>().", F), A>;

//===----------------------------------------------------------------------===//
// SVR4 return value calling convention
//===----------------------------------------------------------------------===//
def RetCC_RISCV32 : CallingConv<[

  // ABI-compliant code returns 64-bit integers in R2.  Make the other
  // call-clobbered argument registers available for code that doesn't
  // care about the ABI.  (R6 is an argument register too, but is
  // call-saved and therefore not suitable for return values.)
  CCIfType<[i32], CCAssignToReg<[v0, v1]>>,

  // ABI-complaint code returns float and double in F0.  Make the
  // other floating-point argument registers available for code that
  // doesn't care about the ABI.  All floating-point argument registers
  // are call-clobbered, so we can use all of them here.
  CCIfType<[f32], CCIfSubtarget<"hasF()", CCAssignToReg<[fv0, fv1]>>>,
  CCIfType<[f32], CCIfSubtarget<"hasD()", CCPromoteToType<f64>>>,
  CCIfType<[f64], CCIfSubtarget<"hasD()", CCAssignToReg<[fv0_64, fv1_64]>>>,
  CCIfType<[f64], CCIfSubtarget<"hasF()", CCAssignToReg<[fv0_p64]>>>,

  CCIfType<[f32], CCAssignToReg<[v0, v1]>>
]>;

//===----------------------------------------------------------------------===//
// SVR4 argument calling conventions
//===----------------------------------------------------------------------===//
//TODO:this is a very simple version of the RISCV calling convention just to start with
def CC_RISCV32 : CallingConv<[
  //Always assign the sret pointer to the first arg reg
  CCIfSRet<CCAssignToReg<[a0]>>,
  //Promote small int types to i32
  CCIfType<[i8,i16], CCPromoteToType<i32>>,

  // The first 14 integer arguments are passed in a0-a13. 
  CCIfType<[i32], CCAssignToRegWithShadow<
                   [a0,   a1,  a2,  a3,  a4,  a5,  a6,  a7],
                   [fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7]>>,

  //Single precision floating point
  CCIfType<[f32], CCIfSubtarget<"hasF()", CCAssignToRegWithShadow<
                     [fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7],
                     [a0 ,  a1,  a2,  a3,  a4,  a5,  a6,  a7]>>>,
  //double precision floating point
  CCIfType<[f32, f64], CCIfSubtarget<"hasD()", CCAssignToRegWithShadow<
        [fa0_64, fa1_64, fa2_64, fa3_64, fa4_64, fa5_64, fa6_64, fa7_64],
        [ a0,     a1,     a2,     a3,     a4,     a5,     a6,     a7   ]>>>,

  // Other arguments are passed in 8-byte-aligned 8-byte stack slots.
  CCIfType<[i32, i64, f32, f64], CCAssignToStack<8, 8>>
]>;
//Var args are all passed in integer regs
def CC_RISCV32_VAR : CallingConv<[
  //Always assign the sret pointer to the first arg reg
  CCIfSRet<CCAssignToReg<[a0]>>,
  //Promote small int types to i32
  CCIfType<[i8,i16], CCPromoteToType<i32>>,

  // The first 8 arguments are passed in a0-a7.
  CCIfType<[i32,f32], CCAssignToRegWithShadow<
                   [a0,   a1,  a2,  a3,  a4,  a5,  a6,  a7],
                   [fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7]>>,

  // Other arguments are passed in 8-byte-aligned 8-byte stack slots.
  CCIfType<[i32, i64, f32, f64], CCAssignToStack<8, 8>>
]>;

def RetCC_RISCV64 : CallingConv<[
  CCIfType<[i8,i16], CCPromoteToType<i32>>,

  // ABI-compliant code returns 64-bit integers in R2.  Make the other
  // call-clobbered argument registers available for code that doesn't
  // care about the ABI.  (R6 is an argument register too, but is
  // call-saved and therefore not suitable for return values.)
  CCIfType<[i32], CCAssignToReg<[v0, v1]>>,
  CCIfType<[i64], CCAssignToReg<[v0_64, v1_64]>>,

  // ABI-complaint code returns float and double in F0.  Make the
  // other floating-point argument registers available for code that
  // doesn't care about the ABI.  All floating-point argument registers
  // are call-clobbered, so we can use all of them here.
  CCIfType<[f32], CCIfSubtarget<"hasF()", CCAssignToReg<[fv0, fv1]>>>,
  CCIfType<[f32], CCIfSubtarget<"hasD()", CCPromoteToType<f64>>>,
  CCIfType<[f64], CCIfSubtarget<"hasD()", CCAssignToReg<[fv0_64, fv1_64]>>>,

  CCIfType<[f32], CCPromoteToType<f64>>,
  CCIfType<[f64], CCAssignToReg<[v0_64, v1_64]>>

]>;

//===----------------------------------------------------------------------===//
// RISCV64 argument calling conventions
//===----------------------------------------------------------------------===//
//TODO:this is a very simple version of the RISCV calling convention just to start with
def CC_RISCV64 : CallingConv<[
  //Always assign the sret pointer to the first arg reg
  CCIfSRet<CCAssignToReg<[a0_64]>>,
  //Promote small int types to i64
  CCIfType<[i8, i16], CCPromoteToType<i32>>,

  // The first 14 integer arguments are passed in a0-a13. 
  CCIfType<[i32], CCAssignToRegWithShadow<
      [ a0, a1, a2, a3, a4, a5, a6, a7],
      [fa0,fa1,fa2,fa3,fa4,fa5,fa6,fa7]>>,
  CCIfType<[i64], CCAssignToRegWithShadow<
      [ a0_64, a1_64, a2_64, a3_64, a4_64, a5_64, a6_64, a7_64],
      [fa0_64,fa1_64,fa2_64,fa3_64,fa4_64,fa5_64,fa6_64,fa7_64]>>,

  //Single precision floating point
  CCIfType<[f32], CCIfSubtarget<"hasF()", CCAssignToRegWithShadow<
      [fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7],
      [ a0,  a1,  a2,  a3,  a4,  a5,  a6,  a7]>>>,
  //double precision floating point
  CCIfType<[f32, f64], CCIfSubtarget<"hasD()", CCAssignToRegWithShadow<
      [fa0_64, fa1_64, fa2_64, fa3_64, fa4_64, fa5_64, fa6_64, fa7_64],
      [ a0_64,  a1_64,  a2_64,  a3_64,  a4_64,  a5_64,  a6_64,  a7_64]>>>,

  // Other arguments are passed in 8-byte-aligned 8-byte stack slots.
  CCIfType<[i32, i64, f32, f64], CCAssignToStack<8, 8>>
]>;

def CC_RISCV64_VAR : CallingConv<[
  //Always assign the sret pointer to the first arg reg
  CCIfSRet<CCAssignToReg<[a0_64]>>,
  //Promote small int types to i64
  CCIfType<[i8, i16], CCPromoteToType<i32>>,

  // The first 14 integer arguments are passed in a0-a13. 
  CCIfType<[i32,f32], CCAssignToRegWithShadow<
      [ a0, a1, a2, a3, a4, a5, a6, a7],
      [fa0,fa1,fa2,fa3,fa4,fa5,fa6,fa7]>>,
  CCIfType<[i64,f64], CCAssignToRegWithShadow<
      [ a0_64, a1_64, a2_64, a3_64, a4_64, a5_64, a6_64, a7_64],
      [fa0_64,fa1_64,fa2_64,fa3_64,fa4_64,fa5_64,fa6_64,fa7_64]>>,

  // Other arguments are passed in 8-byte-aligned 8-byte stack slots.
  CCIfType<[i32, i64, f32, f64], CCAssignToStack<8, 8>>
]>;

//===----------------------------------------------------------------------===//
// Callee-saved register lists.
//===----------------------------------------------------------------------===//

def CSR_RV32  : CalleeSavedRegs<(add ra, sp, tp, (sequence "s%u", 11, 0))>;
def CSR_RV32F : CalleeSavedRegs<(add (sequence "fs%u", 15, 0), ra, sp, tp, gp,
                                     (sequence "s%u", 11, 0))>;
def CSR_RV32D : CalleeSavedRegs<(add (sequence "fs%u_64", 15, 0), ra, sp, tp, gp,
                                     (sequence "s%u", 11, 0))>;

def CSR_RV64  : CalleeSavedRegs<(add ra_64, sp_64, tp_64, (sequence "s%u_64", 11, 0))>;
def CSR_RV64F : CalleeSavedRegs<(add (sequence "fs%u", 15, 0), ra_64, sp_64, tp_64, gp_64,
                                     (sequence "s%u_64", 11, 0))>;
def CSR_RV64D : CalleeSavedRegs<(add (sequence "fs%u_64", 15, 0), ra_64, sp_64, tp_64, gp_64,
                                     (sequence "s%u_64", 11, 0))>;
