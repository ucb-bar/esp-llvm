//===-- RISCVAsmParser.cpp - Parse RISCV assembly instructions --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/RISCVMCTargetDesc.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCTargetAsmParser.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "riscv-asm-parser"

// Return true if Expr is in the range [MinValue, MaxValue].
static bool inRange(const MCExpr *Expr, int64_t MinValue, int64_t MaxValue) {
  if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr)) {
    int64_t Value = CE->getValue();
    return Value >= MinValue && Value <= MaxValue;
  }
  return false;
}

namespace {
class RISCVOperand : public MCParsedAsmOperand {
public:
  enum RegisterKind {
    PCReg,
    PCRReg,
    PCR64Reg,
    GR32Reg,
    GR64Reg,
    PairGR64Reg,
    PairGR128Reg,
    GR128Reg,
    FP32Reg,
    FP64Reg,
    PairFP64Reg,
    PairFP128Reg,
    FP128Reg
  };

private:
  enum OperandKind {
    KindToken,
    KindReg,
    KindImm,
    KindMem
  };

  OperandKind Kind;
  SMLoc StartLoc, EndLoc;

  // A string of length Length, starting at Data.
  struct TokenOp {
    const char *Data;
    unsigned Length;
  };

  // LLVM register Num, which has kind Kind.
  struct RegOp {
    RegisterKind Kind;
    unsigned Num;
  };

  // Base + Disp + Index, where Base and Index are LLVM registers or 0.
  // RegKind says what type the registers have
  struct MemOp {
    unsigned Base : 8;
    unsigned Index : 8;
    unsigned RegKind : 8;
    unsigned Unused : 8;
    const MCExpr *Disp;
  };

  union {
    TokenOp Token;
    RegOp Reg;
    const MCExpr *Imm;
    MemOp Mem;
  };

  void addExpr(MCInst &Inst, const MCExpr *Expr) const {
    // Add as immediates when possible.  Null MCExpr = 0.
    if (Expr == 0)
      Inst.addOperand(MCOperand::createImm(0));
    else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::createImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::createExpr(Expr));
  }

public:
  RISCVOperand(OperandKind kind, SMLoc startLoc, SMLoc endLoc)
      : Kind(kind), StartLoc(startLoc), EndLoc(endLoc) {}

  // Create particular kinds of operand.
  static std::unique_ptr<RISCVOperand> createToken(StringRef Str, SMLoc Loc) {
    auto Op = make_unique<RISCVOperand>(KindToken, Loc, Loc);
    Op->Token.Data = Str.data();
    Op->Token.Length = Str.size();
    return Op;
  }
  static std::unique_ptr<RISCVOperand>
  createReg(RegisterKind Kind, unsigned Num, SMLoc StartLoc, SMLoc EndLoc) {
    auto Op = make_unique<RISCVOperand>(KindReg, StartLoc, EndLoc);
    Op->Reg.Kind = Kind;
    Op->Reg.Num = Num;
    return Op;
  }
  static std::unique_ptr<RISCVOperand> createImm(const MCExpr *Expr,
                                                 SMLoc StartLoc, SMLoc EndLoc) {
    auto Op = make_unique<RISCVOperand>(KindImm, StartLoc, EndLoc);
    Op->Imm = Expr;
    return Op;
  }
  static std::unique_ptr<RISCVOperand>
  createMem(RegisterKind RegKind, unsigned Base, const MCExpr *Disp,
            unsigned Index, SMLoc StartLoc, SMLoc EndLoc) {
    auto Op = make_unique<RISCVOperand>(KindMem, StartLoc, EndLoc);
    Op->Mem.RegKind = RegKind;
    Op->Mem.Base = Base;
    Op->Mem.Index = Index;
    Op->Mem.Disp = Disp;
    return Op;
  }

  // Token operands
  bool isToken() const override {
    return Kind == KindToken;
  }
  StringRef getToken() const {
    assert(Kind == KindToken && "Not a token");
    return StringRef(Token.Data, Token.Length);
  }

