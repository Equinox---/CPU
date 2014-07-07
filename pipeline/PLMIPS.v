/*
 * Pipelined MIPS top level module
 */


module PLMIPS(
			input sysclk,
			input Reset_n,
			input UART_IN,
			input [7:0] switch,
			output [7:0] led,
			output [6:0] digi_out1, digi_out2, digi_out3, digi_out4
			output UART_OUT
			);
	
	wire [31:0] IF_instruct, ID_instruct;
	wire [31:0] PC, IF_PCplus4, ConBA;

	wire [5:0] ID_op;
	wire [4:0] ID_rs;
	wire [4:0] ID_rt;
	wire [4:0] ID_rd;
	wire [4:0] ID_shamnt;
	wire [5:0] ID_func;
	wire [15:0] ID_Imm16;
	wire [25:0] ID_JTaddr;

	// Periperal-related
	wire IRQsig;
	wire [11:0] digit;

	// Control Signals
	wire ID_Sign, ID_SALUsrc1, ID_SALUsrc2, super, ID_SRegWr, ID_SMemWr, ID_SMemRd, EXTOp, LUOp;
	wire [2:0] ID_SPCsrc;
	wire [1:0] ID_SRegDst, ID_SMemtoReg;
	wire [5:0] ID_SALUFun;

	// Register-related
	wire [4:0] AddrC;
	wire [31:0] DatabusA, DatabusB, DataBusC;

	// ALU-related
	wire [31:0] ALUOut;
	wire [31:0] ALUInA, ALUInB;
	wire [31:0] tmpImm, ExtendedImm;

	// DataMem-related
	wire [31:0] rDataFMem1, rDataFMem2, rDataFMem3, rDataFMem;

	// Harzard-related
	wire stall;
	wire ID_Flush, IF_Flush;

	// Forwarding-related
	wire [1:0] ForwardA, ForwardB;
	wire [31:0] tmpALUInA, tmpALUInB;

	// Pipeline Reg related
	wire [31:0] ID_PCplus4, ConBA;
	wire [4:0] EX_rdes, MEM_rdes;

	// Instances of submodule
	ControlUnit ControlUnitInst(.instruct(ID_instruct), .IRQsig(IRQsig), .super(super), .PCsrc(ID_PCsrc),
								.RegDst(ID_RegDst), .RegWr(ID_RegWr), .ALUFun(ID_ALUFun), .MemRd(ID_MemRd),
								.MemWr(ID_MemWr), .MemtoReg(ID_MemtoReg), .Sign(ID_Sign), .ALUsrc1(ID_ALUsrc1),
								.ALUsrc2(ID_ALUsrc2), .EXTOp(EXTOp), .LUOp(LUOp)); // control unit
	//PCUnit PCInst(.Reset_n(Reset_n), .CLK(sysclk), .PCsrc(PCsrc), .PCProtect(stall),
	//			  .ALUOut0(ALUOut[0]), .ConBA(ConBA), .JTaddr(JTaddr), .DatabusA(DatabusA),
	//			  .PCplus4(PCplus4), .PC(PC), .super(super)); //PC
	ROM InstructMemInst(PC, IF_instruct); //instruct fetch
	RegFile RegFileInst(.reset(Reset_n), .clk(sysclk), .addr1(rs), .addr2(rt), .data1(DatabusA),
						.data2(DatabusB), .wr(MEM_RegWr), .addr3(MEM_rdes), .data3(DataBusC)); // register unit
	ALU ALUInst(.A(ALUInA), .B(ALUInB), .S(ALUOut), .ALUFun(ALUFun), .Sign(Sign)); // ALU Unit
	DataMem DataMemInst(.reset(Reset_n), .clk(sysclk), .rd(MemRd), .wr(MemWr),
						.addr(ALUOut), .wdata(DatabusB), .rdata(rDataFMem1)); // Data memory
	Peripheral PeripheralInst(.reset(Reset_n), .clk(sysclk), .rd(MemRd), .wr(MemWr), .addr(ALUOut),
							  .wdata(DatabusB), .rdata(rDataFMem2), .led(led), .switch(switch), .digi(digit), .irqout(IRQsig));
	UART UartInst(.Reset_n, .CLK(sysclk), .rd(MemRd), .wr(MemWr), .addr(ALUOut),
				  .wdata(DatabusB), .rdata(rDataFMem3), .out(UART_OUT), .in(UART_IN));
	digitube_scan DigitubeInst(.digi_in(digit), .digi_out1(digi_out1), .digi_out2(digi_out2), .digi_out3(digi_out3),
							   .digi_out4(digi_out4));
	ExtendUnit ExtendUnitInst(.EXTOp(EXTOp), .Imm16(ID_Imm16), .ExtendedImm(tmpImm)); // Extend unit


	// Pileline specified submodules
	IFIDReg IFIDRegInst(.CLK(sysclk), .Reset_n(Reset_n), .IF_Flush(), .IF_Protect(stall), .IF_instruct(IF_instruct),
						.IF_PCplus4(IF_PCplus4), .ID_instruct(ID_instruct), .ID_PCplus4(ID_PCplus4));
	IDEXReg IDEXRegInst(.CLK(sysclk), .Reset_n(Reset_n), .ID_Flush(ID_Flush),
						.ID_Sign(ID_Sign), .ID_ALUsrc1(ID_ALUsrc1), .ID_ALUsrc2(ID_ALUsrc2), .ID_RegDst(ID_RegDst),
						.ID_ALUFun(ID_ALUFun), .ID_MemWr(ID_MemWr), .ID_MemRd(MemRd), .ID_MemtoReg(ID_MemtoReg),
						.ID_RegWr(ID_RegWr), .ID_DatabusA(ID_DatabusA), .ID_DatabusB(ID_DatabusB), .ID_ExtendedImm(ID_ExtendedImm),
						.ID_rt(ID_rt), .ID_rd(ID_rd), .EX_RegDst(EX_RegDst),
						.EX_Sign(EX_Sign), .EX_ALUsrc1(EX_ALUsrc1), .EX_ALUsrc2(EX_ALUsrc2), .EX_ALUFun(EX_ALUFun),
						.EX_MemWr(EX_MemWr), .EX_MemRd(EX_MemRd), .EX_MemtoReg(EX_MemtoReg), .EX_RegWr(EX_RegWr),
						.EX_DatabusA(EX_DatabusA), .EX_DatabusB(EX_DatabusA), .EX_ExtendedImm(EX_DatabusA),
						.EX_rt(EX_rt), .EX_rd(EX_rt));
	EXMEMReg EXMEMRegInst(.CLK(CLK), .Reset_n(Reset_n), .EX_MemWr(EX_MemWr), .EX_MemRd(EX_MemRd),
						  .EX_RegWr(EX_RegWr), .EX_MemtoReg(EX_MemtoReg), .EX_ALUOut(EX_ALUOut),
			 			  .EX_rdes(EX_rdes), .MEM_MemWr(MEM_MemWr), .MEM_MemRd(MEM_MemRd), .MEM_RegWr(MEM_RegWr), 
			 			  .MEM_MemtoReg(MEM_MemtoReg), .MEM_ALUOut(MEM_MemtoReg), .MEM_rdes(MEM_rdes));

	MEMWBReg MEMWBRegInst(.CLK(CLK), .Reset_n(Reset_n), .MEM_MemtoReg(MEM_MemtoReg), .MEM_RegWr(MEM_RegWr), .MEM_rdes(MEM_rdes),
					.MEM_ALUOut(MEM_ALUOut), .WB_MemtoReg(WB_MemtoReg), .WB_RegWr(WB_RegWr), .WB_rdes(WB_rdes), .WB_ALUOut(WB_ALUOut));

	ForwardUnit ForwardUnitInst(.EXMEM_RegWr(MEM_RegWr), .EXMEM_rdes(MEM_rdes), .IDEX_rs(EX_rs), .IDEX_rt(EX_rt),
				.MEMWB_rdes(WB_rdes), .MEMWB_RegWr(WB_RegWr), .ForwardA(ForwardA), .ForwardB(ForwardB));
	HazardUnit HazardUnitInst(.IDEX_MemRd(EX_MemRd), .IDEX_rd(EX_rd), .IFID_rs(ID_rs), IFID_rt(ID_rt),
							  .ID_Flush(ID_Flush), .stall(stall));



	// muxes
	assign rDataFMem = rDataFMem1 | rDataFMem2 | rDataFMem3;
	Mux2_32 alusrc1inst(.Out(tmpALUInA), .mux(ALUsrc1), .I0(DatabusA), .I1({27'b0, shamnt}));
	Mux2_32 alusrc2inst(.Out(tmpALUInB), .mux(ALUsrc2), .I0(DatabusB), .I1(EX_ExtendedImm));
	Mux2_32 luopinst(.Out(ID_ExtendedImm), .mux(LUOp), .I0(tmpImm), .I1({Imm16, 16'b0}));
	Mux4_32 memtreginst(.Out(DataBusC), .mux(WB_MemtoReg), .I0(ALUOut), .I1(rDataFMem),
						.I2(PCplus4), .I3(0));
	Mux4_5 regdstinst(.Out(EX_rdes), .mux(RegDst), .I0(rd), .I1(rt), .I2(5'd31), .I3(5'd26)); 
	Mux4_32 forwardainst(.Out(ALUInA), .mux(ForwardA), .I0(tmpALUInA), .I1(DataBusC), .I2(MEM_ALUOut), .I3(0));
	Mux4_32 forwardbinst(.Out(ALUInB), .mux(ForwardB), .I0(tmpALUInB), .I1(DataBusC), .I2(MEM_ALUOut), .I3(0));


	// instruction decomposition
	assign ID_op = ID_instruct[31:26];
	assign ID_rs = ID_instruct[25:21];
	assign ID_rt = ID_instruct[20:16];
	assign ID_rd = ID_instruct[15:11];
	assign ID_shamnt = ID_instruct[10:6];
	assign ID_func = ID_instruct[5:0];
	assign ID_Imm16 = ID_instruct[15:0];
	assign ID_JTaddr = ID_instruct[25:0];

	// ConBA
	assign ConBA = PCplus4 + (ExtendedImm << 2);
endmodule