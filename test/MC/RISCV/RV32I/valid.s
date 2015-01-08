# Instructions that are valid
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32I | FileCheck --check-prefix=CHECK32 %s


# CHECK32: addi    x0, x0, 0               # encoding: [0x00,0x00,0x00,0x13]
# CHECK32: addi    x1, x0, 0               # encoding: [0x08,0x00,0x00,0x13]
# CHECK32: addi    x1, x0, 0               # encoding: [0x08,0x00,0x00,0x13]
# CHECK32: addi    x2, x1, 0               # encoding: [0x10,0x40,0x00,0x13]
# CHECK32: addi    x3, x2, 0               # encoding: [0x18,0x80,0x00,0x13]
# CHECK32: addi    x4, x3, 0               # encoding: [0x20,0xc0,0x00,0x13]
# CHECK32: addi    x5, x4, 0               # encoding: [0x29,0x00,0x00,0x13]
# CHECK32: addi    x6, x5, 0               # encoding: [0x31,0x40,0x00,0x13]
# CHECK32: addi    x7, x6, 0               # encoding: [0x39,0x80,0x00,0x13]
# CHECK32: addi    x8, x7, 0               # encoding: [0x41,0xc0,0x00,0x13]
# CHECK32: addi    x9, x8, 0               # encoding: [0x4a,0x00,0x00,0x13]
# CHECK32: addi    x10, x9, 0              # encoding: [0x52,0x40,0x00,0x13]
# CHECK32: addi    x11, x10, 0             # encoding: [0x5a,0x80,0x00,0x13]
# CHECK32: addi    x12, x11, 0             # encoding: [0x62,0xc0,0x00,0x13]
# CHECK32: addi    x13, x12, 0             # encoding: [0x6b,0x00,0x00,0x13]
# CHECK32: addi    x14, x13, 0             # encoding: [0x73,0x40,0x00,0x13]
# CHECK32: addi    x15, x14, 0             # encoding: [0x7b,0x80,0x00,0x13]
# CHECK32: addi    x16, x15, 0             # encoding: [0x83,0xc0,0x00,0x13]
# CHECK32: addi    x17, x16, 0             # encoding: [0x8c,0x00,0x00,0x13]
# CHECK32: addi    x18, x17, 0             # encoding: [0x94,0x40,0x00,0x13]
# CHECK32: addi    x19, x18, 0             # encoding: [0x9c,0x80,0x00,0x13]
# CHECK32: addi    x20, x19, 0             # encoding: [0xa4,0xc0,0x00,0x13]
# CHECK32: addi    x21, x20, 0             # encoding: [0xad,0x00,0x00,0x13]
# CHECK32: addi    x22, x21, 0             # encoding: [0xb5,0x40,0x00,0x13]
# CHECK32: addi    x23, x22, 0             # encoding: [0xbd,0x80,0x00,0x13]
# CHECK32: addi    x24, x23, 0             # encoding: [0xc5,0xc0,0x00,0x13]
# CHECK32: addi    x25, x24, 0             # encoding: [0xce,0x00,0x00,0x13]
# CHECK32: addi    x26, x25, 0             # encoding: [0xd6,0x40,0x00,0x13]
# CHECK32: addi    x27, x26, 0             # encoding: [0xde,0x80,0x00,0x13]
# CHECK32: addi    x28, x27, 0             # encoding: [0xe6,0xc0,0x00,0x13]
# CHECK32: addi    x29, x28, 0             # encoding: [0xef,0x00,0x00,0x13]
# CHECK32: addi    x30, x29, 0             # encoding: [0xf7,0x40,0x00,0x13]

# CHECK32: nop				   # encoding: [0x00,0x00,0x00,0x13]

# CHECK32: addi	x2, x2, 1023               # encoding: [0x10,0x8f,0xfc,0x13]
# CHECK32: addi	x3, x2, -1023              # encoding: [0x18,0xb0,0x04,0x13]
# CHECK32: addi    x30, x0, 0              # encoding: [0xf0,0x00,0x00,0x13]
# CHECK32: mv      x30, x0                 # encoding: [0xf0,0x00,0x00,0x13]

