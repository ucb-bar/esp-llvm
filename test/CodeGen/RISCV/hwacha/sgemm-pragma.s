	.text
	.file	"sgemm-pragma.ll"
	.p2align	2               # -- Begin function _pocl_launcher_sgemm_unroll
	.type	_pocl_launcher_sgemm_unroll,@function
_pocl_launcher_sgemm_unroll:            # @_pocl_launcher_sgemm_unroll
# %bb.0:                                # %for.cond.4.preheader.i
	vpset	vp0
	vlsw	vs1, vs1
	@vp0	vlw	vv0, va2
	@vp0	vfmul.s	vv0, vs1, vv0
	@vp0	vlw	vv1, va1
	@vp0	vfadd.s	vv0, vv1, vv0
	@vp0	vsw	vv0, va1
	vlsw	vs1, vs2
	@vp0	vlw	vv1, va3
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va1
	vlsw	vs1, vs3
	@vp0	vlw	vv1, va4
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va1
	vlsw	vs1, vs4
	@vp0	vlw	vv1, va5
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va1
	vlsw	vs1, vs5
	@vp0	vlw	vv0, va2
	@vp0	vfmul.s	vv0, vs1, vv0
	@vp0	vlw	vv1, va6
	@vp0	vfadd.s	vv0, vv1, vv0
	@vp0	vsw	vv0, va6
	vlsw	vs1, vs6
	@vp0	vlw	vv1, va3
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va6
	vlsw	vs1, vs7
	@vp0	vlw	vv1, va4
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va6
	vlsw	vs1, vs8
	@vp0	vlw	vv1, va5
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va6
	vlsw	vs1, vs9
	@vp0	vlw	vv0, va2
	@vp0	vfmul.s	vv0, vs1, vv0
	@vp0	vlw	vv1, va7
	@vp0	vfadd.s	vv0, vv1, vv0
	@vp0	vsw	vv0, va7
	vlsw	vs1, vs10
	@vp0	vlw	vv1, va3
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va7
	vlsw	vs1, vs11
	@vp0	vlw	vv1, va4
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va7
	vlsw	vs1, vs12
	@vp0	vlw	vv1, va5
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va7
	@vp0	vlw	vv0, va2
	vlsw	vs1, vs13
	@vp0	vfmul.s	vv0, vs1, vv0
	@vp0	vlw	vv1, va8
	@vp0	vfadd.s	vv0, vv1, vv0
	@vp0	vsw	vv0, va8
	@vp0	vlw	vv1, va3
	vlsw	vs1, vs14
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va8
	@vp0	vlw	vv1, va4
	vlsw	vs1, vs15
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va8
	@vp0	vlw	vv1, va5
	vlsw	vs1, vs16
	@vp0	vfmul.s	vv1, vs1, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	@vp0	vsw	vv0, va8
	vstop	
.Lfunc_end0:
	.size	_pocl_launcher_sgemm_unroll, .Lfunc_end0-_pocl_launcher_sgemm_unroll
                                        # -- End function
	.globl	_pocl_launcher_sgemm_unroll_workgroup # -- Begin function _pocl_launcher_sgemm_unroll_workgroup
	.p2align	2
	.type	_pocl_launcher_sgemm_unroll_workgroup,@function
