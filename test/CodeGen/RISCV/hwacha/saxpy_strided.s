	.text
	.file	"saxpy_strided.ll"
	.globl	_pocl_launcher_saxpy_varstride # -- Begin function _pocl_launcher_saxpy_varstride
	.p2align	3
	.type	_pocl_launcher_saxpy_varstride,@function
_pocl_launcher_saxpy_varstride:         # @_pocl_launcher_saxpy_varstride
# %bb.0:                                # %body
	vpset	vp0
	@vp0	vlstw	vv0, va1, va2
	@vp0	vsstw	vv0, va1, va2
	vstop	
.Lfunc_end0:
	.size	_pocl_launcher_saxpy_varstride, .Lfunc_end0-_pocl_launcher_saxpy_varstride
                                        # -- End function
	.globl	_pocl_launcher_saxpy    # -- Begin function _pocl_launcher_saxpy
	.p2align	3
	.type	_pocl_launcher_saxpy,@function
_pocl_launcher_saxpy:                   # @_pocl_launcher_saxpy
# %bb.0:                                # %body
	vpset	vp0
	@vp0	vlstw	vv0, va1, va3
	@vp0	vfmul.s	vv0, vv0, vs4
	@vp0	vlstw	vv1, va2, va3
	@vp0	vfadd.s	vv0, vv1, vv0
	@vp0	vsstw	vv0, va2, va3
	vstop	
.Lfunc_end1:
	.size	_pocl_launcher_saxpy, .Lfunc_end1-_pocl_launcher_saxpy
                                        # -- End function
	.globl	_pocl_launcher_saxpy_workgroup # -- Begin function _pocl_launcher_saxpy_workgroup
	.p2align	2
	.type	_pocl_launcher_saxpy_workgroup,@function
_pocl_launcher_saxpy_workgroup:         # @_pocl_launcher_saxpy_workgroup
# %bb.0:
	addi	sp, sp, -16
	sd	s0, 8(sp)
	sd	s1, 0(sp)
	mv	s0, a0
	addi	a0, zero, 12
	addi	s1, zero, 4
	vmcs	vs1,s1
	vmcs	vs4,a2
	vmca	va1,s0
	vmca	va2,a1
	vmca	va3,a0
	vsetcfg	a0,0,2,0,1
	vsetvl	a0,s1
	la	a0, _pocl_launcher_saxpy
	vf	0(a0)
	fmv.x.w	a0, ft0
	addi	a1, zero, 8
	vmcs	vs1,s1
	vmcs	vs4,a0
	vmca	va1,s0
	vmca	va2,a1
	vsetcfg	a0,0,1,0,1
	vsetvl	a0,s1
	la	a0, _pocl_launcher_saxpy_varstride
	vf	0(a0)
	ld	s1, 0(sp)
	ld	s0, 8(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end2:
	.size	_pocl_launcher_saxpy_workgroup, .Lfunc_end2-_pocl_launcher_saxpy_workgroup
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