# CHECK32: slti	x4, x3, 0                  # encoding: [0x20,0xc0,0x01,0x13]
# CHECK32: slti	x5, x4, 1023               # encoding: [0x29,0x0f,0xfd,0x13]
# CHECK32: sltiu x6, x0, 1                 # encoding: [0x30,0x00,0x05,0x93]
# CHECK32: seqz    x6, x0                  # encoding: [0x30,0x01,0x01,0x93]

# CHECK32: andi	x7, x6, 12                 # encoding: [0x39,0x80,0x33,0x93]
# CHECK32: ori	x8, x7, -24                # encoding: [0x41,0xff,0xa3,0x13]
# CHECK32: xori	x9, x8, 17                 # encoding: [0x4a,0x00,0x46,0x13]
# CHECK32: xori	x10, x9, -1                # encoding: [0x52,0x7f,0xfe,0x13]
# CHECK32: not     x10, x9                 # encoding: [0x52,0x7f,0x02,0x13]

# CHECK32: slli	x11, x9, 5                 # encoding: [0x5a,0x40,0x14,0x93]
# CHECK32: srli	x12, x11, 31               # encoding: [0x62,0xc0,0x7e,0x93]
# CHECK32: srai	x13, x12, 2                # encoding: [0x6b,0x01,0x0a,0x93]
# CHECK32: lui	x14, 1048575               # encoding: [0x77,0xff,0xff,0xb7]
# CHECK32: auipc   x15, 4                  # encoding: [0x78,0x20,0x00,0x37]

# CHECK32: add     x16, x15, x14           # encoding: [0x83,0x9e,0x00,0x33]
# CHECK32: sub     x17, x16, x15           # encoding: [0x8b,0xe1,0x00,0x33]
# CHECK32: slt     x18, x17, x16           # encoding: [0x94,0x22,0x01,0x33]
# CHECK32: sltu    x19, x18, x17           # encoding: [0x9c,0x64,0x01,0xb3]
# CHECK32: and     x20, x19, x18           # encoding: [0xa4,0xa6,0x03,0xb3]
# CHECK32: or      x21, x20, x19           # encoding: [0xac,0xe8,0x03,0x33]
# CHECK32: xor     x22, x21, x20           # encoding: [0xb5,0x2a,0x02,0x33]
# CHECK32: sll     x23, x22, x21           # encoding: [0xbd,0x6d,0x00,0xb3]
# CHECK32: srl     x24, x23, x22           # encoding: [0xc5,0xae,0x02,0xb3]
# CHECK32: sra     x25, x24, x23           # encoding: [0xcd,0xf1,0x02,0xb3]
# CHECK32: mv      x2, x0                  # encoding: [0x10,0x00,0x00,0x13]

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

#-- CONTROL TRANSFER INSTRUCTIONS
	mv 	x2, x0
	jal	x27
	jal	x0			#-- unconditional jump
	jalr	x28, x27, 8
	beq	x28,x27, target_beq
target_beq:
	bne	x28,x27, target_bne
target_bne:
	blt	x29, x28, target_blt
target_blt:
	bltu	x30, x29, target_blt	
target_bltu:
	bge	x31, x30, target_bge
target_bge:
	bgeu	x2, x31, target_bgeu
target_bgeu:
	nop

#-- LOAD AND STORE INSTRUCTIONS	

	lw x5, 0(x3)
	sw x5, x3, 0
	sh x6, x3, 0
	sb x7, x3, 0
	sw x5, x3, -4
	sh x6, x3, -4
	sb x7, x3, -4
	sw x5, x3, 4
	sh x6, x3, 4
	sb x7, x3, 4
	lw x5, x3, 0
	lh x6, x3, 0
	lb x7, x3, 0
	lw x5, x3, -4
	lh x6, x3, -4
	lb x7, x3, -4
	lw x5, x3, 4
	lh x6, x3, 4
	lb x7, x3, 4

#-- MEMORY MODEL
	fence
	fence.i

#-- SYSTEM INSTRUCTIONS
	scall
	sbreak
	rdcycle	x5
	rdcycleh x6
	rdtime	x7
	rdtimeh	x8
	rdinstret x9 
	rdinstreth x10 
		

#-- EOF