  // Register operands.
  bool isReg() const override {
    return Kind == KindReg;
  }
  bool isReg(RegisterKind RegKind) const {
    return Kind == KindReg && Reg.Kind == RegKind;
  }
  unsigned getReg() const override {
    assert(Kind == KindReg && "Not a register");
    return Reg.Num;
  }

  // Immediate operands.
  bool isImm() const override {
    return Kind == KindImm;
  }
  bool isImm(int64_t MinValue, int64_t MaxValue) const {
    return Kind == KindImm && inRange(Imm, MinValue, MaxValue);
  }
  const MCExpr *getImm() const {
    assert(Kind == KindImm && "Not an immediate");
    return Imm;
  }

  // Memory operands.
  bool isMem() const override {
    return Kind == KindMem;
  }
  bool isMem(RegisterKind RegKind, bool HasIndex) const {
    return (Kind == KindMem &&
            Mem.RegKind == RegKind &&
            (HasIndex || !Mem.Index));
  }
  bool isMemDisp12(RegisterKind RegKind, bool HasIndex) const {
    return isMem(RegKind, HasIndex) && inRange(Mem.Disp, 0, 0xfff);
  }
  bool isMemDisp20(RegisterKind RegKind, bool HasIndex) const {
    return isMem(RegKind, HasIndex) && inRange(Mem.Disp, -524288, 524287);
  }

  // Override MCParsedAsmOperand.
  SMLoc getStartLoc() const override { return StartLoc; }
  SMLoc getEndLoc() const override { return EndLoc; }
  void print(raw_ostream &OS) const override;

  // Used by the TableGen code to add particular types of operand
  // to an instruction.
  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands");
    Inst.addOperand(MCOperand::createReg(getReg()));
  }
  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands");
    addExpr(Inst, getImm());
  }

  // Used by the TableGen code to check for particular operand types.
  bool isPCReg() const { return isReg(PCReg); }
  bool isPCRReg() const { return isReg(PCRReg); }
  bool isPCR64Reg() const { return isReg(PCR64Reg); }
  bool isGR32() const { return isReg(GR32Reg); }
  bool isGR64() const { return isReg(GR64Reg); }
  bool isPairGR64() const { return isReg(PairGR64Reg); }
  bool isPairGR128() const { return isReg(PairGR128Reg); }
  bool isGR128() const { return isReg(GR128Reg); }
  bool isFP32() const { return isReg(FP32Reg); }
  bool isFP64() const { return isReg(FP64Reg); }
  bool isPairFP64() const { return isReg(PairFP64Reg); }
  bool isPairFP128() const { return isReg(PairFP128Reg); }
  bool isFP128() const { return isReg(FP128Reg); }
  bool isU4Imm() const { return isImm(0, 15); }
  bool isU12Imm() const { return isImm(0, 4096); }
  bool isS12Imm() const { return isImm(-2048, 2047); }
  bool isU20Imm() const { return isImm(0, 1048576); }
  bool isS20Imm() const { return isImm(-524288, 524287); }
  bool isU32Imm() const { return isImm(0, (1LL << 32) - 1); }
  bool isS32Imm() const { return isImm(-(1LL << 31), (1LL << 31) - 1); }
  bool isU64Imm() const { return isImm(0, 18446744073709551615UL); }
  bool isS64Imm() const { return isImm(-9223372036854775807LL,9223372036854775807LL); }
};

// Maps of asm register numbers to LLVM register numbers, with 0 indicating
// an invalid register.  We don't use register class directly because that
// specifies the allocation order.
static const unsigned GR32Regs[] = {
  RISCV::zero, RISCV::ra, RISCV::sp, RISCV::gp, RISCV::tp,
  RISCV::t0, RISCV::t1, RISCV::t2,
  RISCV::s0, RISCV::s1,
  RISCV::a0, RISCV::a1, RISCV::a2, RISCV::a3, RISCV::a4, RISCV::a5, RISCV::a6, RISCV::a7, 
  RISCV::s2, RISCV::s3, RISCV::s4, RISCV::s5, RISCV::s6, RISCV::s7, RISCV::s8, RISCV::s9, RISCV::s10, RISCV::s11,
  RISCV::t3, RISCV::t4, RISCV::t5, RISCV::t6
};

