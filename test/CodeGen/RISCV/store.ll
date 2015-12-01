; RUN: llc -march=riscv < %s

define void @f1(i32* %p, i32 %a) {
entry:
  store i32 %a, i32* %p, align 4
  ret void
}

define void @offset(i32* %p, i32 %offset, i32 %a) {
  %addr = getelementptr i32, i32* %p, i32 5
  store i32 %a, i32* %addr, align 4
  ret void
}

define void @sh(i16* %p, i16 %a) {
  store i16 %a, i16* %p, align 2
  ret void
}

define void @shoffset(i16* %p, i16 %offset, i16 %a) {
  %addr = getelementptr i16, i16* %p, i16 5
  store i16 %a, i16* %addr, align 2
  ret void
}

define void @sb(i8* %p, i8 %a) {
  store i8 %a, i8* %p, align 1
  ret void
}

define void @sboffset(i8* %p, i8 %offset, i8 %a) {
  %addr = getelementptr i8, i8* %p, i8 5
  store i8 %a, i8* %addr, align 1
  ret void
}
