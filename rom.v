`timescale 1ns/1ps

module ROM (addr,data);
input [31:0] addr;
output [31:0] data;
reg [31:0] data;
localparam ROM_SIZE = 32;
reg [31:0] ROM_DATA[ROM_SIZE-1:0];

always@(*)
	case(addr[30:2])
	// main:
	0: data <= 32'b000010_00000000000000000000000011; // j Initial
	// illop:
	1: data <= 32'b000010_00000000000000000000000110; // j Interrupt
	// xadr:
	2: data <= 32'b000010_00000000000000000000000110; // j Exit1
	// Initial:
	3: data <= 32'b001111_00000_00100_0100000000000000; // lui $a0 0x4000
	// UART_Send:
	4: data <= 32'b001000_00000_00010_0000000000001000; // addi $v0 $0 8
	5: data <= 32'b101011_00100_00010_0000000000011000; // sw $v0 24($a0)
	default: data <= 32'b0;//000010_00000000000000000000000011;
endcase
endmodule
