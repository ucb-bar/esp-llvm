	.text
	.file	"sgemm-pragma.ll"
	.p2align	2               # -- Begin function _pocl_launcher_sgemm_unroll
	.type	_pocl_launcher_sgemm_unroll,@function
_pocl_launcher_sgemm_unroll:            # @_pocl_launcher_sgemm_unroll
# %bb.0:                                # %for.cond.4.preheader.i
	vpset	vp0
	veidx	vv0
	vlsw	vs7, vs7
	vlsw	vs37, vs37
	vfmul.s	vs7, vs37, vs7
	vlsw	vs2, vs2
	vfadd.s	vs2, vs2, vs7
	@vp0	vsxw	vs2, vs0, vs8
	vlsw	vs7, vs12
	vlsw	vs8, vs39
	vfmul.s	vs7, vs8, vs7
	vfadd.s	vs2, vs2, vs7
	@vp0	vsxw	vs2, vs0, vs13
	vlsw	vs7, vs14
	vlsw	vs8, vs41
	vfmul.s	vs7, vs8, vs7
	vfadd.s	vs2, vs2, vs7
	@vp0	vsxw	vs2, vs0, vs15
	vlsw	vs7, vs16
	vlsw	vs8, vs42
	vfmul.s	vs7, vs8, vs7
	vfadd.s	vs2, vs2, vs7
	@vp0	vsxw	vs2, vs0, vs17
	vlsw	vs2, vs10
	vlsw	vs7, vs40
	vfmul.s	vs2, vs7, vs2
	vlsw	vs1, vs1
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs11
	vlsw	vs2, vs22
	vlsw	vs7, vs46
	vfmul.s	vs2, vs7, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs23
	vlsw	vs2, vs24
	vlsw	vs7, vs47
	vfmul.s	vs2, vs7, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs25
	vlsw	vs2, vs26
	vlsw	vs7, vs48
	vfmul.s	vs2, vs7, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs27
	vlsw	vs1, vs29
	vlsw	vs2, vs49
	vfmul.s	vs1, vs2, vs1
	vlsw	vs2, vs28
	vfadd.s	vs1, vs2, vs1
	@vp0	vsxw	vs1, vs0, vs30
	vlsw	vs2, vs9
	vlsw	vs7, vs50
	vfmul.s	vs2, vs7, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs31
	vlsw	vs2, vs32
	vlsw	vs7, vs51
	vfmul.s	vs2, vs7, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs33
	vlsw	vs2, vs34
	vlsw	vs7, vs52
	vfmul.s	vs2, vs7, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs35
	vlsw	vs1, vs18
	vlsw	vs2, vs43
	vfmul.s	vs1, vs2, vs1
	vlsw	vs2, vs36
	vfadd.s	vs1, vs2, vs1
	@vp0	vsxw	vs1, vs0, vs19
	vlsw	vs2, vs20
	vlsw	vs7, vs44
	vfmul.s	vs2, vs7, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs21
	vlsw	vs2, vs3
	vlsw	vs3, vs45
	vfmul.s	vs2, vs3, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs4
	vlsw	vs2, vs5
	vlsw	vs3, vs38
	vfmul.s	vs2, vs3, vs2
	vfadd.s	vs1, vs1, vs2
	@vp0	vsxw	vs1, vs0, vs6
	vstop	
.Lfunc_end0:
	.size	_pocl_launcher_sgemm_unroll, .Lfunc_end0-_pocl_launcher_sgemm_unroll
                                        # -- End function
	.globl	_pocl_launcher_sgemm_unroll_workgroup # -- Begin function _pocl_launcher_sgemm_unroll_workgroup
	.p2align	2
	.type	_pocl_launcher_sgemm_unroll_workgroup,@function
