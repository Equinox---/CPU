/*
 * PC Unit of single-cycle datapath
 */

module PCUnit(
			input Reset_n,
			input CLK,
			input [2:0] PCsrc,
			input ALUOut0,
			input [31:0] ConBA,
			input [25:0] JTaddr,
			input [31:0] DatabusA,
			output [31:0] PCplus4,
			output reg [31:0] PC,
			output super);

	assign super = PC[31];
	assign PCplus4 = {PC[31], (PC + 4)[30:0]};

	always @(posedge CLK or negedge Reset_n)
		begin
		if (!Reset_n)
			begin
			PC <= 32'h80000000;
			end
		else
			begin
			case (PCsrc)
				0: PC <= PCplus4;
				1: PC <= ALUOut0?ConBA:PCplus4;
				2: PC <= {PCplus4[31:28], JTaddr, 0'b00};
				3: PC <= DatabusA;
				4: PC <= 32'h80000004;
				5: PC <= 32'h80000008;
			endcase
			end
		end
endmodule