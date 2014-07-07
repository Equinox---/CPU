`timescale 1ns/1ns

module test_SCMIPS;
	reg clk;
	reg Reset_n;
	reg [7:0] switch;
	wire [7:0] led;
	wire [6:0] digi_out1, digi_out2, digi_out3, digi_out4;

	initial
		begin
		clk <= 0;
		Reset_n <= 0;
		end

	always #5 clk <= ~clk;
	initial
		begin
		#1 Reset_n <= 1;
		#1 switch <= 8'b00000010;
		#100 $stop;
		end
	SCMIPS inst(.sysclk(clk), .Reset_n(Reset_n), .switch(switch), .led(led),
			.digi_out1(digi_out1), .digi_out2(digi_out2), .digi_out3(digi_out3), .digi_out4(digi_out4));
endmodule