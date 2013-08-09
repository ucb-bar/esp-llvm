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

//===----------------------------------------------------------------------===//
// SVR4 return value calling convention
//===----------------------------------------------------------------------===//
def RetCC_RISCV : CallingConv<[

  // ABI-compliant code returns 64-bit integers in R2.  Make the other
  // call-clobbered argument registers available for code that doesn't
  // care about the ABI.  (R6 is an argument register too, but is
  // call-saved and therefore not suitable for return values.)
  //TODO: find a way to use abi namings for this v0,v1 = X16,X17
  CCIfType<[i32], CCAssignToReg<[v0, v1]>>,

  // ABI-complaint code returns float and double in F0.  Make the
  // other floating-point argument registers available for code that
  // doesn't care about the ABI.  All floating-point argument registers
  // are call-clobbered, so we can use all of them here.
  //TODO: find a way to use abi namings for this fv0,fv1 = F16,F17
  CCIfType<[f32], CCAssignToReg<[fv0, fv1]>>

  // ABI-compliant code returns long double by reference, but that conversion
  // is left to higher-level code.  Perhaps we could add an f128 definition
  // here for code that doesn't care about the ABI?
]>;

//===----------------------------------------------------------------------===//
// SVR4 argument calling conventions
//===----------------------------------------------------------------------===//
//TODO:this is a very simple version of the RISCV calling convention just to start with
def CC_RISCV : CallingConv<[

  // The first 14 integer arguments are passed in a0-a13. 
  CCIfType<[i32], CCAssignToReg<[a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13]>>,

  // The first 14 float and double arguments are passed in registers fa0-fa13.
  CCIfType<[f32], CCAssignToReg<[fa0, fa1, fa2, fa3, fa4, fa5, fa6, fa7, fa8, fa9, fa10, fa11, fa12, fa13]>>,

  // Other arguments are passed in 8-byte-aligned 8-byte stack slots.
  CCIfType<[i32, i64, f32, f64], CCAssignToStack<8, 8>>
]>;
