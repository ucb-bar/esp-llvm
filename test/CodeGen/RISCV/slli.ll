; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a) {
  %sll = shl  i32 %a, 6
  ret i32 %sll
}
