# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64IMAFD | FileCheck --check-prefix=CHECK64 %s
# XFAIL: *

#-- rv64d instructions
	fcvt.l.d f18, f19
	fcvt.lu.d f1, f17
	fmv.x.d	f9, f17
	fcvt.d.l f22, f17
	fcvt.d.lu f2, f31
	fmv.d.x f29, f3
		
		
	
#-- EOF

