# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64IMAFD | FileCheck --check-prefix=CHECK64 %s

<<<<<<< HEAD
# CHECK64:	mul     x4, x2, x3              # encoding: [0x20,0xc4,0x04,0x33]
# CHECK64:	mulh    x5, x3, x4              # encoding: [0x29,0x06,0x04,0xb3]
# CHECK64:      mulhu   x6, x4, x5              # encoding: [0x31,0x48,0x05,0xb3]
# CHECK64:	mulw    x8, x6, x7              # encoding: [0x41,0xcc,0x04,0x3b]

# CHECK64:	div     x9, x8, x7              # encoding: [0x49,0xd0,0x06,0x33]
# CHECK64:	rem     x10, x8, x7             # encoding: [0x51,0xd0,0x07,0x33]
# CHECK64:	divu    x9, x8, x7              # encoding: [0x49,0xd0,0x06,0xb3]
# CHECK64:	remu    x10, x8, x7             # encoding: [0x51,0xd0,0x07,0xb3]

# CHECK64:	divw    x9, x8, x7              # encoding: [0x49,0xd0,0x06,0x3b]
# CHECK64:	remw    x10, x8, x7             # encoding: [0x51,0xd0,0x07,0x3b]
# CHECK64:	divuw   x9, x8, x7              # encoding: [0x49,0xd0,0x06,0xbb]
# CHECK64:	remuw   x10, x8, x7             # encoding: [0x51,0xd0,0x07,0xbb]
=======
# CHECK64:	mul     x5, x3, x4              # encoding: [0x29,0x06,0x04,0x33]
# CHECK64:	mulh    x6, x4, x5              # encoding: [0x31,0x48,0x04,0xb3]
# CHECK64:      mulhu   x7, x5, x6              # encoding: [0x39,0x8a,0x05,0xb3]
# CHECK64:	mulhsu	x8, x6, x7		# encoding: [0x41,0xcc,0x05,0xb3]
# CHECK64:	mulw    x9, x7, x8              # encoding: [0x4a,0x0e,0x04,0x3b]


# CHECK64:	div     x10, x9, x8             # encoding: [0x52,0x12,0x06,0x33]
# CHECK64:	rem     x11, x9, x8             # encoding: [0x5a,0x12,0x07,0x33]
# CHECK64:	divu    x10, x9, x8             # encoding: [0x52,0x12,0x06,0xb3]
# CHECK64:	remu    x11, x9, x8             # encoding: [0x5a,0x12,0x07,0xb3]

# CHECK64:	divw    x10, x9, x8             # encoding: [0x52,0x12,0x06,0x3b]
# CHECK64:	remw    x11, x9, x8             # encoding: [0x5a,0x12,0x07,0x3b]
# CHECK64:	divuw   x10, x9, x8             # encoding: [0x52,0x12,0x06,0xbb]
# CHECK64:	remuw   x11, x9, x8             # encoding: [0x5a,0x12,0x07,0xbb]
>>>>>>> upstream/riscv-trunk

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

