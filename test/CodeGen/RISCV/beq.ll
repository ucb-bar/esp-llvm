; RUN: llc -march=riscv < %s

define i32 @f1(i32 %a, i32 %b) {
  br label %loop
loop:
  %cond = icmp eq i32 %a, %b
  br i1 %cond, label %loop, label %exit
  ret i32 1
exit:
  ret i32 2
}

define void @f2(i32 *%src, i32 *%dst, i32 %target, i32 %a, i32 %b) {
  %val = load volatile i32, i32 *%src
  %cond = icmp eq i32 %target, %val
  br i1 %cond, label %then, label %else

then:
  store i32 %a, i32* %dst, align 4
  br label %exit

else:
  store i32 %b, i32* %dst, align 4
  br label %exit

exit:
  ret void
}
