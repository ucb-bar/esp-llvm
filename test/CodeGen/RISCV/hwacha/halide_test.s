	.text
	.file	"halide_test.ll"
	.globl	kernel_output_s0_x___block_id_x # -- Begin function kernel_output_s0_x___block_id_x
	.p2align	3
	.type	kernel_output_s0_x___block_id_x,@function
kernel_output_s0_x___block_id_x:        # @kernel_output_s0_x___block_id_x
# %bb.0:                                # %body
	vpset	vp0
	@vp0	vlw	vv0, va1
	vaddi	vs1, vs0, 1
	@vp0	vsll	vv0, vv0, vs1
	@vp0	vsw	vv0, va2
	vstop	
.Lfunc_end0:
	.size	kernel_output_s0_x___block_id_x, .Lfunc_end0-kernel_output_s0_x___block_id_x
                                        # -- End function
	.globl	kernel_output.s0.x.__block_id_x_trunc # -- Begin function kernel_output.s0.x.__block_id_x_trunc
	.p2align	3
	.type	kernel_output.s0.x.__block_id_x_trunc,@function
kernel_output.s0.x.__block_id_x_trunc:  # @kernel_output.s0.x.__block_id_x_trunc
# %bb.0:                                # %body
	vpset	vp0
	veidx	vv0
	vaddi	vs1, vs0, 0
	@vp0	vaddw	vv1, vv0, vs1
	vaddi	vs1, vs0, 2
	@vp0	vsll	vv1, vv1, vs1
	@vp0	vadd	vv1, vs4, vv1
	@vp0	vaddw	vv0, vv0, vs2
	vaddi	vs1, vs0, 2
	@vp0	vsll	vv0, vv0, vs1
	@vp0	vadd	vv0, vs3, vv0
	@vp0	vlxw	vv2, vs0, vv0
	@vp0	vsxw	vv2, vs0, vv1
	vstop	
.Lfunc_end1:
	.size	kernel_output.s0.x.__block_id_x_trunc, .Lfunc_end1-kernel_output.s0.x.__block_id_x_trunc
                                        # -- End function
	.globl	nonstripmine            # -- Begin function nonstripmine
	.p2align	2
	.type	nonstripmine,@function
nonstripmine:                           # @nonstripmine
# %bb.0:
	addi	a3, zero, 5
	vmcs	vs1,a3
	vmcs	vs2,a0
	vmcs	vs3,a1
	vmcs	vs4,a2
	vsetcfg	a0,2,1,0,1
	vsetvl	a0,a3
	la	a0, kernel_output.s0.x.__block_id_x_trunc
	vf	0(a0)
	ret
.Lfunc_end2:
	.size	nonstripmine, .Lfunc_end2-nonstripmine
                                        # -- End function
	.globl	stripmine               # -- Begin function stripmine
	.p2align	2
	.type	stripmine,@function
stripmine:                              # @stripmine
# %bb.0:                                # %entry
	addi	sp, sp, -48
	sd	s0, 40(sp)
	sd	s1, 32(sp)
	sd	s2, 24(sp)
	sd	s3, 16(sp)
	sd	s4, 8(sp)
	sd	s5, 0(sp)
	mv	s3, a2
	mv	s4, a1
	mv	s2, a0
	addi	a0, a1, 40
	addi	a1, a2, 20
	addi	a2, zero, 5
	vmcs	vs1,a2
	vmca	va1,a0
	vmca	va2,a1
	vsetcfg	a0,0,1,0,1
	vsetvl	a0,a2
	la	a0, kernel_output_s0_x___block_id_x
	vf	0(a0)
	addi	s0, zero, 1
	sext.w	s2, s2
	addi	s5, zero, 100
.LBB3_1:                                # %loop
                                        # =>This Inner Loop Header: Depth=1
	slli	a0, s0, 2
	add	a0, s3, a0
	add	a1, s0, s2
	slli	a1, a1, 2
	add	a1, s4, a1
	sub	a2, s5, s0
	vmcs	vs1,a2
	vmca	va1,a1
	vmca	va2,a0
	vsetcfg	a0,0,1,0,1
	vsetvl	s1,a2
	la	a0, kernel_output_s0_x___block_id_x
	vf	0(a0)
	add	s0, s0, s1
	beq	s0, s5, .LBB3_1
# %bb.2:                                # %afterloop
	ld	s5, 0(sp)
	ld	s4, 8(sp)
	ld	s3, 16(sp)
	ld	s2, 24(sp)
	ld	s1, 32(sp)
	ld	s0, 40(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end3:
	.size	stripmine, .Lfunc_end3-stripmine
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
