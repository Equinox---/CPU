	lui $a0, 0x4000			#**a0=0x40000000	
	addi $a2, $0, 169
	addi $a3, $0, 52
	addi $t5, $a2, 0
	addi $t6, $a3, 0
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
Exit:
	sw $t6, 12($a0)