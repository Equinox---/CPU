/*
 * forwarding Unit of Pipelined MIPS
 */


module ForwardUnit(
					input EXMEM_RegWr,
					input [4:0] EXMEM_rdes,
					input [4:0] IDEX_rs, IDEX_rt,
					input [4:0] MEMWB_rdes,
					input MEMWB_RegWr,
					output reg[1:0] ForwardA, ForwardB
					);
	always @(*)
		begin
		if (EXMEM_RegWr && EXMEM_rdes != 0 && (EXMEM_rdes == IDEX_rs))
			ForwardA <= 2'b10;
		else if (MEMWB_RegWr && (MEMWB_rdes != 0) && (MEMWB_rdes == IDEX_rs))
			ForwardA <= 2'b01;
		else
			ForwardA <= 2'b00;
		if (EXMEM_RegWr && EXMEM_rdes != 0 && (EXMEM_rdes == IDEX_rt))
			ForwardB <= 2'b10;
		else if (MEMWB_RegWr && (MEMWB_rdes != 0) && (MEMWB_rdes == IDEX_rt))
			ForwardB <= 2'b01;
		else
			ForwardB <= 2'b00;
		end

endmodule
module JForwardUnit(
					input [2:0] ID_PCsrc,
					input [4:0] ID_rs,
					input [4:0] EX_rdes, EXMEM_rdes, MEMWB_rdes,
					input EXMEM_RegWr, IDEX_RegWr, MEMWB_RegWr,
					output [1:0] ForwardDatabusA);
	assign ForwardDatabusA = (IDEX_RegWr && (EX_rdes == ID_rs))?2'b01:((EXMEM_RegWr && (EXMEM_rdes == ID_rs))?2'b10:((MEMWB_RegWr && (MEMWB_rdes == ID_rs))?2'b11:2'b00));
endmodule