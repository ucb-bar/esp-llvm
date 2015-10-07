# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32IMAFD | FileCheck --check-prefix=CHECK32 %s
# XFAIL: *

#-- RV64F only
	fcvt.l.s	f9, f8
	fcvt.lu.s	f10, f11
	fcvt.s.l	f13, f14
	fcvt.s.lu	f8, f9	
	
		
#-- EOF

