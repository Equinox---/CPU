`timescale 1ns/1ps

module RegFile (reset,clk,addr1,data1,addr2,data2,wr,addr3,data3,
				r31, ra0, ra1, ra2, rv0);//for test
input reset,clk;
input wr;
input [4:0] addr1,addr2,addr3;
output [31:0] data1,data2;
input [31:0] data3;

reg [31:0] RF_DATA[31:1];
integer i;

/* tmp */
output wire [31:0] r31, rv0, ra0, ra1, ra2;
assign rv0 = RF_DATA[2];
assign ra0 = RF_DATA[4];
assign ra1 = RF_DATA[5];
assign ra2 = RF_DATA[6];
assign r31 = RF_DATA[31];
//for test

assign data1=(addr1==5'b0)?32'b0:RF_DATA[addr1];	//$0 MUST be all zeros
assign data2=(addr2==5'b0)?32'b0:RF_DATA[addr2];

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		for(i=1;i<32;i=i+1) RF_DATA[i]<=32'b0;
	end
	else begin
		if(wr && addr3) RF_DATA[addr3] <= data3;
	end
end
endmodule
