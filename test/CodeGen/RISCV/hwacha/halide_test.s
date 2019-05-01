	.text
	.file	"halide_test.ll"
	.globl	output.s0.x.__block_id_x # -- Begin function output.s0.x.__block_id_x
	.p2align	2
	.type	output.s0.x.__block_id_x,@function
output.s0.x.__block_id_x:               # @output.s0.x.__block_id_x
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
.Lfunc_end0:
	.size	output.s0.x.__block_id_x, .Lfunc_end0-output.s0.x.__block_id_x
                                        # -- End function
	.globl	kernel_output_s0_x___block_id_x # -- Begin function kernel_output_s0_x___block_id_x
	.p2align	2
	.type	kernel_output_s0_x___block_id_x,@function
kernel_output_s0_x___block_id_x:        # @kernel_output_s0_x___block_id_x
# %bb.0:                                # %body
	addi	a3, zero, 5
	vmcs	vs1,a3
	vmcs	vs2,a0
	vmcs	vs3,a1
	vmcs	vs4,a2
	vsetcfg	a0,2,1,0,1
	vsetvl	a0,a3
	la	a0, output.s0.x.__block_id_x
	vf	0(a0)
	ret
.Lfunc_end1:
	.size	kernel_output_s0_x___block_id_x, .Lfunc_end1-kernel_output_s0_x___block_id_x
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
