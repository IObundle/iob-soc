	.file	"firmware.c"
	.option nopic
	.text
	.align	2
	.type	print_dec.part.0, @function
print_dec.part.0:
	li	a5,899
	bleu	a0,a5,.L2
	li	a5,1879048192
	li	a4,57
	sw	a4,8(a5)
	addi	a0,a0,-900
.L3:
	li	a5,89
	bleu	a0,a5,.L11
.L38:
	li	a5,1879048192
	li	a4,57
	sw	a4,8(a5)
	addi	a0,a0,-90
.L12:
	li	a5,8
	bgtu	a0,a5,.L31
.L20:
	beq	a0,a5,.L32
	li	a5,7
	beq	a0,a5,.L33
	li	a5,6
	beq	a0,a5,.L34
	li	a5,5
	beq	a0,a5,.L35
	li	a5,4
	beq	a0,a5,.L36
	li	a5,3
	beq	a0,a5,.L37
	li	a5,2
	bne	a0,a5,.L28
	li	a5,1879048192
	li	a4,50
	sw	a4,8(a5)
	ret
.L2:
	li	a5,799
	bleu	a0,a5,.L4
	li	a5,1879048192
	li	a4,56
	sw	a4,8(a5)
	addi	a0,a0,-800
	li	a5,89
	bgtu	a0,a5,.L38
.L11:
	li	a5,79
	bleu	a0,a5,.L13
	li	a5,1879048192
	li	a4,56
	sw	a4,8(a5)
	addi	a0,a0,-80
	li	a5,8
	bleu	a0,a5,.L20
.L31:
	li	a5,1879048192
	li	a4,57
	sw	a4,8(a5)
	ret
.L13:
	li	a5,69
	bgtu	a0,a5,.L39
	li	a5,59
	bleu	a0,a5,.L15
	li	a5,1879048192
	li	a4,54
	sw	a4,8(a5)
	addi	a0,a0,-60
	j	.L12
.L4:
	li	a5,699
	bgtu	a0,a5,.L40
	li	a5,599
	bleu	a0,a5,.L6
	li	a5,1879048192
	li	a4,54
	sw	a4,8(a5)
	addi	a0,a0,-600
	j	.L3
.L32:
	li	a5,1879048192
	li	a4,56
	sw	a4,8(a5)
	ret
.L33:
	li	a5,1879048192
	li	a4,55
	sw	a4,8(a5)
	ret
.L40:
	li	a5,1879048192
	li	a4,55
	sw	a4,8(a5)
	addi	a0,a0,-700
	j	.L3
.L39:
	li	a5,1879048192
	li	a4,55
	sw	a4,8(a5)
	addi	a0,a0,-70
	j	.L12
.L34:
	li	a5,1879048192
	li	a4,54
	sw	a4,8(a5)
	ret
.L15:
	li	a5,49
	bgtu	a0,a5,.L41
	li	a4,39
	bleu	a0,a4,.L17
	li	a5,1879048192
	li	a4,52
	sw	a4,8(a5)
	addi	a0,a0,-40
	j	.L12
.L6:
	li	a5,499
	bgtu	a0,a5,.L42
	li	a5,399
	bleu	a0,a5,.L8
	li	a5,1879048192
	li	a4,52
	sw	a4,8(a5)
	addi	a0,a0,-400
	j	.L3
.L35:
	li	a5,1879048192
	li	a4,53
	sw	a4,8(a5)
	ret
.L42:
	li	a5,1879048192
	li	a4,53
	sw	a4,8(a5)
	addi	a0,a0,-500
	j	.L3
.L41:
	li	a5,1879048192
	li	a4,53
	sw	a4,8(a5)
	addi	a0,a0,-50
	j	.L12
.L36:
	li	a5,1879048192
	li	a4,52
	sw	a4,8(a5)
	ret
.L17:
	li	a4,29
	bleu	a0,a4,.L18
	li	a5,1879048192
	li	a4,51
	sw	a4,8(a5)
	addi	a0,a0,-30
	j	.L12
.L8:
	li	a5,299
	bleu	a0,a5,.L9
	li	a5,1879048192
	li	a4,51
	sw	a4,8(a5)
	addi	a0,a0,-300
	j	.L3
.L37:
	li	a5,1879048192
	li	a4,51
	sw	a4,8(a5)
	ret
