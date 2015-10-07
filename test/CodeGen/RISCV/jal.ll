; RUN: llc -march=riscv < %s

define i8* @f1() nounwind {
entry:
  %0 = call i8* @llvm.returnaddress(i32 0)
  ret i8* %0
}

define i8* @f2() nounwind {
entry:
  call void @g()
  %0 = call i8* @llvm.returnaddress(i32 0)
  ret i8* %0
}

declare i8* @llvm.returnaddress(i32) nounwind readnone
declare void @g()
