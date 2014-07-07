main:
	j Initial
illop:
	j Interrupt
xadr:
	j Exit1
Initial:
	lui $a0, 0x4000			#**a0=0x40000000
UART_Send:
	addi $v0, $0, 77
	sw $v0, 24($a0)
	#lw $t1, 32($a0)
	#srl $t1, $t1, 3
	#sll $t1, $t1, 3
	#addiu $t1, $t1, 7
	#sw $t1, 32($a1)
Interrupt:
Exit1: