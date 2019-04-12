	.text
	.file	"saxpy_float_pocl_simp.ll"
	.p2align	2               # -- Begin function _pocl_launcher_saxpy
	.type	_pocl_launcher_saxpy,@function
_pocl_launcher_saxpy:                   # @_pocl_launcher_saxpy
# %bb.0:
	vpset	vp0
	veidx	vv0
	@vp0	vlw	vv1, va1
	@vp0	vfmul.s	vv1, vv1, vs1
	@vp0	vlw	vv2, va2
	@vp0	vfadd.s	vv1, vv2, vv1
	@vp0	vsw	vv1, va3
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
	ld	a2, 56(a1)
	ld	a1, 32(a1)
	slli	a1, a1, 9
	add	a1, a2, a1
	slli	a1, a1, 2
	ld	a2, 0(a0)
	ld	a2, 0(a2)
	add	a2, a2, a1
	lw	a2, 0(a2)
	ld	a3, 16(a0)
	flw	ft0, 0(a3)
	ld	a0, 8(a0)
	ld	a0, 0(a0)
	sw	a2, 12(sp)
	add	a0, a0, a1
	lw	a1, 0(a0)
	sw	a1, 8(sp)
	lw	a0, 0(a0)
	sw	a0, 4(sp)
	fmv.x.w	a0, ft0
	addi	a1, sp, 12
	addi	a2, sp, 8
	addi	a3, sp, 4
	vsetcfg	a4,1,2,0,1
	li	a4, 4
	vsetvl	a4,a4
	vf	_pocl_launcher_saxpy
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	_pocl_launcher_saxpy_workgroup, .Lfunc_end1-_pocl_launcher_saxpy_workgroup
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

	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.section	".note.GNU-stack","",@progbits
