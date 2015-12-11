; RUN: llc -march=riscv < %s

@G = global i32 1

define i32 @f1() {
  %tmp = load i32, i32* @G
  ret i32 %tmp
}
