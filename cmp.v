module CMP(A, ALUFun, Sign, Z, V, N, S);
	input [31:0]A;
	input [5:0]ALUFun;
	input Sign, Z, V, N;
	output S;
	wire aeqb,aneqb,altb,alez,agez,agtz;
	assign aeqb=ALUFun[0]? Z:0;
	assign aneqb=~aeqb;
	assign altb=Sign? (N^V):~V;
	assign alez=Sign? (!A||A[31]):!A;
	assign agez=Sign? ~A[31]:1;
	assign agtz=~alez;
	assign S= ALUFun[3]? (ALUFun[2]? (ALUFun[1]? agtz:alez):agez):(ALUFun[2]? altb:(ALUFun[1]? aeqb:aneqb));
endmodule
