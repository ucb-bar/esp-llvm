; RUN: llc -march=riscv < %s

define i32 @f1() {
  ;ret i32 454664;
  ret i32 1164410880;
}