.L9:
	li	a5,199
	bleu	a0,a5,.L10
	li	a5,1879048192
	li	a4,50
	sw	a4,8(a5)
	addi	a0,a0,-200
	j	.L3
.L18:
	li	a4,19
	bleu	a0,a4,.L19
	li	a5,1879048192
	li	a4,50
	sw	a4,8(a5)
	addi	a0,a0,-20
	j	.L12
.L28:
	li	a5,1879048192
	bnez	a0,.L43
	li	a4,48
	sw	a4,8(a5)
	ret
.L10:
	li	a5,99
	bleu	a0,a5,.L3
	li	a5,1879048192
	li	a4,49
	sw	a4,8(a5)
	addi	a0,a0,-100
	j	.L3
.L19:
	li	a4,9
	bleu	a0,a4,.L12
	li	a4,1879048192
	sw	a5,8(a4)
	addi	a0,a0,-10
	j	.L12
.L43:
	li	a4,49
	sw	a4,8(a5)
	ret
	.size	print_dec.part.0, .-print_dec.part.0
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	li	a5,10
	beq	a0,a5,.L46
.L45:
	li	a5,1879048192
	sw	a0,8(a5)
	ret
.L46:
	li	a5,1879048192
	li	a4,13
	sw	a4,8(a5)
	j	.L45
	.size	putchar, .-putchar
	.align	2
	.globl	print
	.type	print, @function
print:
	lbu	a5,0(a0)
	beqz	a5,.L47
	li	a3,10
	li	a4,1879048192
	li	a2,13
.L48:
	addi	a0,a0,1
	beq	a5,a3,.L53
	sw	a5,8(a4)
	lbu	a5,0(a0)
	bnez	a5,.L48
.L47:
	ret
.L53:
	sw	a2,8(a4)
	sw	a5,8(a4)
	lbu	a5,0(a0)
	bnez	a5,.L48
	ret
	.size	print, .-print
	.align	2
	.globl	print_hex
	.type	print_hex, @function
print_hex:
	lui	a5,%hi(.LC0)
	srli	a4,a0,28
	addi	a5,a5,%lo(.LC0)
	add	a4,a5,a4
	lbu	a3,0(a4)
	li	a4,48
	beq	a3,a4,.L81
	li	a4,10
	beq	a3,a4,.L82
.L59:
	srli	a4,a0,24
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a6,0(a4)
	li	a4,1879048192
	sw	a3,8(a4)
	li	a4,48
	beq	a6,a4,.L57
.L58:
	li	a4,10
	beq	a6,a4,.L83
.L57:
	srli	a4,a0,20
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a2,0(a4)
	li	a4,1879048192
	sw	a6,8(a4)
	li	a4,48
	beq	a2,a4,.L61
.L62:
	li	a4,10
	beq	a2,a4,.L84
.L61:
	srli	a4,a0,16
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a3,0(a4)
	li	a4,1879048192
	sw	a2,8(a4)
	li	a4,48
	beq	a3,a4,.L64
.L65:
	li	a4,10
	beq	a3,a4,.L85
.L64:
	srli	a4,a0,12
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a2,0(a4)
	li	a4,1879048192
	sw	a3,8(a4)
	li	a4,48
	beq	a2,a4,.L67
.L68:
	li	a4,10
	beq	a2,a4,.L86
.L67:
	srli	a4,a0,8
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a3,0(a4)
	li	a4,1879048192
	sw	a2,8(a4)
	li	a4,48
	beq	a3,a4,.L70
.L71:
	li	a4,10
	beq	a3,a4,.L87
.L70:
	srli	a4,a0,4
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a4,0(a4)
	li	a2,1879048192
	sw	a3,8(a2)
	li	a3,48
	beq	a4,a3,.L73
.L74:
	li	a3,10
	beq	a4,a3,.L88
.L73:
	andi	a0,a0,15
	add	a5,a5,a0
	lbu	a5,0(a5)
	li	a3,1879048192
	sw	a4,8(a3)
	li	a4,48
	beq	a5,a4,.L76
.L77:
	li	a4,10
	beq	a5,a4,.L89
.L76:
	li	a4,1879048192
	sw	a5,8(a4)
.L54:
	ret
