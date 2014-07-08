main:
	j Initial
illop:
	j Interrupt
xadr:
	j Exit1
Initial:
	add $t4, $0, $0
	lui $a0, 0x4000			#**a0=0x40000000	
	addi $s0, $0, 249		#1-1
	addi $s1, $0, 292
	addi $s2, $0, 560
	addi $s3, $0, 1049
	addi $sp, $0, 1024
Timer:
	jal Normal
	sw $0, 8($a0)
	lui $t0, 65535
	addiu $t0, $t0, 65280
	sw $t0, 0($a0)
	lui $t0, 65535
	addiu $t0, $t0, 65535
	sw $t0, 4($a0)
	addi $t0, $0, 3
	sw $t0, 8($a0)			#Timer is on
	j Exit1
Interrupt:
	sw $ra, 0($sp)
	lw $t4, -4($sp)
	lw $t0, 8($a0)
	andi $t0,$t0, 65529
	sw $t0, 8($a0)
	beq $t4, $0, First
	addi $t3 ,$0, 1
	beq $t4, $t3, Second
	addi $t3 ,$0, 2
	beq $t4, $t3, Third
	addi $t3 ,$0, 3
	beq $t4, $t3, Fourth
Continue:
	sw $a1,20($a0)
	lw $t0, 8($a0)
	addi $a1, $0, 2
	or $t0, $t0, $a1
	sw $t0, 8($a0)
	lw $ra, 0($sp)
	sw $t4, -4($sp)
	addi $26, $26, -4
	jr $26
First:	
	add $a1, $0, $s0
	addi $t4, $0, 1
	sw $t4, 12($a0)
	j Continue
Second:
	add $a1, $0, $s1
	addi $t4, $0, 2
	sw $t4, 12($a0)
	j Continue
Third:
	add $a1, $0, $s2
	addi $t4, $0, 3
	sw $t4, 12($a0)
	j Continue
Fourth:
	add $a1, $0, $s3
	add $t4, $0, $0
	sw $t4, 12($a0)
	j Continue

Normal:
	sll $ra, $ra, 1
	srl $ra, $ra, 1			#CPU is in normal state
	jr $ra	

Exit1: