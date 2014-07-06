/*
 * 16bit -> 32bit Unsign/Sign Extend Unit
 */


module ExtendUnit(
					input [15:0] Imm16,
					input EXTOp,
					output [31:0] ExtendedImm);
	assign ExtendedImm = (EXTOp && Imm16[15])?{16'hffff, Imm16}:{16'b0, Imm16};
endmodule