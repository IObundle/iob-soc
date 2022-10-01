`define DEBOUNCE_VALUE 16'hf00f
 module edge_detector (

iCLK,
iRST_n,
iIn,
oFallING_EDGE,
oRISING_EDGE,
oDEBOUNCE_OUT,
rst_cnt
);

input iCLK;
input iRST_n;

input iIn;
output oFallING_EDGE;
output oRISING_EDGE;

reg  [1:0] in_delay_reg;
reg cnt_enable;


always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				in_delay_reg <= 0;
			end
		else
			begin
				in_delay_reg <= {in_delay_reg[0],iIn};	
			end	
	end
	
			 
assign oFallING_EDGE = (in_delay_reg == 2'b10) ? 1'b1 : 1'b0;	
assign oRISING_EDGE = (in_delay_reg == 2'b01) ? 1'b1 : 1'b0;	


output reg [15:0] rst_cnt;

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				rst_cnt <= 0;
			end
		else if (rst_cnt == `DEBOUNCE_VALUE)
			rst_cnt <= 0;
		else if (cnt_enable)
			begin 
				rst_cnt <= rst_cnt + 1;
			end
	end		
			
			
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				cnt_enable <= 1'b0;
			end
		else if (oRISING_EDGE)
			begin
				cnt_enable <= 1'b1;
			end
		else if (rst_cnt == `DEBOUNCE_VALUE)
			begin
				cnt_enable <= 1'b0;
			end 
	end


output reg oDEBOUNCE_OUT;


always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				oDEBOUNCE_OUT <= 1'b0;
			end
		else if (oRISING_EDGE && ~cnt_enable)
			begin
				oDEBOUNCE_OUT <= 1'b1;
			end
		else 
			oDEBOUNCE_OUT <= 1'b0;
		
	end		
			
endmodule 
