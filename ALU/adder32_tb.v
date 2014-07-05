module adder32tb;
	reg [31:0]A=32'd4294967295, B=32'd1;
	reg Cin=0, Sign=1;
	wire [31:0]S;
	wire Z, V, N;
	adder32 addertb(A, B, Cin, S, Sign, Z, V, N);
endmodule