.L81:
	li	a4,7
	bgt	a1,a4,.L59
	srli	a2,a0,24
	andi	a2,a2,15
	add	a2,a5,a2
	lbu	a6,0(a2)
	bne	a6,a3,.L58
	beq	a1,a4,.L57
	srli	a4,a0,20
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a2,0(a4)
	bne	a2,a6,.L62
	li	a4,6
	beq	a1,a4,.L61
	srli	a4,a0,16
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a3,0(a4)
	bne	a3,a2,.L65
	li	a4,5
	beq	a1,a4,.L64
	srli	a4,a0,12
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a2,0(a4)
	bne	a2,a3,.L68
	li	a4,4
	beq	a1,a4,.L67
	srli	a4,a0,8
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a3,0(a4)
	li	a4,48
	bne	a3,a4,.L71
	li	a4,3
	beq	a1,a4,.L70
	srli	a4,a0,4
	andi	a4,a4,15
	add	a4,a5,a4
	lbu	a4,0(a4)
	bne	a4,a3,.L74
	li	a3,2
	beq	a1,a3,.L73
	andi	a0,a0,15
	add	a5,a5,a0
	lbu	a5,0(a5)
	bne	a5,a4,.L77
	li	a4,1
	beq	a1,a4,.L76
	ret
.L89:
	li	a4,1879048192
	li	a3,13
	sw	a3,8(a4)
	li	a4,1879048192
	sw	a5,8(a4)
	j	.L54
.L82:
	li	a4,1879048192
	li	a2,13
	sw	a2,8(a4)
	j	.L59
.L83:
	li	a4,1879048192
	li	a3,13
	sw	a3,8(a4)
	j	.L57
.L84:
	li	a4,1879048192
	li	a3,13
	sw	a3,8(a4)
	j	.L61
.L85:
	li	a4,1879048192
	li	a2,13
	sw	a2,8(a4)
	j	.L64
.L86:
	li	a4,1879048192
	li	a3,13
	sw	a3,8(a4)
	j	.L67
.L87:
	li	a4,1879048192
	li	a2,13
	sw	a2,8(a4)
	j	.L70
.L88:
	li	a3,1879048192
	li	a2,13
	sw	a2,8(a3)
	j	.L73
	.size	print_hex, .-print_hex
	.align	2
	.globl	print_dec
	.type	print_dec, @function
print_dec:
	li	a5,999
	bleu	a0,a5,.L125
	lui	a4,%hi(.LC1+1)
	li	a5,62
	addi	a4,a4,%lo(.LC1+1)
	li	a3,1879048192
	li	a2,10
	li	a1,13
.L91:
	sw	a5,8(a3)
	lbu	a5,0(a4)
	addi	a4,a4,1
	beqz	a5,.L126
.L94:
	bne	a5,a2,.L91
	sw	a1,8(a3)
	sw	a5,8(a3)
	lbu	a5,0(a4)
	addi	a4,a4,1
	bnez	a5,.L94
.L126:
	ret
.L125:
	li	a5,899
	bleu	a0,a5,.L96
	li	a5,1879048192
	li	a4,57
	sw	a4,8(a5)
	addi	a0,a0,-900
.L97:
	li	a5,89
	bleu	a0,a5,.L105
	li	a5,1879048192
	li	a4,57
	sw	a4,8(a5)
	addi	a0,a0,-90
.L106:
	li	a5,9
	beq	a0,a5,.L127
	li	a5,8
	beq	a0,a5,.L128
	li	a5,7
	beq	a0,a5,.L129
	li	a5,6
	beq	a0,a5,.L130
	li	a5,5
	beq	a0,a5,.L131
	li	a5,4
	beq	a0,a5,.L132
	li	a5,3
	beq	a0,a5,.L133
	li	a5,2
	bne	a0,a5,.L121
	li	a5,1879048192
	li	a4,50
	sw	a4,8(a5)
	ret
.L96:
	li	a5,799
	bgtu	a0,a5,.L134
	li	a5,699
	bleu	a0,a5,.L99
	li	a5,1879048192
	li	a4,55
	sw	a4,8(a5)
	addi	a0,a0,-700
	j	.L97
.L105:
	li	a5,79
	bgtu	a0,a5,.L135
	li	a5,69
	bleu	a0,a5,.L108
	li	a5,1879048192
	li	a4,55
	sw	a4,8(a5)
	addi	a0,a0,-70
	j	.L106