static const unsigned GR64Regs[] = {
  RISCV::zero_64, RISCV::ra_64, RISCV::sp_64, RISCV::gp_64, RISCV::tp_64,
  RISCV::t0_64, RISCV::t1_64, RISCV::t2_64,
  RISCV::s0_64, RISCV::s1_64,
  RISCV::a0_64, RISCV::a1_64, RISCV::a2_64, RISCV::a3_64, RISCV::a4_64, RISCV::a5_64, RISCV::a6_64, RISCV::a7_64, 
  RISCV::s2_64, RISCV::s3_64, RISCV::s4_64, RISCV::s5_64, RISCV::s6_64, RISCV::s7_64, RISCV::s8_64, RISCV::s9_64, RISCV::s10_64, RISCV::s11_64,
  RISCV::t3_64, RISCV::t4_64, RISCV::t5_64, RISCV::t6_64
};

static const unsigned PairGR64Regs[] = {
  RISCV::a0_p64, RISCV::a1_p64, RISCV::a2_p64, RISCV::a3_p64
};

static const unsigned PairGR128Regs[] = {
  RISCV::a0_p128, RISCV::a1_p128, RISCV::a2_p128, RISCV::a3_p128
};

static const unsigned PCReg[] = { RISCV::PC };

static const unsigned FP32Regs[] = {
  RISCV::ft0, RISCV::ft1, RISCV::ft2, RISCV::ft3, RISCV::ft4, RISCV::ft5, RISCV::ft6, RISCV::ft7,
  RISCV::fs0, RISCV::fs1, 
  RISCV::fa0, RISCV::fa1, RISCV::fa2, RISCV::fa3, RISCV::fa4, RISCV::fa5, RISCV::fa6, RISCV::fa7,
  RISCV::fs2, RISCV::fs3, RISCV::fs4, RISCV::fs5, RISCV::fs6, RISCV::fs7, RISCV::fs8, RISCV::fs9, RISCV::fs10, RISCV::fs11,
  RISCV::ft8, RISCV::ft9, RISCV::ft10, RISCV::ft11
};

static const unsigned FP64Regs[] = {
  RISCV::ft0_64, RISCV::ft1_64, RISCV::ft2_64, RISCV::ft3_64, RISCV::ft4_64, RISCV::ft5_64, RISCV::ft6_64, RISCV::ft7_64,
  RISCV::fs0_64, RISCV::fs1_64, 
  RISCV::fa0_64, RISCV::fa1_64, RISCV::fa2_64, RISCV::fa3_64, RISCV::fa4_64, RISCV::fa5_64, RISCV::fa6_64, RISCV::fa7_64,
  RISCV::fs2_64, RISCV::fs3_64, RISCV::fs4_64, RISCV::fs5_64, RISCV::fs6_64, RISCV::fs7_64, RISCV::fs8_64, RISCV::fs9_64, RISCV::fs10_64, RISCV::fs11_64,
  RISCV::ft8_64, RISCV::ft9_64, RISCV::ft10_64, RISCV::ft11_64
};

static const unsigned PairFP64Regs[] = {
  RISCV::fa0_p64, RISCV::fa1_p64, RISCV::fa2_p64, RISCV::fa3_p64
};

static const unsigned PairFP128Regs[] = {
  RISCV::fa0_p128, RISCV::fa1_p128, RISCV::fa2_p128, RISCV::fa3_p128
};

