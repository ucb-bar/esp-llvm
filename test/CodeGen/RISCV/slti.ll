; RUN: llc -march=riscv < %s

define void @f1(i32 %a, i32 %b, i32 *%dest) {
  %slti = icmp slt i32 %a, 50
  %conv = zext i1 %slti to i32
  store i32 %conv, i32* %dest, align 4
  ret void
}

define void @f2(i32 %a, i32 %b, i32 *%dest) {
  %sltiu = icmp ult i32 %a, 30
  %conv = zext i1 %sltiu to i32
  store i32 %conv, i32* %dest, align 4
  ret void
}
