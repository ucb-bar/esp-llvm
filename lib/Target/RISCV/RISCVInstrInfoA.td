//==- RISCVInstrInfoA.td - Floating-point RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//RV32
//TODO: add LR/SC and acq/rel

def AMOSWAP_W : InstA<"amoswap.w" , 0b0101111, 0b00000, 0b010, atomic_swap     , GR32, memreg>, Requires<[HasA]>;
def AMOADD_W  : InstA<"amoadd.w"  , 0b0101111, 0b00001, 0b010, atomic_load_add , GR32, memreg>, Requires<[HasA]>;
def AMOXOR_W  : InstA<"amoxor.w"  , 0b0101111, 0b00100, 0b010, atomic_load_xor , GR32, memreg>, Requires<[HasA]>;
def AMOAND_W  : InstA<"amoand.w"  , 0b0101111, 0b01100, 0b010, atomic_load_and , GR32, memreg>, Requires<[HasA]>;
def AMOOR_W   : InstA<"amoor.w"   , 0b0101111, 0b01000, 0b010, atomic_load_or  , GR32, memreg>, Requires<[HasA]>;
def AMOMIN_W  : InstA<"amomin.w"  , 0b0101111, 0b10000, 0b010, atomic_load_min , GR32, memreg>, Requires<[HasA]>;
def AMOMAX_W  : InstA<"amomax.w"  , 0b0101111, 0b10100, 0b010, atomic_load_max , GR32, memreg>, Requires<[HasA]>;
def AMOMINU_W : InstA<"amominu.w" , 0b0101111, 0b11000, 0b010, atomic_load_umin, GR32, memreg>, Requires<[HasA]>;
def AMOMAXU_W : InstA<"amomaxu.w" , 0b0101111, 0b11100, 0b010, atomic_load_umax, GR32, memreg>, Requires<[HasA]>;

def LR_W : InstLR<"lr.w", 0b010, GR32, memreg>, Requires<[HasA]>;
def SC_W : InstSC<"sc.w", 0b010, GR32, memreg>, Requires<[HasA]>;


let usesCustomInserter = 1 in {
  def ATOMIC_CMP_SWAP_4 : PsuedoInst<
      (outs GR32:$dst), (ins GR32:$ptr, GR32:$old, GR32:$new),
      [(set GR32:$dst, (atomic_cmp_swap_32 GR32:$ptr, GR32:$old, GR32:$new))]>,
        Requires<[HasA]>;
}

//RV64A
//TODO: add LR/SC and acq/rel

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

def LR_W64 : InstLR<"lr.w", 0b010, GR64, memreg64>, Requires<[IsRV64, HasA]>;
def SC_W64 : InstSC<"sc.w", 0b010, GR64, memreg64>, Requires<[IsRV64, HasA]>;
def LR_D   : InstLR<"lr.d", 0b011, GR64, memreg64>, Requires<[IsRV64, HasA]>;
def SC_D   : InstSC<"sc.d", 0b011, GR64, memreg64>, Requires<[IsRV64, HasA]>;


let usesCustomInserter = 1 in {
  def ATOMIC_CMP_SWAP_8 : PsuedoInst<
      (outs GR64:$dst), (ins GR64:$ptr, GR64:$old, GR64:$new),
      [(set GR64:$dst, (atomic_cmp_swap_64 GR64:$ptr, GR64:$old, GR64:$new))]>,
        Requires<[IsRV64, HasA]>;
}
