`timescale 1ns/1ns

module test_PLMIPS;
	reg clk;
	reg Reset_n;
	reg [7:0] switch;
	reg UART_IN;
	wire UART_OUT;
	wire [7:0] led;
	wire [6:0] digi_out1, digi_out2, digi_out3, digi_out4;
	//parameter DELAY = 31250;

	initial
		begin
		clk <= 0;
		Reset_n <= 0;
		end
	always #5 clk <= ~clk;
	initial
		begin
		 #1 Reset_n <= 1;
		 #1 switch <= 2;
		 #500 $stop;
		end
	PLMIPS inst(.sysclk(clk), .Reset_n(Reset_n), .UART_IN(UART_IN), .UART_OUT(UART_OUT),
			.led(led), .switch(switch), .digi_out1(digi_out1), .digi_out2(digi_out2),
			.digi_out3(digi_out3), .digi_out4(digi_out4));

endmodule