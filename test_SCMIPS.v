`timescale 1ns/1ns

module test_SCMIPS;
	reg clk;
	reg Reset_n;
	reg [7:0] switch;
	wire [7:0] led;
	wire [7:0] digi_out1, digi_out2, digi_out3, digi_out4;

	initial
		begin
		clk <= 0;
		forever #5 clk <= ~clk;
		Reset_n <= 1;
		end

	

endmodule