_pocl_launcher_sgemm_unroll_workgroup:  # @_pocl_launcher_sgemm_unroll_workgroup
# %bb.0:
	addi	sp, sp, -112
	sd	s1, 104(sp)
	sd	s2, 96(sp)
	sd	s3, 88(sp)
	sd	s4, 80(sp)
	sd	s5, 72(sp)
	sd	s6, 64(sp)
	sd	s7, 56(sp)
	sd	s8, 48(sp)
	sd	s9, 40(sp)
	ld	a2, 48(a1)
	ld	a3, 72(a1)
	add	a6, a3, a2
	ld	a3, 40(a1)
	ld	a4, 64(a1)
	add	t1, a4, a3
	ld	a4, 32(a1)
	slli	a4, a4, 7
	ld	a5, 56(a1)
	ld	a1, 24(a0)
	lw	a2, 0(a1)
	mul	a7, a6, a2
	slli	t0, a7, 2
	add	a1, a5, t0
	add	a1, a1, a4
	slli	a1, a1, 2
	ld	a3, 16(a0)
	ld	t2, 0(a3)
	add	a3, t2, a1
	ld	a1, 0(a0)
	ld	t4, 0(a1)
	ld	a0, 8(a0)
	ld	t3, 0(a0)
	lw	a3, 0(a3)
	sw	a3, 36(sp)
	slli	a3, a6, 2
	ori	a0, a3, 1
	ori	a1, a3, 2
	ori	a3, a3, 3
	mul	t5, a3, a2
	mul	a6, a1, a2
	mul	a0, a0, a2
	slli	a1, t1, 2
	ori	a3, a1, 1
	mul	t6, a3, a2
	ori	a3, a1, 3
	mul	a3, a3, a2
	ori	s1, a1, 2
	mul	s1, s1, a2
	mul	a2, t1, a2
	add	a7, t1, a7
	slli	a2, a2, 2
	add	a2, a5, a2
	add	a2, a2, a4
	slli	a2, a2, 2
	add	a2, t3, a2
	lw	a2, 0(a2)
	sw	a2, 32(sp)
	add	t1, a5, s1
	add	s2, a5, a3
	add	s1, a5, t6
	add	a2, a5, a0
	add	a3, a5, a6
	add	a5, a5, t5
	add	t6, a0, a1
	add	t0, t0, a1
	add	t5, t5, a1
	add	a1, a6, a1
	add	s1, s1, a4
	add	a5, a5, a4
	add	a3, a3, a4
	add	a2, a2, a4
	add	a0, s2, a4
	add	a4, t1, a4
	slli	s1, s1, 2
	add	s1, t3, s1
	lw	s1, 0(s1)
	sw	s1, 28(sp)
	slli	a2, a2, 2
	slli	a3, a3, 2
	slli	a5, a5, 2
	add	a6, t2, a5
	add	t1, t2, a3
	add	t2, t2, a2
	slli	a4, a4, 2
	slli	a0, a0, 2
	add	a0, t3, a0
	add	a4, t3, a4
	slli	a1, a1, 2
	slli	s1, t5, 2
	slli	a5, t0, 2
	slli	a3, t6, 2
	slli	a2, a7, 4
	add	a2, t4, a2
	add	a3, t4, a3
	add	t6, t4, a5
	add	s1, t4, s1
	add	a1, t4, a1
	lw	a4, 0(a4)
	sw	a4, 24(sp)
	lw	a0, 0(a0)
	sw	a0, 20(sp)
	lw	a0, 0(t2)
	sw	a0, 16(sp)
	lw	a0, 0(t1)
	sw	a0, 12(sp)
	lw	a0, 0(a6)
	sw	a0, 8(sp)
	addi	s2, a2, 4
	addi	s4, a2, 8
	addi	s3, a2, 12
	addi	a6, sp, 36
	addi	a7, sp, 32
	addi	t0, sp, 28
	addi	t1, sp, 24
	addi	t2, sp, 20
	addi	t3, sp, 16
	addi	t4, sp, 12
	addi	t5, sp, 8
	addi	a5, a3, 4
	addi	a0, a3, 8
	addi	a2, a3, 12
	addi	a4, a1, 4
	addi	s5, a1, 8
	addi	s6, a1, 12
	addi	s7, s1, 4
	addi	s8, s1, 8
	addi	s9, s1, 12
	vmca	va1,a6
	vmca	va2,a7
	vmca	va3,t0
	vmca	va4,t1
	vmca	va5,t2
	vmca	va6,t3
	vmca	va7,t4
	vmca	va8,t5
	vmcs	vs1,t6
	vmcs	vs2,s2
	vmcs	vs3,s4
	vmcs	vs4,s3
	vmcs	vs5,a3
	vmcs	vs6,a5
	vmcs	vs7,a0
	vmcs	vs8,a2
	vmcs	vs9,a1
	vmcs	vs10,a4
	vmcs	vs11,s5
	vmcs	vs12,s6
	vmcs	vs13,s1
	vmcs	vs14,s7
	vmcs	vs15,s8
	vmcs	vs16,s9
	vsetcfg	a0,0,2,0,1
	li	a0, 4
	vsetvl	a0,a0
	vf	_pocl_launcher_sgemm_unroll
	ld	s9, 40(sp)
	ld	s8, 48(sp)
	ld	s7, 56(sp)
	ld	s6, 64(sp)
	ld	s5, 72(sp)
	ld	s4, 80(sp)
	ld	s3, 88(sp)
	ld	s2, 96(sp)
	ld	s1, 104(sp)
	addi	sp, sp, 112
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
