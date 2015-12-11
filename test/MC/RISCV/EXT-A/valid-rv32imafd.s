# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32IMAFD
# XFAIL:

lr.w		x5, x4
sc.w		x6, x5
amoswap.w	x8, x7, x6
amoadd.w	x9, x8, x7
amoxor.w	x10, x9, x8
amoand.w	x11, x10, x9
amoor.w		x12, x11, x10
amomin.w	x13, x12, x11
amomax.w	x14, x13, x12
amominu.w	x15, x14, x13
amomaxu.w	x16, x15, x14


#-- EOF

