; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a) {
  %addi = add i32 %a, 2
  ret i32 %addi
}
