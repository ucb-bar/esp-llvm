; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a) {
  %shl = shl i32 %a, 1
  ret i32 %shl
}
