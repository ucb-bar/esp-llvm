# Instructions that are expected to fail
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32I | FileCheck %s
# XFAIL: *

	#-- overflow 32-immediate
	addi x1, x0, 1200000000

#-- EOF

