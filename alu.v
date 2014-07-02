module ALU(A, B, ALUFun, Sign, S);
	input [31:0]A, B;
	input [5:0]ALUFun;
	input Sign;
	output [31:0]S;
	wire Z, V, N;
	wire [31:0] Sa, Sl, Ss;
	wire Sc;
	arith ALU_arith(.A(A), .B(B), .ALUFun(ALUFun), .Sign(Sign), .S(Sa), .Z(Z), .V(V), .N(N));
	CMP ALU_CMP(.A(A), .ALUFun(ALUFun), .Sign(Sign), .Z(Z), .V(V), .N(N), .S(Sc));
	Logic ALU_Logic(.A(A), .B(B), .ALUFun(ALUFun), .S(Sl));
	Shift ALU_Shift(.A(A), .B(B), .ALUFun(ALUFun), .S(Ss));
	assign S=ALUFun[5]? (ALUFun[4]? {31'b0,Sc}:(Ss)):(ALUFun[4]? (Sl):(Sa));
endmodule 