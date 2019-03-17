	.text
	.file	"sgemm-pragma.ll"
	.p2align	2               # -- Begin function _pocl_launcher_sgemm_unroll
	.type	_pocl_launcher_sgemm_unroll,@function
_pocl_launcher_sgemm_unroll:            # @_pocl_launcher_sgemm_unroll
# %bb.0:                                # %for.cond.4.preheader.i
	vpset	vp0
	vmcs	vs4,a7
	vmcs	vs5,a6
	vmcs	vs1,a5
	vmcs	vs2,a4
	vmcs	vs3,a3
	vmcs	vs6,a2
	vmcs	vs7,a1
	vmcs	vs8,a0
	veidx	vv0
	vlsw	vs5, vs5
	ld	a0, 224(sp)
	@vp0	vlxw	vv1, vs0, a0
	@vp0	vfmul.s	vv1, vv1, vs5
	vlsw	vs5, vs7
	@vp0	vfadd.s	vv1, vs5, vv1
	@vp0	vsxw	vv1, vs0, vs4
	ld	a0, 24(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 240(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 32(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 40(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 256(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 48(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 56(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 264(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 64(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 8(sp)
	@vp0	vlxw	vv1, vs0, a0
	ld	a0, 248(sp)
	@vp0	vlxw	vv2, vs0, a0
	@vp0	vfmul.s	vv1, vv2, vv1
	vlsw	vs4, vs8
	@vp0	vfadd.s	vv1, vs4, vv1
	ld	a0, 16(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 104(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 296(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 112(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 120(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 304(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 128(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 136(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 312(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 144(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 160(sp)
	@vp0	vlxw	vv1, vs0, a0
	ld	a0, 320(sp)
	@vp0	vlxw	vv2, vs0, a0
	@vp0	vfmul.s	vv1, vv2, vv1
	ld	a0, 152(sp)
	@vp0	vlxw	vv2, vs0, a0
	@vp0	vfadd.s	vv1, vv2, vv1
	ld	a0, 168(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 0(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 328(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 176(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 184(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 336(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 192(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 200(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 344(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 208(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 72(sp)
	@vp0	vlxw	vv1, vs0, a0
	ld	a0, 272(sp)
	@vp0	vlxw	vv2, vs0, a0
	@vp0	vfmul.s	vv1, vv2, vv1
	ld	a0, 216(sp)
	@vp0	vlxw	vv2, vs0, a0
	@vp0	vfadd.s	vv1, vv2, vv1
	ld	a0, 80(sp)
	@vp0	vsxw	vv1, vs0, a0
	ld	a0, 88(sp)
	@vp0	vlxw	vv2, vs0, a0
	ld	a0, 280(sp)
	@vp0	vlxw	vv3, vs0, a0
	@vp0	vfmul.s	vv2, vv3, vv2
	@vp0	vfadd.s	vv1, vv1, vv2
	ld	a0, 96(sp)
	@vp0	vsxw	vv1, vs0, a0
	vlsw	vs4, vs6
	ld	a0, 288(sp)
	@vp0	vlxw	vv2, vs0, a0
	@vp0	vfmul.s	vv2, vv2, vs4
	@vp0	vfadd.s	vv1, vv1, vv2
	@vp0	vsxw	vv1, vs0, vs3
	vlsw	vs2, vs2
	ld	a0, 232(sp)
	@vp0	vlxw	vv2, vs0, a0
	@vp0	vfmul.s	vv2, vv2, vs2
	@vp0	vfadd.s	vv1, vv1, vv2
	@vp0	vsxw	vv1, vs0, vs1
	vstop	
.Lfunc_end0:
	.size	_pocl_launcher_sgemm_unroll, .Lfunc_end0-_pocl_launcher_sgemm_unroll
                                        # -- End function
	.globl	_pocl_launcher_sgemm_unroll_workgroup # -- Begin function _pocl_launcher_sgemm_unroll_workgroup
	.p2align	2
	.type	_pocl_launcher_sgemm_unroll_workgroup,@function
_pocl_launcher_sgemm_unroll_workgroup:  # @_pocl_launcher_sgemm_unroll_workgroup
# %bb.0:
	addi	sp, sp, -544
	sd	s1, 536(sp)
	sd	s2, 528(sp)
	sd	s3, 520(sp)
	sd	s4, 512(sp)
	sd	s5, 504(sp)
	sd	s6, 496(sp)
	ld	a2, 48(a1)
	ld	a3, 72(a1)
	add	a6, a3, a2
	ld	a3, 40(a1)
	ld	a4, 64(a1)
	add	t0, a4, a3
	ld	a4, 24(a0)
	lw	a4, 0(a4)
	slli	a2, a6, 2
	ori	a5, a2, 1
	mul	a7, a5, a4
	ld	a5, 32(a1)
	slli	a5, a5, 7
	ld	a1, 56(a1)
	add	a3, a1, a7
	add	a3, a3, a5
	slli	t1, a3, 2
	ld	a3, 0(a0)
	ld	t4, 0(a3)
	ld	a3, 8(a0)
	ld	t5, 0(a3)
	ld	a0, 16(a0)
	ld	t3, 0(a0)
	add	t2, t3, t1
	lw	a0, 0(t2)
	sw	a0, 492(sp)
	ori	a0, a2, 2
	mul	t1, a0, a4
	slli	a0, t0, 2
	ori	a3, a0, 3
	mul	t6, a3, a4
	ori	a3, a0, 2
	mul	s2, a3, a4
	mul	a3, a6, a4
	ori	a2, a2, 3
	mul	a2, a2, a4
	ori	s1, a0, 1
	mul	s1, s1, a4
	mul	a4, t0, a4
	add	a6, t0, a3
	slli	a3, a3, 2
	slli	a4, a4, 2
	add	t0, a1, s2
	add	t6, a1, t6
	add	s3, a1, s1
	add	a4, a1, a4
	add	s2, a1, a2
	add	s1, a1, t1
	add	a1, a1, a3
	add	t1, t1, a0
	add	s4, a2, a0
	add	a7, a7, a0
	add	s5, a3, a0
	add	a2, a4, a5
	add	a3, s3, a5
	add	a1, a1, a5
	add	s3, s1, a5
	add	s1, t6, a5
	add	a4, s2, a5
	add	a5, t0, a5
	slli	a1, a1, 2
	add	a0, t3, a1
	lw	a1, 0(a0)
	sw	a1, 488(sp)
	slli	a3, a3, 2
	slli	a1, a2, 2
	slli	a2, s1, 2
	slli	a5, a5, 2
	add	s2, t5, a5
	add	t6, t5, a2
	add	s6, t5, a1
	add	s1, t5, a3
	slli	a2, s3, 2
	slli	a3, a4, 2
	add	t5, t3, a3
	add	a4, t3, a2
	slli	s3, s5, 2
	slli	a5, a7, 2
	slli	a1, s4, 2
	slli	a3, a6, 4
	slli	a2, t1, 2
	add	t3, t4, a2
	add	a7, t4, a3
	add	t0, t4, a1
	add	t1, t4, a5
	add	a6, t4, s3
	lw	a1, 0(s2)
	sw	a1, 484(sp)
	lw	a1, 0(t5)
	sw	a1, 480(sp)
	lw	a1, 0(t6)
	sw	a1, 476(sp)
	lw	a1, 0(t5)
	sw	a1, 472(sp)
	lw	a1, 0(s6)
	sw	a1, 468(sp)
	lw	a1, 0(a0)
	sw	a1, 464(sp)
	lw	a1, 0(s1)
	sw	a1, 460(sp)
	lw	a1, 0(s6)
	sw	a1, 456(sp)
	lw	a1, 0(t2)
	sw	a1, 452(sp)
	lw	a1, 0(s1)
	sw	a1, 448(sp)
	lw	a1, 0(a0)
	sw	a1, 444(sp)
	lw	a1, 0(s2)
	sw	a1, 440(sp)
	lw	a1, 0(a0)
	sw	a1, 436(sp)
	lw	a1, 0(t6)
	sw	a1, 432(sp)
	lw	a0, 0(a0)
	sw	a0, 428(sp)
	lw	a0, 0(s6)
	sw	a0, 424(sp)
	lw	a0, 0(t5)
	sw	a0, 420(sp)
	lw	a0, 0(s1)
	sw	a0, 416(sp)
	lw	a0, 0(t5)
	sw	a0, 412(sp)
	lw	a0, 0(s1)
	sw	a0, 408(sp)
	lw	a0, 0(t2)
	sw	a0, 404(sp)
	lw	a0, 0(s2)
	sw	a0, 400(sp)
	lw	a0, 0(t2)
	sw	a0, 396(sp)
	lw	a0, 0(t6)
	sw	a0, 392(sp)
	lw	a0, 0(t2)
	sw	a0, 388(sp)
	lw	a0, 0(a4)
	sw	a0, 384(sp)
	lw	a0, 0(s6)
	sw	a0, 380(sp)
	lw	a0, 0(a4)
	sw	a0, 376(sp)
	lw	a0, 0(a4)
	sw	a0, 372(sp)
	lw	a0, 0(s2)
	sw	a0, 368(sp)
	lw	a0, 0(a4)
	sw	a0, 364(sp)
	lw	a0, 0(t6)
	sw	a0, 360(sp)
	lw	a0, 0(a4)
	sw	a0, 356(sp)
	lw	a0, 0(t5)
	sw	a0, 352(sp)
	addi	a0, t3, 12
	sd	a0, 344(sp)
	addi	a0, t3, 8
	sd	a0, 336(sp)
	addi	a0, t3, 4
	sd	a0, 328(sp)
	sd	t3, 320(sp)
	addi	a0, t1, 12
	sd	a0, 312(sp)
	addi	a0, t1, 8
	sd	a0, 304(sp)
	addi	a0, t1, 4
	sd	a0, 296(sp)
	addi	a0, t0, 8
	sd	a0, 288(sp)
	addi	a0, t0, 4
	sd	a0, 280(sp)
	addi	a0, a7, 12
	sd	a0, 264(sp)
	addi	a0, a7, 8
	sd	a0, 256(sp)
	sd	t1, 248(sp)
	addi	a0, a7, 4
	sd	a0, 240(sp)
	sd	t0, 272(sp)
	addi	a0, t0, 12
	sd	a0, 232(sp)
	sd	a6, 224(sp)
	addi	a0, sp, 352
	sd	a0, 216(sp)
	addi	a0, sp, 356
	sd	a0, 208(sp)
	addi	a0, sp, 360
	sd	a0, 200(sp)
	addi	a0, sp, 364
	sd	a0, 192(sp)
	addi	a0, sp, 368
	sd	a0, 184(sp)
	addi	a0, sp, 372
	sd	a0, 176(sp)
	addi	a0, sp, 376
	sd	a0, 168(sp)
	addi	a0, sp, 380
	sd	a0, 160(sp)
	addi	a0, sp, 384
	sd	a0, 152(sp)
	addi	a0, sp, 388
	sd	a0, 144(sp)
	addi	a0, sp, 392
	sd	a0, 136(sp)
	addi	a0, sp, 396
	sd	a0, 128(sp)
	addi	a0, sp, 400
	sd	a0, 120(sp)
	addi	a0, sp, 404
	sd	a0, 112(sp)
	addi	a0, sp, 408
	sd	a0, 104(sp)
	addi	a0, sp, 412
	sd	a0, 96(sp)
	addi	a0, sp, 416
	sd	a0, 88(sp)
	addi	a0, sp, 420
	sd	a0, 80(sp)
	addi	a0, sp, 424
	sd	a0, 72(sp)
	addi	a0, sp, 428
	sd	a0, 64(sp)
	addi	a0, sp, 432
	sd	a0, 56(sp)
	addi	a0, sp, 436
	sd	a0, 48(sp)
	addi	a0, sp, 440
	sd	a0, 40(sp)
	addi	a0, sp, 444
	sd	a0, 32(sp)
	addi	a0, sp, 448
	sd	a0, 24(sp)
	addi	a0, sp, 452
	sd	a0, 16(sp)
	addi	a0, sp, 456
	sd	a0, 8(sp)
	addi	a0, sp, 460
	sd	a0, 0(sp)
	addi	a0, sp, 492
	addi	a1, sp, 488
	addi	a2, sp, 484
	addi	a3, sp, 480
	addi	a4, sp, 476
	addi	a5, sp, 472
	addi	a6, sp, 468
	addi	a7, sp, 464
	vsetcfg	s1,1,3,0,1
	li	s1, 4
	vsetvl	s1,s1
	vf	_pocl_launcher_sgemm_unroll
	ld	s6, 496(sp)
	ld	s5, 504(sp)
	ld	s4, 512(sp)
	ld	s3, 520(sp)
	ld	s2, 528(sp)
	ld	s1, 536(sp)
	addi	sp, sp, 544
	ret
.Lfunc_end1:
	.size	_pocl_launcher_sgemm_unroll_workgroup, .Lfunc_end1-_pocl_launcher_sgemm_unroll_workgroup
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

	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm ea484e8fe591e40d9c18ce982f25f006610ea782)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"
	.ident	"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"
	.section	".note.GNU-stack","",@progbits