static const unsigned PCRRegs[] = {
  RISCV::status, RISCV::epc, RISCV::evec, RISCV::ptbr, RISCV::asid,
  RISCV::count, RISCV::compare, RISCV::sup0, RISCV::sup1, RISCV::tohost, RISCV::fromhost,
  //read only
  RISCV::badvaddr, RISCV::cause, RISCV::hartid, RISCV::impl, 
  //write only
  RISCV::fatc,  RISCV::send_ipi, RISCV::clear_ipi
};

static const unsigned PCR64Regs[] = {
  RISCV::status_64, RISCV::epc_64, RISCV::evec_64, RISCV::ptbr_64, RISCV::asid_64,
  RISCV::count_64, RISCV::compare_64, RISCV::sup0_64, RISCV::sup1_64, RISCV::tohost_64, RISCV::fromhost_64,
  //read only
  RISCV::badvaddr_64, RISCV::cause_64, RISCV::hartid_64, RISCV::impl_64, 
  //write only
  RISCV::fatc_64,  RISCV::send_ipi_64, RISCV::clear_ipi_64
};

class RISCVAsmParser : public MCTargetAsmParser {
#define GET_ASSEMBLER_HEADER
#include "RISCVGenAsmMatcher.inc"

private:
  const MCSubtargetInfo &STI;
  MCAsmParser &Parser;
  struct Register {
    char Prefix;
    unsigned Number;
    SMLoc StartLoc, EndLoc;
  };

  bool parseRegister(Register &Reg);
  bool parseParenSuffix(StringRef Name, OperandVector &Operands);

  OperandMatchResultTy parseRegister(Register &Reg, char Prefix,
                                     const unsigned *Regs,
                                     bool IsAddress = false);

  OperandMatchResultTy parseRegister(OperandVector &Operands, char Prefix,
                                     const unsigned *Regs,
                                     RISCVOperand::RegisterKind Kind,
                                     bool IsAddress = false);

  OperandMatchResultTy parseAddress(OperandVector &Operands,
                                    const unsigned *Regs,
                                    RISCVOperand::RegisterKind RegKind,
                                    bool HasIndex);

  bool parseOperand(OperandVector &Operands, StringRef Mnemonic);

public:
  RISCVAsmParser(const MCSubtargetInfo &sti, MCAsmParser &parser,
                 const MCInstrInfo &MII, const MCTargetOptions &Options)
      : MCTargetAsmParser(Options, sti), STI(sti), Parser(parser) {
    MCAsmParserExtension::Initialize(Parser);

    // Initialize the set of available features.
    setAvailableFeatures(ComputeAvailableFeatures(STI.getFeatureBits()));
  }

