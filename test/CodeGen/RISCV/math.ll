; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a, i32 %b, i32 %c) {
  %add = add  i32 %a, %b
  %sub = sub  i32 %add, %c
  %sll = shl  i32 %sub, %b
  %slt = icmp slt i32 %sll, %b
  %sltext = zext i1 %slt to i32
  %sltu = icmp ult i32 %sltext, %b
  %sltuext = zext i1 %sltu to i32
  %srl = lshr i32 %sltuext, %b
  %sra = ashr i32 %srl, %b
  %xor = xor  i32 %sra, %b
  %or  = or   i32 %xor, %b
  %and = and  i32 %or, %b
  ret i32 %and
}
