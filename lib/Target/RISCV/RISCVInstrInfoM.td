//===- RISCVInstrM.td - Multiply Divide RISCV instructions ----*- tblgen-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//RV32
def MUL   : InstR<"mul"  , mul   , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b000>, Requires<[IsRV32, HasM]>;
def MULH  : InstR<"mulh" , mulhs , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b001>, Requires<[HasM]>;
//TODO: no corresponding llvm ir instruction
//def MULHSU: InstR<"mulh", mulhs , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b010>, Requires<[HasM]>;
def MULHU : InstR<"mulhu", mulhu , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b011>, Requires<[HasM]>;
def DIV   : InstR<"div"  , sdiv  , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b100>, Requires<[IsRV32, HasM]>;
def DIVU  : InstR<"divu" , udiv  , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b101>, Requires<[IsRV32, HasM]>;
def REM   : InstR<"rem"  , srem  , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b110>, Requires<[IsRV32, HasM]>;
def REMU  : InstR<"remu" , urem  , GR32, GR32>, RV_FMT_R< 0b0110011, 0b0000001, 0b111>, Requires<[IsRV32, HasM]>;

//RV64
//standard M instructions on 64bit values
def MUL64   : InstR<"mul"  , mul   , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b000>, Requires<[IsRV64, HasM]>;
def MULH64  : InstR<"mulh" , mulhs , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b001>, Requires<[IsRV64, HasM]>;
//TODO: no corresponding llvm ir instruction
 //def MULHSU: InstR<"mulh", mulhs , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b010>, Requires<[IsRV64, HasM]>;
def MULHU64 : InstR<"mulhu", mulhu , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b011>, Requires<[IsRV64, HasM]>;
def DIV64   : InstR<"div"  , sdiv  , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b100>, Requires<[IsRV64, HasM]>;
def DIVU64  : InstR<"divu" , udiv  , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b101>, Requires<[IsRV64, HasM]>;
def REM64   : InstR<"rem"  , srem  , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b110>, Requires<[IsRV64, HasM]>;
def REMU64  : InstR<"remu" , urem  , GR64, GR64>, RV_FMT_R< 0b0110011, 0b0000001, 0b111>, Requires<[IsRV64, HasM]>;

//special rv64 instructions
//TODO:llvm mul won't sign extend
def MULW    : InstR<"mulw" , mul   , GR32, GR32>, RV_FMT_R< 0b0111011, 0b0000001, 0b000>, Requires<[IsRV64, HasM]>;
def DIVW    : InstR<"divw" , sdiv  , GR32, GR32>, RV_FMT_R< 0b0111011, 0b0000001, 0b100>, Requires<[IsRV64, HasM]>;
def DIVUW   : InstR<"divuw", udiv  , GR32, GR32>, RV_FMT_R< 0b0111011, 0b0000001, 0b101>, Requires<[IsRV64, HasM]>;
def REMW    : InstR<"remw" , srem  , GR32, GR32>, RV_FMT_R< 0b0111011, 0b0000001, 0b110>, Requires<[IsRV64, HasM]>;
def REMUW   : InstR<"remuw", urem  , GR32, GR32>, RV_FMT_R< 0b0111011, 0b0000001, 0b111>, Requires<[IsRV64, HasM]>;
