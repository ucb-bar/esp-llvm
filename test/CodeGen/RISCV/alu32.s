	.text
	.file	"alu32.ll"
	.globl	addi                    # -- Begin function addi
	.p2align	2
	.type	addi,@function
addi:                                   # @addi
# %bb.0:
	addi	a0, a0, 1
	ret
.Lfunc_end0:
	.size	addi, .Lfunc_end0-addi
                                        # -- End function
	.globl	slti                    # -- Begin function slti
	.p2align	2
	.type	slti,@function
slti:                                   # @slti
# %bb.0:
	sext.w	a0, a0
	slti	a0, a0, 2
	ret
.Lfunc_end1:
	.size	slti, .Lfunc_end1-slti
                                        # -- End function
	.globl	sltiu                   # -- Begin function sltiu
	.p2align	2
	.type	sltiu,@function
sltiu:                                  # @sltiu
# %bb.0:
	sext.w	a0, a0
	sltiu	a0, a0, 3
	ret
.Lfunc_end2:
	.size	sltiu, .Lfunc_end2-sltiu
                                        # -- End function
	.globl	xori                    # -- Begin function xori
	.p2align	2
	.type	xori,@function
xori:                                   # @xori
# %bb.0:
	xori	a0, a0, 4
	ret
.Lfunc_end3:
	.size	xori, .Lfunc_end3-xori
                                        # -- End function
	.globl	ori                     # -- Begin function ori
	.p2align	2
	.type	ori,@function
ori:                                    # @ori
# %bb.0:
	ori	a0, a0, 5
	ret
.Lfunc_end4:
	.size	ori, .Lfunc_end4-ori
                                        # -- End function
	.globl	andi                    # -- Begin function andi
	.p2align	2
	.type	andi,@function
andi:                                   # @andi
# %bb.0:
	andi	a0, a0, 6
	ret
.Lfunc_end5:
	.size	andi, .Lfunc_end5-andi
                                        # -- End function
	.globl	slli                    # -- Begin function slli
	.p2align	2
	.type	slli,@function
slli:                                   # @slli
# %bb.0:
	slli	a0, a0, 7
	ret
.Lfunc_end6:
	.size	slli, .Lfunc_end6-slli
                                        # -- End function
	.globl	srli                    # -- Begin function srli
	.p2align	2
	.type	srli,@function
srli:                                   # @srli
# %bb.0:
	srliw	a0, a0, 8
	ret
.Lfunc_end7:
	.size	srli, .Lfunc_end7-srli
                                        # -- End function
	.globl	srai                    # -- Begin function srai
	.p2align	2
	.type	srai,@function
srai:                                   # @srai
# %bb.0:
	sraiw	a0, a0, 9
	ret
.Lfunc_end8:
	.size	srai, .Lfunc_end8-srai
                                        # -- End function
	.globl	add                     # -- Begin function add
	.p2align	2
	.type	add,@function
add:                                    # @add
# %bb.0:
	add	a0, a0, a1
	ret
.Lfunc_end9:
	.size	add, .Lfunc_end9-add
                                        # -- End function
	.globl	sub                     # -- Begin function sub
	.p2align	2
	.type	sub,@function
sub:                                    # @sub
# %bb.0:
	sub	a0, a0, a1
	ret
.Lfunc_end10:
	.size	sub, .Lfunc_end10-sub
                                        # -- End function
	.globl	sll                     # -- Begin function sll
	.p2align	2
	.type	sll,@function
sll:                                    # @sll
# %bb.0:
	sllw	a0, a0, a1
	ret
.Lfunc_end11:
	.size	sll, .Lfunc_end11-sll
                                        # -- End function
	.globl	slt                     # -- Begin function slt
	.p2align	2
	.type	slt,@function
slt:                                    # @slt
# %bb.0:
	sext.w	a1, a1
	sext.w	a0, a0
	slt	a0, a0, a1
	ret
.Lfunc_end12:
	.size	slt, .Lfunc_end12-slt
                                        # -- End function
	.globl	sltu                    # -- Begin function sltu
	.p2align	2
	.type	sltu,@function
sltu:                                   # @sltu
# %bb.0:
	sext.w	a1, a1
	sext.w	a0, a0
	sltu	a0, a0, a1
	ret
.Lfunc_end13:
	.size	sltu, .Lfunc_end13-sltu
                                        # -- End function
	.globl	xor                     # -- Begin function xor
	.p2align	2
	.type	xor,@function
xor:                                    # @xor
# %bb.0:
	xor	a0, a0, a1
	ret
.Lfunc_end14:
	.size	xor, .Lfunc_end14-xor
                                        # -- End function
	.globl	srl                     # -- Begin function srl
	.p2align	2
	.type	srl,@function
srl:                                    # @srl
# %bb.0:
	srlw	a0, a0, a1
	ret
.Lfunc_end15:
	.size	srl, .Lfunc_end15-srl
                                        # -- End function
	.globl	sra                     # -- Begin function sra
	.p2align	2
	.type	sra,@function
sra:                                    # @sra
# %bb.0:
	sraw	a0, a0, a1
	ret
.Lfunc_end16:
	.size	sra, .Lfunc_end16-sra
                                        # -- End function
	.globl	or                      # -- Begin function or
	.p2align	2
	.type	or,@function
or:                                     # @or
# %bb.0:
	or	a0, a0, a1
	ret
.Lfunc_end17:
	.size	or, .Lfunc_end17-or
                                        # -- End function
	.globl	and                     # -- Begin function and
	.p2align	2
	.type	and,@function
and:                                    # @and
# %bb.0:
	and	a0, a0, a1
	ret
.Lfunc_end18:
	.size	and, .Lfunc_end18-and
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
