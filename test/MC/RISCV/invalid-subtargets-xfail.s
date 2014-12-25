# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32IJ | FileCheck %s
# XFAIL: *

	addi	x0, x0, 0
	
#-- EOF

