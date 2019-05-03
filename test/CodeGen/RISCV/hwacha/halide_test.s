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
	mv	s2, a2
	mv	s3, a1
	addi	s0, zero, 1
	sext.w	s4, a0
	addi	s5, zero, 100
.LBB1_1:                                # %loop
                                        # =>This Inner Loop Header: Depth=1
	slli	a0, s0, 2
	add	a0, s2, a0
	add	a1, s0, s4
	slli	a1, a1, 2
	add	a1, s3, a1
	sub	a2, s5, s0
	vmcs	vs1,a2
	vmca	va1,a1
	vmca	va2,a0
	vsetcfg	a0,0,1,0,1
	vsetvl	s1,a2
	la	a0, kernel_output_s0_x___block_id_x
	vf	0(a0)
	add	s0, s0, s1
	beq	s0, s5, .LBB1_1
# %bb.2:                                # %afterloop
	ld	s5, 0(sp)
	ld	s4, 8(sp)
	ld	s3, 16(sp)
	ld	s2, 24(sp)
	ld	s1, 32(sp)
	ld	s0, 40(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end1:
	.size	stripmine, .Lfunc_end1-stripmine
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