  // Override MCTargetAsmParser.
  bool ParseDirective(AsmToken DirectiveID) override;
  bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, SMLoc &EndLoc) override;
  bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;
  bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                               OperandVector &Operands, MCStreamer &Out,
                               uint64_t &ErrorInfo,
                               bool MatchingInlineAsm) override;

  // Used by the TableGen code to parse particular operand types.
  OperandMatchResultTy parseGR32(OperandVector &Operands) {
    return parseRegister(Operands, 'x', GR32Regs, RISCVOperand::GR32Reg);
  }

  OperandMatchResultTy parseGR64(OperandVector &Operands) {
    return parseRegister(Operands, 'x', GR64Regs, RISCVOperand::GR64Reg);
  }

  OperandMatchResultTy parsePairGR64(OperandVector &Operands) {
    return parseRegister(Operands, 'x', PairGR64Regs,
                         RISCVOperand::PairGR64Reg);
  }

  OperandMatchResultTy parsePairGR128(OperandVector &Operands) {
    return parseRegister(Operands, 'x', PairGR128Regs,
                         RISCVOperand::PairGR128Reg);
  }

  OperandMatchResultTy parsePCReg(OperandVector &Operands) {
    return parseRegister(Operands, 'p', PCReg, RISCVOperand::PCReg);
  }

  OperandMatchResultTy parseFP32(OperandVector &Operands) {
    return parseRegister(Operands, 'f', FP32Regs, RISCVOperand::FP32Reg);
  }

  OperandMatchResultTy parseFP64(OperandVector &Operands) {
    return parseRegister(Operands, 'f', FP64Regs, RISCVOperand::FP64Reg);
  }

  OperandMatchResultTy parsePairFP64(OperandVector &Operands) {
    return parseRegister(Operands, 'f', PairFP64Regs,
                         RISCVOperand::PairFP64Reg);
  }

  OperandMatchResultTy parsePairFP128(OperandVector &Operands) {
    return parseRegister(Operands, 'f', PairFP128Regs,
                         RISCVOperand::PairFP128Reg);
  }

  OperandMatchResultTy parsePCRReg(OperandVector &Operands) {
    const AsmToken &Tok = Parser.getTok();
    if(Tok.is(AsmToken::Identifier) && Tok.getIdentifier().equals("ASM_CR")) {
      SMLoc S = Tok.getLoc();
      const AsmToken Tok = Parser.getTok();
      if(Tok.is(AsmToken::LParen)) {
        const AsmToken Tok = Parser.getTok();
        if(Tok.is(AsmToken::Identifier)) {
          std::unique_ptr<RISCVOperand> op;
          //TODO: make this a tablegen or something
          if(Tok.getIdentifier().equals_lower("PCR_K0"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::sup0,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_K1"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::sup1,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_EPC"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::epc,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_badvaddr"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::badvaddr,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_ptbr"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::ptbr,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_ptbr"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::ptbr,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_asid"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::asid,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_count"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::count,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_compare"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::compare,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_evec"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::evec,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_cause"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::cause,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_status"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::status,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_hartid"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::hartid,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_impl"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::impl,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_fatc"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::fatc,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_send_ipi"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::send_ipi,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_clear_ipi"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::clear_ipi,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_tohost"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::tohost,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_fromhost"))
            op = RISCVOperand::createReg(RISCVOperand::PCRReg,RISCV::fromhost,S, Tok.getLoc());
          else
            return MatchOperand_ParseFail;

          Operands.push_back(std::move(op));

          Parser.Lex();//eat close paren
          return MatchOperand_Success;
        }else {
          return MatchOperand_ParseFail;
        }
      }else {
        return MatchOperand_ParseFail;
      }
    }else {
      return MatchOperand_NoMatch;
    }
    //fallback
    return parseRegister(Operands, 'p', PCRRegs, RISCVOperand::PCRReg);
  }

  OperandMatchResultTy
  parsePCR64Reg(OperandVector &Operands) {
    const AsmToken &Tok = Parser.getTok();
    if(Tok.is(AsmToken::Identifier) && Tok.getIdentifier().equals("ASM_CR")) {
      SMLoc S = Tok.getLoc();
      const AsmToken Tok = Parser.getTok();
      if(Tok.is(AsmToken::LParen)) {
        const AsmToken Tok = Parser.getTok();
        if(Tok.is(AsmToken::Identifier)) {
          std::unique_ptr<RISCVOperand> op;
          //TODO: make this a tablegen or something
          if(Tok.getIdentifier().equals_lower("PCR_K0"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::sup0_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_K1"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::sup1_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_EPC"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::epc_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_badvaddr"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::badvaddr_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_ptbr"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::ptbr_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_ptbr"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::ptbr_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_asid"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::asid_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_count"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::count_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_compare"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::compare_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_evec"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::evec_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_cause"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::cause_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_status"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::status_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_hartid"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::hartid_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_impl"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::impl_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_fatc"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::fatc_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_send_ipi"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::send_ipi_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_clear_ipi"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::clear_ipi_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_tohost"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::tohost_64,S, Tok.getLoc());
          else if(Tok.getIdentifier().equals_lower("PCR_fromhost"))
            op = RISCVOperand::createReg(RISCVOperand::PCR64Reg,RISCV::fromhost_64,S, Tok.getLoc());
          else
            return MatchOperand_ParseFail;

          Operands.push_back(std::move(op));

          Parser.Lex();//eat close paren
          return MatchOperand_Success;
        }else {
          return MatchOperand_ParseFail;
        }
      }else {
        return MatchOperand_ParseFail;
      }
    }else {
      return MatchOperand_NoMatch;
    }
    //fallback
    return parseRegister(Operands, 'p', PCR64Regs, RISCVOperand::PCR64Reg);
  }

};
}

