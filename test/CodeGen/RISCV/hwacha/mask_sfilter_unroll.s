	.text
	.file	"mask_sfilter_unroll.ll"
	.p2align	2               # -- Begin function _pocl_launcher_mask_sfilter_unroll
	.type	_pocl_launcher_mask_sfilter_unroll,@function
_pocl_launcher_mask_sfilter_unroll:     # @_pocl_launcher_mask_sfilter_unroll
# %bb.0:
	vpset	vp0
	vslli	vs14, vs14, 7
	vadd	vs14, vs14, vs16
	veidx	vv0
	@vp0	vadd	vv0, vs14, vv0
	vadd	vs14, vs17, vs15
	vslli	vs14, vs14, 1
	vlshu	vs15, vs19
	@vp0	vcmpeq	vp1, vs15, vs0
	@!vp1	vcjal	1, vs0, .LBB0_1
	@vp1	vcjal	1, vs0, .LBB0_5
.LBB0_1:                                # %if.then.i
	vlsw	vs15, vs21
	vfmul.s	vs15, vs15, vs6
	vlsw	vs16, vs20
	vfmul.s	vs16, vs16, vs5
	vfadd.s	vs15, vs16, vs15
	vlsw	vs16, vs22
	vfmul.s	vs16, vs16, vs7
	vfadd.s	vs15, vs15, vs16
	vlsw	vs16, vs23
	vfmul.s	vs16, vs16, vs8
	vfadd.s	vs15, vs15, vs16
	vlsw	vs16, vs24
	vfmul.s	vs16, vs16, vs9
	vfadd.s	vs15, vs15, vs16
	vlsw	vs16, vs25
	vfmul.s	vs16, vs16, vs10
	vfadd.s	vs15, vs15, vs16
	vlsw	vs16, vs26
	vfmul.s	vs16, vs16, vs11
	vfadd.s	vs15, vs15, vs16
	vlsw	vs16, vs18
	vfmul.s	vs16, vs16, vs13
	vlsw	vs17, vs27
	vfmul.s	vs17, vs17, vs12
	vfadd.s	vs15, vs15, vs17
	vfadd.s	vs15, vs15, vs16
	@vp0	vsxw	vs15, vs0, vs28
	vori	vs15, vs14, 1
	vmul	vs14, vs15, vs3
	@vp0	vadd	vv1, vv0, vs14
.LBB0_2:                                # %if.end.i
	vaddi	vs16, vs0, 1
	@vp0	vsll	vv2, vv1, vs16
	@vp0	vadd	vv2, vs4, vv2
	@vp0	vlxhu	vv7, vs0, vv2
	@vp0	vcmpeq	vp1, vv7, vs0
	@vp1	vcjal	1, vs0, .LBB0_4
	@!vp1	vcjal	1, vs0, .LBB0_3
