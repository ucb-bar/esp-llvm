//==- RISCVInstrM.td - Multiply Divide RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//RV32
def MUL   : InstR<"mul"  , 0b0110011, 0b0000001000, mul   , GR32, GR32>, Requires<[IsRV32, HasM]>;
def MULH  : InstR<"mulh" , 0b0110011, 0b0000001001, mulhs , GR32, GR32>, Requires<[HasM]>;
//TODO: no corresponding llvm ir instruction
//def MULHSU: InstR<"mulh", 0b0110011, 0b0000001010, mulhs , GR32, GR32>, Requires<[HasM]>;
def MULHU : InstR<"mulhu", 0b0110011, 0b0000001011, mulhu , GR32, GR32>, Requires<[HasM]>;
def DIV   : InstR<"div"  , 0b0110011, 0b0000001100, sdiv  , GR32, GR32>, Requires<[IsRV32, HasM]>;
def DIVU  : InstR<"divu" , 0b0110011, 0b0000001101, udiv  , GR32, GR32>, Requires<[IsRV32, HasM]>;
def REM   : InstR<"rem"  , 0b0110011, 0b0000001110, srem  , GR32, GR32>, Requires<[IsRV32, HasM]>;
def REMU  : InstR<"remu" , 0b0110011, 0b0000001111, urem  , GR32, GR32>, Requires<[IsRV32, HasM]>;

//RV64
//standard M instructions on 64bit values
def MUL64   : InstR<"mul"  , 0b0110011, 0b0000001000, mul   , GR64, GR64>, Requires<[IsRV64, HasM]>;
def MULH64  : InstR<"mulh" , 0b0110011, 0b0000001001, mulhs , GR64, GR64>, Requires<[IsRV64, HasM]>;
//TODO: no corresponding llvm ir instruction
 //def MULHSU: InstR<"mulh", 0b0110011, 0b0000001010, mulhs , GR64, GR64>, Requires<[IsRV64, HasM]>;
def MULHU64 : InstR<"mulhu", 0b0110011, 0b0000001011, mulhu , GR64, GR64>, Requires<[IsRV64, HasM]>;
def DIV64   : InstR<"div"  , 0b0110011, 0b0000001100, sdiv  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def DIVU64  : InstR<"divu" , 0b0110011, 0b0000001101, udiv  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def REM64   : InstR<"rem"  , 0b0110011, 0b0000001110, srem  , GR64, GR64>, Requires<[IsRV64, HasM]>;
def REMU64  : InstR<"remu" , 0b0110011, 0b0000001111, urem  , GR64, GR64>, Requires<[IsRV64, HasM]>;

//special rv64 instructions
//TODO:llvm mul won't sign extend
def MULW    : InstR<"mulw" , 0b0111011, 0b0000001000, mul   , GR32, GR32>, Requires<[IsRV64, HasM]>;
def DIVW    : InstR<"divw" , 0b0111011, 0b0000001100, sdiv  , GR32, GR32>, Requires<[IsRV64, HasM]>;
def DIVUW   : InstR<"divuw", 0b0111011, 0b0000001101, udiv  , GR32, GR32>, Requires<[IsRV64, HasM]>;
def REMW    : InstR<"remw" , 0b0111011, 0b0000001110, srem  , GR32, GR32>, Requires<[IsRV64, HasM]>;
def REMUW   : InstR<"remuw", 0b0111011, 0b0000001111, urem  , GR32, GR32>, Requires<[IsRV64, HasM]>;
