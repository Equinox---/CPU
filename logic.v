module Logic(A, B, ALUFun, S);
	input [31:0]A, B;
	input [5:0]ALUFun;
	output [31:0]S;
	wire [31:0]aandb, aorb, axorb, anorb;
	assign aandb=A&B;
	assign aorb=A|B;
	assign axorb=A^B;
	assign anorb=~(A|B);
	assign S=ALUFun[3]? (ALUFun[2]? aorb:(ALUFun[1]? B:aandb)):(ALUFun[2]? axorb:anorb);
endmodule
	
