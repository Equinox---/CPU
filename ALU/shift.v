module Shift(A, B, ALUFun, S);
	input [31:0]A, B;
	input [5:0]ALUFun;
	output [31:0]S;
	wire [31:0]shift16,shift8,shift4,shift2,shift1;
	assign shift16=A[4]? (ALUFun[1]? (B[31]? {16'b1,B[31:16]}:{16'b0,B[31:16]}):(ALUFun[0]? {16'b0,B[31:16]}:{B[15:0],16'b0})):B;
	assign shift8=A[3]? (ALUFun[1]? (shift16[31]? {8'b1,shift16[31:8]}:{8'b0,shift16[31:8]}):(ALUFun[0]? {8'b0,shift16[31:8]}:{shift16[23:0],8'b0})):shift16;
	assign shift4=A[2]? (ALUFun[1]? (shift8[31]? {4'b1,shift8[31:4]}:{4'b0,shift8[31:4]}):(ALUFun[0]? {4'b0,shift8[31:4]}:{shift8[27:0],4'b0})):shift8;
	assign shift2=A[1]? (ALUFun[1]? (shift4[31]? {2'b1,shift4[31:2]}:{2'b0,shift4[31:2]}):(ALUFun[0]? {2'b0,shift4[31:2]}:{shift4[29:0],2'b0})):shift4;
	assign shift1=A[0]? (ALUFun[1]? (shift2[31]? {1'b1,shift2[31:1]}:{1'b0,shift2[31:1]}):(ALUFun[0]? {1'b0,shift2[31:1]}:{shift2[30:0],1'b0})):shift2;
	assign S=shift1;	
endmodule