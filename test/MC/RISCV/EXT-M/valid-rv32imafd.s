# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32IMAFD | FileCheck --check-prefix=CHECK32 %s

# CHECK32:	mul     x4, x2, x3              # encoding: [0x20,0xc4,0x04,0x33]
# CHECK32:	mulh    x5, x3, x4              # encoding: [0x29,0x06,0x04,0xb3]
# CHECK32:	mulhu   x6, x4, x5              # encoding: [0x31,0x48,0x05,0xb3]
# CHECK32:	mulhsu  x8, x6, x7              # encodign: [0x39,0x8a,0x05,0xb3]	
# CHECK32:	div     x9, x8, x7              # encoding: [0x49,0xd0,0x06,0x33]
# CHECK32:	rem     x10, x8, x7             # encoding: [0x51,0xd0,0x07,0x33]
# CHECK32:	divu    x9, x8, x7              # encoding: [0x49,0xd0,0x06,0xb3]
# CHECK32:	remu    x10, x8, x7             # encoding: [0x51,0xd0,0x07,0xb3]

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

