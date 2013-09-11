//==- RISCVInstrInfoRV64M.td - Multiply Divide RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//standard M instructions on 64bit values
def MUL64   : InstR<"MUL"  , 0b0110011, 0b0000001000, mul   , GR64, GR64>, Requires<[IsRV64, HasM]>;
def MULH64  : InstR<"MULH" , 0b0110011, 0b0000001001, mulhs , GR64, GR64>, Requires<[IsRV64, HasM]>;
//TODO: no corresponding llvm ir instruction
 //def MULHSU: InstR<"MULH", 0b0110011, 0b0000001010, mulhs , GR64, GR64>, Requires<[IsRV64, HasM]>;
def MULHU64 : InstR<"MULHU", 0b0110011, 0b0000001011, mulhu , GR64, GR64>, Requires<[IsRV64, HasM]>;
def DIV64   : InstR<"DIV"  , 0b0110011, 0b0000001100, sdiv  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def DIVU64  : InstR<"DIVU" , 0b0110011, 0b0000001101, udiv  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def REM64   : InstR<"REM"  , 0b0110011, 0b0000001110, srem  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def REMU64  : InstR<"REMU" , 0b0110011, 0b0000001111, urem  , GR64, GR64>, Requires<[IsRV64, HasM]>;

//special rv64 instructions
//TODO:tell LLVM to only do lower bits
def MULW    : InstR<"MULW" , 0b0111011, 0b0000001000, mul   , GR64, GR64>, Requires<[IsRV64, HasM]>;
def DIVW    : InstR<"DIVW" , 0b0111011, 0b0000001100, sdiv  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def DIVUW   : InstR<"DIVUW", 0b0111011, 0b0000001101, udiv  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def REMW    : InstR<"REMW" , 0b0111011, 0b0000001110, srem  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def REMUW   : InstR<"REMUW", 0b0111011, 0b0000001111, urem  , GR64, GR64>, Requires<[IsRV64, HasM]>;