.L127:
	li	a5,1879048192
	li	a4,57
	sw	a4,8(a5)
	ret
.L134:
	li	a5,1879048192
	li	a4,56
	sw	a4,8(a5)
	addi	a0,a0,-800
	j	.L97
.L135:
	li	a5,1879048192
	li	a4,56
	sw	a4,8(a5)
	addi	a0,a0,-80
	j	.L106
.L128:
	li	a5,1879048192
	li	a4,56
	sw	a4,8(a5)
	ret
.L129:
	li	a5,1879048192
	li	a4,55
	sw	a4,8(a5)
	ret
.L99:
	li	a5,599
	bgtu	a0,a5,.L136
	li	a5,499
	bleu	a0,a5,.L101
	li	a5,1879048192
	li	a4,53
	sw	a4,8(a5)
	addi	a0,a0,-500
	j	.L97
.L108:
	li	a5,59
	bgtu	a0,a5,.L137
	li	a5,49
	bleu	a0,a5,.L110
	li	a5,1879048192
	li	a4,53
	sw	a4,8(a5)
	addi	a0,a0,-50
	j	.L106
.L130:
	li	a5,1879048192
	li	a4,54
	sw	a4,8(a5)
	ret
.L137:
	li	a5,1879048192
	li	a4,54
	sw	a4,8(a5)
	addi	a0,a0,-60
	j	.L106
.L136:
	li	a5,1879048192
	li	a4,54
	sw	a4,8(a5)
	addi	a0,a0,-600
	j	.L97
.L131:
	li	a5,1879048192
	li	a4,53
	sw	a4,8(a5)
	ret
.L110:
	li	a4,39
	bleu	a0,a4,.L111
	li	a5,1879048192
	li	a4,52
	sw	a4,8(a5)
	addi	a0,a0,-40
	j	.L106
.L101:
	li	a5,399
	bleu	a0,a5,.L102
	li	a5,1879048192
	li	a4,52
	sw	a4,8(a5)
	addi	a0,a0,-400
	j	.L97
.L132:
	li	a5,1879048192
	li	a4,52
	sw	a4,8(a5)
	ret
.L111:
	li	a4,29
	bleu	a0,a4,.L112
	li	a5,1879048192
	li	a4,51
	sw	a4,8(a5)
	addi	a0,a0,-30
	j	.L106
.L102:
	li	a5,299
	bleu	a0,a5,.L103
	li	a5,1879048192
	li	a4,51
	sw	a4,8(a5)
	addi	a0,a0,-300
	j	.L97
.L133:
	li	a5,1879048192
	li	a4,51
	sw	a4,8(a5)
	ret
.L112:
	li	a4,19
	bleu	a0,a4,.L113
	li	a5,1879048192
	li	a4,50
	sw	a4,8(a5)
	addi	a0,a0,-20
	j	.L106
.L103:
	li	a5,199
	bleu	a0,a5,.L104
	li	a5,1879048192
	li	a4,50
	sw	a4,8(a5)
	addi	a0,a0,-200
	j	.L97
.L121:
	li	a5,1879048192
	bnez	a0,.L138
	li	a4,48
	sw	a4,8(a5)
	ret
.L113:
	li	a4,9
	bleu	a0,a4,.L106
	li	a4,1879048192
	sw	a5,8(a4)
	addi	a0,a0,-10
	j	.L106
.L104:
	li	a5,99
	bleu	a0,a5,.L97
	li	a5,1879048192
	li	a4,49
	sw	a4,8(a5)
	addi	a0,a0,-100
	j	.L97
.L138:
	li	a4,49
	sw	a4,8(a5)
	ret
	.size	print_dec, .-print_dec
	.align	2
	.globl	getchar_prompt
	.type	getchar_prompt, @function
getchar_prompt:
 #APP
# 86 "firmware.c" 1
	rdcycle a6
# 0 "" 2
 #NO_APP
	beqz	a0,.L140
	lbu	a5,0(a0)
	mv	a4,a0
	beqz	a5,.L140
	li	a2,10
	li	a3,1879048192
	li	a1,13
.L141:
	addi	a4,a4,1
	beq	a5,a2,.L160
	sw	a5,8(a3)
	lbu	a5,0(a4)
	bnez	a5,.L141
