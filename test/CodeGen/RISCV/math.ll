define i32 @f1(i32 %a, i32 %b, i32 %c) {
  %add = add  i32 %a, %b
  %sub = sub  i32 %add, %c
  %sll = shl  i32 %sub, %b
  %srl = lshr i32 %sll, %b
  %sra = ashr i32 %srl, %b
  %xor = xor  i32 %sra, %b
  %or  = or   i32 %xor, %b
  %and = and  i32 %or, %b
  ret i32 %and
}
