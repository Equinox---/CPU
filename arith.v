module arith(A, B, ALUFun, Sign, S, Z, V, N);
	input [31:0]A, B;
	input [5:0]ALUFun;
	input Sign;
	output [31:0]S;
	output Z, V, N;
	wire[31:0]optB;
	assign optB=ALUFun[0]? ~B:B;
	adder32 a32_2(.A(A), .B(optB), .Cin(ALUFun[0]), .S(S), .Sign(Sign), .Z(Z), .V(V), .N(N));
endmodule
	
	