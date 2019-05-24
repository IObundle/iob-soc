`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2019 01:53:57 PM
// Design Name: 
// Module Name: top_system_MIG_debug
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_system_MIG_debug(

	           input 	 C0_SYS_CLK_clk_p, C0_SYS_CLK_clk_n, 
	           //input        clk,
	           input 	 resetn,
	           output  [6:0] led,
	           output 	 ser_tx,
		   output 	 trap,
//   ///////////////////////////////////////////////////////////            
//   ////////////// MIG - DDR4 inputs and outputs //////////////
//   ///////////////////////////////////////////////////////////
		   input 	 sys_rst, 
		   output 	 c0_ddr4_act_n,
		   output [16:0] c0_ddr4_adr,
		   output [1:0]  c0_ddr4_ba,
		   output [0:0]  c0_ddr4_bg,
		   output [0:0]  c0_ddr4_cke,
		   output [0:0]  c0_ddr4_odt,
		   output [0:0]  c0_ddr4_cs_n,
		   output [0:0]  c0_ddr4_ck_t,
		   output [0:0]  c0_ddr4_ck_c,
		   output 	 c0_ddr4_reset_n,
		   inout [3:0] 	 c0_ddr4_dm_dbi_n,
		   inout [31:0]  c0_ddr4_dq,
		   inout [3:0] 	 c0_ddr4_dqs_c,
		   inout [3:0] 	 c0_ddr4_dqs_t 
               
    );

        wire 		  clk;
        wire        wire_resetn_int;
        wire        wire_axi_awvalid;
        wire        wire_axi_awready;
        wire [31:0] wire_axi_awaddr;
        wire [ 2:0] wire_axi_awprot;
        
        wire        wire_axi_wvalid;
        wire        wire_axi_wready;
        wire [31:0] wire_axi_wdata;
        wire [ 3:0] wire_axi_wstrb;
        
        wire        wire_axi_bvalid;
        wire        wire_axi_bready;
        
        wire        wire_axi_arvalid;
        wire        wire_axi_arready;
        wire [31:0] wire_axi_araddr;
        wire [ 2:0] wire_axi_arprot;
        
        wire        wire_axi_rvalid;
        wire        wire_axi_rready;
        wire [31:0] wire_axi_rdata;
        
        // AXI-full extra wires
        wire        wire_axi_rlast;
        wire [1:0]  wire_axi_bresp;
        wire [7:0]  wire_axi_arlen;
        wire [2:0]  wire_axi_arsize;
        wire [1:0]  wire_axi_arburst;
        wire [7:0]  wire_axi_awlen;
        wire [2:0]  wire_axi_awsize;
        wire [1:0]  wire_axi_awburst;

   wire 	    init_calib_complete;
   wire [1:0] 	    slave_select;
   
   assign led[2] = wire_axi_rdata [0];
   //assign led[1] = ;
   assign led[0] = init_calib_complete;
   assign led[3] = (~resetn) & init_calib_complete;
   
   assign led[6] = slave_select[1];
   assign led[5] = slave_select[0];
   
      
      system system (
		           .clk        (clk       ),
		           .resetn     ((~resetn) & init_calib_complete),
		           .ser_tx     (ser_tx    ),
		           .trap       (trap      ),
		           .s_sel      (slave_select),
		           //// Address-Write
		           .resetn_int_sys    (wire_resetn_int),
		           .sys_s_axi_awvalid (wire_axi_awvalid),
		           .sys_s_axi_awready (wire_axi_awready),
		           .sys_s_axi_awaddr  (wire_axi_awaddr ),
		           //// Data-Write  
		           .sys_s_axi_wvalid  (wire_axi_wvalid ),
		           .sys_s_axi_wready  (wire_axi_wready ),
		           .sys_s_axi_wdata   (wire_axi_wdata  ),
		           .sys_s_axi_wstrb   (wire_axi_wstrb  ),
		           //// Response    
		           .sys_s_axi_bvalid  (wire_axi_bvalid ),
		           .sys_s_axi_bready  (wire_axi_bready ),
		           //// Address-Read
		           .sys_s_axi_arvalid (wire_axi_arvalid),
		           .sys_s_axi_arready (wire_axi_arready),
		           .sys_s_axi_araddr  (wire_axi_araddr ),
		           //// Data-Read   
		           .sys_s_axi_rvalid  (wire_axi_rvalid ),
		           .sys_s_axi_rready  (wire_axi_rready ),
		           .sys_s_axi_rdata   (wire_axi_rdata  )
		           ///////// AXI_Full signals
		           //// Read         
//		           .sys_s_axi_arlen   (8'd0              ), 
//		           .sys_s_axi_arsize  (3'b010            ),     
//                   .sys_s_axi_arburst (2'b00             ),
//                   .sys_s_axi_rlast   (wire_axi_rlast  ),
                   //// Write        
//                   .sys_s_axi_awlen   (8'd0              ),
//                   .sys_s_axi_awsize  (3'b010            ),
//                   .sys_s_axi_awburst (2'b00             ),
//                   .sys_s_axi_wlast   (|wire_axi_wstrb ),
//                   .sys_s_axi_bresp   (wire_axi_bresp  )
		           
	                 );
   
           ddr4_0 ddr4_ram (
                   .c0_sys_clk_p        (C0_SYS_CLK_clk_p),
                   .c0_sys_clk_n        (C0_SYS_CLK_clk_n),
//                   .c0_sys_clk_i          (clk),
                   .addn_ui_clkout1     (clk             ), // 100MHz
                  // .addn_ui_clkout2     (                ), // 50MHz
                   //.addn_ui_clkout3     (               ), // 25MHz
                   //.addn_ui_clkout4     (                ), // 10MHz
                   .c0_init_calib_complete (init_calib_complete),
                   .dbg_rd_valid          (led[1]),
                   
                   .c0_ddr4_aresetn       (wire_resetn_int ),
     		       .c0_ddr4_s_axi_awvalid (wire_axi_awvalid),
		           .c0_ddr4_s_axi_awready (wire_axi_awready),
		           .c0_ddr4_s_axi_awaddr  (wire_axi_awaddr[29:0]),
		           //// Data-Write  
		           .c0_ddr4_s_axi_wvalid  (wire_axi_wvalid ),
		           .c0_ddr4_s_axi_wready  (wire_axi_wready ),
		           .c0_ddr4_s_axi_wdata   (wire_axi_wdata  ),
		           .c0_ddr4_s_axi_wstrb   (wire_axi_wstrb  ),
		           //// Response    
		           .c0_ddr4_s_axi_bvalid  (wire_axi_bvalid ),
		           .c0_ddr4_s_axi_bready  (wire_axi_bready ),
		           //// Address-Read
		           .c0_ddr4_s_axi_arvalid (wire_axi_arvalid),
		           .c0_ddr4_s_axi_arready (wire_axi_arready),
		           .c0_ddr4_s_axi_araddr  (wire_axi_araddr[29:0]),
		           //// Data-Read   
		           .c0_ddr4_s_axi_rvalid  (wire_axi_rvalid ),
		           .c0_ddr4_s_axi_rready  (wire_axi_rready ),
		           .c0_ddr4_s_axi_rdata   (wire_axi_rdata  ),
		           ///////// AXI_Full signals
		           //// Read         
		           .c0_ddr4_s_axi_arlen   (8'd0            ), 
		           .c0_ddr4_s_axi_arsize  (3'b010          ),     
                   .c0_ddr4_s_axi_arburst (2'b00           ),
                   .c0_ddr4_s_axi_rlast   (wire_axi_rlast  ),
                   // Write        
                   .c0_ddr4_s_axi_awlen   (8'd0            ),
                   .c0_ddr4_s_axi_awsize  (3'b010          ),
                   .c0_ddr4_s_axi_awburst (2'b00           ),
                   .c0_ddr4_s_axi_wlast   (|wire_axi_wstrb ),
                   .c0_ddr4_s_axi_bresp   (wire_axi_bresp  ),
                   //unused 
                   .c0_ddr4_s_axi_awlock                (1'b0),
                   .c0_ddr4_s_axi_awqos                 (4'b0),
                   .c0_ddr4_s_axi_arlock                (1'b0),
                   .c0_ddr4_s_axi_arprot                (3'b0),
                   .c0_ddr4_s_axi_arqos                 (4'b0),
                   // Constraints of the DDR4 
                   .sys_rst             (sys_rst),
                   .c0_ddr4_act_n       (c0_ddr4_act_n),
                   .c0_ddr4_adr         (c0_ddr4_adr),
                   .c0_ddr4_ba          (c0_ddr4_ba),
                   .c0_ddr4_bg          (c0_ddr4_bg),
                   .c0_ddr4_cke         (c0_ddr4_cke),
                   .c0_ddr4_odt         (c0_ddr4_odt),
                   .c0_ddr4_cs_n        (c0_ddr4_cs_n),
                   .c0_ddr4_ck_t        (c0_ddr4_ck_t),
                   .c0_ddr4_ck_c        (c0_ddr4_ck_c),
                   .c0_ddr4_reset_n     (c0_ddr4_reset_n),
                   .c0_ddr4_dm_dbi_n    (c0_ddr4_dm_dbi_n),
                   .c0_ddr4_dq          (c0_ddr4_dq),
                   .c0_ddr4_dqs_c       (c0_ddr4_dqs_c),
                   .c0_ddr4_dqs_t       (c0_ddr4_dqs_t)
                       );   

endmodule
