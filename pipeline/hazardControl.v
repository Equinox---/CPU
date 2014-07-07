/*
 * Hazard detection: stalling and branching 
 */


module HazardUnit(
					input IDEX_MemRd,
					input [4:0] IDEX_rd, IFID_rs, IFID_rt,
					output ID_Flush,
					output stall
					);

	always @(*)
		begin
		stall <= 0;
		ID_Flush <= 0;
		if (IDEX_MemRd && ((IDEX_rd == IFID_rs) || (IDEX_rd == IFID_rt)))
			begin
			ID_Flush <= 1;
			stall <= 1;
			end
		end
endmodule