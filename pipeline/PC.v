/*
 * PC Unit of single-cycle datapath
 */

module PCUnit(
			input Reset_n,
			input CLK,
			input [2:0] PCsrc,
			input PCProtect, //stall the pipeline
			input ALUOut0,
			input [31:0] ConBA,
			input [25:0] JTaddr,
			input [31:0] DatabusA,
			output [31:0] PCplus4,
			output reg [31:0] PC,
			output super);

	wire [31:0] tmpPCplus4;

	assign super = PC[31];
	assign tmpPCplus4 = PC + 4;
	assign PCplus4 = {PC[31], tmpPCplus4[30:0]};

	always @(posedge CLK or negedge Reset_n)
		begin
		if (!Reset_n)
			begin
			PC <= 32'h80000000;
			end
		else
			begin
			if (!PCProtect)
				case (PCsrc)
					0: PC <= PCplus4;
					1: PC <= ALUOut0?ConBA:PCplus4;
					2: PC <= {PCplus4[31:28], JTaddr, 2'b0};
					3: PC <= DatabusA;
					4: PC <= 32'h80000004;
					5: PC <= 32'h80000008;
				endcase
			end
		end
endmodule