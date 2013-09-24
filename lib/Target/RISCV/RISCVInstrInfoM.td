//==- RISCVInstrM.td - Multiply Divide RISCV instructions --*- tblgen-*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

def MUL   : InstR<"mul"  , 0b0110011, 0b0000001000, mul   , GR32, GR32>, Requires<[HasM]>;
def MULH  : InstR<"mulh" , 0b0110011, 0b0000001001, mulhs , GR32, GR32>, Requires<[HasM]>;
//TODO: no corresponding llvm ir instruction
//def MULHSU: InstR<"mulh", 0b0110011, 0b0000001010, mulhs , GR32, GR32>, Requires<[HasM]>;
def MULHU : InstR<"mulhu", 0b0110011, 0b0000001011, mulhu , GR32, GR32>, Requires<[HasM]>;
def DIV   : InstR<"div"  , 0b0110011, 0b0000001100, sdiv  , GR32, GR32>, Requires<[HasM]>;
def DIVU  : InstR<"divu" , 0b0110011, 0b0000001101, udiv  , GR32, GR32>, Requires<[HasM]>;
def REM   : InstR<"rem"  , 0b0110011, 0b0000001110, srem  , GR32, GR32>, Requires<[HasM]>;
def REMU  : InstR<"remu" , 0b0110011, 0b0000001111, urem  , GR32, GR32>, Requires<[HasM]>;
