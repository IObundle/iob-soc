`timescale 1ns / 1ps

module axi_to_mem#(
		   parameter ADDR_SIZE = 14,
		   parameter WAIT_TIME = 10
		   )(

		     input 			   clock ,
		     input 			   reset ,

		     //----------------------------------------------
		     //--		AXI MIG CONTROLLER INTERFACE 0		  --
		     //----------------------------------------------
		     //-- Slave Interface Write Address Ports
		     input [3:0] 		   axi_awid, 
		     input [ADDR_SIZE-1:0] 	   axi_awaddr, 
		     input [7:0] 		   axi_awlen, 
		     input [2:0] 		   axi_awsize, 
		     input [1:0] 		   axi_awburst, 
		     input 			   axi_awlock, 
		     input [3:0] 		   axi_awcache, 
		     input [2:0] 		   axi_awprot, 
		     input [3:0] 		   axi_awqos, 
		     input 			   axi_awvalid, 
		     output reg 		   axi_awready, 
		     //-- Slave Interface Write Data Ports
		     input [31:0] 		   axi_wdata, 
		     input [3:0] 		   axi_wstrb, 
		     input 			   axi_wlast, 
		     input 			   axi_wvalid, 
		     output reg 		   axi_wready, 
		     //-- Slave Interface Write Response Ports
		     output [3:0] 		   axi_bid, 
		     output [1:0] 		   axi_bresp, 
		     output reg 		   axi_bvalid, 
		     input 			   axi_bready, 
		     //-- Slave Interface Read Address Ports
		     input [3:0] 		   axi_arid, 
		     input [ADDR_SIZE-1:0] 	   axi_araddr, 
		     input [7:0] 		   axi_arlen, 
		     input [2:0] 		   axi_arsize, 
		     input [1:0] 		   axi_arburst, 
		     input 			   axi_arlock, 
		     input [3:0] 		   axi_arcache, 
		     input [2:0] 		   axi_arprot, 
		     input [3:0] 		   axi_arqos, 
		     input 			   axi_arvalid, 
		     output reg 		   axi_arready, 
		     //-- Slave Interface Read Data Ports
		     output [3:0] 		   axi_rid, 
		     output [31:0] 		   axi_rdata, 
		     output [1:0] 		   axi_rresp, 
		     output reg 		   axi_rlast, 
		     output reg 		   axi_rvalid, 
		     input 			   axi_rready,

		     output reg [3:0] 		   wr_mem_en,
		     output reg [ADDR_SIZE-1 -2:0] addr_mem,
		     output [31:0] 		   wr_data_mem,
		     input [31:0] 		   rd_data_mem

		     );


   parameter 	IDLE 			= 3'd0;
   parameter 	ST_AW 			= 3'd1;
   parameter 	ST_W 			= 3'd2;
   parameter 	ST_B 			= 3'd3;
   parameter 	ST_AR 			= 3'd4;
   parameter 	ST_RDWAIT 		= 3'd5;
   parameter 	ST_R 			= 3'd6;
   
   reg [2:0] 					   state, state_nxt;  //TODO STATES !|
   integer 					   counter_timer, counter_timer_nxt;
   
   
   reg [ADDR_SIZE-1:0] 				   addr , addr_nxt;
   reg [7:0] 					   counter , counter_nxt;
   reg [2:0] 					   sum, sum_nxt;
   reg [3:0] 					   axi_id ,axi_id_nxt;
   
   reg [31:0] 					   rd_data_buffer , rd_data_buffer_nxt; 


   //assign addr_mem 	= addr[ADDR_SIZE-1 : 2];
   assign wr_data_mem 	= axi_wdata;
   assign axi_bid 		= axi_id;
   assign axi_rid 		= axi_id;
   assign axi_bresp 	= 2'd0;
   assign axi_rresp 	= 2'd0;

   assign axi_rdata = rd_data_buffer;

   always @ (posedge clock, posedge reset) begin
      if(reset == 1'b1) begin
	 state 			<= IDLE;
	 addr 			<= {ADDR_SIZE{1'b0}};
	 counter 		<= 8'd0;
	 sum 			<= 2'd0;
	 axi_id 			<= 4'd0;
	 rd_data_buffer 	<= 32'd0;
	 counter_timer 	<= 0;
      end else begin
	 state 			<= state_nxt;
	 addr 			<= addr_nxt;
	 counter 		<= counter_nxt;
	 sum 			<= sum_nxt;
	 axi_id 			<= axi_id_nxt;
	 rd_data_buffer 	<= rd_data_buffer_nxt; 
	 counter_timer 	<= counter_timer_nxt;
      end
   end


   always @ (*) begin
      state_nxt		= state;
      addr_nxt		= addr;
      sum_nxt 		= sum;
      counter_nxt 	= counter;
      wr_mem_en 		= 4'd0;
      axi_id_nxt 		= axi_id;

      axi_awready 	= 1'b0;
      axi_wready 		= 1'b0;
      axi_bvalid 		= 1'b0;
      axi_arready 	= 1'b0;
      axi_rlast 		= 1'b0;
      axi_rvalid 		= 1'b0;

      counter_timer_nxt 	= counter_timer;
      rd_data_buffer_nxt 	= rd_data_buffer;

      addr_mem 	= addr[ADDR_SIZE-1 : 2];

      case(state)	

	IDLE : begin 
	   counter_timer_nxt = WAIT_TIME;
	   if(axi_awvalid == 1'b1) begin //WRITE
	      state_nxt		= ST_AW;
	   end else if(axi_arvalid == 1'b1) begin //READ
	      state_nxt		= ST_AR;
	      rd_data_buffer_nxt = WAIT_TIME;
	   end
	end

	ST_AW : begin
	   if(axi_awvalid == 1'b1) begin //WRITE
	      axi_awready 		= 1'b1;
	      axi_id_nxt 			= axi_awid;
	      addr_nxt 			= axi_awaddr;
	      counter_nxt 		= axi_awlen;
	      if(axi_awsize == 3'd0) begin
		 sum_nxt 		= 3'b001;
	      end else if (axi_awsize == 3'd1) begin
		 sum_nxt 		= 3'b010;
	      end else if (axi_awsize == 3'd2) begin
		 sum_nxt 		= 3'b100;
	      end
	      state_nxt 	= ST_W;
	   end	
	end

	ST_W : begin
	   axi_wready 		= 1'b1;
	   addr_mem 	= addr[ADDR_SIZE-1 : 2];
	   if(axi_wvalid == 1'b1)begin
	      addr_nxt		= addr + sum;	
	      counter_nxt 	= counter - 1'b1;
	      wr_mem_en 		= axi_wstrb;
	      if(counter == 8'd0) begin
		 state_nxt = ST_B;
	      end
	   end
	end

	ST_B : begin
	   axi_bvalid = 1'b1;
	   if(axi_bready == 1'b1)begin	
	      state_nxt = IDLE;
	   end
	end


	ST_AR : begin
	   if(axi_arvalid == 1'b1)begin
	      axi_arready = 1'b1;
	      addr_nxt 			= axi_araddr;
	      counter_nxt 		= axi_arlen;
	      axi_id_nxt 			= axi_arid;
	      if(axi_arsize == 3'd0) begin
		 sum_nxt 		= 3'b001;
	      end else if (axi_arsize == 3'd1) begin
		 sum_nxt 		= 3'b010;
	      end else if (axi_arsize == 3'd2) begin
		 sum_nxt 		= 3'b100;
	      end
	      state_nxt = ST_RDWAIT;
	   end
	end

	ST_RDWAIT : begin 
	   counter_timer_nxt 			= counter_timer - 1'b1;

	   //addr_mem 					= addr_nxt[ADDR_SIZE-1 : 2];

	   if(counter_timer == 0) begin
	      rd_data_buffer_nxt 		= rd_data_mem;
	      addr_nxt				= addr + sum;
	      addr_mem 				= addr_nxt[ADDR_SIZE-1 : 2];
	      state_nxt 				= ST_R;
	   end
	end

	ST_R : begin
	   axi_rvalid = 1'b1;
	   if(axi_rready == 1'b1) begin
	      rd_data_buffer_nxt 		= rd_data_mem;
	      addr_nxt				= addr + sum;	
	      addr_mem 				= addr_nxt[ADDR_SIZE-1 : 2];
	      counter_nxt 			= counter - 1'b1;
	      if(counter == 8'd0) begin
		 axi_rlast 		= 1'b1;
		 state_nxt 		= IDLE;	
	      end
	   end
	end


      endcase

   end


endmodule
