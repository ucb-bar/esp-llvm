; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a) {
  %addi = add  i32 %a, 2
  ret i32 %addi
}
define i32 @f2(i32 %a) {
  %xori = xor  i32 %a, 15
  ret i32 %xori
}
define i32 @f3(i32 %a) {
  %ori = or  i32 %a, 15
  ret i32 %ori
}
define i32 @f4(i32 %a) {
  %andi = and  i32 %a, 2
  ret i32 %andi
}
