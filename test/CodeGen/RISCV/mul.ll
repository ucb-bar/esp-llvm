; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a, i32 %b, i32 %c) {
  %mul = mul  i32 %a, %b
  ret i32 %mul
}
