	.text
	.file	"branch.ll"
	.globl	foo                     # -- Begin function foo
	.p2align	2
	.type	foo,@function
foo:                                    # @foo
# %bb.0:
	lw	a3, 0(a1)
	sext.w	a0, a0
	beq	a3, a0, .LBB0_12
# %bb.1:                                # %test2
	lw	a3, 0(a1)
	bne	a3, a0, .LBB0_12
# %bb.2:                                # %test3
	lw	a3, 0(a1)
	blt	a3, a0, .LBB0_12
# %bb.3:                                # %test4
	lw	a3, 0(a1)
	bge	a3, a0, .LBB0_12
# %bb.4:                                # %test5
	lw	a3, 0(a1)
	bltu	a3, a0, .LBB0_12
# %bb.5:                                # %test6
	lw	a3, 0(a1)
	bgeu	a3, a0, .LBB0_12
# %bb.6:                                # %test7
	lw	a3, 0(a1)
	blt	a0, a3, .LBB0_12
# %bb.7:                                # %test8
	lw	a3, 0(a1)
	bge	a0, a3, .LBB0_12
# %bb.8:                                # %test9
	lw	a3, 0(a1)
	bltu	a0, a3, .LBB0_12
# %bb.9:                                # %test10
	lw	a3, 0(a1)
	bgeu	a0, a3, .LBB0_12
# %bb.10:                               # %test11
	lw	a0, 0(a1)
	andi	a0, a2, 1
	bnez	a0, .LBB0_12
# %bb.11:                               # %test12
	lw	a0, 0(a1)
.LBB0_12:                               # %end
	ret
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
