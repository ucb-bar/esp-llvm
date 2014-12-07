; RUN: llc -march=riscv < %s

define void @f1(i32 %a, i32 %b, i32 *%dest) {
  %slt = icmp slt i32 %a, %b
  %conv = zext i1 %slt to i32
  store i32 %conv, i32* %dest, align 4
  ret void
}

define void @f2(i32 %a, i32 %b, i32 *%dest) {
  %sltu = icmp ult i32 %a, %b
  %conv = zext i1 %sltu to i32
  store i32 %conv, i32* %dest, align 4
  ret void
}
