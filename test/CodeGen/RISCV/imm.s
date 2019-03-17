	.text
	.file	"imm.ll"
	.globl	zero                    # -- Begin function zero
	.p2align	2
	.type	zero,@function
zero:                                   # @zero
# %bb.0:
	mv	a0, zero
	ret
.Lfunc_end0:
	.size	zero, .Lfunc_end0-zero
                                        # -- End function
	.globl	pos_small               # -- Begin function pos_small
	.p2align	2
	.type	pos_small,@function
pos_small:                              # @pos_small
# %bb.0:
	addi	a0, zero, 2047
	ret
.Lfunc_end1:
	.size	pos_small, .Lfunc_end1-pos_small
                                        # -- End function
	.globl	neg_small               # -- Begin function neg_small
	.p2align	2
	.type	neg_small,@function
neg_small:                              # @neg_small
# %bb.0:
	addi	a0, zero, -2048
	ret
.Lfunc_end2:
	.size	neg_small, .Lfunc_end2-neg_small
                                        # -- End function
	.globl	pos_i32                 # -- Begin function pos_i32
	.p2align	2
	.type	pos_i32,@function
pos_i32:                                # @pos_i32
# %bb.0:
	lui	a0, 423811
	addiw	a0, a0, -1297
	ret
.Lfunc_end3:
	.size	pos_i32, .Lfunc_end3-pos_i32
                                        # -- End function
	.globl	neg_i32                 # -- Begin function neg_i32
	.p2align	2
	.type	neg_i32,@function
neg_i32:                                # @neg_i32
# %bb.0:
	lui	a0, 912092
	addiw	a0, a0, -273
	ret
.Lfunc_end4:
	.size	neg_i32, .Lfunc_end4-neg_i32
                                        # -- End function
	.globl	pos_i32_hi20_only       # -- Begin function pos_i32_hi20_only
	.p2align	2
	.type	pos_i32_hi20_only,@function
pos_i32_hi20_only:                      # @pos_i32_hi20_only
# %bb.0:
	lui	a0, 16
	ret
.Lfunc_end5:
	.size	pos_i32_hi20_only, .Lfunc_end5-pos_i32_hi20_only
                                        # -- End function
	.globl	neg_i32_hi20_only       # -- Begin function neg_i32_hi20_only
	.p2align	2
	.type	neg_i32_hi20_only,@function
neg_i32_hi20_only:                      # @neg_i32_hi20_only
# %bb.0:
	lui	a0, 1048560
	ret
.Lfunc_end6:
	.size	neg_i32_hi20_only, .Lfunc_end6-neg_i32_hi20_only
                                        # -- End function
	.globl	imm64_1                 # -- Begin function imm64_1
	.p2align	2
	.type	imm64_1,@function
imm64_1:                                # @imm64_1
# %bb.0:
	addi	a0, zero, 1
	slli	a0, a0, 31
	ret
.Lfunc_end7:
	.size	imm64_1, .Lfunc_end7-imm64_1
                                        # -- End function
	.globl	imm64_2                 # -- Begin function imm64_2
	.p2align	2
	.type	imm64_2,@function
imm64_2:                                # @imm64_2
# %bb.0:
	addi	a0, zero, 1
	slli	a0, a0, 32
	addi	a0, a0, -1
	ret
.Lfunc_end8:
	.size	imm64_2, .Lfunc_end8-imm64_2
                                        # -- End function
	.globl	imm64_3                 # -- Begin function imm64_3
	.p2align	2
	.type	imm64_3,@function
imm64_3:                                # @imm64_3
# %bb.0:
	addi	a0, zero, 1
	slli	a0, a0, 32
	ret
.Lfunc_end9:
	.size	imm64_3, .Lfunc_end9-imm64_3
                                        # -- End function
	.globl	imm64_4                 # -- Begin function imm64_4
	.p2align	2
	.type	imm64_4,@function
imm64_4:                                # @imm64_4
# %bb.0:
	addi	a0, zero, -1
	slli	a0, a0, 63
	ret
.Lfunc_end10:
	.size	imm64_4, .Lfunc_end10-imm64_4
                                        # -- End function
	.globl	imm64_5                 # -- Begin function imm64_5
	.p2align	2
	.type	imm64_5,@function
imm64_5:                                # @imm64_5
# %bb.0:
	addi	a0, zero, -1
	slli	a0, a0, 63
	ret
.Lfunc_end11:
	.size	imm64_5, .Lfunc_end11-imm64_5
                                        # -- End function
	.globl	imm64_6                 # -- Begin function imm64_6
	.p2align	2
	.type	imm64_6,@function
imm64_6:                                # @imm64_6
# %bb.0:
	lui	a0, 9321
	addiw	a0, a0, -1329
	slli	a0, a0, 35
	ret
.Lfunc_end12:
	.size	imm64_6, .Lfunc_end12-imm64_6
                                        # -- End function
	.globl	imm64_7                 # -- Begin function imm64_7
	.p2align	2
	.type	imm64_7,@function
imm64_7:                                # @imm64_7
# %bb.0:
	addi	a0, zero, 7
	slli	a0, a0, 36
	addi	a0, a0, 11
	slli	a0, a0, 24
	addi	a0, a0, 15
	ret
.Lfunc_end13:
	.size	imm64_7, .Lfunc_end13-imm64_7
                                        # -- End function
	.globl	imm64_8                 # -- Begin function imm64_8
	.p2align	2
	.type	imm64_8,@function
imm64_8:                                # @imm64_8
# %bb.0:
	lui	a0, 583
	addiw	a0, a0, -1875
	slli	a0, a0, 14
	addi	a0, a0, -947
	slli	a0, a0, 12
	addi	a0, a0, 1511
	slli	a0, a0, 13
	addi	a0, a0, -272
	ret
.Lfunc_end14:
	.size	imm64_8, .Lfunc_end14-imm64_8
                                        # -- End function
	.globl	imm64_9                 # -- Begin function imm64_9
	.p2align	2
	.type	imm64_9,@function
imm64_9:                                # @imm64_9
# %bb.0:
	addi	a0, zero, -1
	ret
.Lfunc_end15:
	.size	imm64_9, .Lfunc_end15-imm64_9
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