.L140:
	li	a7,12001280
	addi	a7,a7,-1280
	li	a1,10
	li	a3,1879048192
	li	t3,13
	li	t1,-1
.L148:
 #APP
# 94 "firmware.c" 1
	rdcycle a2
# 0 "" 2
 #NO_APP
	sub	a5,a2,a6
	bleu	a5,a7,.L144
	mv	a6,a2
	beqz	a0,.L144
	lbu	a5,0(a0)
	mv	a4,a0
	beqz	a5,.L144
.L145:
	addi	a4,a4,1
	beq	a5,a1,.L161
	sw	a5,8(a3)
	lbu	a5,0(a4)
	bnez	a5,.L145
.L159:
	mv	a6,a2
.L144:
	lw	a5,8(a3)
	beq	a5,t1,.L148
	andi	a0,a5,0xff
	ret
.L161:
	sw	t3,8(a3)
	sw	a1,8(a3)
	lbu	a5,0(a4)
	bnez	a5,.L145
	j	.L159
.L160:
	sw	a1,8(a3)
	sw	a5,8(a3)
	lbu	a5,0(a4)
	bnez	a5,.L141
	j	.L140
	.size	getchar_prompt, .-getchar_prompt
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
 #APP
# 86 "firmware.c" 1
	rdcycle a5
# 0 "" 2
 #NO_APP
	li	a4,1879048192
	li	a5,-1
.L163:
 #APP
# 94 "firmware.c" 1
	rdcycle a3
# 0 "" 2
 #NO_APP
	lw	a0,8(a4)
	beq	a0,a5,.L163
	andi	a0,a0,0xff
	ret
	.size	getchar, .-getchar
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-96
	lui	a5,%hi(.LC2+1)
	sw	ra,92(sp)
	sw	s0,88(sp)
	sw	s1,84(sp)
	sw	s2,80(sp)
	sw	s3,76(sp)
	sw	s4,72(sp)
	sw	s5,68(sp)
	sw	s6,64(sp)
	sw	s7,60(sp)
	sw	s8,56(sp)
	sw	s9,52(sp)
	sw	s10,48(sp)
	sw	s11,44(sp)
	li	a4,46
	addi	a5,a5,%lo(.LC2+1)
	li	a3,1879048192
	li	a1,10
	li	a2,13
.L166:
	sw	a4,8(a3)
	lbu	a4,0(a5)
	addi	a5,a5,1
	beqz	a4,.L248
	bne	a4,a1,.L166
	sw	a2,8(a3)
	j	.L166
.L248:
	li	a5,4096
	lui	s0,%hi(vect)
	sw	a5,%lo(vect)(s0)
	lui	a5,%hi(.LC3+1)
	li	a4,87
	addi	a5,a5,%lo(.LC3+1)
	li	a3,1879048192
	li	a1,10
	li	a2,13
.L169:
	sw	a4,8(a3)
	lbu	a4,0(a5)
	addi	a5,a5,1
	beqz	a4,.L249
	bne	a4,a1,.L169
	sw	a2,8(a3)
	j	.L169
.L249:
	li	a0,4096
	li	a1,8
	call	print_hex
	lui	s11,%hi(.LC5+1)
	addi	a5,s11,%lo(.LC5+1)
	lui	s7,%hi(.LC7)
	lui	s6,%hi(.LC8)
	sw	a5,24(sp)
	addi	a5,s7,%lo(.LC7)
	lui	s5,%hi(.LC9)
	sw	a5,8(sp)
	addi	a5,s6,%lo(.LC8)
	lui	s4,%hi(.LC10)
	sw	a5,12(sp)
	addi	a5,s5,%lo(.LC9)
	lui	s3,%hi(.LC11)
	sw	a5,16(sp)
	addi	a5,s4,%lo(.LC10)
	sw	a5,0(sp)
	addi	a5,s3,%lo(.LC11)
	sw	a5,4(sp)
	lui	a5,%hi(.LC1+1)
	addi	a5,a5,%lo(.LC1+1)
	lui	s10,%hi(.LC12+1)
	lw	a0,%lo(vect)(s0)
	lui	s9,%hi(.LC4)
	lui	s8,%hi(.LC6)
	lui	t3,%hi(.LC13+1)
	sw	a5,28(sp)
	lui	a6,%hi(.LC0)
	addi	a5,s10,%lo(.LC12+1)
	lui	s2,%hi(.LC14)
	addi	s9,s9,%lo(.LC4)
	addi	s8,s8,%lo(.LC6)
	addi	s6,t3,%lo(.LC13+1)
	sw	a5,20(sp)
	addi	s5,a6,%lo(.LC0)
	addi	s2,s2,%lo(.LC14)
	li	s4,10
	li	s3,1879048192
	li	s10,13
	li	s1,53
	li	s11,48