#define GET_REGISTER_MATCHER
#define GET_SUBTARGET_FEATURE_NAME
#define GET_MATCHER_IMPLEMENTATION
#include "RISCVGenAsmMatcher.inc"

void RISCVOperand::print(raw_ostream &OS) const {
  llvm_unreachable("Not implemented");
}

// Parse one register of the form %<prefix><number>.
bool RISCVAsmParser::parseRegister(Register &Reg) {
  Reg.StartLoc = Parser.getTok().getLoc();

  // Expect a register name.
  if (Parser.getTok().isNot(AsmToken::Identifier))
    return true;

  // Check the prefix.
  StringRef Name = Parser.getTok().getString();
  if (Name.size() < 2)
    return true;
  Reg.Prefix = Name[0];

  // Treat the rest of the register name as a register number.
  if (Name.substr(1).getAsInteger(10, Reg.Number))
    return true;

  Reg.EndLoc = Parser.getTok().getLoc();
  Parser.Lex();
  return false;
}

/// Sometimes (i.e. load/stores) the operand may be followed immediately by
/// either this.
/// ::= '(', register, ')'
/// handle it before we iterate so we don't get tripped up by the lack of
/// a comma.
bool RISCVAsmParser::parseParenSuffix(StringRef Name, OperandVector &Operands) {

  if (getLexer().is(AsmToken::LParen)) {

    Parser.Lex();

    if (parseOperand(Operands, Name)) {
      SMLoc Loc = getLexer().getLoc();
      Parser.eatToEndOfStatement();
      return Error(Loc, "unexpected token in argument list" );
    }
    if (Parser.getTok().isNot(AsmToken::RParen)) {
      SMLoc Loc = getLexer().getLoc();
      Parser.eatToEndOfStatement();
      return Error(Loc, "unexpected token, expected ')'" );
    }
    Parser.Lex();
  }

  return false;
}

// Parse a register with prefix Prefix and convert it to LLVM numbering.
// Regs maps asm register numbers to LLVM register numbers, with zero
// entries indicating an invalid register.  IsAddress says whether the
// register appears in an address context.
RISCVAsmParser::OperandMatchResultTy
RISCVAsmParser::parseRegister(Register &Reg, char Prefix,
                                const unsigned *Regs, bool IsAddress) {
  if (parseRegister(Reg))
    return MatchOperand_NoMatch;
  if (Reg.Prefix != Prefix || Reg.Number > 31 || Regs[Reg.Number] == 0) {
    Error(Reg.StartLoc, "invalid register");
    return MatchOperand_ParseFail;
  }
  if (Reg.Number == 0 && IsAddress) {
    Error(Reg.StartLoc, "%r0 used in an address");
    return MatchOperand_ParseFail;
  }
  Reg.Number = Regs[Reg.Number];
  return MatchOperand_Success;
}

// Parse a register and add it to Operands.  Prefix is 'r' for GPRs,
// 'f' for FPRs, etc.  Regs maps asm register numbers to LLVM register numbers,
// with zero entries indicating an invalid register.  Kind is the type of
// register represented by Regs and IsAddress says whether the register is
// being parsed in an address context, meaning that %r0 evaluates as 0.
RISCVAsmParser::OperandMatchResultTy
RISCVAsmParser::parseRegister(OperandVector &Operands, char Prefix,
                              const unsigned *Regs,
                              RISCVOperand::RegisterKind Kind, bool IsAddress) {
  Register Reg;
  OperandMatchResultTy Result = parseRegister(Reg, Prefix, Regs, IsAddress);
  if (Result == MatchOperand_Success)
    Operands.push_back(RISCVOperand::createReg(Kind, Reg.Number,
                                                 Reg.StartLoc, Reg.EndLoc));
  return Result;
}

