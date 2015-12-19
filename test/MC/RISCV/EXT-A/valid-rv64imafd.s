# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64IMAFD
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

#-- rv64imafd only
lr.d		x5, x4
sc.d		x6, x5
amoswap.d	x8, x7, x6
amoadd.d	x9, x8, x7
amoxor.d	x10, x9, x8
amoand.d	x11, x10, x9
amoor.d		x12, x11, x10
amomin.d	x13, x12, x11
amomax.d	x14, x13, x12
amominu.d	x15, x14, x13
amomaxu.d	x16, x15, x14


#-- EOF

