main:
	j Initial
illop:
	j Interrupt
xadr:
	j Exit1

Initial:
	addi $t5, $a2, 0 #t5 is operand1
	addi $t6, $a3, 0 #t6 is operand2
	sub $t7, $t5, $t6
Judge:
	beq $t7, $0, Exit
	bltz $t7,Negative
Positive:
	add $t5,$t6,$0
	sub $t7, $t7, $t6
	j Judge
Negative:
	sub $t6, $0, $t7
	add $t7, $t5, $t7
	j Judge
	
Interrupt:

Exit:
	add $v0, $t6, $0
	#sw $v0, 12($a0)
UART_Send:
	#sw $v0, 24($a0)
	lw $t1, 32($a0)
	srl $t1, $t1, 3
	sll $t1, $t1, 3
	addiu $t1, $t1, 7
	sw $t1, 32($a1)
Exit1:
	lw $s0, 12($a0)
	addi $s1, $zero, 32
	or $s0, $s0, $s1
	sw $s0, 12($a0)