# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64IMAFD | FileCheck %s
# XFAIL: *

#-- rq != {rs1|rs2} 
div	x10, x10, x8
div	x10, x8, x10
div	x10, x10, x10

divu	x10, x10, x8
divu	x10, x8, x10
divu	x10, x10, x10

divw	x10, x10, x8
divw	x10, x8, x10
divw	x10, x10, x10

divuw	x10, x10, x8
divuw	x10, x8, x10
divuw	x10, x10, x10
#-- EOF

