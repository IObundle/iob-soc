`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2019 02:26:25 PM
// Design Name: 
// Module Name: iob_axi_simpleuart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple UART with AXI-Lite slave interface
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module iob_axi_simpleuart(
                     // Serial i/f
                     output            ser_tx,
                     input             ser_rx,
                     // AXI Data Bus      
                     input             clk,
                     input             uart_resetn, 
                     /// Address-Write
    	             input             uart_axi_awvalid,
	                 output reg        uart_axi_awready,
	                 input  [31:0]     uart_axi_awaddr,
                     /// Data-Write
	                 input             uart_axi_wvalid,
	                 output reg        uart_axi_wready,
	                 input  [31:0]     uart_axi_wdata,
	                 input  [ 3:0]     uart_axi_wstrb,
                     /// Write-Response
	                 output  reg       uart_axi_bvalid,
	                 input             uart_axi_bready,
                     /// Address-Read
	                 input             uart_axi_arvalid,
	                 output reg        uart_axi_arready,
	                 input  [31:0]     uart_axi_araddr,
                     /// Data-Read
	                 output reg        uart_axi_rvalid,
	                 input             uart_axi_rready,
	                 output [31:0]     uart_axi_rdata

    );
    
    	    
	        always @(posedge clk, negedge uart_resetn)
                if(~uart_resetn) begin 
                    uart_axi_awready <= 1'b0;
                    uart_axi_wready  <= 1'b0;
                    uart_axi_bvalid  <= 1'b0;
                    uart_axi_arready <= 1'b0;
                    uart_axi_rvalid  <= 1'b0;
                end else begin 
                    uart_axi_awready <= (|uart_axi_wstrb)|uart_axi_arvalid;
                    uart_axi_wready  <= (|uart_axi_wstrb)|uart_axi_arvalid;
                    uart_axi_bvalid  <= (|uart_axi_wstrb)|uart_axi_arvalid;
                    uart_axi_arready <= (|uart_axi_wstrb)|uart_axi_arvalid;
                    uart_axi_rvalid  <= (|uart_axi_wstrb)|uart_axi_arvalid;
                end   
                               
///////////////////////////////////// 
////// Simple UART /////////////////
///////////////////////////////////	                   
   simpleuart simpleuart (
                   //serial i/f
		           .ser_tx (ser_tx),
		           .ser_rx (ser_rx),
                   //data bus
		           .clk     (clk                 ),
		           .resetn  (uart_resetn         ),
                   .address (uart_axi_araddr[3:2]),
	               .sel     (uart_axi_wvalid     ),	
	               .we      (|uart_axi_wstrb     ),
		           .dat_di  (uart_axi_wdata      ),
		           .dat_do  (uart_axi_rdata      )
	                   );
 ///////////////////////////////////
///////////////////////////////////	                         
	       
endmodule
