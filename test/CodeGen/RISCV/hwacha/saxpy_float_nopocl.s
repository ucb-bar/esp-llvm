	.text
	.file	"saxpy_float_nopocl.ll"
	.globl	_pocl_launcher_saxpy    # -- Begin function _pocl_launcher_saxpy
	.p2align	2
	.type	_pocl_launcher_saxpy,@function
_pocl_launcher_saxpy:                   # @_pocl_launcher_saxpy
# %bb.0:                                # %body
	vpset	vp0
	@vp0	vlw	vv0, va1
	@vp0	vfmul.s	vv0, vv0, vs4
	@vp0	vlw	vv1, va2
	@vp0	vfadd.s	vv0, vv1, vv0
	@vp0	vsw	vv0, va2
	vstop	
.Lfunc_end0:
	.size	_pocl_launcher_saxpy, .Lfunc_end0-_pocl_launcher_saxpy
                                        # -- End function
	.globl	_pocl_launcher_saxpy_workgroup # -- Begin function _pocl_launcher_saxpy_workgroup
	.p2align	2
	.type	_pocl_launcher_saxpy_workgroup,@function
_pocl_launcher_saxpy_workgroup:         # @_pocl_launcher_saxpy_workgroup
# %bb.0:
	addi	sp, sp, -16
	lw	a0, 0(a0)
	sw	a0, 12(sp)
	lw	a0, 0(a1)
	sw	a0, 8(sp)
	addi	a0, sp, 12
	addi	a1, sp, 8
	addi	a3, zero, 1234
	vmcs	vs1,a3
	vmcs	vs4,a2
	vmca	va1,a0
	vmca	va2,a1
	vsetcfg	a0,0,2,0,1
	vsetvl	a0,a3
	la	a0, _pocl_launcher_saxpy
	vf	0(a0)
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	_pocl_launcher_saxpy_workgroup, .Lfunc_end1-_pocl_launcher_saxpy_workgroup
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
