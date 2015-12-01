; RUN: llc -march=riscv < %s

define i32 @f1(i32* %p) {
entry:
  %b = load i32, i32* %p, align 4
  ret i32 %b
}

define i32 @offset(i32* %p) {
  %addr = getelementptr i32, i32* %p, i32 5
  %ret = load i32, i32* %addr, align 4
  ret i32 %ret
}

define i32 @lh(i16* %p) {
entry:
  %b = load i16, i16* %p, align 2
  %ret = sext i16 %b to i32
  ret i32 %ret
}

define i32 @lhoffset(i16* %p) {
  %addr = getelementptr i16, i16* %p, i16 5
  %b = load i16, i16* %addr, align 2
  %ret = sext i16 %b to i32
  ret i32 %ret
}

define i32 @lb(i8* %p) {
entry:
  %b = load i8, i8* %p, align 1
  %ret = sext i8 %b to i32
  ret i32 %ret
}

define i32 @lboffset(i8* %p) {
  %addr = getelementptr i8, i8* %p, i8 5
  %b = load i8, i8* %addr, align 1
  %ret = sext i8 %b to i32
  ret i32 %ret
}
