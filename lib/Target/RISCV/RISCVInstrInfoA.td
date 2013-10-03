//==- RISCVInstrInfoA.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//TODO: add LR/SC and acq/rel

def AMOSWAP_W : InstA<"amoswap.w" , 0b0101111, 0b00000, 0b010, atomic_swap     , GR32, memreg32>, Requires<[HasA]>;
def AMOADD_W  : InstA<"amoadd.w"  , 0b0101111, 0b00001, 0b010, atomic_load_add , GR32, memreg32>, Requires<[HasA]>;
def AMOXOR_W  : InstA<"amoxor.w"  , 0b0101111, 0b00100, 0b010, atomic_load_xor , GR32, memreg32>, Requires<[HasA]>;
def AMOAND_W  : InstA<"amoand.w"  , 0b0101111, 0b01100, 0b010, atomic_load_and , GR32, memreg32>, Requires<[HasA]>;
def AMOOR_W   : InstA<"amoor.w"   , 0b0101111, 0b01000, 0b010, atomic_load_or  , GR32, memreg32>, Requires<[HasA]>;
def AMOMIN_W  : InstA<"amomin.w"  , 0b0101111, 0b10000, 0b010, atomic_load_min , GR32, memreg32>, Requires<[HasA]>;
def AMOMAX_W  : InstA<"amomax.w"  , 0b0101111, 0b10100, 0b010, atomic_load_max , GR32, memreg32>, Requires<[HasA]>;
def AMOMINU_W : InstA<"amominu.w" , 0b0101111, 0b11000, 0b010, atomic_load_umin, GR32, memreg32>, Requires<[HasA]>;
def AMOMAXU_W : InstA<"amomaxu.w" , 0b0101111, 0b11100, 0b010, atomic_load_umax, GR32, memreg32>, Requires<[HasA]>;
