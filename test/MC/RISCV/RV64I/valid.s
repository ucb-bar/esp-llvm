# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV64I | FileCheck --check-prefix=CHECK64 %s
# XFAIL:


# CHECK64: addi    x0, x0, 0               # encoding: [0x13,0x00,0x00,0x00]
# CHECK64: addi    x1, x0, 0               # encoding: [0x93,0x00,0x00,0x00]
# CHECK64: addi    x2, x1, 0               # encoding: [0x13,0x81,0x00,0x00]
# CHECK64: addi    x3, x2, 0               # encoding: [0x93,0x01,0x01,0x00]
# CHECK64: addi    x4, x3, 0               # encoding: [0x13,0x82,0x01,0x00]
# CHECK64: addi    x5, x4, 0               # encoding: [0x93,0x02,0x02,0x00]
# CHECK64: addi    x6, x5, 0               # encoding: [0x13,0x83,0x02,0x00]
# CHECK64: addi    x7, x6, 0               # encoding: [0x93,0x03,0x03,0x00]
# CHECK64: addi    x8, x7, 0               # encoding: [0x13,0x84,0x03,0x00]
# CHECK64: addi    x9, x8, 0               # encoding: [0x93,0x04,0x04,0x00]
# CHECK64: addi    x10, x9, 0              # encoding: [0x13,0x85,0x04,0x00]
# CHECK64: addi    x11, x10, 0             # encoding: [0x93,0x05,0x05,0x00]
# CHECK64: addi    x12, x11, 0             # encoding: [0x13,0x86,0x05,0x00]
# CHECK64: addi    x13, x12, 0             # encoding: [0x93,0x06,0x06,0x00]
# CHECK64: addi    x14, x13, 0             # encoding: [0x13,0x87,0x06,0x00]
# CHECK64: addi    x15, x14, 0             # encoding: [0x93,0x07,0x07,0x00]
# CHECK64: addi    x16, x15, 0             # encoding: [0x13,0x88,0x07,0x00]
# CHECK64: addi    x17, x16, 0             # encoding: [0x93,0x08,0x08,0x00]
# CHECK64: addi    x18, x17, 0             # encoding: [0x13,0x89,0x08,0x00]
# CHECK64: addi    x19, x18, 0             # encoding: [0x93,0x09,0x09,0x00]
# CHECK64: addi    x20, x19, 0             # encoding: [0x13,0x8a,0x09,0x00]
# CHECK64: addi    x21, x20, 0             # encoding: [0x93,0x0a,0x0a,0x00]
# CHECK64: addi    x22, x21, 0             # encoding: [0x13,0x8b,0x0a,0x00]
# CHECK64: addi    x23, x22, 0             # encoding: [0x93,0x0b,0x0b,0x00]
# CHECK64: addi    x24, x23, 0             # encoding: [0x13,0x8c,0x0b,0x00]
# CHECK64: addi    x25, x24, 0             # encoding: [0x93,0x0c,0x0c,0x00]
# CHECK64: addi    x26, x25, 0             # encoding: [0x13,0x8d,0x0c,0x00]
# CHECK64: addi    x27, x26, 0             # encoding: [0x93,0x0d,0x0d,0x00]
# CHECK64: addi    x28, x27, 0             # encoding: [0x13,0x8e,0x0d,0x00]
# CHECK64: addi    x29, x28, 0             # encoding: [0x93,0x0e,0x0e,0x00]
# CHECK64: addi    x30, x29, 0             # encoding: [0x13,0x8f,0x0e,0x00]
# CHECK64: addi    x31, x30, 0             # encoding: [0x93,0x0f,0x0f,0x00]

# CHECK64: addi    x0, x0, 0               # encoding: [0x13,0x00,0x00,0x00]