// Parse a memory operand and add it to Operands.  Regs maps asm register
// numbers to LLVM address registers and RegKind says what kind of address
// register we're using (GR32Reg or GR64Reg).  HasIndex says whether
// the address allows index registers.
RISCVAsmParser::OperandMatchResultTy
RISCVAsmParser::parseAddress(OperandVector &Operands, const unsigned *Regs,
                             RISCVOperand::RegisterKind RegKind,
                             bool HasIndex) {
  SMLoc StartLoc = Parser.getTok().getLoc();

  // Parse the displacement, which must always be present.
  const MCExpr *Disp;
  if (getParser().parseExpression(Disp))
    return MatchOperand_NoMatch;

  // Parse the optional base and index.
  unsigned Index = 0;
  unsigned Base = 0;
  if (getLexer().is(AsmToken::LParen)) {
    Parser.Lex();

    // Parse the first register.
    Register Reg;
    OperandMatchResultTy Result = parseRegister(Reg, 'x', GR32Regs, true);
    if (Result != MatchOperand_Success)
      return Result;

    // Check whether there's a second register.  If so, the one that we
    // just parsed was the index.
    if (getLexer().is(AsmToken::Comma)) {
      Parser.Lex();

      if (!HasIndex) {
        Error(Reg.StartLoc, "invalid use of indexed addressing");
        return MatchOperand_ParseFail;
      }

      Index = Reg.Number;
      Result = parseRegister(Reg, 'x', GR32Regs, true);
      if (Result != MatchOperand_Success)
        return Result;
    }
    Base = Reg.Number;

    // Consume the closing bracket.
    if (getLexer().isNot(AsmToken::RParen))
      return MatchOperand_NoMatch;
    Parser.Lex();
  }

  SMLoc EndLoc =
    SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
  Operands.push_back(RISCVOperand::createMem(RegKind, Base, Disp, Index,
                                               StartLoc, EndLoc));
  return MatchOperand_Success;
}

bool RISCVAsmParser::ParseDirective(AsmToken DirectiveID) {
  return true;
}

bool RISCVAsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
                                     SMLoc &EndLoc) {
  Register Reg;
  if (parseRegister(Reg))
    return Error(Reg.StartLoc, "register expected");
  if (Reg.Prefix == 'x' && Reg.Number < 32)
    RegNo = GR32Regs[Reg.Number];
  else if (Reg.Prefix == 'f' && Reg.Number < 32)
    RegNo = FP32Regs[Reg.Number];
  else
    return Error(Reg.StartLoc, "invalid register");
  StartLoc = Reg.StartLoc;
  EndLoc = Reg.EndLoc;
  return false;
}

bool RISCVAsmParser::ParseInstruction(ParseInstructionInfo &Info,
                                      StringRef Name, SMLoc NameLoc,
                                      OperandVector &Operands) {

  // Check if we have valid mnemonic
  if (!mnemonicIsValid(Name, 0)) {
    Parser.eatToEndOfStatement();
    return Error(NameLoc, "unknown instruction");
  }

  // First operand in MCInst is instruction mnemonic.
  Operands.push_back(RISCVOperand::createToken(Name, NameLoc));

  // Read the remaining operands
  if (getLexer().isNot(AsmToken::EndOfStatement)) {

    // Read the first operand
    if( parseOperand(Operands,Name)) {
      SMLoc Loc = getLexer().getLoc();
      Parser.eatToEndOfStatement();
      return Error(Loc, "unexpected token in argument list");
    }

    if( getLexer().is(AsmToken::LBrac) )
      return true;

    while (getLexer().is(AsmToken::Comma)) {

      Parser.Lex(); // Eat the comma.

      // Parse and remember the operand
      if( parseOperand(Operands, Name )){
        SMLoc Loc = getLexer().getLoc();
        Parser.eatToEndOfStatement();
        return Error(Loc, "unexpected token in argument list");
      }

      // Parse parenthesis suffixes before we iterate
      if( getLexer().is(AsmToken::LParen) &&
                 parseParenSuffix(Name,Operands))
        return true;
    }
  }

  if( getLexer().isNot(AsmToken::EndOfStatement)) {

    SMLoc Loc = getLexer().getLoc();
    Parser.eatToEndOfStatement();
    return Error(Loc, "unexpected token in argument list" );
  }
  Parser.Lex(); // Consume the EndOfStatement.
  return false;

}

