`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IOBundle
// Engineer: 
// 
// Create Date: 04/03/2019 12:44:46 PM
// Design Name: 
// Module Name: iob_axi_interconnect, memory_mapped_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: AXI Interconnect (currently only for AXI-Lite) - PicoRV32 doesn't support AXI-Full
//      slave_0 -> Ideally for Program RAM, since PicoRV32 starts at the address 0 to read the program
//          
//
// Dependencies: memory_mapped_par.vh (file with only the parameters defined) 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//
// WARNING: Separate processes (always@*) because Verilator doesn't like it
//////////////////////////////////////////////////////////////////////////////////


module iob_axi_interconnect(
                     output [1:0]      slave_select, 
		     input 	       mem_select, 
                     /////////////////////////////////////  
                     //// master AXI interface //////////
                     ///////////////////////////////////
                     input 	       clk,
//                     input             m_resetn, 
                     /// Address-Write
    	             input 	       m_axi_awvalid,
	             output reg        m_axi_awready,
	             input [31:0]      m_axi_awaddr,
                     /// Data-Write
	             input 	       m_axi_wvalid,
	             output reg        m_axi_wready,
	             input [31:0]      m_axi_wdata,
	             input [ 3:0]      m_axi_wstrb,
                     /// Write-Response
	             output reg        m_axi_bvalid,
	             input 	       m_axi_bready,
                     /// Address-Read
	             input 	       m_axi_arvalid,
	             output reg        m_axi_arready,
	             input [31:0]      m_axi_araddr,
                     /// Data-Read
	             output reg        m_axi_rvalid,
	             input 	       m_axi_rready,
	             output reg [31:0] m_axi_rdata,
	                 
	                 ///////////////////////////////////
	                 //// slave 0 AXI interface ///////
	                 /////////////////////////////////  
//	                 output            s_clk_0,
//	                 output            s_resetn_0,
	                 /// Address-Write
                     output reg        s_axi_awvalid_0,
	             input 	       s_axi_awready_0,
	             output reg [31:0] s_axi_awaddr_0,
                     /// Data-Write
	             output reg        s_axi_wvalid_0,
	             input 	       s_axi_wready_0,
	             output reg [31:0] s_axi_wdata_0,
	             output reg [ 3:0] s_axi_wstrb_0,
                     /// Write-Response
	             input 	       s_axi_bvalid_0,
	             output reg        s_axi_bready_0,
                     /// Address-Read
	             output reg        s_axi_arvalid_0,
	             input 	       s_axi_arready_0,
	             output reg [31:0] s_axi_araddr_0,
                     /// Data-Read
	             input 	       s_axi_rvalid_0,
	             output reg        s_axi_rready_0,
	             input [31:0]      s_axi_rdata_0,

	                 ///////////////////////////////////
	                 //// slave 1 AXI interface ///////
	                 /////////////////////////////////  
//	                 output            s_clk_1,
//	                 output            s_resetn_1,
	                 /// Address-Write 
                     output reg        s_axi_awvalid_1,
	             input 	       s_axi_awready_1,
	             output reg [31:0] s_axi_awaddr_1,
                     /// Data-Write
	             output reg        s_axi_wvalid_1,
	             input 	       s_axi_wready_1,
	             output reg [31:0] s_axi_wdata_1,
	             output reg [ 3:0] s_axi_wstrb_1,
                     /// Write-Response
	             input 	       s_axi_bvalid_1,
	             output reg        s_axi_bready_1,
                     /// Address-Read
	             output reg        s_axi_arvalid_1,
	             input 	       s_axi_arready_1,
	             output reg [31:0] s_axi_araddr_1,
                     /// Data-Read
	             input 	       s_axi_rvalid_1,
	             output reg        s_axi_rready_1,
	             input [31:0]      s_axi_rdata_1,
	               
	                 ///////////////////////////////////
	                 //// slave 2 AXI interface ///////
	                 /////////////////////////////////  
//	                 output            s_clk_2,
//	                 output            s_resetn_2,
	                 /// Address-Write
                     output reg        s_axi_awvalid_2,
	             input 	       s_axi_awready_2,
	             output reg [31:0] s_axi_awaddr_2,
                     /// Data-Write
	             output reg        s_axi_wvalid_2,
	             input 	       s_axi_wready_2,
	             output reg [31:0] s_axi_wdata_2,
	             output reg [ 3:0] s_axi_wstrb_2,
                     /// Write-Response
	             input 	       s_axi_bvalid_2,
	             output reg        s_axi_bready_2,
                     /// Address-Read
	             output reg        s_axi_arvalid_2,
	             input 	       s_axi_arready_2,
	             output reg [31:0] s_axi_araddr_2,
                     /// Data-Read
	             input 	       s_axi_rvalid_2,
	             output reg        s_axi_rready_2,
	             input [31:0]      s_axi_rdata_2,
	                 
	                 ///////////////////////////////////
	                 //// slave 3 AXI interface ///////
	                 ///////////////////////////////// 
//	                 output            s_clk_3,
//	                 output            s_resetn_3,
	                 /// Address-Write 
                     output reg        s_axi_awvalid_3,
	             input 	       s_axi_awready_3,
	             output reg [31:0] s_axi_awaddr_3,
                     /// Data-Write
	             output reg        s_axi_wvalid_3,
	             input 	       s_axi_wready_3,
	             output reg [31:0] s_axi_wdata_3,
	             output reg [3:0]  s_axi_wstrb_3,
                     /// Write-Response
	             input 	       s_axi_bvalid_3,
	             output reg        s_axi_bready_3,
                     /// Address-Read
	             output reg        s_axi_arvalid_3,
	             input 	       s_axi_arready_3,
	             output reg [31:0] s_axi_araddr_3,
                     /// Data-Read
	             input 	       s_axi_rvalid_3,
	             output reg        s_axi_rready_3,
	             input [31:0]      s_axi_rdata_3                  	                   
                        );


wire [1:0] s_sel;
assign slave_select = s_sel;



    iob_memory_mapped_decoder mm_dec (
                            .mem_addr (m_axi_awaddr),
                            .s_sel    (s_sel       )
                        );

//// Clock and Reset
//assign s_clk_0    = m_clk;
//assign s_clk_1    = m_clk;
//assign s_clk_2    = m_clk;
//assign s_clk_3    = m_clk;
//assign s_resetn_0 = m_resetn;
//assign s_resetn_1 = m_resetn;
//assign s_resetn_2 = m_resetn;
//assign s_resetn_3 = m_resetn;

//// Address-Write
//assign s_axi_awaddr_0 = m_axi_awaddr;     
//assign s_axi_awaddr_1 = m_axi_awaddr;
//assign s_axi_awaddr_2 = m_axi_awaddr;
//assign s_axi_awaddr_3 = m_axi_awaddr;      
//// Data-Write
//assign s_axi_wdata_0 = m_axi_wdata;     
//assign s_axi_wdata_1 = m_axi_wdata;
//assign s_axi_wdata_2 = m_axi_wdata;
//assign s_axi_wdata_3 = m_axi_wdata;   
//// Address-Read
//assign s_axi_araddr_0 = m_axi_araddr;     
//assign s_axi_araddr_1 = m_axi_araddr;
//assign s_axi_araddr_2 = m_axi_araddr;   
//assign s_axi_araddr_3 = m_axi_araddr;  
 
    
                                
always @*
    begin: IOBundle_AXI_interconnect
        case (s_sel)
            default: begin
	       if (mem_select == 0) begin
                        // Address-Write ////////////////////
                        s_axi_awvalid_0 <= m_axi_awvalid;
                        s_axi_awvalid_1 <= 1'b0;
                        s_axi_awvalid_2 <= 1'b0;
                        s_axi_awvalid_3 <= 1'b0;
                        m_axi_awready   <= s_axi_awready_0;
                        s_axi_awaddr_0  <= m_axi_awaddr;
                        s_axi_awaddr_1  <= 32'd0;
                        s_axi_awaddr_2  <= 32'd0;
                        s_axi_awaddr_3  <= 32'd0;
                        
                        // Data-Write //////////////////////
                        s_axi_wvalid_0  <= m_axi_wvalid;
                        s_axi_wvalid_1  <= 1'b0;
                        s_axi_wvalid_2  <= 1'b0;
                        s_axi_wvalid_3  <= 1'b0;
                        m_axi_wready    <= s_axi_wready_0;
                        s_axi_wstrb_0   <= m_axi_wstrb;
                        s_axi_wstrb_1   <= 3'b000;
                        s_axi_wstrb_2   <= 3'b000; 
                        s_axi_wstrb_3   <= 3'b000; 
                        s_axi_wdata_0   <= m_axi_wdata;
                        s_axi_wdata_1   <= 32'd0;
                        s_axi_wdata_2   <= 32'd0;
                        s_axi_wdata_3   <= 32'd0;
                                                
                        // Write-Response //////////////////
                        m_axi_bvalid    <= s_axi_bvalid_0;
                        s_axi_bready_0  <= m_axi_bready;
                        s_axi_bready_1  <= 1'b0;
                        s_axi_bready_2  <= 1'b0;
                        s_axi_bready_3  <= 1'b0;   
                        
                        // Address-Read ////////////////////
                        s_axi_arvalid_0 <= m_axi_arvalid;
                        s_axi_arvalid_1 <= 1'b0;
                        s_axi_arvalid_2 <= 1'b0;
                        s_axi_arvalid_3 <= 1'b0;
                        m_axi_arready   <= s_axi_arready_0;
                        s_axi_araddr_0  <= m_axi_araddr;
                        s_axi_araddr_1  <= 32'd0;
                        s_axi_araddr_2  <= 32'd0;
                        s_axi_araddr_3  <= 32'd0;
                        
                        // Data-Read ///////////////////////
                        s_axi_rready_0  <= m_axi_rready;
                        s_axi_rready_1  <= 1'b0;
                        s_axi_rready_2  <= 1'b0;
                        s_axi_rready_3  <= 1'b0;
                        m_axi_rvalid    <= s_axi_rvalid_0;
                        m_axi_rdata     <= s_axi_rdata_0;
               end else begin // if (mem_select == 0)
		    // Address-Write ////////////////////
                        s_axi_awvalid_0 <= 1'b0;
                        s_axi_awvalid_1 <= m_axi_awvalid;
                        s_axi_awvalid_2 <= 1'b0;
                        s_axi_awvalid_3 <= 1'b0;
                        m_axi_awready   <= s_axi_awready_1;
                        s_axi_awaddr_0  <= 32'd0;
                        s_axi_awaddr_1  <= m_axi_awaddr;
                        s_axi_awaddr_2  <= 32'd0;
                        s_axi_awaddr_3  <= 32'd0;
                        
                        // Data-Write //////////////////////
                        s_axi_wvalid_0  <= 1'b0;
                        s_axi_wvalid_1  <= m_axi_wvalid;
                        s_axi_wvalid_2  <= 1'b0;
                        s_axi_wvalid_3  <= 1'b0;
                        m_axi_wready    <= s_axi_wready_1;
                        s_axi_wstrb_0   <= 3'b000;
                        s_axi_wstrb_1   <= m_axi_wstrb;
                        s_axi_wstrb_2   <= 3'b000; 
                        s_axi_wstrb_3   <= 3'b000;
                        s_axi_wdata_0   <= 32'd0;
                        s_axi_wdata_1   <= m_axi_wdata;
                        s_axi_wdata_2   <= 32'd0;
                        s_axi_wdata_3   <= 32'd0;
                        
                        // Write-Response //////////////////
                        m_axi_bvalid    <= s_axi_bvalid_1;
                        s_axi_bready_0  <= 1'b0;
                        s_axi_bready_1  <= m_axi_bready;
                        s_axi_bready_2  <= 1'b0; 
                        s_axi_bready_3  <= 1'b0; 
                        
                        // Address-Read ////////////////////
                        s_axi_arvalid_0 <= 1'b0;
                        s_axi_arvalid_1 <= m_axi_arvalid;
                        s_axi_arvalid_2 <= 1'b0;
                        s_axi_arvalid_3 <= 1'b0;
                        m_axi_arready   <= s_axi_arready_1;
                        s_axi_araddr_0  <= 32'd0;
                        s_axi_araddr_1  <= m_axi_araddr;
                        s_axi_araddr_2  <= 32'd0;
                        s_axi_araddr_3  <= 32'd0;
                                               
                        // Data-Read ///////////////////////
                        s_axi_rready_0  <= 1'b0;
                        s_axi_rready_1  <= m_axi_rready;
                        s_axi_rready_2  <= 1'b0;
                        s_axi_rready_3  <= 1'b0;
                        m_axi_rvalid    <= s_axi_rvalid_1;
                        m_axi_rdata     <= s_axi_rdata_1;                         
               end // else: !if(mem_select == 0)

	    end // case: default
	  
            2'b01: begin
	        if (mem_select == 0) begin
                        // Address-Write ////////////////////
                        s_axi_awvalid_0 <= 1'b0;
                        s_axi_awvalid_1 <= m_axi_awvalid;
                        s_axi_awvalid_2 <= 1'b0;
                        s_axi_awvalid_3 <= 1'b0;
                        m_axi_awready   <= s_axi_awready_1;
                        s_axi_awaddr_0  <= 32'd0;
                        s_axi_awaddr_1  <= m_axi_awaddr;
                        s_axi_awaddr_2  <= 32'd0;
                        s_axi_awaddr_3  <= 32'd0;
                        
                        // Data-Write //////////////////////
                        s_axi_wvalid_0  <= 1'b0;
                        s_axi_wvalid_1  <= m_axi_wvalid;
                        s_axi_wvalid_2  <= 1'b0;
                        s_axi_wvalid_3  <= 1'b0;
                        m_axi_wready    <= s_axi_wready_1;
                        s_axi_wstrb_0   <= 3'b000;
                        s_axi_wstrb_1   <= m_axi_wstrb;
                        s_axi_wstrb_2   <= 3'b000; 
                        s_axi_wstrb_3   <= 3'b000;
                        s_axi_wdata_0   <= 32'd0;
                        s_axi_wdata_1   <= m_axi_wdata;
                        s_axi_wdata_2   <= 32'd0;
                        s_axi_wdata_3   <= 32'd0;
                        
                        // Write-Response //////////////////
                        m_axi_bvalid    <= s_axi_bvalid_1;
                        s_axi_bready_0  <= 1'b0;
                        s_axi_bready_1  <= m_axi_bready;
                        s_axi_bready_2  <= 1'b0; 
                        s_axi_bready_3  <= 1'b0; 
                        
                        // Address-Read ////////////////////
                        s_axi_arvalid_0 <= 1'b0;
                        s_axi_arvalid_1 <= m_axi_arvalid;
                        s_axi_arvalid_2 <= 1'b0;
                        s_axi_arvalid_3 <= 1'b0;
                        m_axi_arready   <= s_axi_arready_1;
                        s_axi_araddr_0  <= 32'd0;
                        s_axi_araddr_1  <= m_axi_araddr;
                        s_axi_araddr_2  <= 32'd0;
                        s_axi_araddr_3  <= 32'd0;
                                               
                        // Data-Read ///////////////////////
                        s_axi_rready_0  <= 1'b0;
                        s_axi_rready_1  <= m_axi_rready;
                        s_axi_rready_2  <= 1'b0;
                        s_axi_rready_3  <= 1'b0;
                        m_axi_rvalid    <= s_axi_rvalid_1;
                        m_axi_rdata     <= s_axi_rdata_1;                         
                end // if (mem_select == 0)
		else begin
		                           // Address-Write ////////////////////
                        s_axi_awvalid_0 <= m_axi_awvalid;
                        s_axi_awvalid_1 <= 1'b0;
                        s_axi_awvalid_2 <= 1'b0;
                        s_axi_awvalid_3 <= 1'b0;
                        m_axi_awready   <= s_axi_awready_0;
                        s_axi_awaddr_0  <= m_axi_awaddr;
                        s_axi_awaddr_1  <= 32'd0;
                        s_axi_awaddr_2  <= 32'd0;
                        s_axi_awaddr_3  <= 32'd0;
                        
                        // Data-Write //////////////////////
                        s_axi_wvalid_0  <= m_axi_wvalid;
                        s_axi_wvalid_1  <= 1'b0;
                        s_axi_wvalid_2  <= 1'b0;
                        s_axi_wvalid_3  <= 1'b0;
                        m_axi_wready    <= s_axi_wready_0;
                        s_axi_wstrb_0   <= m_axi_wstrb;
                        s_axi_wstrb_1   <= 3'b000;
                        s_axi_wstrb_2   <= 3'b000; 
                        s_axi_wstrb_3   <= 3'b000; 
                        s_axi_wdata_0   <= m_axi_wdata;
                        s_axi_wdata_1   <= 32'd0;
                        s_axi_wdata_2   <= 32'd0;
                        s_axi_wdata_3   <= 32'd0;
                                                
                        // Write-Response //////////////////
                        m_axi_bvalid    <= s_axi_bvalid_0;
                        s_axi_bready_0  <= m_axi_bready;
                        s_axi_bready_1  <= 1'b0;
                        s_axi_bready_2  <= 1'b0;
                        s_axi_bready_3  <= 1'b0;   
                        
                        // Address-Read ////////////////////
                        s_axi_arvalid_0 <= m_axi_arvalid;
                        s_axi_arvalid_1 <= 1'b0;
                        s_axi_arvalid_2 <= 1'b0;
                        s_axi_arvalid_3 <= 1'b0;
                        m_axi_arready   <= s_axi_arready_0;
                        s_axi_araddr_0  <= m_axi_araddr;
                        s_axi_araddr_1  <= 32'd0;
                        s_axi_araddr_2  <= 32'd0;
                        s_axi_araddr_3  <= 32'd0;
                        
                        // Data-Read ///////////////////////
                        s_axi_rready_0  <= m_axi_rready;
                        s_axi_rready_1  <= 1'b0;
                        s_axi_rready_2  <= 1'b0;
                        s_axi_rready_3  <= 1'b0;
                        m_axi_rvalid    <= s_axi_rvalid_0;
                        m_axi_rdata     <= s_axi_rdata_0;
		end // else: !if(mem_select == 0)
	    end // case: 2'b01
	  

            2'b10: begin
                        // Address-Write ////////////////////
                        s_axi_awvalid_0 <= 1'b0;
                        s_axi_awvalid_1 <= 1'b0;
                        s_axi_awvalid_2 <= m_axi_awvalid;
                        s_axi_awvalid_3 <= 1'b0;
                        m_axi_awready   <= s_axi_awready_2;
                        s_axi_awaddr_0  <= 32'd0;
                        s_axi_awaddr_1  <= 32'd0;
                        s_axi_awaddr_2  <= m_axi_awaddr;
                        s_axi_awaddr_3  <= 32'd0;
                        
                        // Data-Write //////////////////////
                        s_axi_wvalid_0  <= 1'b0;
                        s_axi_wvalid_1  <= 1'b0;
                        s_axi_wvalid_2  <= m_axi_wvalid;
                        s_axi_wvalid_3  <= 1'b0;
                        m_axi_wready    <= s_axi_wready_2;
                        s_axi_wstrb_0   <= 3'b000;
                        s_axi_wstrb_1   <= 3'b000;
                        s_axi_wstrb_2   <= m_axi_wstrb;
                        s_axi_wstrb_3   <= 3'b000;
                        s_axi_wdata_0   <= 32'd0;
                        s_axi_wdata_1   <= 32'd0;
                        s_axi_wdata_2   <= m_axi_wdata;
                        s_axi_wdata_3   <= 32'd0;
                        
                        // Write-Response //////////////////
                        m_axi_bvalid    <= s_axi_bvalid_2;
                        s_axi_bready_0  <= 1'b0;
                        s_axi_bready_1  <= 1'b0;
                        s_axi_bready_2  <= m_axi_bready;
                        s_axi_bready_3  <= 1'b0;  
                        
                        // Address-Read ////////////////////
                        s_axi_arvalid_0 <= 1'b0;
                        s_axi_arvalid_1 <= 1'b0;
                        s_axi_arvalid_2 <= m_axi_arvalid;
                        s_axi_arvalid_3 <= 1'b0;
                        m_axi_arready   <= s_axi_arready_2;
                        s_axi_araddr_0  <= 32'd0;
                        s_axi_araddr_1  <= 32'd0;
                        s_axi_araddr_2  <= m_axi_araddr;
                        s_axi_araddr_3  <= 32'd0;
                        
                        // Data-Read ///////////////////////
                        s_axi_rready_0  <= 1'b0;
                        s_axi_rready_1  <= 1'b0;
                        s_axi_rready_2  <= m_axi_rready;
                        s_axi_rready_3  <= 1'b0;
                        m_axi_rvalid    <= s_axi_rvalid_2;
                        m_axi_rdata     <= s_axi_rdata_2;                    
                    end
                    
            2'b11: begin
                        // Address-Write ////////////////////
                        s_axi_awvalid_0 <= 1'b0;
                        s_axi_awvalid_1 <= 1'b0;
                        s_axi_awvalid_2 <= 1'b0;
                        s_axi_awvalid_3 <= m_axi_awvalid;
                        m_axi_awready   <= s_axi_awready_3;
                        s_axi_awaddr_0  <= 32'd0;
                        s_axi_awaddr_1  <= 32'd0;
                        s_axi_awaddr_2  <= 32'd0;
                        s_axi_awaddr_3  <= m_axi_awaddr;
                        
                        // Data-Write //////////////////////
                        s_axi_wvalid_0  <= 1'b0;
                        s_axi_wvalid_1  <= 1'b0;
                        s_axi_wvalid_2  <= 1'b0;
                        s_axi_wvalid_3  <= m_axi_wvalid;
                        m_axi_wready    <= s_axi_wready_3;
                        s_axi_wstrb_0   <= 3'b000;
                        s_axi_wstrb_1   <= 3'b000;
                        s_axi_wstrb_2   <= 3'b000;  
                        s_axi_wstrb_3   <= m_axi_wstrb;
                        s_axi_wdata_0   <= 32'd0;
                        s_axi_wdata_1   <= 32'd0;
                        s_axi_wdata_2   <= 32'd0;
                        s_axi_wdata_3   <= m_axi_wdata;
                        
                        // Write-Response //////////////////
                        m_axi_bvalid    <= s_axi_bvalid_3;
                        s_axi_bready_0  <= 1'b0;
                        s_axi_bready_1  <= 1'b0;
                        s_axi_bready_2  <= 1'b0;   
                        s_axi_bready_3  <= m_axi_bready;
                        
                        // Address-Read ////////////////////
                        s_axi_arvalid_0 <= 1'b0;
                        s_axi_arvalid_1 <= 1'b0;
                        s_axi_arvalid_2 <= 1'b0;
                        s_axi_arvalid_3 <= m_axi_arvalid;
                        m_axi_arready   <= s_axi_arready_3;
                        s_axi_araddr_0  <= 32'd0;
                        s_axi_araddr_1  <= 32'd0;
                        s_axi_araddr_2  <= 32'd0;
                        s_axi_araddr_3  <= m_axi_araddr;
                        
                        // Data-Read ///////////////////////
                        s_axi_rready_0  <= 1'b0;
                        s_axi_rready_1  <= 1'b0;
                        s_axi_rready_2  <= 1'b0;
                        s_axi_rready_3  <= m_axi_rready;
                        m_axi_rvalid    <= s_axi_rvalid_3;
                        m_axi_rdata     <= s_axi_rdata_3; 
                    end
                    
                    
        endcase
    end                       
                   
endmodule


module iob_memory_mapped_decoder(
                    input      [31:0] mem_addr,
                    output reg  [1:0] s_sel
                );
                
    //`include "memory_mapped_par.vh"   
    
    
    always @* begin
                  
           if(mem_addr < 32'h40000000)  // slave_0
        begin
            s_sel <= 2'b00;
        end 
    else if(mem_addr < 32'h80000000) // slave_2 and 3
        begin  
            if (mem_addr ==  32'h70000000 || mem_addr ==  32'h70000004 || mem_addr ==  32'h70000008 || mem_addr ==  32'h7000000C  ) s_sel <= 2'b10;
            else s_sel <= 2'b11;
        end         
    else /*if( (mem_addr>>2) < 2**MEM_ADDR_PAR_3)*/ // slave_1
        begin  
            s_sel <= 2'b01; //DDR, starts at 0x80000000 and ends at  0xBFFFFFFC (0xC0000000-0x4) (1 GB)
        end              
end       
                 
               
                
endmodule
