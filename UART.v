/*
 * UART Module
 */

module UARTUnit(
				input Reset_n,
				input CLK,
				input rd, wr,
				input [31:0] addr, wdata,
				output reg[31:0] rdata,
				output out, in
				);

	reg [7:0] UART_TXD;
	reg [7:0] UART_RXD;
	reg [4:0] UART_CON;

	reg TX_EN;
	reg prevTX_STATUS;
	wire baud_rate_clk;
	wire RX_STATUS, TX_STATUS;


	always@(*)
		begin
		if(rd)
			begin
			case(addr)
				32'h40000018: 
					begin
					rdata <= {24'b0, UART_TXD};
					UART_CON[2] <= 0;
					end
				32'h4000001C:
					begin
					rdata <= {24'b0, UART_RXD};
					UART_CON[3] <= 0;
					end			
				32'h40000020: rdata <= {27'b0,UART_CON};
				default: rdata <= 32'b0;
			endcase
			end
		else
			rdata <= 32'b0;
		end

	always @(negedge Reset_n or posedge CLK)
		begin
		if (~Reset_n)
			begin
			UART_TXD <= 8'b0;
			UART_RXD <= 8'b0;
			UART_CON <= 5'b0;
			prevTX_STATUS <= 1;
			TX_EN <= 0;
			end
		else
			begin
			UART_CON[4] <= TX_STATUS;
			prevTX_STATUS <= TX_STATUS;
			TX_EN <= 0;
			if (RX_STATUS && UART_CON[1])
				begin
				UART_CON[3] <= 1;
				end
			if (TX_STATUS && ~prevTX_STATUS && UART_CON[0])
				UART_CON[2] <= 1;
			if (wr)
				begin
				case (addr)
					32'h40000018:
						begin
						UART_TXD <= wdata[7:0];
						TX_EN <= 1;
						end
					32'h40000020: UART_CON <= wdata[4:0];
					default: ;
				endcase
				end
			end
		end


	brgenerator brgenInst(.sysclk(CLK), .brclk(baud_rate_clk), .reset(Reset_n));
	sender senderInst(.txdata(UART_TXD), .txen(TX_EN), .txstatus(TX_STATUS),
					  .sysclk(CLK), .brclk(baud_rate_clk), .uarttx(out),
					  .reset(Reset_n));
	receiver recvInst(.uartrx(in), .sysclk(CLK), .brclk(baud_rate_clk),
					  .rxdata(UART_RXD), .rxstatus(RX_STATUS), .reset(Reset_n));
endmodule


module brgenerator(sysclk,brclk,reset);
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
		else if(count==7'd120) begin
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
	
