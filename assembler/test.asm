main:
	j Initial
illop:
	j Interrupt
xadr:
	j Exit1

Initial:
	jal Normal
	addi $t0, $zero, 0x0002
	lui $a0, 0x4000
	sw $t0, 12($a0)
	j Exit1

Normal:
	sll $ra, $ra, 1
	srl $ra, $ra, 1			#CPU is in normal state
	jr $ra
	
Interrupt:
Exit1: