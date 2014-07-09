/*
 * Hazard detection: stalling and branching 
 */


module HazardUnit(
					input IDEX_MemRd,
					input [4:0] IDEX_rd, IFID_rs, IFID_rt,
					output ID_Flush,
					output stall // flush IDEX and keep PC/IFID
					);

	assign stall = (IDEX_MemRd && ((IDEX_rd == IFID_rs) || (IDEX_rd == IFID_rt)));
	assign ID_Flush = stall;
endmodule