# CHECK64: addi	x3, x2, 1023               # encoding: [0x93,0x01,0xf1,0x3f]
# CHECK64: addi	x4, x3, -1023              # encoding: [0x13,0x82,0x11,0xc0]
# CHECK64: addi x31, x0, 0                 # encoding: [0x93,0x0f,0x00,0x00]
# CHECK64: addi x31, x0, 0                 # encoding: [0x93,0x0f,0x00,0x00]
# CHECK64: slti	x5, x4, 0                  # encoding: [0x93,0x22,0x02,0x00]
# CHECK64: slti	x6, x5, 1023               # encoding: [0x13,0xa3,0xf2,0x3f]
# CHECK64: sltiu x7, x0, 1                 # encoding: [0x93,0x33,0x10,0x00]
# CHECK64: sltiu x7, x0, 1                 # encoding: [0x93,0x33,0x10,0x00]
# CHECK64: andi	x8, x7, 12                 # encoding: [0x13,0xf4,0xc3,0x00]
# CHECK64: ori	x9, x8, -24                # encoding: [0x93,0x64,0x84,0xfe]
# CHECK64: xori	x10, x9, 17                # encoding: [0x13,0xc5,0x14,0x01]
# CHECK64: xori	x11, x10, -1               # encoding: [0x93,0x45,0xf5,0xff]
# CHECK64: xori x11, x10, -1               # encoding: [0x93,0x45,0xf5,0xff]
# CHECK64: slli	x12, x10, 5                # encoding: [0x13,0x16,0x55,0x00]
# CHECK64: srli	x13, x12, 31               # encoding: [0x93,0x56,0xf6,0x01]
# CHECK64: srai	x14, x13, 2                # encoding: [0x13,0xd7,0x26,0x40]
# CHECK64: lui	x15, 1048575               # encoding: [0xb7,0xf7,0xff,0xff]
# CHECK64: auipc   x16, 4                  # encoding: [0x17,0x48,0x00,0x00]

# CHECK64: addiw	x5, x4, 1023       # encoding: [0x9b,0x02,0xf2,0x3f]
# CHECK64: addiw	x6, x7, 0          # encoding: [0x1b,0x83,0x03,0x00]
# CHECK64: addiw	x6, x7, 0          # encoding: [0x1b,0x83,0x03,0x00]
# CHECK64: slliw	x12, x10, 2        # encoding: [0x1b,0x16,0x25,0x00]
# CHECK64: srliw	x13, x12, 3        # encoding: [0x9b,0x56,0x36,0x00]
# CHECK64: sraiw	x14, x13, 4        # encoding: [0x1b,0xd7,0x46,0x40]

# CHECK64: add     x17, x16, x15           # encoding: [0xb3,0x08,0xf8,0x00]
# CHECK64: sub     x18, x17, x16           # encoding: [0x33,0x89,0x08,0x41]
# CHECK64: slt     x19, x18, x17           # encoding: [0xb3,0x29,0x19,0x01]
# CHECK64: sltu    x20, x19, x18           # encoding: [0x33,0xba,0x29,0x01]
# CHECK64: and     x21, x20, x19           # encoding: [0xb3,0x7a,0x3a,0x01]
# CHECK64: or      x22, x21, x20           # encoding: [0x33,0xeb,0x4a,0x01]
# CHECK64: xor     x23, x22, x21           # encoding: [0xb3,0x4b,0x5b,0x01]
# CHECK64: sll     x24, x23, x22           # encoding: [0x33,0x9c,0x6b,0x01]
# CHECK64: srl     x25, x24, x23           # encoding: [0xb3,0x5c,0x7c,0x01]
# CHECK64: sra     x26, x25, x24           # encoding: [0x33,0xdd,0x8c,0x41]

# CHECK64: addw	x10, x11, x12              # encoding: [0x3b,0x85,0xc5,0x00]
# CHECK64: subw	x9, x8, x7                 # encoding: [0xbb,0x04,0x74,0x40]
# CHECK64: sllw	x4, x5, x6                 # encoding: [0x3b,0x92,0x62,0x00]
# CHECK64: srlw	x6, x7, x8                 # encoding: [0x3b,0xd3,0x83,0x00]
# CHECK64: sraw	x9, x10, x11               # encoding: [0xbb,0x54,0xb5,0x40]

# CHECK64: addi      x2, x0, 0             # encoding: [0x13,0x01,0x00,0x00]

# CHECK64: jalr      x28, x27, 8           # encoding: [0x67,0x8e,0x8d,0x00]

# CHECK64: fence
# CHECK64: fence.i                         # encoding: [0x0f,0x10,0x00,0x00]

# CHECK64: scall                           # encoding: [0x73,0x00,0x00,0x00]
# CHECK64: sbreak                          # encoding: [0x73,0x00,0x10,0x00]
# CHECK64: rdcycle   x5                    # encoding: [0xf3,0x22,0x00,0xc0]
# CHECK64: rdtime    x7                    # encoding: [0xf3,0x23,0x10,0xc0]
# CHECK64: rdinstret x9                    # encoding: [0xf3,0x24,0x20,0xc0]

