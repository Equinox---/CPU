/*
 * Top Level Single-Cycle CPU module
 */



module SCMIPS(
			input rawclk,
			input Reset_n,
			input UART_IN,
			input [7:0] switch,
			output [7:0] led,
			output [6:0] digi_out1, digi_out2, digi_out3, digi_out4,
			output UART_OUT
			);

	// Instruct and PC-realted
	wire [31:0] instruct;
	wire [31:0] PC, PCplus4, ConBA;

	wire [5:0] op;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [4:0] shamnt;
	wire [5:0] func;
	wire [15:0] Imm16;
	wire [25:0] JTaddr;

	// Periperal-related
	wire IRQsig;
	wire [11:0] digit;

	// Control Signals
	wire Sign, ALUsrc1, ALUsrc2, super, RegWr, MemWr, MemRd, EXTOp, LUOp;
	wire [2:0] PCsrc;
	wire [1:0] RegDst, MemtoReg;
	wire [5:0] ALUFun;

	// Register-related
	wire [4:0] AddrC;
	wire [31:0] DatabusA, DatabusB, DataBusC;

	// ALU-related
	wire [31:0] ALUOut;
	wire [31:0] ALUInA, ALUInB;
	wire [31:0] tmpImm, ExtendedImm;

	// DataMem-related
	wire [31:0] rDataFMem1, rDataFMem2, rDataFMem3, rDataFMem;
	wire sysclk;

	// 分频
	frequency freq(.sysclk(rawclk), .newclk(sysclk), .reset(Reset_n));
	// Instances of submodule
	ControlUnit ControlUnitInst(.instruct(instruct), .IRQsig(IRQsig), .super(super), .PCsrc(PCsrc),
								.RegDst(RegDst), .RegWr(RegWr), .ALUFun(ALUFun), .MemRd(MemRd),
								.MemWr(MemWr), .MemtoReg(MemtoReg), .Sign(Sign), .ALUsrc1(ALUsrc1),
								.ALUsrc2(ALUsrc2), .EXTOp(EXTOp), .LUOp(LUOp)); // control unit
	PCUnit PCInst(.Reset_n(Reset_n), .CLK(sysclk), .PCsrc(PCsrc),
				  .ALUOut0(ALUOut[0]), .ConBA(ConBA), .JTaddr(JTaddr), .DatabusA(DatabusA),
				  .PCplus4(PCplus4), .PC(PC), .super(super)); //PC
	ROM InstructMemInst(PC, instruct); //instruct fetch
	RegFile RegFileInst(.reset(Reset_n), .clk(sysclk), .addr1(rs), .addr2(rt), .data1(DatabusA),
						.data2(DatabusB), .wr(RegWr), .addr3(AddrC), .data3(DataBusC)); // register unit
	ALU ALUInst(.A(ALUInA), .B(ALUInB), .S(ALUOut), .ALUFun(ALUFun), .Sign(Sign)); // ALU Unit
	DataMem DataMemInst(.reset(Reset_n), .clk(sysclk), .rd(MemRd), .wr(MemWr),
						.addr(ALUOut), .wdata(DatabusB), .rdata(rDataFMem1)); // Data memory
	Peripheral PeripheralInst(.reset(Reset_n), .clk(sysclk), .rd(MemRd), .wr(MemWr), .addr(ALUOut),
							  .wdata(DatabusB), .rdata(rDataFMem2), .led(led), .switch(switch), .digi(digit), .irqout(IRQsig));
	UARTUnit UartInst(.Reset_n(Reset_n), .CLK(sysclk), .rd(MemRd), .wr(MemWr), .addr(ALUOut),
				  .wdata(DatabusB), .rdata(rDataFMem3), .out(UART_OUT), .in(UART_IN));
	digitube_scan DigitubeInst(.digi_in(digit), .digi_out1(digi_out1), .digi_out2(digi_out2), .digi_out3(digi_out3),
							   .digi_out4(digi_out4));
	ExtendUnit ExtendUnitInst(.EXTOp(EXTOp), .Imm16(Imm16), .ExtendedImm(ExtendedImm)); // Extend unit


	// Variety of Muxer muxed by control signals
	assign rDataFMem = rDataFMem1 | rDataFMem2 | rDataFMem3;
	Mux2_32 alusrc1inst(.Out(ALUInA), .mux(ALUsrc1), .I0(DatabusA), .I1({27'b0, shamnt}));
	Mux2_32 alusrc2inst(.Out(ALUInB), .mux(ALUsrc2), .I0(DatabusB), .I1(tmpImm));
	Mux2_32 luopinst(.Out(tmpImm), .mux(LUOp), .I0(ExtendedImm), .I1({Imm16, 16'b0}));
	Mux4_32 memtreginst(.Out(DataBusC), .mux(MemtoReg), .I0(ALUOut), .I1(rDataFMem),
						.I2(PCplus4), .I3(0));
	Mux4_5 regdstinst(.Out(AddrC), .mux(RegDst), .I0(rd), .I1(rt), .I2(5'd31), .I3(5'd26)); 


	// instruction decomposition
	assign op = instruct[31:26];
	assign rs = instruct[25:21];
	assign rt = instruct[20:16];
	assign rd = instruct[15:11];
	assign shamnt = instruct[10:6];
	assign func = instruct[5:0];
	assign Imm16 = instruct[15:0];
	assign JTaddr = instruct[25:0];

	// ConBA
	assign ConBA = PCplus4 + (ExtendedImm << 2);

endmodule



module frequency(sysclk, newclk, reset);		//12?€¨¦‡‡???
	input sysclk,reset;
	output reg newclk=0;
	reg [3:0] count=0;
	always@(posedge sysclk or negedge reset) begin
		if(reset==0) begin
			count<=0;
			newclk<=0;
		end
		else begin
			if(count==4'd4) begin
				count<=0;
				newclk<=~newclk;
			end
			else count<=count+4'd1;
		end
	end
endmodule