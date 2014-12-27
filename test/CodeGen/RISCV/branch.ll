; RUN: llc -march=riscv < %s | FileCheck %s

define i32 @eq(i32 %a, i32 %b) {
; CHECK-LABEL: eq:
  br label %loop
loop:
  %cond = icmp eq i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: beq
  ret i32 1
exit:
  ret i32 2
}

define i32 @ne(i32 %a, i32 %b) {
; CHECK-LABEL: ne:
  br label %loop
loop:
  %cond = icmp ne i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: bne
  ret i32 1
exit:
  ret i32 2
}

define i32 @lt(i32 %a, i32 %b) {
; CHECK-LABEL: lt:
  br label %loop
loop:
  %cond = icmp slt i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: blt
  ret i32 1
exit:
  ret i32 2
}

define i32 @ge(i32 %a, i32 %b) {
; CHECK-LABEL: ge:
  br label %loop
loop:
  %cond = icmp sge i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: bge
  ret i32 1
exit:
  ret i32 2
}

define i32 @ltu(i32 %a, i32 %b) {
; CHECK-LABEL: ltu:
  br label %loop
loop:
  %cond = icmp ult i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: bltu
  ret i32 1
exit:
  ret i32 2
}

define i32 @geu(i32 %a, i32 %b) {
; CHECK-LABEL: geu:
  br label %loop
loop:
  %cond = icmp uge i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: bgeu
  ret i32 1
exit:
  ret i32 2
}

; Synthesizable branches.

define i32 @gt(i32 %a, i32 %b) {
; CHECK-LABEL: gt:
  br label %loop
loop:
  %cond = icmp sgt i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: blt
  ret i32 1
exit:
  ret i32 2
}

define i32 @le(i32 %a, i32 %b) {
; CHECK-LABEL: le:
  br label %loop
loop:
  %cond = icmp sle i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: bge
  ret i32 1
exit:
  ret i32 2
}

define i32 @gtu(i32 %a, i32 %b) {
; CHECK-LABEL: gtu:
  br label %loop
loop:
  %cond = icmp ugt i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: bltu
  ret i32 1
exit:
  ret i32 2
}

define i32 @leu(i32 %a, i32 %b) {
; CHECK-LABEL: leu:
  br label %loop
loop:
  %cond = icmp ule i32 %a, %b
  br i1 %cond, label %loop, label %exit
; CHECK: bgeu
  ret i32 1
exit:
  ret i32 2
}

