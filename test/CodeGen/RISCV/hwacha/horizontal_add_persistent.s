	.text
	.file	"horizontal_add_persistent.ll"
	.globl	horizontal_add          # -- Begin function horizontal_add
	.p2align	3
	.type	horizontal_add,@function
horizontal_add:                         # @horizontal_add
# %bb.0:                                # %body
	vpset	vp0
	@vp0	vlw	vv1, va1
	@vp0	vfmul.s	vv1, vv1, vs4
	@vp0	vlw	vv2, va2
	@vp0	vfadd.s	vv1, vv2, vv1
	@vp0	vfadd.s	vv0, vv0, vv1
	vstop	
.Lfunc_end0:
	.size	horizontal_add, .Lfunc_end0-horizontal_add
                                        # -- End function
	.globl	init_vector             # -- Begin function init_vector
	.p2align	3
	.type	init_vector,@function
init_vector:                            # @init_vector
# %bb.0:                                # %body
	vpset	vp0
	@vp0	vlw	vv0, va1
	vstop	
.Lfunc_end1:
	.size	init_vector, .Lfunc_end1-init_vector
                                        # -- End function
	.globl	store_vector            # -- Begin function store_vector
	.p2align	3
	.type	store_vector,@function
store_vector:                           # @store_vector
# %bb.0:                                # %body
	vpset	vp0
	@vp0	vsw	vv0, va1
	vstop	
.Lfunc_end2:
	.size	store_vector, .Lfunc_end2-store_vector
                                        # -- End function
	.globl	horizontal_add_launcher # -- Begin function horizontal_add_launcher
	.p2align	2
	.type	horizontal_add_launcher,@function
horizontal_add_launcher:                # @horizontal_add_launcher
# %bb.0:
	addi	sp, sp, -48
	sd	s0, 40(sp)
	sd	s1, 32(sp)
	sd	s2, 24(sp)
	sd	s3, 16(sp)
	sd	s4, 8(sp)
	sd	s5, 0(sp)
	mv	s2, a2
	mv	s5, a1
	mv	s0, a0
	addi	s4, zero, 1234
	vmcs	vs1,s4
	vmca	va1,s0
	vsetcfg	a0,0,3,0,1
	vsetvl	s1,s4
	la	a0, init_vector
	vf	0(a0)
	vmcs	vs1,s1
	vmcs	vs4,s2
	vmcs	vs5,a1
	vmca	va1,s0
	vmca	va2,s5
	vsetcfg	a0,0,3,0,1
	vsetvl	s3,s1
	la	a0, horizontal_add
	vf	0(a0)
	vmcs	vs1,s4
	vmcs	vs4,s2
	vmcs	vs5,a1
	vmca	va1,s0
	vmca	va2,s5
	vsetcfg	a0,0,3,0,1
	vsetvl	a0,s4
	la	a0, horizontal_add
	vf	0(a0)
	vmcs	vs1,s4
	vmcs	vs3,a1
	vmca	va1,s5
	vsetcfg	a0,0,3,0,1
	vsetvl	a0,s4
	la	a0, store_vector
	vf	0(a0)
	mv	a0, s3
	ld	s5, 0(sp)
	ld	s4, 8(sp)
	ld	s3, 16(sp)
	ld	s2, 24(sp)
	ld	s1, 32(sp)
	ld	s0, 40(sp)
	addi	sp, sp, 48
	ret
.Lfunc_end3:
	.size	horizontal_add_launcher, .Lfunc_end3-horizontal_add_launcher
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
