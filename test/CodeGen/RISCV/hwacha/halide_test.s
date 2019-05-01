	.text
	.file	"halide_test.ll"
	.globl	output.s0.x.__block_id_x # -- Begin function output.s0.x.__block_id_x
	.p2align	3
	.type	output.s0.x.__block_id_x,@function
output.s0.x.__block_id_x:               # @output.s0.x.__block_id_x
# %bb.0:                                # %body
	addi	sp, sp, -16
	sd	ra, 8(sp)
	sd	s0, 0(sp)
	addi	s0, sp, 16
	vpset	vp0
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
	addi	sp, s0, -16
	ld	s0, 0(sp)
	ld	ra, 8(sp)
	addi	sp, sp, 16
	vstop	
.Lfunc_end0:
	.size	output.s0.x.__block_id_x, .Lfunc_end0-output.s0.x.__block_id_x
                                        # -- End function
	.globl	kernel_output_s0_x___block_id_x # -- Begin function kernel_output_s0_x___block_id_x
	.p2align	2
	.type	kernel_output_s0_x___block_id_x,@function
kernel_output_s0_x___block_id_x:        # @kernel_output_s0_x___block_id_x
# %bb.0:                                # %entry
	addi	sp, sp, -64
	sd	ra, 56(sp)
	sd	s0, 48(sp)
	sd	s1, 40(sp)
	sd	s2, 32(sp)
	sd	s3, 24(sp)
	sd	s4, 16(sp)
	sd	s5, 8(sp)
	sd	s6, 0(sp)
	addi	s0, sp, 64
	mv	s2, a2
	mv	s3, a1
	mv	s4, a0
	addi	s1, zero, 1
	addi	s5, zero, 100
.LBB1_1:                                # %loop
                                        # =>This Inner Loop Header: Depth=1
	sub	a0, s5, s1
	vmcs	vs1,a0
	vmcs	vs2,s4
	vmcs	vs3,s3
	vmcs	vs4,s2
	vsetcfg	a1,2,1,0,1
	vsetvl	s6,a0
	la	a0, output.s0.x.__block_id_x
	vf	0(a0)
	add	s1, s1, s6
	beq	s1, s5, .LBB1_1
# %bb.2:                                # %afterloop
	addi	sp, s0, -64
	ld	s6, 0(sp)
	ld	s5, 8(sp)
	ld	s4, 16(sp)
	ld	s3, 24(sp)
	ld	s2, 32(sp)
	ld	s1, 40(sp)
	ld	s0, 48(sp)
	ld	ra, 56(sp)
	addi	sp, sp, 64
	ret
.Lfunc_end1:
	.size	kernel_output_s0_x___block_id_x, .Lfunc_end1-kernel_output_s0_x___block_id_x
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
