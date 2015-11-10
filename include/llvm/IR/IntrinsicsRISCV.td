//===- IntrinsicsRISCV.td - Defines RISCV intrinsics -----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the RISCV-specific intrinsics.
//
//===----------------------------------------------------------------------===//

let TargetPrefix = "hwacha" in {
  def int_hwacha_veidx : Intrinsic<[llvm_i64_ty], [], []>;
}