#-- register encodings: x0-x31
#--                     x0 == $0
	addi	x0, x0, 0
	addi	x1, x0, 0
	addi	x2, x1, 0
	addi	x3, x2, 0
	addi	x4, x3, 0
	addi	x5, x4, 0
	addi	x6, x5, 0
	addi	x7, x6, 0
	addi	x8, x7, 0
	addi	x9, x8, 0
	addi	x10, x9, 0
	addi	x11, x10, 0
	addi	x12, x11, 0
	addi	x13, x12, 0
	addi	x14, x13, 0
	addi	x15, x14, 0
	addi	x16, x15, 0
	addi	x17, x16, 0
	addi	x18, x17, 0
	addi	x19, x18, 0
	addi	x20, x19, 0
	addi	x21, x20, 0
	addi	x22, x21, 0
	addi	x23, x22, 0
	addi	x24, x23, 0
	addi	x25, x24, 0
	addi	x26, x25, 0
	addi	x27, x26, 0
	addi	x28, x27, 0
	addi	x29, x28, 0
	addi	x30, x29, 0
	addi	x31, x30, 0

#-- INTEGER COMPUTATIONAL INSTRUCTIONS
#-- Integer Register-Immediate
	nop				#-- pseudo-op for addi x0, x0, 0
	addi	x3, x2, 1023
	addi	x4, x3, -1023
	addi	x31, x0, 0
	mv	x31, x0			#-- pseudo-op for addi x31, x0, 0
	slti	x5, x4, 0
	slti	x6, x5, 1023
	sltiu	x7, x0, 1
	seqz	x7,x0			#-- pseudo-op for sltiu x7,x0,1
	andi	x8, x7, 12
	ori	x9, x8, -24
	xori	x10, x9, 17
	xori	x11, x10, -1
	not	x11, x10		#-- pseudo-op for xori x11, x10, -1
	slli	x12, x10, 5	
	srli	x13, x12, 31
	srai	x14, x13, 2
	lui	x15, 1048575
	auipc	x16, 4

#-- RV64I only
	addiw	x5, x4, 1023
	addiw	x6, x7, 0
	sext.w	x6, x7			#-- pseudo-op for addiw x6, x7, 0
	slliw	x12, x10, 2
	srliw	x13, x12, 3
	sraiw	x14, x13, 4
	

#-- Integer Register-Register
	add	x17, x16, x15
	sub	x18, x17, x16
	slt	x19, x18, x17
	sltu	x20, x19, x18
	and	x21, x20, x19
	or	x22, x21, x20
	xor	x23, x22, x21
	sll	x24, x23, x22
	srl	x25, x24, x23
	sra	x26, x25, x24

#-- RV64I only
	addw	x10, x11, x12
	subw	x9, x8, x7
	sllw	x4, x5, x6
	srlw	x6, x7, x8
	sraw	x9, x10, x11
	

#-- CONTROL TRANSFER INSTRUCTIONS
	mv 	x2, x0
	jal	x27, 8
	jal	x0, 8			#-- unconditional jump
	jalr	x28, x27, 8	
	beq	x28,x27, target_beq
target_beq:
	bne	x28,x27, target_bne
target_bne:
	blt	x29, x28, target_blt
target_blt:
	bltu	x30, x29, target_bltu	
target_bltu:
	bge	x31, x30, target_bge
target_bge:
	bgeu	x2, x31, target_bgeu
target_bgeu:
	nop

#-- LOAD AND STORE INSTRUCTIONS	

	sw x5, 0(x3)
	sh x6, 0(x3)
	sb x7, 0(x3)
	sw x5, -4(x3)
	sh x6, -4(x3)
	sb x7, -4(x3)
	sw x5, 4(x3)
	sh x6, 4(x3)
	sb x7, 4(x3)
	lw x5, 0(x3)
	lh x6, 0(x3)
	lb x7, 0(x3)
	lw x5, -4(x3)
	lh x6, -4(x3)
	lb x7, -4(x3)
	lw x5, 4(x3)
	lh x6, 4(x3)
	lb x7, 4(x3)

#-- RV64I only
	ld x5, 0(x3)
	ld x6, -4(x3)
	ld x7, 4(x3)
	lwu x5, 0(x3)
	lhu x6, 0(x3)
	lbu x7, 0(x3)
	lwu x5, -4(x3)
	lhu x6, -4(x3)
	lbu x7, -4(x3)
	lwu x5, 4(x3)
	lhu x6, 4(x3)
	lbu x7, 4(x3)


#-- MEMORY MODEL
	fence
	fence.i

#-- SYSTEM INSTRUCTIONS
#-- *h encodings not supported in RV64I
	scall
	sbreak
	rdcycle	x5
	rdtime	x7
	rdinstret x9 
		

#-- EOF

