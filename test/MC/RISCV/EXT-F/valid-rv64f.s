# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64IMAFD | FileCheck --check-prefix=CHECK64 %s
# XFAIL:

# CHECK64:	fadd.s	f2, f1, f0              # encoding: [0x53,0xf1,0x00,0x00]
# CHECK64:	fadd.s	f5, f4, f3              # encoding: [0xd3,0x72,0x32,0x00]
# CHECK64:	fadd.s	f8, f7, f6              # encoding: [0x53,0xf4,0x63,0x00]
# CHECK64:	fadd.s	f11, f10, f9            # encoding: [0xd3,0x75,0x95,0x00]
# CHECK64:	fadd.s	f14, f13, f12           # encoding: [0x53,0xf7,0xc6,0x00]
# CHECK64:	fadd.s	f17, f16, f15           # encoding: [0xd3,0x78,0xf8,0x00]
# CHECK64:	fadd.s	f20, f19, f18           # encoding: [0x53,0xfa,0x29,0x01]
# CHECK64:	fadd.s	f23, f22, f21           # encoding: [0xd3,0x7b,0x5b,0x01]
# CHECK64:	fadd.s	f26, f25, f24           # encoding: [0x53,0xfd,0x8c,0x01]
# CHECK64:	fadd.s	f29, f28, f27           # encoding: [0xd3,0x7e,0xbe,0x01]
# CHECK64:	fadd.s	f0, f31, f30            # encoding: [0x53,0xf0,0xef,0x01]

#-- test register state f0-f31	
	fadd.s	f2, f1, f0
	fadd.s	f5, f4, f3
	fadd.s	f8, f7, f6
	fadd.s	f11, f10, f9
	fadd.s	f14, f13, f12
	fadd.s	f17, f16, f15
	fadd.s	f20, f19, f18
	fadd.s	f23, f22, f21
	fadd.s	f26, f25, f24
	fadd.s	f29, f28, f27
	fadd.s	f0, f31, f30

#-- test rv32f instructions
	flw		f1, x0, 12
	flw		f3, x2, -12
	fmadd.s		f5, f4, f3, f2	
	fmsub.s		f5, f4, f3, f2	
	fnmsub.s	f5, f4, f3, f2	
	fnmadd.s	f8, f9, f10, f11
	fadd.s		f12, f11, f10
	fsub.s		f13, f14, f15
	fmul.s		f16, f17, f18
	fdiv.s		f19, f20, f21
	fsqrt.s		f23, f20
	fsgnj.s		f24, f25, f26
	fsgnjn.s	f31, f20, f30	
	fsgnjx.s	f31, f20, f30	
	fmin.s		f14, f4, f1
	fmax.s		f16, f1, f18
	fcvt.w.s	f8, f31
	fcvt.wu.s	f9, f10
	fmv.x.s		f19, f18
	feq.s		f0, f1, f2
	flt.s		f22, f7, f9
	fle.s		f4, f6, f7
	fclass.s	f9, f22
	fcvt.s.w	f4, f31
	fcvt.s.wu	f19, f0, f1
	fmv.s.x		f12, f29
	fcsr		f10
	frrm		f11
	frflags		f12
	fscsr		f13, f12
	fsrm		f14, f15
	fsflags		f16, f15
	fsrmi		f12, 13
	fsrmi		f12, -13
	fsflagsi	f18, 17
	fsflagsi	f18, -17

#-- RV64F only
	fcvt.l.s	f9, f8
	fcvt.lu.s	f10, f11
	fcvt.s.l	f13, f14
	fcvt.s.lu	f8, f9	
	
		
#-- EOF

