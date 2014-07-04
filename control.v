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
	
	
endmodule 