bool RISCVAsmParser::parseOperand(OperandVector &Operands, StringRef Mnemonic) {
  // Check if the current operand has a custom associated parser, if so, try to
  // custom parse the operand, or fallback to the general approach.
  OperandMatchResultTy ResTy = MatchOperandParserImpl(Operands, Mnemonic);
  if (ResTy == MatchOperand_Success)
    return false;

  // If there wasn't a custom match, try the generic matcher below. Otherwise,
  // there was a match, but an error occurred, in which case, just return that
  // the operand parsing failed.
  if (ResTy == MatchOperand_ParseFail)
    return true;

  // The only other type of operand is an immediate.
  const MCExpr *Expr;
  SMLoc StartLoc = Parser.getTok().getLoc();
  if (getParser().parseExpression(Expr))
    return true;

  SMLoc EndLoc =
    SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
  Operands.push_back(RISCVOperand::createImm(Expr, StartLoc, EndLoc));
  return false;
}

bool RISCVAsmParser::MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                                             OperandVector &Operands,
                                             MCStreamer &Out,
                                             uint64_t &ErrorInfo,
                                             bool MatchingInlineAsm) {
  MCInst Inst;
  unsigned MatchResult;

  MatchResult = MatchInstructionImpl(Operands, Inst, ErrorInfo,
                                     MatchingInlineAsm);
  switch (MatchResult) {
  default: break;
  case Match_Success:{
#if 0
    if(processInstruction(Inst,IDLoc, Instructions))
      return true;
    for(unsigned i=0; i< Instructions.size(); i++ ){ 
      Out.EmitInstruction(Inst,STI);
    }
    return false;
  }
#endif
    Inst.setLoc(IDLoc);
    Out.EmitInstruction(Inst, STI);
    return false;
  }
  case Match_MissingFeature: {
    assert(ErrorInfo && "Unknown missing feature!");
    // Special case the error message for the very common case where only
    // a single subtarget feature is missing
    std::string Msg = "instruction requires:";
    unsigned Mask = 1;
    for (unsigned I = 0; I < sizeof(ErrorInfo) * 8 - 1; ++I) {
      if (ErrorInfo & Mask) {
        Msg += " ";
        Msg += getSubtargetFeatureName(ErrorInfo & Mask);
      }
      Mask <<= 1;
    }
    return Error(IDLoc, Msg);
  }

  case Match_InvalidOperand: {
    SMLoc ErrorLoc = IDLoc;
    if (ErrorInfo != ~0U) {
      if (ErrorInfo >= Operands.size())
        return Error(IDLoc, "too few operands for instruction");

      ErrorLoc = ((RISCVOperand &)*Operands[ErrorInfo]).getStartLoc();
      if (ErrorLoc == SMLoc())
        ErrorLoc = IDLoc;
    }
    return Error(ErrorLoc, "invalid operand for instruction");
  }

  case Match_MnemonicFail:
    return Error(IDLoc, "invalid instruction");
  }

  llvm_unreachable("Unexpected match type");
}

// Force static initialization.
extern "C" void LLVMInitializeRISCVAsmParser() {
  RegisterMCAsmParser<RISCVAsmParser> X(TheRISCVTarget);
  RegisterMCAsmParser<RISCVAsmParser> Y(TheRISCV64Target);
}
