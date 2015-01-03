# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32IMAFD | FileCheck --check-prefix=CHECK32 %s

# CHECK32:	mul     x5, x3, x4              # encoding: [0x29,0x06,0x04,0x33]
# CHECK32:	mulh    x6, x4, x5              # encoding: [0x31,0x48,0x04,0xb3]
# CHECK32:	mulhu   x7, x5, x6              # encoding: [0x39,0x8a,0x05,0xb3]
# CHECK32:	mulhsu  x8, x6, x7              # encoding: [0x41,0xcc,0x05,0xb3]
# CHECK32:	div     x10, x9, x8             # encoding: [0x52,0x12,0x06,0x33]
# CHECK32:	rem     x11, x9, x8             # encoding: [0x5a,0x12,0x07,0x33]
# CHECK32:	divu    x10, x9, x8             # encoding: [0x52,0x12,0x06,0xb3]
# CHECK32:	remu    x11, x9, x8             # encoding: [0x5a,0x12,0x07,0xb3]

#-- Multiplication
mul	x5, x3, x4
mulh	x6, x4, x5
mulhu	x7, x5, x6
mulhsu	x8, x6, x7

#-- Division
div	x10, x9, x8
rem	x11, x9, x8
divu	x10, x9, x8
remu	x11, x9, x8

#-- EOF

