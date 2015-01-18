# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64IMAFD | FileCheck --check-prefix=CHECK64 %s

# CHECK64:	mul     x5, x3, x4              # encoding: [0xb3,0x82,0x41,0x02]
# CHECK64:	mulh    x6, x4, x5              # encoding: [0x33,0x13,0x52,0x02]
# CHECK64:      mulhu   x7, x5, x6              # encoding: [0xb3,0xb3,0x62,0x02]
# CHECK64:	mulw    x9, x7, x8              # encoding: [0xbb,0x84,0x83,0x02]

# CHECK64:	div     x10, x9, x8             # encoding: [0x33,0xc5,0x84,0x02]
# CHECK64:	rem     x11, x9, x8             # encoding: [0xb3,0xe5,0x84,0x02]
# CHECK64:	divu    x10, x9, x8             # encoding: [0x33,0xd5,0x84,0x02]
# CHECK64:	remu    x11, x9, x8             # encoding: [0xb3,0xf5,0x84,0x02]

# CHECK64:	divw    x10, x9, x8             # encoding: [0x3b,0xc5,0x84,0x02]
# CHECK64:	remw    x11, x9, x8             # encoding: [0xbb,0xe5,0x84,0x02]
# CHECK64:	divuw   x10, x9, x8             # encoding: [0x3b,0xd5,0x84,0x02]
# CHECK64:	remuw   x11, x9, x8             # encoding: [0xbb,0xf5,0x84,0x02]

#-- Multiplication
mul	x5, x3, x4
mulh	x6, x4, x5
mulhu	x7, x5, x6
mulw	x9, x7, x8

#-- Division
div     x10, x9, x8
rem     x11, x9, x8
divu    x10, x9, x8
remu	x11, x9, x8

divw	x10, x9, x8
remw	x11, x9, x8
divuw	x10, x9, x8
remuw	x11, x9, x8


#-- EOF