.L172:
	li	a3,10
	mv	a2,s9
.L173:
	addi	a2,a2,1
	beq	a3,s4,.L250
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L173
.L176:
	lw	a2,24(sp)
	li	a3,78
.L177:
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	a2,a2,1
	beqz	a3,.L251
.L179:
	bne	a3,s4,.L177
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	a2,a2,1
	bnez	a3,.L179
.L251:
	sw	s1,8(s3)
	li	a3,10
	mv	a2,s8
.L180:
	addi	a2,a2,1
	beq	a3,s4,.L252
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L180
.L183:
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	lw	a2,8(sp)
	sw	s1,8(s3)
	sw	s11,8(s3)
	li	a3,10
.L184:
	addi	a2,a2,1
	beq	a3,s4,.L253
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L184
.L187:
	lw	a2,12(sp)
	li	a3,54
	sw	a3,8(s3)
	li	a3,10
.L188:
	addi	a2,a2,1
	beq	a3,s4,.L254
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L188
.L191:
	lw	a2,16(sp)
	li	a3,55
	sw	a3,8(s3)
	li	a3,10
.L192:
	addi	a2,a2,1
	beq	a3,s4,.L255
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L192
.L195:
	lw	a2,0(sp)
	li	a3,56
	sw	a3,8(s3)
	li	a3,10
.L196:
	addi	a2,a2,1
	beq	a3,s4,.L256
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L196
.L199:
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	sw	s11,8(s3)
	lw	a2,4(sp)
	sw	s11,8(s3)
	sw	s11,8(s3)
	li	a3,10
.L200:
	addi	a2,a2,1
	beq	a3,s4,.L257
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L200
	lw	a3,0(a0)
	bnez	a3,.L204
.L214:
	li	a3,87
	mv	a2,s6
.L205:
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	t5,s3,8
	addi	a2,a2,1
	beqz	a3,.L258
.L216:
	bne	a3,s4,.L205
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	t5,s3,8
	addi	a2,a2,1
	bnez	a3,.L216
.L258:
	li	a3,32
	sw	a3,0(t5)
	lw	a3,0(a0)
	srli	t4,a3,28
	add	t4,s5,t4
	srli	t6,a3,24
	srli	a1,a3,20
	srli	a2,a3,16
	lbu	t4,0(t4)
	andi	t6,t6,15
	andi	a1,a1,15
	andi	a2,a2,15
	add	t6,s5,t6
	add	a1,s5,a1
	add	a2,s5,a2
	lbu	t6,0(t6)
	lbu	a1,0(a1)
	lbu	a2,0(a2)
	beq	t4,s11,.L217
	beq	t4,s4,.L218
	sw	t4,8(s3)
.L219:
	beq	t6,s4,.L222
	sw	t6,8(s3)
.L223:
	beq	a1,s4,.L226
.L228:
	sw	a1,8(s3)
	mv	a1,a2
	beq	a2,s4,.L230
.L229:
	srli	a2,a3,12
	andi	a2,a2,15
	add	a2,s5,a2
	lbu	t4,0(a2)
	sw	a1,8(s3)
	beq	t4,s4,.L259
.L232:
	srli	a2,a3,8
	andi	a2,a2,15
	add	a2,s5,a2
	lbu	a1,0(a2)
	sw	t4,8(s3)
	beq	a1,s4,.L260
.L234:
	srli	a2,a3,4
	andi	a2,a2,15
	add	a2,s5,a2
	lbu	a2,0(a2)
	sw	a1,8(s3)
	beq	a2,s4,.L261
.L236:
	andi	a3,a3,15
	add	a3,s5,a3
	lbu	a3,0(a3)
	sw	a2,8(s3)
	beq	a3,s4,.L262
