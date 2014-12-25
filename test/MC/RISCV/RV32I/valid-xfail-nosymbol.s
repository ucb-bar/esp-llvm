# Instructions that are expected to fail
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32I | FileCheck %s
# XFAIL: *

	#-- branch to an unknown symbol 
	beq     x0,x0, my_branch_target

#-- EOF

