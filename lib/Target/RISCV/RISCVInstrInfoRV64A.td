//==- RISCVInstrInfoA.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//TODO add gr32 operations
def AMOSWAP_D : InstA<"amoswap.d" , 0b0101111, 0b00000, 0b011, atomic_swap     , GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOADD_D  : InstA<"amoadd.D"  , 0b0101111, 0b00001, 0b011, atomic_load_add , GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOXOR_D  : InstA<"amoxor.d"  , 0b0101111, 0b00100, 0b011, atomic_load_xor , GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOAND_D  : InstA<"amoand.d"  , 0b0101111, 0b01100, 0b011, atomic_load_and , GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOOR_D   : InstA<"amoor.d"   , 0b0101111, 0b01000, 0b011, atomic_load_or  , GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOMIN_D  : InstA<"amomin.d"  , 0b0101111, 0b10000, 0b011, atomic_load_min , GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOMAX_D  : InstA<"amomax.d"  , 0b0101111, 0b10100, 0b011, atomic_load_max , GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOMINU_D : InstA<"amominu.d" , 0b0101111, 0b11000, 0b011, atomic_load_umin, GR64, memreg64>, Requires<[IsRV64, HasA]>;
def AMOMAXU_D : InstA<"amomaxu.d" , 0b0101111, 0b11100, 0b011, atomic_load_umax, GR64, memreg64>, Requires<[IsRV64, HasA]>;