.L238:
	sw	a3,8(s3)
	mv	a2,s2
	li	a3,10
.L239:
	addi	a2,a2,1
	beq	a3,s4,.L263
.L240:
	sw	a3,8(s3)
	lbu	a3,0(a2)
	beqz	a3,.L172
	addi	a2,a2,1
	bne	a3,s4,.L240
.L263:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L239
	j	.L172
.L250:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L173
	j	.L176
.L226:
	sw	s10,8(s3)
	j	.L228
.L222:
	sw	s10,8(s3)
	sw	t6,8(s3)
	j	.L223
.L218:
	sw	s10,0(t5)
	sw	t4,8(s3)
	j	.L219
.L257:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L200
	lw	a3,0(a0)
	beqz	a3,.L214
.L204:
	lw	a0,0(a0)
	li	a3,999
	bleu	a0,a3,.L264
	lw	a2,28(sp)
	li	a3,62
.L206:
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	a2,a2,1
	beqz	a3,.L210
.L209:
	bne	a3,s4,.L206
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	a2,a2,1
	bnez	a3,.L209
.L210:
	lw	a2,20(sp)
	li	a3,32
.L211:
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	a2,a2,1
	beqz	a3,.L265
.L213:
	bne	a3,s4,.L211
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	addi	a2,a2,1
	bnez	a3,.L213
.L265:
	li	a0,0
	call	print_dec.part.0
	sw	s10,8(s3)
	sw	s4,8(s3)
	lw	a0,%lo(vect)(s0)
	j	.L214
.L256:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L196
	j	.L199
.L255:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L192
	j	.L195
.L254:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L188
	j	.L191
.L253:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L184
	j	.L187
.L252:
	sw	s10,8(s3)
	sw	a3,8(s3)
	lbu	a3,0(a2)
	bnez	a3,.L180
	j	.L183
.L264:
	call	print_dec.part.0
	j	.L210
.L217:
	bne	t6,s11,.L219
	bne	a1,s11,.L223
	li	a1,48
	beq	a2,s11,.L229
	mv	a1,a2
	bne	a2,s4,.L229
.L230:
	srli	a2,a3,12
	andi	a2,a2,15
	add	a2,s5,a2
	lbu	t4,0(a2)
	sw	s10,8(s3)
	li	a1,10
	sw	a1,8(s3)
	bne	t4,s4,.L232
.L259:
	srli	a2,a3,8
	andi	a2,a2,15
	add	a2,s5,a2
	lbu	a1,0(a2)
	sw	s10,8(s3)
	sw	t4,8(s3)
	bne	a1,s4,.L234
.L260:
	srli	a2,a3,4
	andi	a2,a2,15
	add	a2,s5,a2
	lbu	a2,0(a2)
	sw	s10,8(s3)
	sw	a1,8(s3)
	bne	a2,s4,.L236
.L261:
	andi	a3,a3,15
	add	a3,s5,a3
	lbu	a3,0(a3)
	sw	s10,8(s3)
	sw	a2,8(s3)
	bne	a3,s4,.L238
.L262:
	sw	s10,8(s3)
	j	.L238
	.size	main, .-main
	.comm	flag,4,4
	.comm	vect,4,4
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"0123456789abcdef"
	.zero	3
.LC1:
	.string	">=1000"
	.zero	1
.LC2:
	.string	"... Initializing program in main memory:\n"
	.zero	2
.LC3:
	.string	"Writting number at 0x"
	.zero	2
.LC4:
	.string	"\nSelect the number of N = {N3, N2, N1, N0} for prints (between 0 and 9):\n"
	.zero	2
.LC5:
	.string	"N3 = "
	.zero	2
.LC6:
	.string	"\nN3<<4 = "
	.zero	2
.LC7:
	.string	"\nN2 = "
	.zero	1
.LC8:
	.string	"\nN1 = "
	.zero	1
.LC9:
	.string	"\nN0 = "
	.zero	1
.LC10:
	.string	"\nN ="
	.zero	3
.LC11:
	.string	"\nWrite verification:\n"
	.zero	2
.LC12:
	.string	" should've been "
	.zero	3
.LC13:
	.string	"Write print:\n"
	.zero	2
.LC14:
	.string	"\nEnd of program.\n"
	.ident	"GCC: (GNU) 7.2.0"
