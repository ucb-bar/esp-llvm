define i32 @f1(i32 %a, i32 %b, i32 %c) {
  %slt = icmp slt i32 %a, %b
  %add = add i32 %a, %c
  ret i32 %add
}