_pocl_launcher_sgemm_unroll_workgroup:  # @_pocl_launcher_sgemm_unroll_workgroup
# %bb.0:
	addi	sp, sp, -240
	sd	s1, 232(sp)
	sd	s2, 224(sp)
	sd	s3, 216(sp)
	sd	s4, 208(sp)
	sd	s5, 200(sp)
	sd	s6, 192(sp)
	sd	s7, 184(sp)
	sd	s8, 176(sp)
	sd	s9, 168(sp)
	sd	s10, 160(sp)
	sd	s11, 152(sp)
	ld	a2, 48(a1)
	ld	a3, 72(a1)
	add	a6, a3, a2
	ld	a3, 40(a1)
	ld	a4, 64(a1)
	add	t1, a4, a3
	ld	a4, 24(a0)
	lw	a5, 0(a4)
	slli	a2, a6, 2
	ori	a4, a2, 1
	mul	a7, a4, a5
	ld	a4, 32(a1)
	slli	a4, a4, 7
	ld	a1, 56(a1)
	add	a3, a1, a7
	add	a3, a3, a4
	slli	t2, a3, 2
	ld	a3, 0(a0)
	ld	t0, 0(a3)
	ld	a3, 8(a0)
	ld	t6, 0(a3)
	ld	a0, 16(a0)
	ld	t5, 0(a0)
	add	t3, t5, t2
	lw	a0, 0(t3)
	sw	a0, 148(sp)
	slli	a0, t1, 2
	ori	a3, a0, 3
	mul	t2, a3, a5
	ori	a3, a0, 2
	mul	t4, a3, a5
	mul	a3, a6, a5
	ori	a6, a2, 3
	ori	a2, a2, 2
	mul	a2, a2, a5
	mul	a6, a6, a5
	ori	s1, a0, 1
	mul	s1, s1, a5
	mul	a5, t1, a5
	add	t1, t1, a3
	slli	a3, a3, 2
	slli	a5, a5, 2
	add	t4, a1, t4
	add	t2, a1, t2
	add	s3, a1, s1
	add	a5, a1, a5
	add	s2, a1, a6
	add	s1, a1, a2
	add	a1, a1, a3
	add	s4, a3, a0
	add	s5, a2, a0
	add	a7, a7, a0
	add	a6, a6, a0
	add	a2, a5, a4
	add	a5, s3, a4
	add	a1, a1, a4
	add	s3, s1, a4
	add	a3, t2, a4
	add	a0, s2, a4
	add	a4, t4, a4
	slli	a1, a1, 2
	add	s1, t5, a1
	lw	a1, 0(s1)
	sw	a1, 144(sp)
	slli	a5, a5, 2
	slli	a2, a2, 2
	slli	a3, a3, 2
	slli	a1, a4, 2
	add	s2, t6, a1
	add	t4, t6, a3
	add	s6, t6, a2
	add	a3, t6, a5
	slli	a4, s3, 2
	slli	a0, a0, 2
	add	t6, t5, a0
	add	a4, t5, a4
	slli	t5, a6, 2
	slli	a1, a7, 2
	slli	a2, s5, 2
	slli	a5, s4, 2
	slli	a0, t1, 4
	add	t2, t0, a0
	add	a0, t0, a5
	sd	a0, 0(sp)
	add	s3, t0, a2
	add	t1, t0, a1
	add	t0, t0, t5
	lw	a0, 0(s2)
	sw	a0, 140(sp)
	lw	a0, 0(t6)
	sw	a0, 136(sp)
	lw	a0, 0(t4)
	sw	a0, 132(sp)
	lw	a0, 0(t6)
	sw	a0, 128(sp)
	lw	a0, 0(s6)
	sw	a0, 124(sp)
	lw	a0, 0(s1)
	sw	a0, 120(sp)
	lw	a0, 0(a3)
	sw	a0, 116(sp)
	lw	a0, 0(s6)
	sw	a0, 112(sp)
	lw	a0, 0(t3)
	sw	a0, 108(sp)
	lw	a0, 0(a3)
	sw	a0, 104(sp)
	lw	a0, 0(s1)
	sw	a0, 100(sp)
	lw	a0, 0(s2)
	sw	a0, 96(sp)
	lw	a0, 0(s1)
	sw	a0, 92(sp)
	lw	a0, 0(t4)
	sw	a0, 88(sp)
	lw	a0, 0(s1)
	sw	a0, 84(sp)
	lw	a0, 0(s6)
	sw	a0, 80(sp)
	lw	a0, 0(t6)
	sw	a0, 76(sp)
	lw	a0, 0(a3)
	sw	a0, 72(sp)
	lw	a0, 0(t6)
	sw	a0, 68(sp)
	lw	a0, 0(a3)
	sw	a0, 64(sp)
	lw	a0, 0(t3)
	sw	a0, 60(sp)
	lw	a0, 0(s2)
	sw	a0, 56(sp)
	lw	a0, 0(t3)
	sw	a0, 52(sp)
	lw	a0, 0(t4)
	sw	a0, 48(sp)
	lw	a0, 0(t3)
	sw	a0, 44(sp)
	lw	a0, 0(a4)
	sw	a0, 40(sp)
	lw	a0, 0(s6)
	sw	a0, 36(sp)
	lw	a0, 0(a4)
	sw	a0, 32(sp)
	lw	a0, 0(a4)
	sw	a0, 28(sp)
	lw	a0, 0(s2)
	sw	a0, 24(sp)
	lw	a0, 0(a4)
	sw	a0, 20(sp)
	lw	a0, 0(t4)
	sw	a0, 16(sp)
	lw	a0, 0(a4)
	sw	a0, 12(sp)
	lw	a0, 0(t6)
	sw	a0, 8(sp)
	addi	t3, t2, 4
	addi	t4, t2, 8
	addi	t5, t2, 12
	addi	s2, sp, 112
	addi	s4, sp, 104
	addi	s5, sp, 100
	addi	s6, sp, 96
	addi	s7, sp, 92
	addi	s8, sp, 88
	addi	s9, sp, 84
	addi	s10, sp, 80
	addi	s11, sp, 76
	addi	a0, t0, 12
	addi	a1, t0, 4
	addi	a2, t0, 8
	addi	a3, t1, 4
	addi	a4, t1, 8
	addi	a5, t1, 12
	addi	a6, s3, 4
	addi	a7, s3, 8
	addi	t2, s3, 12
	addi	t6, sp, 148
	vmcs	vs1,t6
	addi	s1, sp, 144
	vmcs	vs2,s1
	addi	s1, sp, 140
	vmcs	vs3,s1
	addi	s1, sp, 136
	vmcs	vs4,s1
	addi	s1, sp, 132
	vmcs	vs5,s1
	addi	s1, sp, 128
	vmcs	vs6,s1
	addi	s1, sp, 124
	vmcs	vs7,s1
	addi	s1, sp, 120
	vmcs	vs8,s1
	addi	s1, sp, 116
	vmcs	vs9,s1
	vmcs	vs10,s2
	addi	s1, sp, 108
	vmcs	vs11,s1
	vmcs	vs12,s4
	vmcs	vs13,s5
	vmcs	vs14,s6
	vmcs	vs15,s7
	vmcs	vs16,s8
	vmcs	vs17,s9
	vmcs	vs18,s10
	vmcs	vs19,s11
	addi	s1, sp, 72
	vmcs	vs20,s1
	addi	s1, sp, 68
	vmcs	vs21,s1
	addi	s1, sp, 64
	vmcs	vs22,s1
	addi	s1, sp, 60
	vmcs	vs23,s1
	addi	s1, sp, 56
	vmcs	vs24,s1
	addi	s1, sp, 52
	vmcs	vs25,s1
	addi	s1, sp, 48
	vmcs	vs26,s1
	addi	s1, sp, 44
	vmcs	vs27,s1
	addi	s1, sp, 40
	vmcs	vs28,s1
	addi	s1, sp, 36
	vmcs	vs29,s1
	addi	s1, sp, 32
	vmcs	vs30,s1
	addi	s1, sp, 28
	vmcs	vs31,s1
	addi	s1, sp, 24
	vmcs	vs32,s1
	addi	s1, sp, 20
	vmcs	vs33,s1
	addi	s1, sp, 16
	vmcs	vs34,s1
	addi	s1, sp, 12
	vmcs	vs35,s1
	addi	s1, sp, 8
	vmcs	vs36,s1
	ld	s1, 0(sp)
	vmcs	vs37,s1
	vmcs	vs38,a0
	vmcs	vs39,t3
	vmcs	vs40,t1
	vmcs	vs41,t4
	vmcs	vs42,t5
	vmcs	vs43,t0
	vmcs	vs44,a1
	vmcs	vs45,a2
	vmcs	vs46,a3
	vmcs	vs47,a4
	vmcs	vs48,a5
	vmcs	vs49,s3
	vmcs	vs50,a6
	vmcs	vs51,a7
	vmcs	vs52,t2
	vsetcfg	a0,1,0,0,1
	li	a0, 4
	vsetvl	a0,a0
	vf	_pocl_launcher_sgemm_unroll
	ld	s11, 152(sp)
	ld	s10, 160(sp)
	ld	s9, 168(sp)
	ld	s8, 176(sp)
	ld	s7, 184(sp)
	ld	s6, 192(sp)
	ld	s5, 200(sp)
	ld	s4, 208(sp)
	ld	s3, 216(sp)
	ld	s2, 224(sp)
	ld	s1, 232(sp)
	addi	sp, sp, 240
	ret
.Lfunc_end1:
	.size	_pocl_launcher_sgemm_unroll_workgroup, .Lfunc_end1-_pocl_launcher_sgemm_unroll_workgroup
                                        # -- End function
	.globl	pocl.barrier            # -- Begin function pocl.barrier
	.p2align	2
	.type	pocl.barrier,@function
pocl.barrier:                           # @pocl.barrier
# %bb.0:
	ret
.Lfunc_end2:
	.size	pocl.barrier, .Lfunc_end2-pocl.barrier
                                        # -- End function

	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm ea484e8fe591e40d9c18ce982f25f006610ea782)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.section	".note.GNU-stack","",@progbits
