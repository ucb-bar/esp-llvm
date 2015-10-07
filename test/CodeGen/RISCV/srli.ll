; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a) {
  %srl = lshr  i32 %a, 6
  ret i32 %srl
}
define i32 @f2(i32 %a) {
  %sra = ashr  i32 %a, 6
  ret i32 %sra
}
