# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64IMAFD | FileCheck --check-prefix=CHECK64 %s
# XFAIL:

#-- test register state f0-f31
        fadd.s  f2, f1, f0
        fadd.s  f5, f4, f3
        fadd.s  f8, f7, f6
        fadd.s  f11, f10, f9
        fadd.s  f14, f13, f12
        fadd.s  f17, f16, f15
        fadd.s  f20, f19, f18
        fadd.s  f23, f22, f21
        fadd.s  f26, f25, f24
        fadd.s  f29, f28, f27
        fadd.s  f0, f31, f30

#-- rv32d instructions
	fld	f0, x1, 14
	fld	f0, x1, -14
	fsd	f5, x8, 36
	fsd	f5, x8, -36
	fmadd.d	f5, f6, f7, f0
	fmsub.d	f10, f9, f13, f31
	fnmsub.d f22, f7, f17, f11
	fnmadd.d f12, f18, f22, f4
	fadd.d	f13, f12, f2
	fsub.d	f17, f15, f14
	fmul.d	f9, f18, f30
	fdiv.d	f3, f8, f9
	fsqrt.d	f12, f19, f20
	fsgnj.d	f12, f11, f10
	fsgnjn.d f17, f18, f20
	fsgnjx.d f27, f18, f20
	fmin.d	f0, f1, f2
	fmax.d	f8, f17, f22
	fcvt.s.d f11, f18, f29
	fcvt.d.s f9, f8, f7
	feq.d	f21, f31, f27
	flt.d	f18, f15, f10
	fle.d	f9, f18, f0
	fclass.d f31, f9
	fcvt.w.d f22, f13, f8
	fcvt.d.w f19, f7, f3
	fcvt.d.wu f18, f3
	
#-- rv64d instructions
	fcvt.l.d f18, f19
	fcvt.lu.d f1, f17
	fmv.x.d	f9, f17
	fcvt.d.l f22, f17
	fcvt.d.lu f2, f31
	fmv.d.x f29, f3
		
		
	
#-- EOF

