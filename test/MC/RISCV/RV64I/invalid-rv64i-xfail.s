# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64I | FileCheck --check-prefix=CHECK64 %s
# XFAIL: *

	rdcycleh x6
	rdtimeh	x8
	rdinstreth x10 
		

#-- EOF

