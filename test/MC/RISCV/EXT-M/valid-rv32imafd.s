# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32IMAFD | FileCheck --check-prefix=CHECK32 %s

# CHECK32:	mul     x5, x3, x4              # encoding: [0xb3,0x82,0x41,0x02]
# CHECK32:	mulh    x6, x4, x5              # encoding: [0x33,0x13,0x52,0x02]
# CHECK32:	mulhu   x7, x5, x6              # encoding: [0xb3,0xb3,0x62,0x02]
# CHECK32:	div     x10, x9, x8             # encoding: [0x33,0xc5,0x84,0x02]
# CHECK32:	rem     x11, x9, x8             # encoding: [0xb3,0xe5,0x84,0x02]
# CHECK32:	divu    x10, x9, x8             # encoding: [0x33,0xd5,0x84,0x02]
# CHECK32:	remu    x11, x9, x8             # encoding: [0xb3,0xf5,0x84,0x02]

#-- Multiplication
mul	x5, x3, x4
mulh	x6, x4, x5
mulhu	x7, x5, x6
#mulhsu	x8, x6, x7	#-- currently unsupported

#-- Division
div	x10, x9, x8
rem	x11, x9, x8
divu	x10, x9, x8
remu	x11, x9, x8

#-- EOF

