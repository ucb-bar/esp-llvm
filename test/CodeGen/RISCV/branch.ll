; RUN: llc -march=riscv < %s

define i32 @eq(i32 %a, i32 %b) {
  br label %loop
loop:
  %cond = icmp eq i32 %a, %b
  br i1 %cond, label %loop, label %exit
  ret i32 1
exit:
  ret i32 2
}

define i32 @ne(i32 %a, i32 %b) {
  br label %loop
loop:
  %cond = icmp ne i32 %a, %b
  br i1 %cond, label %loop, label %exit
  ret i32 1
exit:
  ret i32 2
}

define i32 @lt(i32 %a, i32 %b) {
  br label %loop
loop:
  %cond = icmp slt i32 %a, %b
  br i1 %cond, label %loop, label %exit
  ret i32 1
exit:
  ret i32 2
}

define i32 @ge(i32 %a, i32 %b) {
  br label %loop
loop:
  %cond = icmp sge i32 %a, %b
  br i1 %cond, label %loop, label %exit
  ret i32 1
exit:
  ret i32 2
}

define i32 @ltu(i32 %a, i32 %b) {
  br label %loop
loop:
  %cond = icmp ult i32 %a, %b
  br i1 %cond, label %loop, label %exit
  ret i32 1
exit:
  ret i32 2
}

define i32 @geu(i32 %a, i32 %b) {
  br label %loop
loop:
  %cond = icmp uge i32 %a, %b
  br i1 %cond, label %loop, label %exit
  ret i32 1
exit:
  ret i32 2
}

