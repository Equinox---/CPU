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
		if (~Reset_n)
			begin
			ID_PCplus4 <= 0;
			ID_instruct <= 0;
			end
		else
			if (IF_Flush)
				begin
				ID_PCplus4 <= 0;
				ID_instruct <= 0;
				end
			else if (!IF_Protect)
				begin
				ID_instruct <= IF_instruct;
				ID_PCplus4 <= IF_PCplus4;
				end
		end
endmodule
// EXTOp, LUOp in ID
module IDEXReg(
				input CLK, Reset_n, ID_Flush,
				input branchBeforeInter,
				input ID_Sign, ID_ALUsrc1, ID_ALUsrc2,
				input [1:0] ID_RegDst,
				input [5:0] ID_ALUFun,
				input ID_MemWr, ID_MemRd, 
				input [1:0] ID_MemtoReg,
				input ID_RegWr,
				input [31:0] ID_DatabusA, ID_DatabusB,
				input [31:0] ID_ExtendedImm,
				input [4:0] ID_rt, ID_rd, ID_rs, ID_shamnt,
				input [31:0] ID_PCplus4,
				input [2:0] ID_PCsrc,
				output reg [2:0] EX_PCsrc,
				output reg [31:0] EX_PCplus4,
				output reg [1:0] EX_RegDst,
				output reg EX_Sign, EX_ALUsrc1, EX_ALUsrc2,
				output reg [5:0] EX_ALUFun,
				output reg EX_MemWr, EX_MemRd, 
				output reg [1:0]EX_MemtoReg,
				output reg EX_RegWr,
				output reg [31:0] EX_DatabusA, EX_DatabusB,
				output reg [31:0] EX_ExtendedImm,
				output reg [4:0] EX_rt, EX_rd, EX_rs, EX_shamnt);
	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n)
			begin
			{EX_Sign, EX_ALUsrc1, EX_ALUsrc2, EX_RegDst, EX_ALUFun, EX_MemWr, EX_MemRd, EX_shamnt, EX_rs, EX_PCsrc,
				EX_MemtoReg, EX_RegWr, EX_DatabusA, EX_DatabusB,EX_ExtendedImm,EX_rt, EX_rd, EX_PCplus4} <= 0;
			end
		else
			begin
			if (ID_Flush)
				{EX_Sign, EX_ALUsrc1, EX_ALUsrc2, EX_RegDst, EX_ALUFun, EX_MemWr, EX_MemRd, EX_shamnt, EX_rs, EX_PCsrc,
					EX_MemtoReg, EX_RegWr, EX_DatabusA, EX_DatabusB,EX_ExtendedImm,EX_rt, EX_rd, EX_PCplus4} <= 0;
			else
				{EX_Sign, EX_ALUsrc1, EX_ALUsrc2, EX_RegDst, EX_ALUFun, EX_MemWr, EX_MemRd, EX_shamnt, EX_rs, EX_PCsrc,
					EX_MemtoReg, EX_RegWr, EX_DatabusA, EX_DatabusB,EX_ExtendedImm,EX_rt, EX_rd, EX_PCplus4}
					<= {ID_Sign, ID_ALUsrc1, ID_ALUsrc2, ID_RegDst, ID_ALUFun, ID_MemWr, ID_MemRd, ID_shamnt, ID_rs, ID_PCsrc,
					ID_MemtoReg, ID_RegWr, ID_DatabusA, ID_DatabusB,ID_ExtendedImm,ID_rt, ID_rd, branchBeforeInter?(ID_PCplus4 - 4):ID_PCplus4};
			end
		end
endmodule


module EXMEMReg(
				input CLK, Reset_n,
				input EX_MemWr, EX_MemRd, EX_RegWr,
				input [1:0]EX_MemtoReg,
				input [31:0] EX_ALUOut,
				input [31:0] EX_PCplus4, EX_DatabusB,
				input [4:0] EX_rdes,
				output reg [31:0] MEM_PCplus4,
				output reg MEM_MemWr, MEM_MemRd, MEM_RegWr,
				output reg [1:0]MEM_MemtoReg,
				output reg [31:0] MEM_ALUOut, MEM_DatabusB,
				output reg [4:0] MEM_rdes);
	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n)
			begin
			{MEM_MemWr, MEM_MemRd, MEM_RegWr, MEM_MemtoReg, MEM_ALUOut, MEM_rdes, MEM_PCplus4, MEM_DatabusB} <= 0;
			end
		else
			begin
			{MEM_MemWr, MEM_MemRd, MEM_RegWr, MEM_MemtoReg, MEM_ALUOut, MEM_rdes, MEM_PCplus4, MEM_DatabusB}
				<= {EX_MemWr, EX_MemRd, EX_RegWr, EX_MemtoReg, EX_ALUOut, EX_rdes, EX_PCplus4, EX_DatabusB};
			end
		end
endmodule

module MEMWBReg(
				input CLK, Reset_n,
				input [1:0] MEM_MemtoReg,
				input MEM_RegWr,
				input [4:0] MEM_rdes,
				input [31:0] MEM_ALUOut, MEM_PCplus4, MEM_rDataFMem,
				output reg [1:0] WB_MemtoReg,
				output reg WB_RegWr,
				output reg [4:0] WB_rdes,
				output reg [31:0] WB_ALUOut, WB_PCplus4, WB_rDataFMem);
	always @(posedge CLK or negedge Reset_n)
		begin
		if (~Reset_n)
			begin
			{WB_ALUOut, WB_RegWr, WB_rdes, WB_MemtoReg, WB_PCplus4, WB_rDataFMem} <= 0;
			end
		else
			begin
			{WB_ALUOut, WB_RegWr, WB_rdes, WB_MemtoReg, WB_PCplus4, WB_rDataFMem}
				<= {MEM_ALUOut, MEM_RegWr, MEM_rdes, MEM_MemtoReg, MEM_PCplus4, MEM_rDataFMem};
			end
		end
endmodule