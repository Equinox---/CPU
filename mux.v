/*
 * Helping mux modules
 */

module Mux2_32(
				input [31:0] I0, I1,
				input mux,
				output [31:0] Out);
	assign Out = mux?I1:I0;
endmodule

module Mux4_32(
				input [31:0] I0, I1, I2, I3,
				input [1:0] mux,
				output [31:0] Out);
	assign Out = mux[1]?(mux[0]?I3:I2):(mux[0]?I1:I0);
endmodule

module Mux4_5(
				input [4:0] I0, I1, I2, I3,
				input [1:0] mux,
				output [4:0] Out);
	assign Out = mux[1]?(mux[0]?I3:I2):(mux[0]?I1:I0);
endmodule