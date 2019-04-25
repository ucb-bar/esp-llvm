//===- IntrinsicsRISCV.td - Defines RISCV intrinsics -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the RISCV-specific intrinsics.
//
//===----------------------------------------------------------------------===//

def llvm_float_ptr_ty        : LLVMPointerType<llvm_float_ty>; 
def llvm_double_ptr_ty        : LLVMPointerType<llvm_float_ty>; 

let TargetPrefix = "hwacha" in {
  def int_hwacha_veidx : Intrinsic<[llvm_i64_ty], [], [IntrNoMem]>;
  def int_hwacha_loadstridefloat : Intrinsic<[llvm_float_ty], [llvm_float_ptr_ty, llvm_i64_ty], [IntrReadMem]>;
  def int_hwacha_loadstridedouble : Intrinsic<[llvm_double_ty], [llvm_double_ptr_ty, llvm_i64_ty], [IntrReadMem]>;
  def int_hwacha_storestridefloat : Intrinsic<[], [ llvm_float_ty, llvm_float_ptr_ty, llvm_i64_ty], [IntrWriteMem]>;
  def int_hwacha_storestridedouble : Intrinsic<[], [ llvm_double_ty, llvm_double_ptr_ty, llvm_i64_ty], [IntrWriteMem]>;
}

let TargetPrefix = "riscv" in {

//===----------------------------------------------------------------------===//
// Atomics

class MaskedAtomicRMW32Intrinsic
    : Intrinsic<[llvm_i32_ty],
                [llvm_anyptr_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty],
                [IntrArgMemOnly, NoCapture<0>, ImmArg<3>]>;

class MaskedAtomicRMW32WithSextIntrinsic
    : Intrinsic<[llvm_i32_ty],
                [llvm_anyptr_ty, llvm_i32_ty, llvm_i32_ty, llvm_i32_ty,
                 llvm_i32_ty],
                [IntrArgMemOnly, NoCapture<0>, ImmArg<4>]>;

def int_riscv_masked_atomicrmw_xchg_i32 : MaskedAtomicRMW32Intrinsic;
def int_riscv_masked_atomicrmw_add_i32  : MaskedAtomicRMW32Intrinsic;
def int_riscv_masked_atomicrmw_sub_i32  : MaskedAtomicRMW32Intrinsic;
def int_riscv_masked_atomicrmw_nand_i32 : MaskedAtomicRMW32Intrinsic;
def int_riscv_masked_atomicrmw_max_i32  : MaskedAtomicRMW32WithSextIntrinsic;
def int_riscv_masked_atomicrmw_min_i32  : MaskedAtomicRMW32WithSextIntrinsic;
def int_riscv_masked_atomicrmw_umax_i32 : MaskedAtomicRMW32Intrinsic;
def int_riscv_masked_atomicrmw_umin_i32 : MaskedAtomicRMW32Intrinsic;

def int_riscv_masked_cmpxchg_i32
    : Intrinsic<[llvm_i32_ty], [llvm_anyptr_ty, llvm_i32_ty, llvm_i32_ty,
                                llvm_i32_ty, llvm_i32_ty],
                [IntrArgMemOnly, NoCapture<0>, ImmArg<4>]>;

class MaskedAtomicRMW64Intrinsic
    : Intrinsic<[llvm_i64_ty],
                [llvm_anyptr_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty],
                [IntrArgMemOnly, NoCapture<0>, ImmArg<3>]>;

class MaskedAtomicRMW64WithSextIntrinsic
    : Intrinsic<[llvm_i64_ty],
                [llvm_anyptr_ty, llvm_i64_ty, llvm_i64_ty, llvm_i64_ty,
                 llvm_i64_ty],
                [IntrArgMemOnly, NoCapture<0>, ImmArg<4>]>;

def int_riscv_masked_atomicrmw_xchg_i64 : MaskedAtomicRMW64Intrinsic;
def int_riscv_masked_atomicrmw_add_i64  : MaskedAtomicRMW64Intrinsic;
def int_riscv_masked_atomicrmw_sub_i64  : MaskedAtomicRMW64Intrinsic;
def int_riscv_masked_atomicrmw_nand_i64 : MaskedAtomicRMW64Intrinsic;
def int_riscv_masked_atomicrmw_max_i64  : MaskedAtomicRMW64WithSextIntrinsic;
def int_riscv_masked_atomicrmw_min_i64  : MaskedAtomicRMW64WithSextIntrinsic;
def int_riscv_masked_atomicrmw_umax_i64 : MaskedAtomicRMW64Intrinsic;
def int_riscv_masked_atomicrmw_umin_i64 : MaskedAtomicRMW64Intrinsic;

def int_riscv_masked_cmpxchg_i64
    : Intrinsic<[llvm_i64_ty], [llvm_anyptr_ty, llvm_i64_ty, llvm_i64_ty,
                                llvm_i64_ty, llvm_i64_ty],
                [IntrArgMemOnly, NoCapture<0>, ImmArg<4>]>;

} // TargetPrefix = "riscv"
