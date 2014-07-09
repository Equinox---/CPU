/*
 * Pipelined MIPS top level module
 */


module PLMIPS(
			input sysclk,
			input Reset_n,
			input UART_IN,
			input [7:0] switch,
			output [7:0] led,
			output [6:0] digi_out1, digi_out2, digi_out3, digi_out4,
			output UART_OUT
			);
	
	wire [31:0] IF_instruct, ID_instruct;
	wire [31:0] PC, ConBA;

	wire [5:0] ID_op;
	wire [4:0] ID_rs, EX_rs;
	wire [4:0] ID_rt, EX_rt;
	wire [4:0] ID_rd, EX_rd;
	wire [4:0] ID_shamnt, EX_shamnt;
	wire [5:0] ID_func;
	wire [15:0] ID_Imm16;
	wire [25:0] ID_JTaddr;

	wire jorei;
	// Periperal-related
	wire IRQsig;
	wire [11:0] digit;

	wire [31:0] IF_PCplus4, ID_PCplus4, EX_PCplus4, MEM_PCplus4, WB_PCplus4;
	wire [4:0] EX_rdes, MEM_rdes, WB_rdes;
	wire [31:0] EX_DatabusA, EX_DatabusB, ID_DatabusA, ID_DatabusB, MEM_DatabusB;
	// Control Signals
	//ID
	wire ID_Sign, ID_ALUsrc1, ID_ALUsrc2, super, ID_RegWr, ID_MemWr, ID_MemRd, EXTOp, LUOp;
	wire [2:0] ID_PCsrc;
	wire [1:0] ID_RegDst, ID_MemtoReg;
	wire [5:0] ID_ALUFun;
	//EX
	wire EX_Sign, EX_ALUsrc1, EX_ALUsrc2, EX_RegWr, EX_MemWr, EX_MemRd;
	wire [2:0] EX_PCsrc;
	wire [1:0] EX_RegDst, EX_MemtoReg;
	wire [5:0] EX_ALUFun;
	//MEM
	wire MEM_RegWr, MEM_MemWr, MEM_MemRd;
	wire [1:0] MEM_MemtoReg;
	//WB
	wire WB_RegWr;
	wire [1:0] WB_MemtoReg;

	// Register-related
	wire [4:0] AddrC;
	wire [31:0] DatabusA, DatabusB, DataBusC;

	// ALU-related
	wire [31:0] EX_ALUOut, MEM_ALUOut, WB_ALUOut;
	wire [31:0] ALUInA, ALUInB;
	wire [31:0] tmpImm, ID_ExtendedImm, EX_ExtendedImm;

	// DataMem-related
	wire [31:0] rDataFMem1, rDataFMem2, rDataFMem3, rDataFMem;

	// Harzard-related
	wire stall;
	wire ID_Flush1, ID_Flush2, ID_Flush, IF_Flush;

	// Forwarding-related
	wire [1:0] ForwardA, ForwardB;
	wire [31:0] tmpALUInA, tmpALUInB;

	

	// Instances of submodule
	ControlUnit ControlUnitInst(.instruct(ID_instruct), .IRQsig(IRQsig), .super(super), .PCsrc(ID_PCsrc),
								.RegDst(ID_RegDst), .RegWr(ID_RegWr), .ALUFun(ID_ALUFun), .MemRd(ID_MemRd),
								.MemWr(ID_MemWr), .MemtoReg(ID_MemtoReg), .Sign(ID_Sign), .ALUsrc1(ID_ALUsrc1),
								.ALUsrc2(ID_ALUsrc2), .EXTOp(EXTOp), .LUOp(LUOp)); // control unit
	PCUnit PCInst(.Reset_n(Reset_n), .CLK(sysclk), .ID_PCsrc(ID_PCsrc), .EX_PCsrc(EX_PCsrc), .PCProtect(stall),
				  .ALUOut0(EX_ALUOut[0]), .ConBA(ConBA), .JTaddr(ID_JTaddr), .DatabusA(DatabusA),
				  .PCplus4(IF_PCplus4), .PC(PC), .super(super)); //PC
	ROM InstructMemInst(PC, IF_instruct); //instruct fetch
	RegFile RegFileInst(.reset(Reset_n), .clk(sysclk), .addr1(rs), .addr2(rt), .data1(ID_DatabusA),
						.data2(ID_DatabusB), .wr(MEM_RegWr), .addr3(MEM_rdes), .data3(DataBusC)); // register unit
	ALU ALUInst(.A(ALUInA), .B(ALUInB), .S(EX_ALUOut), .ALUFun(EX_ALUFun), .Sign(EX_Sign)); // ALU Unit
	DataMem DataMemInst(.reset(Reset_n), .clk(sysclk), .rd(MEM_MemRd), .wr(MEM_MemWr),
						.addr(MEM_ALUOut), .wdata(MEM_DatabusB), .rdata(rDataFMem1)); // Data memory
	Peripheral PeripheralInst(.reset(Reset_n), .clk(sysclk), .rd(MEM_MemRd), .wr(MEM_MemWr), .addr(MEM_ALUOut),
							  .wdata(MEM_DatabusB), .rdata(rDataFMem2), .led(led), .switch(switch), .digi(digit), .irqout(IRQsig));
	UARTUnit UartInst(.Reset_n(Reset_n), .CLK(sysclk), .rd(MEM_MemRd), .wr(MEM_MemWr), .addr(MEM_ALUOut),
				  .wdata(MEM_DatabusB), .rdata(rDataFMem3), .out(UART_OUT), .in(UART_IN));
	digitube_scan DigitubeInst(.digi_in(digit), .digi_out1(digi_out1), .digi_out2(digi_out2), .digi_out3(digi_out3),
							   .digi_out4(digi_out4));
	ExtendUnit ExtendUnitInst(.EXTOp(EXTOp), .Imm16(ID_Imm16), .ExtendedImm(tmpImm)); // Extend unit


	// Pileline specified submodules
	IFIDReg IFIDRegInst(.CLK(sysclk), .Reset_n(Reset_n), .IF_Flush(IF_Flush), .IF_Protect(stall), .IF_instruct(IF_instruct),
						.IF_PCplus4(IF_PCplus4), .ID_instruct(ID_instruct), .ID_PCplus4(ID_PCplus4));
	IDEXReg IDEXRegInst(.CLK(sysclk), .Reset_n(Reset_n), .ID_Flush(ID_Flush),
						.ID_Sign(ID_Sign), .ID_ALUsrc1(ID_ALUsrc1), .ID_ALUsrc2(ID_ALUsrc2), .ID_RegDst(ID_RegDst),
						.ID_ALUFun(ID_ALUFun), .ID_MemWr(ID_MemWr), .ID_MemRd(ID_MemRd), .ID_MemtoReg(ID_MemtoReg),
						.ID_RegWr(ID_RegWr), .ID_DatabusA(ID_DatabusA), .ID_DatabusB(ID_DatabusB), .ID_ExtendedImm(ID_ExtendedImm),
						.ID_rt(ID_rt), .ID_rd(ID_rd), .ID_shamnt(ID_shamnt), .EX_shamnt(EX_shamnt), .EX_RegDst(EX_RegDst),
						.EX_Sign(EX_Sign), .EX_ALUsrc1(EX_ALUsrc1), .EX_ALUsrc2(EX_ALUsrc2), .EX_ALUFun(EX_ALUFun),
						.EX_MemWr(EX_MemWr), .EX_MemRd(EX_MemRd), .EX_MemtoReg(EX_MemtoReg), .EX_RegWr(EX_RegWr),
						.EX_DatabusA(EX_DatabusA), .EX_DatabusB(EX_DatabusB), .EX_ExtendedImm(EX_ExtendedImm),
						.EX_rt(EX_rt), .EX_rd(EX_rt), .ID_PCplus4(ID_PCplus4), .EX_PCplus4(EX_PCplus4));
	EXMEMReg EXMEMRegInst(.CLK(sysclk), .Reset_n(Reset_n), .EX_MemWr(EX_MemWr), .EX_MemRd(EX_MemRd), .EX_PCplus4(EX_PCplus4),
						  .EX_RegWr(EX_RegWr), .EX_MemtoReg(EX_MemtoReg), .EX_ALUOut(EX_ALUOut), .EX_DatabusB(EX_DatabusB),
			 			  .EX_rdes(EX_rdes), .MEM_MemWr(MEM_MemWr), .MEM_MemRd(MEM_MemRd), .MEM_RegWr(MEM_RegWr), .MEM_PCplus4(MEM_PCplus4),
			 			  .MEM_MemtoReg(MEM_MemtoReg), .MEM_ALUOut(MEM_MemtoReg), .MEM_rdes(MEM_rdes), .MEM_DatabusB(MEM_DatabusB));

	MEMWBReg MEMWBRegInst(.CLK(sysclk), .Reset_n(Reset_n), .MEM_MemtoReg(MEM_MemtoReg), .MEM_RegWr(MEM_RegWr), .MEM_rdes(MEM_rdes), .MEM_PCplus4(MEM_PCplus4),
					.MEM_ALUOut(MEM_ALUOut), .WB_MemtoReg(WB_MemtoReg), .WB_RegWr(WB_RegWr), .WB_rdes(WB_rdes), .WB_ALUOut(WB_ALUOut), .WB_PCplus4(WB_PCplus4));

	ForwardUnit ForwardUnitInst(.EXMEM_RegWr(MEM_RegWr), .EXMEM_rdes(MEM_rdes), .IDEX_rs(EX_rs), .IDEX_rt(EX_rt),
				.MEMWB_rdes(WB_rdes), .MEMWB_RegWr(WB_RegWr), .ForwardA(ForwardA), .ForwardB(ForwardB));
	HazardUnit HazardUnitInst(.IDEX_MemRd(EX_MemRd), .IDEX_rd(EX_rd), .IFID_rs(ID_rs), .IFID_rt(ID_rt),
							  .ID_Flush(ID_Flush1), .stall(stall));



	// Control
	assign IF_Flush1 = (ID_PCsrc == 2 || ID_PCplus4 == 3 || jorei); //jump instruction or interrupt/exception
	assign ID_Flush2 = (ID_PCsrc == 1 && EX_ALUOut[0] == 1 && (!jorei)); //branch instruction

	assign jorei = (ID_PCsrc == 4 || ID_PCsrc == 5);
	assign ID_Flush = ID_Flush1 | ID_Flush2;
	assign IF_Flush = IF_Flush1 | ID_Flush2;
	// muxes
	assign rDataFMem = rDataFMem1 | rDataFMem2 | rDataFMem3;
	Mux2_32 alusrc1inst(.Out(tmpALUInA), .mux(EX_ALUsrc1), .I0(EX_DatabusA), .I1({27'b0, EX_shamnt}));
	Mux2_32 alusrc2inst(.Out(tmpALUInB), .mux(EX_ALUsrc2), .I0(EX_DatabusB), .I1(EX_ExtendedImm));
	Mux2_32 luopinst(.Out(ID_ExtendedImm), .mux(LUOp), .I0(tmpImm), .I1({ID_Imm16, 16'b0}));
	Mux4_32 memtreginst(.Out(DataBusC), .mux(WB_MemtoReg), .I0(WB_ALUOut), .I1(rDataFMem),
						.I2(WB_PCplus4), .I3(0));

	Mux4_5 regdstinst(.Out(EX_rdes), .mux(EX_RegDst), .I0(rd), .I1(rt), .I2(5'd31), .I3(5'd26)); 
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
	assign ConBA = EX_PCplus4 + (EX_ExtendedImm << 2);
endmodule