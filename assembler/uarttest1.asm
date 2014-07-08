main:
	j Initial
illop:
	j Interrupt
xadr:
	j Exit1

Initial:
	addi $t1, $0, 1			#t1=1
	addi $t2, $0, 0			#t2-number of operand
	addi $t3, $0, 2			#t3=2
	addi $t4, $0, 0			#**t4=number of interrupt
	lui $a0, 0x4000			#**a0=0x40000000	
	addiu $sp, $0, 0x0400	#sp=0x00000400
	# led
	addi $s0, $zero, 1
	sw $s0, 12($a0)
UART_Receive:
	lw $t0, 32($a0)			
	sll $t4, $t0, 28		#t0=UART_CON
	srl $t4, $t4, 31		#t4=UART_CON[3]
	bne $t4, $t1, UART_Receive
	# led
	addi $s1, $zero, 2
	or $s0, $s1, $s0
sw $s0, 12($a0)
	addi $t2, $t2, 1
	beq $t2, $t3, Load2
	#led
	addi $s1, $0, 4
	or $s0, $s1, $s0
sw $s0, 12($a0)
	lw $a2, 28($a0)			#**a2=operand1
	sll $t0, $t0, 29
	srl $t0, $t0, 29
	sw $t0, 32($a0)
	j UART_Receive
Load2:
addi $s1, $0, 8
	or $s0, $s1, $s0
	sw $s0, 12($a0)
	lw $a3, 28($a0)     #**a3=operand2
	sll $t0, $t0, 29
	srl $t0, $t0, 29
	sw $t0, 32($a0)	
	
	sw $a3, 24($a0)
Interrupt:
Exit1: