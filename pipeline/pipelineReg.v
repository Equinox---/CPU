/*
 * Pipeline Registers
 */
//PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun
//Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp

module IFIDReg(
				input CLK,
				input Reset_n,
				input IF_Flush,
				input IF_Protect,
				input [31:0] IF_instruct,
				input [31:0] IF_PCplus4,
				output [31:0] ID_instruct,
				output [31:0] ID_PCplus4
				);

	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n or IF_Flush)
			begin
			ID_PCplus4 <= 0;
			ID_instruct <= 0;
			end
		else
			begin
			ID_instruct <= IF_instruct;
			ID_PCplus4 <= IF_PCplus4;
			end
		end
endmodule
// EXTOp, LUOp in ID
module IDEXReg(
				input CLK, Reset_n, ID_Flush,
				input ID_Sign, ID_ALUsrc1, ID_ALUsrc2,
				input [1:0] ID_RegDst,
				input [5:0] ID_ALUFun,
				input ID_MemWr, ID_MemRd, 
				input [1:0] ID_MemtoReg,
				input ID_RegWr,
				input [31:0] ID_DatabusA, ID_DatabusB,
				input [31:0] ID_ExtendedImm,
				input [4:0] ID_rt, ID_rd,
				output [1:0] EX_RegDst,
				output EX_Sign, EX_ALUsrc1, EX_ALUsrc2,
				output [1:0] EX_RegDst,
				output [5:0] EX_ALUFun,
				output EX_MemWr, EX_MemRd, 
				output [1:0]EX_MemtoReg,
				output EX_RegWr,
				output [31:0] EX_DatabusA, EX_DatabusB,
				output [31:0] EX_ExtendedImm,
				output [4:0] EX_rt, EX_rd);
	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n or ID_Flush)
			begin

			end
		else
			begin

			end
		end
endmodule
module EXMEMReg(
				input CLK, Reset_n,
				input EX_MemWr, EX_MemRd, EX_RegWr,
				input [1:0]EX_MemtoReg,
				input [31:0] EX_ALUOut,
				input [4:0] EX_rdes,
				output MEM_MemWr, MEM_MemRd, MEM_RegWr,
				output [1:0]MEM_MemtoReg,
				output [31:0] MEM_ALUOut,
				output [4:0] MEM_rdes);

endmodule
module MEMWBReg(
				input CLK, Reset_n,
				input [1:0] MEM_MemtoReg,
				input MEM_RegWr,
				input [4:0] MEM_rdes,
				input [31:0] MEM_ALUOut,
				output [1:0] WB_MemtoReg,
				output WB_RegWr,
				output [4:0] WB_rdes,
				output [31:0] WB_ALUOut);
endmodule