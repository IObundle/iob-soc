`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2019 03:48:19 PM
// Design Name: 
// Module Name: top_system_test_AXI
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top Environment to te
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_system_test_AXI(
	          input      C0_SYS_CLK_clk_p, C0_SYS_CLK_clk_n,	  
	          // input      clk,
	           input      resetn,
	           output [6:0]    led,
	           output     ser_tx,
               output     trap
              
    );
    
    
    ////////////single ended clock
        wire 		  clk;
        wire 		  clk_ibufg;
     
       IBUFGDS ibufg_inst (.I(C0_SYS_CLK_clk_p), .IB(C0_SYS_CLK_clk_n), .O(clk_ibufg));
       BUFG bufg_inst     (.I(clk_ibufg), .O(clk));
    
    ////////////////////////////

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


   wire [1:0] 	    slave_select;
   
      assign led[3] = (wire_resetn_int);  
      assign led [2] = wire_axi_rdata [0];
      assign led [1] = 1'b1;
      assign led[6] = slave_select[1];
      assign led[5] = slave_select[0];


/*  
   reg [31:0] reg_axi_rdata;
   reg reg_axi_rvalid;
   
   always @*
       begin
          reg_axi_rvalid <= wire_axi_rvalid;
          if (wire_axi_rvalid == 1'b1) reg_axi_rdata <= wire_axi_rdata; 
       end
   
   
      
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
		           .sys_s_axi_rvalid  (reg_axi_rvalid ),
		           .sys_s_axi_rready  (wire_axi_rready ),
		           .sys_s_axi_rdata   (reg_axi_rdata  )
		           ///////// AXI_Full signals
		           //// Read         
//		           .sys_s_axi_arlen   (8'd0              ), 
//		           .sys_s_axi_arsize  (3'b010            ),     
//                   .sys_s_axi_arburst (2'b00           ),
//                   .sys_s_axi_rlast   (wire_axi_rlast  ),
                   //// Write        
//                   .sys_s_axi_awlen   (8'd0            ),
//                   .sys_s_axi_awsize  (3'b010          ),
//                   .sys_s_axi_awburst (2'b00           ),
//                   .sys_s_axi_wlast   (|wire_axi_wstrb ),
//                   .sys_s_axi_bresp   (wire_axi_bresp  )
		           
	                 );
   
   
   */


   
  
      system system (
		           .clk        (clk       ),
		           .reset      (~resetn   ),
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








///////////////////////////////////////////////////////
///// Open source RAM with AXI memory instance ///////
/////////////////////////////////////////////////////
  wire [3:0] main_mem_en;
  wire [29:0] main_mem_addr;
  wire [31:0] main_mem_read_data, main_mem_write_data;    		             	   
		             	   
		             	               
         axi_to_mem#(
             .ADDR_SIZE(32),
             .WAIT_TIME(10)
            ) axi_to_mem (
                   .clock (clk        ),
                   .reset (~wire_resetn_int),
                   // Address - Write
                   .axi_awvalid   (wire_axi_awvalid),
		           .axi_awready   (wire_axi_awready),
		           .axi_awaddr    (wire_axi_awaddr),
		           // Data-Write
		           .axi_wvalid    (wire_axi_wvalid),
		           .axi_wready    (wire_axi_wready),
		           .axi_wdata     (wire_axi_wdata ),
		           .axi_wstrb     (wire_axi_wstrb ),
		           // Response
		           .axi_bvalid    (wire_axi_bvalid),
		           .axi_bready    (wire_axi_bready),
		           // Address-Read
		           .axi_arvalid   (wire_axi_arvalid),
		           .axi_arready   (wire_axi_arready),
		           .axi_araddr    (wire_axi_araddr ),
		           // Data-Read
		           .axi_rvalid    (wire_axi_rvalid),
		           .axi_rready    (wire_axi_rready),
		           .axi_rdata     (wire_axi_rdata ),
		           //AXI_Full signals
		           //Read
		           .axi_arlen     (8'd0          ), 
		           .axi_arsize    (3'b010        ),     
                   .axi_arburst   (2'b00         ),
                   .axi_rlast     (wire_axi_rlast),
                   //Write
                   .axi_awlen     (8'd0           ),
                   .axi_awsize    (3'b010         ),
                   .axi_awburst   (2'b00          ),
                   .axi_wlast     (|wire_axi_wstrb),
                   .axi_bresp     (wire_axi_bresp ),
                   //Memory interface
                   .wr_mem_en   (main_mem_en        ),//[3:0]
                   .addr_mem    (main_mem_addr      ),// [ADDR_SIZE-1 -2 : 0]
                   .wr_data_mem (main_mem_write_data),// [31:0]
                   .rd_data_mem (main_mem_read_data ) // [31:0]
                       );
  
  
        main_memory  #(.ADDR_W(30) ) main_memory (
                    .clk                (clk                ),
                    .main_mem_write_data(main_mem_write_data),
                    .main_mem_addr      (main_mem_addr      ),
                    .main_mem_en        (main_mem_en        ),
                    .main_mem_read_data (main_mem_read_data )                            
                        );

            
//////////////////////////////////////////////////////
/////////////////////////////////////////////////////  






//// BRAM AXI-Full
//    bram_axi bram_axi_test (
//                   .s_aclk(clk),
//                   .s_aresetn(wire_resetn_int),
//                   // Address-Write
//     		       .s_axi_awvalid(wire_axi_awvalid),
//		           .s_axi_awready(wire_axi_awready),
//		           .s_axi_awaddr(wire_axi_awaddr),
//		          // .mem_axi_awprot(),
//		           // Data-Write
//		           .s_axi_wvalid(wire_axi_wvalid),
//		           .s_axi_wready(wire_axi_wready),
//		           .s_axi_wdata(wire_axi_wdata),
//		           .s_axi_wstrb(wire_axi_wstrb),
//		           // Response
//		           .s_axi_bvalid(wire_axi_bvalid),
//		           .s_axi_bready(wire_axi_bready),
//		           // Address-Read
//		           .s_axi_arvalid(wire_axi_arvalid),
//		           .s_axi_arready(wire_axi_arready),
//		           .s_axi_araddr(wire_axi_araddr),
//		          // .mem_axi_arprot(),
//		           // Data-Read
//		           .s_axi_rvalid(wire_axi_rvalid),
//		           .s_axi_rready(wire_axi_rready),
//		           .s_axi_rdata(wire_axi_rdata),
//		           //AXI_Full signals
//		           //Read
//		           .s_axi_arlen   (8'd0  ), 
//		           .s_axi_arsize  (3'b010),     
//                   .s_axi_arburst (2'b00 ),
//                   .s_axi_rlast  (wire_axi_rlast), //only for simulation
//                   //Write
//                   .s_axi_awlen   (8'd0  ),
//                   .s_axi_awsize  (3'b010),
//                   .s_axi_awburst (2'b00 ),
//                   .s_axi_wlast   (|wire_axi_wstrb),
//                   .s_axi_bresp   (wire_axi_bresp )
//                       );





endmodule

