	.text
	.file	"maskdfilter.ll"
	.p2align	2               # -- Begin function _pocl_launcher_mask_dfilter
	.type	_pocl_launcher_mask_dfilter,@function
_pocl_launcher_mask_dfilter:            # @_pocl_launcher_mask_dfilter
# %bb.0:
	vpset	vp0
	@vp0	vlhu	vv3, va1
	@vp0	vcmpeq	vp1, vv3, vs0
	@vp1	vcjal	1, vs0, .LBB0_2
	@!vp1	vcjal	1, vs0, .LBB0_1
.LBB0_1:                                # %if.then.i
	fmv.d.x	ft0, vs9
	fmv.d.x	ft1, vs8
	fmv.d.x	ft2, vs7
	fmv.d.x	ft3, vs6
	fmv.d.x	ft4, vs5
	fmv.d.x	ft5, vs4
	fmv.d.x	ft6, vs3
	fmv.d.x	ft7, vs2
	fmv.d.x	fa0, vs1
	@vp0	vld	vv0, va4
	@vp0	vfmul.d	vv0, vv0, ft7
	@vp0	vld	vv1, va3
	@vp0	vfmul.d	vv1, vv1, fa0
	@vp0	vfadd.d	vv0, vv1, vv0
	@vp0	vld	vv1, va2
	@vp0	vfmul.d	vv1, vv1, ft6
	@vp0	vfadd.d	vv0, vv0, vv1
	@vp0	vld	vv1, va6
	@vp0	vfmul.d	vv1, vv1, ft5
	@vp0	vfadd.d	vv0, vv0, vv1
	@vp0	vld	vv1, va7
	@vp0	vfmul.d	vv1, vv1, ft4
	@vp0	vfadd.d	vv0, vv0, vv1
	@vp0	vld	vv1, va8
	@vp0	vfmul.d	vv1, vv1, ft3
	@vp0	vfadd.d	vv0, vv0, vv1
	@vp0	vld	vv1, va9
	@vp0	vfmul.d	vv1, vv1, ft2
	@vp0	vfadd.d	vv0, vv0, vv1
	@vp0	vld	vv1, va11
	@vp0	vfmul.d	vv1, vv1, ft0
	@vp0	vld	vv2, va10
	@vp0	vfmul.d	vv2, vv2, ft1
	@vp0	vfadd.d	vv0, vv0, vv2
	@vp0	vfadd.d	vv0, vv0, vv1
	@vp0	vsd	vv0, va5
.LBB0_2:                                # %mask_dfilter.exit
	vstop	
.Lfunc_end0:
	.size	_pocl_launcher_mask_dfilter, .Lfunc_end0-_pocl_launcher_mask_dfilter
                                        # -- End function
	.globl	_pocl_launcher_mask_dfilter_workgroup # -- Begin function _pocl_launcher_mask_dfilter_workgroup
	.p2align	2
	.type	_pocl_launcher_mask_dfilter_workgroup,@function
_pocl_launcher_mask_dfilter_workgroup:  # @_pocl_launcher_mask_dfilter_workgroup
# %bb.0:
	addi	sp, sp, -128
	sd	s1, 120(sp)
	sd	s2, 112(sp)
	sd	s3, 104(sp)
	sd	s4, 96(sp)
	sd	s5, 88(sp)
	ld	a2, 40(a1)
	ld	a3, 64(a1)
	add	a2, a3, a2
	ld	a3, 16(a0)
	ld	a3, 0(a3)
	mul	a4, a3, a2
	ld	t4, 56(a1)
	add	a4, t4, a4
	ld	a1, 32(a1)
	slli	a1, a1, 6
	add	t3, a4, a1
	ld	a4, 24(a0)
	ld	a4, 0(a4)
	slli	a5, t3, 1
	add	a4, a4, a5
	ld	a5, 96(a0)
	ld	a6, 0(a5)
	ld	a5, 88(a0)
	ld	a7, 0(a5)
	ld	a5, 80(a0)
	ld	t0, 0(a5)
	ld	a5, 72(a0)
	ld	t1, 0(a5)
	ld	a5, 64(a0)
	ld	t2, 0(a5)
	ld	a5, 56(a0)
	ld	t5, 0(a5)
	ld	a5, 48(a0)
	ld	t6, 0(a5)
	ld	a5, 40(a0)
	ld	s2, 0(a5)
	ld	s1, 32(a0)
	ld	s1, 0(s1)
	ld	a5, 8(a0)
	ld	a5, 0(a5)
	ld	a0, 0(a0)
	ld	a0, 0(a0)
	lh	a4, 0(a4)
	sh	a4, 86(sp)
	addi	a4, a2, -1
	addi	a2, a2, 1
	mul	a2, a3, a2
	mul	a3, a3, a4
	add	a3, t4, a3
	add	a3, a3, a1
	slli	a3, a3, 3
	add	a3, a0, a3
	ld	a4, 8(a3)
	sd	a4, 72(sp)
	add	a2, t4, a2
	add	a1, a2, a1
	ld	a2, -8(a3)
	sd	a2, 64(sp)
	slli	a1, a1, 3
	slli	a2, t3, 3
	add	a4, a5, a2
	add	a2, a0, a2
	add	a0, a0, a1
	ld	a1, 0(a3)
	sd	a1, 56(sp)
	ld	a1, 0(a4)
	sd	a1, 48(sp)
	ld	a1, -8(a2)
	sd	a1, 40(sp)
	ld	a1, 0(a2)
	sd	a1, 32(sp)
	ld	a1, 8(a2)
	sd	a1, 24(sp)
	ld	a1, -8(a0)
	sd	a1, 16(sp)
	ld	a1, 0(a0)
	sd	a1, 8(sp)
	ld	a0, 8(a0)
	sd	a0, 0(sp)
	addi	a0, sp, 86
	addi	a1, sp, 72
	addi	a2, sp, 64
	addi	a3, sp, 56
	addi	a4, sp, 48
	addi	a5, sp, 40
	addi	t3, sp, 32
	addi	t4, sp, 24
	addi	s3, sp, 16
	addi	s4, sp, 8
	mv	s5, sp
	vmcs	vs1,s1
	vmcs	vs2,s2
	vmcs	vs3,t6
	vmcs	vs4,t5
	vmcs	vs5,t2
	vmcs	vs6,t1
	vmcs	vs7,t0
	vmcs	vs8,a7
	vmcs	vs9,a6
	vmca	va1,a0
	vmca	va2,a1
	vmca	va3,a2
	vmca	va4,a3
	vmca	va5,a4
	vmca	va6,a5
	vmca	va7,t3
	vmca	va8,t4
	vmca	va9,s3
	vmca	va10,s4
	vmca	va11,s5
	vsetcfg	a0,3,0,1,2
	li	a0, 4
	vsetvl	a0,a0
	vf	_pocl_launcher_mask_dfilter
	ld	s5, 88(sp)
	ld	s4, 96(sp)
	ld	s3, 104(sp)
	ld	s2, 112(sp)
	ld	s1, 120(sp)
	addi	sp, sp, 128
	ret
.Lfunc_end1:
	.size	_pocl_launcher_mask_dfilter_workgroup, .Lfunc_end1-_pocl_launcher_mask_dfilter_workgroup
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

	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 2c5a12490b9af0b82717673d0ccde46a50a8bee5)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.section	".note.GNU-stack","",@progbits
