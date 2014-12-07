; RUN: llc -march=riscv < %s

define i32 @addi(i32 %a) {
  %result     = add  i32 %a, 100
  ret i32 %result
}
define i32 @subi(i32 %a) {
  %result     = sub  i32 %a, 100
  ret i32 %result
}
define i32 @slli(i32 %a) {
  %result     = shl  i32 %a, 5
  ret i32 %result
}
define i32 @slti(i32 %a) {
  %slti    = icmp slt i32 %a, 4
  %result  = zext i1 %slti to i32
  ret i32 %result
}
define i32 @sltiu(i32 %a) {
  %sltiu   = icmp slt i32 %a, 4
  %result  = zext i1 %sltiu to i32
  ret i32 %result
}
define i32 @srli(i32 %a) {
  %result     = lshr  i32 %a, 5
  ret i32 %result
}
define i32 @srai(i32 %a) {
  %result     = ashr  i32 %a, 5
  ret i32 %result
}
define i32 @xori(i32 %a) {
  %result     = xor  i32 %a, 567
  ret i32 %result
}
define i32 @ori(i32 %a) {
  %result     = or  i32 %a, 567
  ret i32 %result
}
define i32 @andi(i32 %a) {
  %result     = and  i32 %a, 567
  ret i32 %result
}
