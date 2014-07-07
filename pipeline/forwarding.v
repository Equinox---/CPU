/*
 * forwarding Unit of Pipelined MIPS
 */


module ForwardUnit(
					input EXMEM_RegWr,
					input [5:0] EXMEM_rdes,
					input [5:0] IDEX_rs, IDEX_rt,
					input [5:0] MEMWB_rdes,
					input MEMWB_RegWr,
					output [1:0] ForwardA, ForwardB
					);
	always @(*)
		begin
		if (EXMEM_RegWr && EXMEM_rdes != 0 && (EXMEM_rdes == IDEX_rs))
			ForwardA <= 2'b10;
		else if (MEMWB_RegWr && (MEMWB_rdes != 0) && (MEMWB_rdes == IDEX_rs))
			ForwardA <= 2'b01;
		if (EXMEM_RegWr && EXMEM_rdes != 0 && (EXMEM_rdes == IDEX_rt))
			ForwardB <= 2'b10;
		else if (MEMWB_RegWr && (MEMWB_rdes != 0) && (MEMWB_rdes == IDEX_rt))
			ForwardB <= 2'b01;
		end

endmodule