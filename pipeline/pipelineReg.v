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
				output reg [31:0] ID_instruct,
				output reg [31:0] ID_PCplus4
				);

	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n || IF_Flush)
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
				input [31:0] ID_PCplus4,
				output [31:0] EX_PCplus4,
				output reg [1:0] EX_RegDst,
				output reg EX_Sign, EX_ALUsrc1, EX_ALUsrc2,
				output reg [5:0] EX_ALUFun,
				output reg EX_MemWr, EX_MemRd, 
				output reg [1:0]EX_MemtoReg,
				output reg EX_RegWr,
				output reg [31:0] EX_DatabusA, EX_DatabusB,
				output reg [31:0] EX_ExtendedImm,
				output reg [4:0] EX_rt, EX_rd);
	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n || ID_Flush)
			begin
			{EX_Sign, EX_ALUsrc1, EX_ALUsrc2, EX_RegDst, EX_ALUFun, EX_MemWr, EX_MemRd,
				EX_MemtoReg, EX_RegWr, EX_DatabusA, EX_DatabusB,EX_ExtendedImm,EX_rt, EX_rd, EX_PCplus4} <= 0;
			end
		else
			begin
			{EX_Sign, EX_ALUsrc1, EX_ALUsrc2, EX_RegDst, EX_ALUFun, EX_MemWr, EX_MemRd,
				EX_MemtoReg, EX_RegWr, EX_DatabusA, EX_DatabusB,EX_ExtendedImm,EX_rt, EX_rd, EX_PCplus4}
				<= {ID_Sign, ID_ALUsrc1, ID_ALUsrc2, ID_RegDst, ID_ALUFun, ID_MemWr, ID_MemRd,
				ID_MemtoReg, ID_RegWr, ID_DatabusA, ID_DatabusB,ID_ExtendedImm,ID_rt, ID_rd, ID_PCplus4};
			end
		end
endmodule


module EXMEMReg(
				input CLK, Reset_n,
				input EX_MemWr, EX_MemRd, EX_RegWr,
				input [1:0]EX_MemtoReg,
				input [31:0] EX_ALUOut,
				input [4:0] EX_rdes,
				output reg MEM_MemWr, MEM_MemRd, MEM_RegWr,
				output reg [1:0]MEM_MemtoReg,
				output reg [31:0] MEM_ALUOut,
				output reg [4:0] MEM_rdes);
	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n)
			begin
			{MEM_MemWr, MEM_MemRd, MEM_RegWr, MEM_MemtoReg, MEM_ALUOut, MEM_rdes} <= 0;
			end
		else
			begin
			{MEM_MemWr, MEM_MemRd, MEM_RegWr, MEM_MemtoReg, MEM_ALUOut, MEM_rdes}
				<= {EX_MemWr, EX_MemRd, EX_RegWr, EX_MemtoReg, EX_ALUOut, EX_rdes};
			end
		end
endmodule

module MEMWBReg(
				input CLK, Reset_n,
				input [1:0] MEM_MemtoReg,
				input MEM_RegWr,
				input [4:0] MEM_rdes,
				input [31:0] MEM_ALUOut,
				output reg [1:0] WB_MemtoReg,
				output reg WB_RegWr,
				output reg [4:0] WB_rdes,
				output reg [31:0] WB_ALUOut);
	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n)
			begin
			{WB_ALUOut, WB_RegWr, WB_rdes, WB_MemtoReg} <= 0;
			end
		else
			begin
			{WB_ALUOut, WB_RegWr, WB_rdes, WB_MemtoReg}
				<= {MEM_ALUOut, MEM_RegWr, MEM_rdes, MEM_MemtoReg};
			end
		end
endmodule