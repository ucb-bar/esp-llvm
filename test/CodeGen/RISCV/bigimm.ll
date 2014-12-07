; RUN: llc -march=riscv < %s

define i32 @f1() {
  ret i32 19088743 ;0x01234567
}
