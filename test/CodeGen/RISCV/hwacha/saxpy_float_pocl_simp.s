	.text
	.file	"saxpy_float_pocl_simp.ll"
	.globl	_pocl_launcher_saxpy    # -- Begin function _pocl_launcher_saxpy
	.p2align	3
	.type	_pocl_launcher_saxpy,@function
_pocl_launcher_saxpy:                   # @_pocl_launcher_saxpy
# %bb.0:                                # %body
	vpset	vp0
	veidx	vv0
	vaddi	vs1, vs0, 32
	@vp0	vsll	vv0, vv0, vs1
	vaddi	vs1, vs0, 30
	@vp0	vsra	vv0, vv0, vs1
	@vp0	vadd	vv1, vs2, vv0
	@vp0	vlxw	vv2, vs0, vv1
	@vp0	vfmul.s	vv2, vv2, vs4
	@vp0	vadd	vv0, vs3, vv0
	@vp0	vlxw	vv3, vs0, vv0
	@vp0	vfadd.s	vv2, vv3, vv2
	@vp0	vsxw	vv2, vs0, vv0
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
	sd	s0, 8(sp)
	addi	a3, zero, 1234
	vmcs	vs1,a3
	vmcs	vs2,a0
	vmcs	vs3,a1
	vmcs	vs4,a2
	vsetcfg	a0,2,2,0,1
	vsetvl	s0,a3
	la	a0, _pocl_launcher_saxpy
	vf	0(a0)
	mv	a0, s0
	ld	s0, 8(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	_pocl_launcher_saxpy_workgroup, .Lfunc_end1-_pocl_launcher_saxpy_workgroup
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
