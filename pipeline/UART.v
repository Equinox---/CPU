/*
 * UART Module
 */

module UARTUnit(
				input Reset_n,
				input CLK,
				input rd, wr,
				input [31:0] addr, wdata,
				output [31:0] rdata,
				output out,
				input in
				);

	reg [7:0] UART_TXD;
	wire [7:0] UART_RXD;
	reg UART_CON0, UART_CON1, UART_CON2, UART_CON3;
	wire UART_CON4;
	wire [4:0] UART_CON;

	reg TX_EN;
	reg prevTX_STATUS;
	wire baud_rate_clk;
	wire RX_STATUS, TX_STATUS;

	initial
		begin
		UART_CON2 <= 0;
		UART_CON3 <= 0;
		UART_CON0 <= 1;
		UART_CON1 <= 1;
		end
	assign UART_CON4 = TX_STATUS;
	assign UART_CON = {UART_CON4, UART_CON3, UART_CON2, UART_CON1, UART_CON0};

	always @(negedge Reset_n or posedge CLK)
		begin
		if (~Reset_n)
			begin
			UART_TXD <= 8'b0;
			{UART_CON0, UART_CON1} <= 2'b1;
			{UART_CON2, UART_CON3} <= 2'b0;
			prevTX_STATUS <= 1;
			TX_EN <= 0;
			end
		else
			begin
			if (RX_STATUS && UART_CON1)
				UART_CON3 <= 1;
			else if (rd && (addr == 32'h4000001C))
					UART_CON3 <= 0;
			if (TX_STATUS && ~prevTX_STATUS && UART_CON0)
				UART_CON2 <= 1;
			else if (rd && (addr == 32'h40000018))
				UART_CON2 <= 0;
			prevTX_STATUS <= TX_STATUS;
			TX_EN <= 0;
			if (wr)
				begin
				case (addr)
					32'h40000018:
						begin
						UART_TXD <= wdata[7:0];
						TX_EN <= 1;
						end
					32'h40000020: {UART_CON1, UART_CON0} <= wdata[1:0];
					default: ;
				endcase
				end
			if (rd)
				case(addr)
					32'h40000018: 
						UART_CON2 <= 0;
					32'h4000001C:
						UART_CON3 <= 0;
					default:;
				endcase
		end
		end
	assign rdata = rd?((addr == 32'h40000018)?{24'b0, UART_TXD}:((addr == 32'h4000001C)?{24'b0, UART_RXD}:((addr == 32'h40000020)?{27'b0,UART_CON}:32'b0))):32'b0;

	Baud_Rate_Generator brgenInst(.sysclk(CLK), .resetn(Reset_n), .baud_rate_clk(baud_rate_clk));
	UART_Sender senderInst(CLK, baud_rate_clk, Reset_n, TX_EN, TX_STATUS, out, UART_TXD);
	UART_Receiver recvInst(in, CLK, baud_rate_clk, Reset_n, UART_RXD, RX_STATUS);
endmodule

module Baud_Rate_Generator(sysclk, resetn, baud_rate_clk);
	input sysclk, resetn;
	output reg baud_rate_clk;
	integer count;
	
	initial begin
		count <= 0;
		baud_rate_clk <= 0;
	end
	always @(negedge resetn, posedge sysclk)
		begin
		if (!resetn)
			begin
			count <= 0;
			baud_rate_clk <= 0;
			end
		else
			if (count == 161)
				begin
					count <= 0;
					baud_rate_clk <= ~baud_rate_clk;
				end
			else
				count <= count + 1;
		end
		
endmodule
module UART_Receiver(UART_RX, sysclk, clk, resetn, RX_DATA, RX_STATUS);
	input UART_RX, sysclk, clk, resetn;
	output reg [7:0] RX_DATA;
	output reg RX_STATUS;
	reg enable;
	reg [7:0] buff;
	reg [3:0] data_count;
	reg [3:0] inner_count;
	reg [2:0] beg_count; 
	reg pre_beg, ok, flag1, pre_flag;

	initial
		begin
		enable <= 0;
		RX_DATA <= 0;
		RX_STATUS <= 0;
		pre_beg <= 0;
		beg_count <= 0;
		inner_count <= 0;
		data_count <= 0;
		ok <= 0;
		flag1 <= 1;
		pre_flag <= 1;
		end
	always @(posedge sysclk, negedge resetn)
		begin
		if (!resetn)
			begin
			pre_beg <= 0;
			end
		else if (!enable && !pre_beg && !UART_RX)
				begin
				pre_beg <= 1;
				end
		else if (!pre_flag)
			pre_beg <= 0;
		end
	always @(posedge clk, negedge resetn)
		begin
		if (!resetn)
			begin
			beg_count <= 0;
			enable <= 0;
			ok <= 0;
			data_count <= 0;
			inner_count <= 0;
			pre_flag <= 1;
			end
		else
			begin
			ok <= 0;
			pre_flag <= 1;
			if (pre_beg && pre_flag)
				begin
				beg_count <= beg_count + 1;
				if (beg_count == 7)
					begin
					enable <= 1;
					pre_flag <= 0;
					end
				end
			else if (enable)
				begin
				inner_count <= inner_count + 1;
				if (inner_count == 15)
					begin
					if (data_count == 8)
						begin
							enable <= 0;
							ok <= 1;
							data_count <= 0;
						end
					else
						begin
						buff[data_count] <= UART_RX;
						data_count <= data_count + 1;
						end
					end
				end
			end
		end
	always @(posedge sysclk, negedge resetn)
		begin
		if (!resetn)
			begin
			RX_DATA <= 0;
			RX_STATUS <= 0;
			flag1 <= 1;
			end
		else
			begin
			RX_STATUS <= 0;
			if (!ok)
				flag1 <= 1;
			else if (flag1)
				begin
				RX_STATUS <= 1;
				RX_DATA <= buff;
				flag1 <= 0;
				end
			end
		end
endmodule
module UART_Sender(sysclk, clk, resetn, TX_EN, TX_STATUS, UART_TX, TX_DATA);
	input sysclk, clk, resetn, TX_EN;
	output reg TX_STATUS, UART_TX;
	input [7:0] TX_DATA;
	reg [3:0] inner_count;
	reg [3:0] data_count;
	reg tmp_tx, flag;

	initial
		begin
		UART_TX <= 1;
		TX_STATUS <= 1;
		inner_count <= 0;
		data_count <= 0;
		tmp_tx <= 0;
		flag <= 1;
		end
			
	always @(posedge sysclk, negedge resetn)
		begin
		if (!resetn)
			begin
			TX_STATUS <= 1;
			flag <= 1;
			end
		else if (TX_EN)
			TX_STATUS <= 0;
		else if (!tmp_tx)
			flag <= 1;
		else if (tmp_tx && flag)
			begin
			TX_STATUS <= 1;
			flag <= 0;
			end
		
		end
	always @(posedge clk, negedge resetn)
		begin
			if (!resetn)
				begin
				UART_TX <= 1;
				inner_count <= 0;
				data_count <= 0;
				tmp_tx <= 0;
				end
			else if (!TX_STATUS)
				begin
				tmp_tx <= 0;
				inner_count <= inner_count + 1;
				if (inner_count == 0)
					begin
					data_count <= data_count + 1;
					if (data_count == 0)
						UART_TX <= 0;
					else if (data_count == 9)
						UART_TX <= 1;
					else if (data_count == 10) begin
						tmp_tx <= 1;
						data_count <= 0;
						inner_count <= 0;
						end
					else
						UART_TX <= TX_DATA[data_count - 1];
					end
				end
		end

endmodule
/*module brgenerator(sysclk,brclk,reset);
	input sysclk,reset;
	output reg brclk=0;
	reg [7:0] count=0;
	always@(posedge sysclk or negedge reset) begin
		if(reset==0) begin
			count<=0;
			brclk<=0;
		end
		else begin
			if(count==216) begin
				count<=0;
				brclk<=~brclk;
			end
			else count<=count+8'd1;
		end
	end
endmodule

module sender(txdata,txen,txstatus,sysclk,brclk,uarttx,reset);
	input [7:0]txdata;
	input txen,sysclk,brclk,reset;
	output reg uarttx=1,txstatus=1;
	reg [6:0]count=7'd0;
	reg recden=0;
	always@(posedge sysclk or negedge reset) begin
		if(reset==0) begin
			recden<=0;
			txstatus<=1;
		end
		else if(txen) begin
			txstatus<=0;
			recden<=1;
		end
		else if(count==7'd120) begin
			txstatus<=1;
			recden<=0;
		end
	end
	always@(posedge brclk or negedge reset) begin
		if(reset==0) begin
			uarttx<=1;
			
		end
		else if(recden) begin
			case(count)
				7'd0: uarttx<=0;
				7'd12: uarttx<=txdata[0];
				7'd24: uarttx<=txdata[1];
				7'd36: uarttx<=txdata[2];
				7'd48: uarttx<=txdata[3];
				7'd60: uarttx<=txdata[4];
				7'd72: uarttx<=txdata[5];
				7'd84: uarttx<=txdata[6];
				7'd96: uarttx<=txdata[7];
				7'd108: begin
					uarttx<=1;
					
					
				end
				default: ;
			endcase
		end
	end
	always@(posedge brclk or negedge reset) begin
		if(reset==0) count<=7'd0;
		else if(count==7'd120) count<=7'd0;
		else if(recden) count<=count+1;
	end
endmodule

module receiver(uartrx,sysclk,brclk,rxdata,rxstatus,reset);
	input uartrx,sysclk,brclk,reset;
	output reg rxstatus=0;
	output reg [7:0]rxdata=8'b0;
	reg [6:0]count=7'd0;
	reg recd1=1,recd2=1,recden=0;
	reg [7:0]rxdata1=8'b0;
	always@(posedge sysclk or negedge reset) begin
		if(reset==0) begin
			recd1<=1;
			recd2<=1;
			recden<=0;
			rxdata<=8'b0;
			rxstatus<=0;
		end
		else if(recd1&&recd2) begin
			recd2<=uartrx;
			recd1<=recd2;
		end
		else if(recd1&&~recd2) begin
			recden<=1;
			recd1<=0;
		end
		else if(count==7'd120&&~rxstatus) begin
			rxstatus<=1;
			rxdata<=rxdata1;
		end
		else  if(rxstatus==1) begin
			rxstatus<=0;
			recd1<=1;
			recd2<=1;
			recden<=0;
		end
	end
	always@(posedge brclk or negedge reset) begin
		if(reset==0) rxdata1<=8'b0;
		else begin
			case(count)
				7'd18: rxdata1[0]<=uartrx;
				7'd30: rxdata1[1]<=uartrx;
				7'd42: rxdata1[2]<=uartrx;
				7'd54: rxdata1[3]<=uartrx;
				7'd66: rxdata1[4]<=uartrx;
				7'd78: rxdata1[5]<=uartrx;
				7'd90: rxdata1[6]<=uartrx;
				7'd102: rxdata1[7]<=uartrx;
				default: ;
			endcase
		end
	end
	always@(posedge brclk or negedge reset) begin
		if(reset==0) count<=7'd0;
		else if(recd1&&~recd2) begin
			count<=7'd1;
		end
		else if(recden) count<=count+7'd1;
		else count<=7'd0;
	end
endmodule
	
*/