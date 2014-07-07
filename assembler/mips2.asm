Initial:
	addi $t2, $0, 0		#t2-number of operand
	addi $t3, $0, 2		#t3=2
UART_Receive:
	lui $a0, 0x4000
	addi $a0, $zero, 0x0020	#a0=UART_CON
	lw $t0, 0($a0)
	sll $t0, $t0, 28
	srl $t0, $t0, 31		#t0=UART_CON[3]
	addi $t1, $0, 1		#t1=1
	bne $t0, $t1, UART_Receive
	addi $t2, $t2, 1
	
	beq $t2, $t3, Load2
	lui $a1, 0x4000
	addi $a1, $zero, 0x001C	#a1=UART_RXD
	lw $a2, 0($a1)	#a2=operand1
	j UART_Receive
Load2:
	lw $a3, 0($a1)		#a3=operand2	