.LBB0_3:                                # %if.then.66.i
	vlsw	vs4, vs30
	vfmul.s	vs4, vs4, vs6
	vlsw	vs6, vs29
	vfmul.s	vs5, vs6, vs5
	vfadd.s	vs4, vs5, vs4
	vlsw	vs5, vs31
	vfmul.s	vs5, vs5, vs7
	vfadd.s	vs4, vs4, vs5
	vaddi	vs5, vs0, -1
	@vp0	vadd	vv2, vv0, vs5
	@vp0	vadd	vv3, vs14, vv2
	vaddi	vs5, vs0, 2
	@vp0	vsll	vv3, vv3, vs5
	@vp0	vadd	vv3, vs1, vv3
	@vp0	vlxw	vv5, vs0, vv3
	@vp0	vfmul.s	vv5, vv5, vs8
	@vp0	vfadd.s	vv5, vs4, vv5
	vaddi	vs4, vs0, 2
	@vp0	vsll	vv1, vv1, vs4
	@vp0	vadd	vv3, vs1, vv1
	@vp0	vlxw	vv6, vs0, vv3
	@vp0	vfmul.s	vv6, vv6, vs9
	@vp0	vfadd.s	vv5, vv5, vv6
	vaddi	vs4, vs15, 1
	vmul	vs3, vs4, vs3
	vaddi	vs4, vs0, 1
	@vp0	vadd	vv3, vv0, vs4
	@vp0	vadd	vv4, vs14, vv3
	vaddi	vs4, vs0, 2
	@vp0	vsll	vv4, vv4, vs4
	@vp0	vadd	vv4, vs1, vv4
	@vp0	vlxw	vv6, vs0, vv4
	@vp0	vfmul.s	vv6, vv6, vs10
	@vp0	vadd	vv1, vs2, vv1
	@vp0	vfadd.s	vv5, vv5, vv6
	@vp0	vadd	vv3, vs3, vv3
	@vp0	vadd	vv0, vs3, vv0
	@vp0	vadd	vv2, vs3, vv2
	vaddi	vs2, vs0, 2
	@vp0	vsll	vv2, vv2, vs2
	@vp0	vadd	vv2, vs1, vv2
	@vp0	vlxw	vv6, vs0, vv2
	@vp0	vfmul.s	vv6, vv6, vs11
	@vp0	vfadd.s	vv5, vv5, vv6
	vaddi	vs2, vs0, 2
	@vp0	vsll	vv0, vv0, vs2
	@vp0	vadd	vv0, vs1, vv0
	@vp0	vlxw	vv6, vs0, vv0
	@vp0	vfmul.s	vv6, vv6, vs12
	@vp0	vfadd.s	vv5, vv5, vv6
	vaddi	vs2, vs0, 2
	@vp0	vsll	vv0, vv3, vs2
	@vp0	vadd	vv0, vs1, vv0
	@vp0	vlxw	vv6, vs0, vv0
	@vp0	vfmul.s	vv6, vv6, vs13
	@vp0	vfadd.s	vv5, vv5, vv6
	@vp0	vsxw	vv5, vs0, vv1
.LBB0_4:                                # %mask_sfilter_unroll.exit
	vstop	
.LBB0_5:                                # %entry.if.end_crit_edge.i
	vori	vs15, vs14, 1
	vmul	vs14, vs15, vs3
	@vp0	vadd	vv1, vv0, vs14
	@vp0	vcjal	1, vs0, .LBB0_2
.Lfunc_end0:
	.size	_pocl_launcher_mask_sfilter_unroll, .Lfunc_end0-_pocl_launcher_mask_sfilter_unroll
                                        # -- End function
	.globl	_pocl_launcher_mask_sfilter_unroll_workgroup # -- Begin function _pocl_launcher_mask_sfilter_unroll_workgroup
	.p2align	2
	.type	_pocl_launcher_mask_sfilter_unroll_workgroup,@function
_pocl_launcher_mask_sfilter_unroll_workgroup: # @_pocl_launcher_mask_sfilter_unroll_workgroup
# %bb.0:
	addi	sp, sp, -144
	sd	s1, 136(sp)
	sd	s2, 128(sp)
	sd	s3, 120(sp)
	sd	s4, 112(sp)
	sd	s5, 104(sp)
	sd	s6, 96(sp)
	sd	s7, 88(sp)
	sd	s8, 80(sp)
	sd	s9, 72(sp)
	sd	s10, 64(sp)
	sd	s11, 56(sp)
	ld	a2, 16(a0)
	ld	t4, 0(a2)
	ld	a7, 40(a1)
	ld	a6, 64(a1)
	add	a2, a6, a7
	slli	a3, a2, 1
	ori	a4, a3, 1
	mul	a4, t4, a4
	ld	t2, 56(a1)
	add	a4, t2, a4
	ld	t0, 32(a1)
	slli	a1, t0, 7
	add	a4, a4, a1
	slli	a4, a4, 2
	ld	a5, 96(a0)
	flw	ft0, 0(a5)
	ld	a5, 88(a0)
	flw	ft1, 0(a5)
	ld	a5, 80(a0)
	flw	ft2, 0(a5)
	ld	a5, 72(a0)
	flw	ft3, 0(a5)
	ld	a5, 64(a0)
	flw	ft4, 0(a5)
	ld	a5, 56(a0)
	flw	ft5, 0(a5)
	ld	a5, 48(a0)
	flw	ft6, 0(a5)
	ld	a5, 40(a0)
	flw	ft7, 0(a5)
	ld	a5, 32(a0)
	flw	fa0, 0(a5)
	ld	a5, 8(a0)
	ld	t3, 0(a5)
	ld	a5, 24(a0)
	ld	t1, 0(a5)
	ld	a0, 0(a0)
	ld	a0, 0(a0)
	add	a4, a0, a4
	lw	a5, 4(a4)
	sw	a5, 52(sp)
	mul	a2, t4, a2
	slli	a2, a2, 1
	add	a2, t2, a2
	add	a2, a2, a1
	slli	a5, a2, 1
	add	a5, t1, a5
	lh	a5, 0(a5)
	sh	a5, 50(sp)
	addi	a3, a3, -1
	mul	a3, t4, a3
	add	a3, t2, a3
	add	a1, a3, a1
	slli	a1, a1, 2
	add	a1, a0, a1
	lw	a3, -4(a1)
	sw	a3, 44(sp)
	lw	a3, 0(a1)
	sw	a3, 40(sp)
	lw	a1, 4(a1)
	sw	a1, 36(sp)
	slli	a1, a2, 2
	add	a2, a0, a1
	lw	a3, -4(a2)
	sw	a3, 32(sp)
	lw	a3, 0(a2)
	sw	a3, 28(sp)
	lw	a3, 4(a2)
	sw	a3, 24(sp)
	lw	a3, -4(a4)
	sw	a3, 20(sp)
	lw	a3, 0(a4)
	sw	a3, 16(sp)
	add	a1, t3, a1
	lw	a1, 0(a1)
	sw	a1, 12(sp)
	lw	a1, -4(a2)
	sw	a1, 8(sp)
	lw	a1, 0(a2)
	sw	a1, 4(sp)
	lw	a1, 4(a2)
	sw	a1, 0(sp)
	fmv.x.w	a1, fa0
	fmv.x.w	a2, ft7
	fmv.x.w	a3, ft6
	fmv.x.w	a4, ft5
	fmv.x.w	a5, ft4
	fmv.x.w	t5, ft3
	fmv.x.w	t6, ft2
	fmv.x.w	s1, ft1
	fmv.x.w	s2, ft0
	addi	s3, sp, 52
	addi	s4, sp, 50
	addi	s5, sp, 44
	addi	s6, sp, 40
	addi	s7, sp, 36
	addi	s8, sp, 32
	addi	s9, sp, 28
	addi	s10, sp, 24
	addi	s11, sp, 20
	vmcs	vs1,a0
	vmcs	vs2,t3
	vmcs	vs3,t4
	vmcs	vs4,t1
	vmcs	vs5,a1
	vmcs	vs6,a2
	vmcs	vs7,a3
	vmcs	vs8,a4
	vmcs	vs9,a5
	vmcs	vs10,t5
	vmcs	vs11,t6
	vmcs	vs12,s1
	vmcs	vs13,s2
	vmcs	vs14,t0
	vmcs	vs15,a7
	vmcs	vs16,t2
	vmcs	vs17,a6
	vmcs	vs18,s3
	vmcs	vs19,s4
	vmcs	vs20,s5
	vmcs	vs21,s6
	vmcs	vs22,s7
	vmcs	vs23,s8
	vmcs	vs24,s9
	vmcs	vs25,s10
	vmcs	vs26,s11
	addi	a0, sp, 16
	vmcs	vs27,a0
	addi	a0, sp, 12
	vmcs	vs28,a0
	addi	a0, sp, 8
	vmcs	vs29,a0
	addi	a0, sp, 4
	vmcs	vs30,a0
	mv	a0, sp
	vmcs	vs31,a0
	vsetcfg	a0,5,2,1,2
	li	a0, 4
	vsetvl	a0,a0
	vf	_pocl_launcher_mask_sfilter_unroll
	ld	s11, 56(sp)
	ld	s10, 64(sp)
	ld	s9, 72(sp)
	ld	s8, 80(sp)
	ld	s7, 88(sp)
	ld	s6, 96(sp)
	ld	s5, 104(sp)
	ld	s4, 112(sp)
	ld	s3, 120(sp)
	ld	s2, 128(sp)
	ld	s1, 136(sp)
	addi	sp, sp, 144
	ret
.Lfunc_end1:
	.size	_pocl_launcher_mask_sfilter_unroll_workgroup, .Lfunc_end1-_pocl_launcher_mask_sfilter_unroll_workgroup
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
