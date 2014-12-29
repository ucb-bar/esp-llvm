# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32IMAFD | FileCheck --check-prefix=CHECK32 %s
# XFAIL: *

	fadd.s	x2, x1, x0
		
#-- EOF

