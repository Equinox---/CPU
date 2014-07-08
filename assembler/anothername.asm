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
UART_Receive:
	lw $t0, 32($a0)			
	sll $t4, $t0, 28		#t0=UART_CON
	srl $t4, $t4, 31		#t4=UART_CON[3]
	bne $t4, $t1, UART_Receive
	addi $t2, $t2, 1
	beq $t2, $t3, Load2
	lw $a2, 28($a0)			#**a2=operand1
	sll $t0, $t0, 29
	srl $t0, $t0, 29
	sw $t0, 32($a0)
	j UART_Receive
Load2:
	lw $a3, 28($a0)			#**a3=operand2
	sll $t0, $t0, 29
	srl $t0, $t0, 29
	sw $t0, 32($a0)	
Timer:
	jal Normal
	sw $0, 8($a0)
	lui $t0, 0xffff
	addiu $t0, $t0, 0xff00
	sw $t0, 0($a0)
	addiu $t0, $t0, 0xff
	sw $t0, 4($a0)
	addi $t0, $0, 3
	sw $t0, 8($a0)			#Timer is on
	#calculate graetest common divisor
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
	
Interrupt:
	lw $t0, 8($a0)
	andi $t0,$t0,  0xfff9
	sw $t0, 8($a0)
	sw $ra, 0($sp)
	
	beq $t4, $0, First
	addi $t3 ,$0, 1
	beq $t4, $t3, Second
	addi $t3 ,$0, 2
	beq $t4, $t3, Third
	addi $t3 ,$0, 3
	beq $t4, $t3, Fourth
Continue:
	lw $ra, 0($sp)
	sw $a1,20($a0)
	addiu $t1 $0, 2
	lw $t0, 8($a0)
	or $t0, $t0, $t1
	sw $t0, 8($a0)
	addi $26, $26, -4
	jr $26
First:	
	sll $t0, $a2, 28
	srl $t0, $t0, 28
	jal DigitalTube
	addi $a1, $a1, 128
	addi $t4, $0, 1
	j Continue
Second:
	
	sll $t0, $a2, 24
	srl $t0, $t0, 28
	jal DigitalTube
	addi $a1, $a1, 256
	addi $t4, $0, 2
	j Continue
Third:
	sll $t0, $a3, 28
	srl $t0, $t0, 28
	jal DigitalTube
	addi $a1, $a1, 512
	addi $t4, $0, 3
	j Continue
Fourth:
	sll $t0, $a3, 24
	srl $t0, $t0, 28
	jal DigitalTube
	addi $a1, $a1, 1024
	addi $t4, $0, 0
	j Continue
	
DigitalTube:
	addi $t1, $t0, -15
	beq $t1, $0, Fifteen
	addi $t1, $t0, -14
	beq $t1, $0, Fourteen
	addi $t1, $t0, -13
	beq $t1, $0, Thirteen
	addi $t1, $t0, -12
	beq $t1, $0, Twelve
	addi $t1, $t0, -11
	beq $t1, $0, Eleven
	addi $t1, $t0, -10
	beq $t1, $0, Ten
	addi $t1, $t0, -9
	beq $t1, $0, Nine
	addi $t1, $t0, -8
	beq $t1, $0, Eight
	addi $t1, $t0, -7
	beq $t1, $0, Seven
	addi $t1, $t0, -6
	beq $t1, $0, Six
	addi $t1, $t0, -5
	beq $t1, $0, Five
	addi $t1, $t0, -4
	beq $t1, $0, Four
	addi $t1, $t0, -3
	beq $t1, $0, Three
	addi $t1, $t0, -2
	beq $t1, $0, Two
	addi $t1, $t0, -1
	beq $t1, $0, One
	beq $t0, $0, Zero
Fifteen:
	addi $a1, $0, 14
	jr $ra
Fourteen:
	addi $a1, $0, 6
	jr $ra
Thirteen:
	addi $a1, $0, 33
	jr $ra
Twelve:
	addi $a1, $0, 70
	jr $ra
Eleven:
	addi $a1, $0, 3
	jr $ra
Ten:
	addi $a1, $0, 8
	jr $ra
Nine:
	addi $a1, $0, 16
	jr $ra
Eight:
	addi $a1, $0, 0
	jr $ra	
Seven:
	addi $a1, $0, 120
	jr $ra
Six:
	addi $a1, $0, 2
	jr $ra
Five:
	addi $a1, $0, 18
	jr $ra
Four:
	addi $a1, $0, 25
	jr $ra
Three:
	addi $a1, $0, 48
	jr $ra
Two:
	addi $a1, $0, 36
	jr $ra
One:
	addi $a1, $0, 121
	jr $ra
Zero:
	addi $a1, $0, 64
	jr $ra
	
	
Normal:
	sll $ra, $ra, 1
	srl $ra, $ra, 1			#CPU is in normal state
	jr $ra
	
Exit:
	add $v0, $t6, $0
	sw $v0, 12($a0)
UART_Send:
	sw $v0, 24($a0)
	lw $t1, 32($a0)
	srl $t1, $t1, 3
	sll $t1, $t1, 3
	addiu $t1, $t1, 7
	sw $t1, 32($a1)
Exit1:
	
