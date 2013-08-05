define void @f1(i32* %p, i32 %a) {
entry:
  store i32 %a, i32* %p, align 4
  ret void
}
