	lui $a0, 0x4000			#**a0=0x40000000	

	addi $a2, $0, 169
	addi $a3, $0, 52

	j First
	
Continue:

	sw $a1,20($a0)
	j Exit1

First:	
	sll $t0, $a2, 28
	srl $t0, $t0, 28
	jal DigitalTube
	addi $a1, $a1, 128
	addi $t4, $0, 1
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


Exit1:
	
