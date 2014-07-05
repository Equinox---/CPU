/* Main Control Unit of single-cycle datapath
 *
 *
 * Interface:
 */



module ControlUnit(input [31:0] instruct,
					input IRQsig,
					output[2:0] PCsrc,
					output[1:0] RegDst, MemtoReg,
					output[5:0] ALUFun,
					output Sign, ALUsrc1, ALUsrc2,
					output RegWr, MemWr, MemRd,
					output EXTOp, LUOp);
	wire [5:0] op;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [4:0] shamnt;
	wire [5:0] func;
	wire [15:0] Imm16;
	wire [25:0] JTaddr;

	/*assign op = instruct[31:26];
	assign rs = instruct[25:21];
	assign rt = instruct[20:16];
	assign rd = instruct[15:11];
	assign shamnt = instruct[10:6];
	assign func = instruct[5:0];
	assign Imm16 = instruct[15:0];
	assign JTaddr = instruct[25:0];*///put it in the top level module

	/*assign isRType = (op == 0);
	assign isIType = (op >= 4 && op < 13) || op == 1 || op == 15 || op == 35 || op == 43;
	assign isJType = (op == 2 || op == 3);

	assign PCsrc[0] = (isRType && (func == 8 || func == 9))\
						|| (op < 8 && op >= 4) || op == 1;
	assign PCsrc[1] = (isRType && (func == 8 || func == 9))\
						|| isJType;
	*/
	always @(*)
		begin
		if (IRQ)
			{PCsrc, RegDst, ReWr, MemtoReg} <= {3'h5, 2'h3, 1'h1, 2'h2};
		else
			case ({op,func})
				12'b000000100000: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b000000, 1'h1, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000100001: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b000000, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000100010: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b000001, 1'h1, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000100011: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b000001, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000100100: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b011000, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000100101: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b011110, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000100110: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b010110, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000100111: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b010001, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000101010: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h0, 1'h0, 6'b110101, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000000000: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h1, 1'h0, 6'b100000, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000000010: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h1, 1'h0, 6'b100001, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000000011: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h0, 1'h1, 1'h1, 1'h0, 6'b100011, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000001000: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h3, 2'h0, 1'h0, 1'h0, 1'h0, 6'b000000, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000000001001: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h3, 2'h2, 1'h1, 1'h0, 1'h0, 6'b000000, 1'h0, 1'h0, 1'h0, 2'h2, 1'h0, 1'h0};
				12'b001000??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h1, 1'h0, 1'h1, 6'b000000, 1'h1, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b001001??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h1, 1'h0, 1'h1, 6'b000000, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b001010??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h1, 1'h0, 1'h1, 6'b110101, 1'h1, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b001011??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h1, 1'h0, 1'h1, 6'b110101, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b001100??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h1, 1'h0, 1'h1, 6'b110000, 1'h0, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b000100??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h1, 2'h1, 1'h0, 1'h0, 1'h0, 6'b110011, 1'h1, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b000101??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h1, 2'h1, 1'h0, 1'h0, 1'h0, 6'b110001, 1'h1, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b000110??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h1, 2'h1, 1'h0, 1'h0, 1'h0, 6'b111101, 1'h1, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b000111??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h1, 2'h1, 1'h0, 1'h0, 1'h0, 6'b111111, 1'h1, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b000001??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h1, 2'h1, 1'h0, 1'h0, 1'h0, 6'b111001, 1'h1, 1'h0, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b101011??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h0, 1'h0, 1'h0, 6'b000000, 1'h1, 1'h1, 1'h0, 2'h0, 1'h1, 1'h0};
				12'b100011??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h1, 1'h0, 1'h0, 6'b000000, 1'h1, 1'h0, 1'h1, 2'h1, 1'h1, 1'h0};
				12'b001111??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h0, 2'h1, 1'h1, 1'h0, 1'h1, 6'b011010, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h1};
				12'b000010??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h2, 2'h0, 1'h0, 1'h0, 1'h0, 6'b000000, 1'h0, 1'h0, 1'h0, 2'h0, 1'h0, 1'h0};
				12'b000011??????: {PCsrc, RegDst, RegWr, ALUsrc1, ALUsrc2, ALUFun, Sign, MemWr, MemRd, MemtoReg, EXTOp, LUOp} <= {3'h2, 2'h2, 1'h1, 1'h0, 1'h0, 6'b000000, 1'h0, 1'h0, 1'h0, 2'h2, 1'h0, 1'h0};
				default: {PCsrc, RegDst, ReWr, MemtoReg} <= {3'h5, 2'h3, 1'h1, 2'h2};
			endcase
		end
 
endmodule