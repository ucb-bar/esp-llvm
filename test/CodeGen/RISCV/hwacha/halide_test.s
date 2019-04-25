	.text
	.file	"halide_test.ll"
	.p2align	2               # -- Begin function output.s0.x.__block_id_x
	.type	output.s0.x.__block_id_x,@function
output.s0.x.__block_id_x:               # @output.s0.x.__block_id_x
# %bb.0:                                # %body
	vpset	vp0
	veidx	vv0
	vaddi	vs4, vs0, 0
	@vp0	vaddw	vv1, vv0, vs4
	vaddi	vs4, vs0, 2
	@vp0	vsll	vv1, vv1, vs4
	@vp0	vadd	vv1, vs3, vv1
	@vp0	vaddw	vv0, vv0, vs1
	vaddi	vs1, vs0, 2
	@vp0	vsll	vv0, vv0, vs1
	@vp0	vadd	vv0, vs2, vv0
	@vp0	vlxw	vv2, vs0, vv0
	@vp0	vsxw	vv2, vs0, vv1
	vstop	
.Lfunc_end0:
	.size	output.s0.x.__block_id_x, .Lfunc_end0-output.s0.x.__block_id_x
                                        # -- End function
	.globl	kernel_output_s0_x___block_id_x # -- Begin function kernel_output_s0_x___block_id_x
	.p2align	2
	.type	kernel_output_s0_x___block_id_x,@function
kernel_output_s0_x___block_id_x:        # @kernel_output_s0_x___block_id_x
# %bb.0:                                # %body
	vmcs	vs1,a0
	vmcs	vs2,a1
	vmcs	vs3,a2
	vsetcfg	a0,2,1,0,1
	li	a0, 4
	vsetvl	a0,a0
	vf	output.s0.x.__block_id_x
	ret
.Lfunc_end1:
	.size	kernel_output_s0_x___block_id_x, .Lfunc_end1-kernel_output_s0_x___block_id_x
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
