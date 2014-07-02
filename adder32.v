module adder32(A, B, Cin, S, Sign, Z, V, N);
	input [31:0]A, B;
	input Cin, Sign;
	output [31:0]S;
	output Z, V, N;
	wire c0, c1, c2, c3, c4, c5, c6, c30,Cout;
	
	adder4cla adder0(.s(S[3:0]),.co(c0),.a(A[3:0]),.b(B[3:0]),.cin(Cin));
	adder4cla adder1(.s(S[7:4]),.co(c1),.a(A[7:4]),.b(B[7:4]),.cin(c0));
	adder4cla adder2(.s(S[11:8]),.co(c2),.a(A[11:8]),.b(B[11:8]),.cin(c1));
	adder4cla adder3(.s(S[15:12]),.co(c3),.a(A[15:12]),.b(B[15:12]),.cin(c2));
	adder4cla adder4(.s(S[19:16]),.co(c4),.a(A[19:16]),.b(B[19:16]),.cin(c3));
	adder4cla adder5(.s(S[23:20]),.co(c5),.a(A[23:20]),.b(B[23:20]),.cin(c4));
	adder4cla adder6(.s(S[27:24]),.co(c6),.a(A[27:24]),.b(B[27:24]),.cin(c5));
	adder4cla adder7(.s(S[31:28]),.co(Cout),.a(A[31:28]),.b(B[31:28]),.cin(c6));
	assign c30=( (S[31]&&(A[31]^~B[31])) || (~S[31]&&(A[31]^B[31])) );
	assign Z=(S===0);
	assign N=( (Sign&&S[31]) || (!Sign&&Cin&&S[31]) );
	assign V=( (Sign&&Cout^c30) || (~Sign&&Cout) );
endmodule