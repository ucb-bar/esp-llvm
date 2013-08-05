define i32 @f1(i32* %p) {
entry:
  %b = load i32* %p, align 4
  ret i32 %b
}
