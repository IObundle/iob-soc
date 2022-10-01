// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// $Id: //acds/rel/16.1/ip/merlin/altera_tristate_controller_aggregator/altera_tristate_controller_aggregator.sv#1 $
// $Revision: #1 $
// $Date: 2016/08/07 $
// $Author: swbranch $

`timescale 1 ns / 1 ns

module altera_tristate_controller_aggregator#(
					  parameter 
					  AV_ADDRESS_W               = 32,
					  AV_DATA_W                  = 32,
					  AV_BYTEENABLE_W            = 4
					      
					  ) (
					     //Declare Avalon Slave
					     input  wire [(AV_ADDRESS_W    ? AV_ADDRESS_W    - 1 : 0) : 0]  av_address,
                                             input  wire                                                    av_read,
					     input  wire                                                    av_write,
					     input  wire [(AV_BYTEENABLE_W ? AV_BYTEENABLE_W - 1 : 0) :0]   av_byteenable,
					     input  wire [(AV_BYTEENABLE_W ? AV_BYTEENABLE_W  - 1 : 0) :0]  av_writebyteenable,
					     output wire [(AV_DATA_W       ? AV_DATA_W       - 1 : 0) :0]   av_readdata,
					     input  wire [(AV_DATA_W       ? AV_DATA_W       - 1 : 0) :0]   av_writedata,
					     input  wire                                                    av_lock,
					     input  wire                                                    av_chipselect,
					     input  wire                                                    av_outputenable,
					     output wire                                                    av_waitrequest,
					     input  wire                                                    av_begintransfer,
					    				     
					     //Declare Tristate Conduit Master
                                             output wire                                                     tcm0_request,
           				     input  wire                                                     tcm0_grant,
					     output wire [(AV_ADDRESS_W    ? AV_ADDRESS_W      - 1 : 0) :0]  tcm0_address,
                                             output wire                                                     tcm0_read,
					     output wire                                                     tcm0_read_n,
					     output wire                                                     tcm0_write,
					     output wire                                                     tcm0_write_n,
					     output wire                                                     tcm0_begintransfer,
					     output wire                                                     tcm0_begintransfer_n,
					     output wire [(AV_BYTEENABLE_W ? AV_BYTEENABLE_W   - 1 : 0) :0]  tcm0_byteenable,
					     output wire [(AV_BYTEENABLE_W ? AV_BYTEENABLE_W   - 1 : 0) :0]  tcm0_byteenable_n,
					     output wire [(AV_DATA_W       ? AV_DATA_W         - 1 : 0) :0]  tcm0_writedata,
					     input  wire [(AV_DATA_W       ? AV_DATA_W         - 1 : 0) :0]  tcm0_readdata,
					     output wire                                                     tcm0_data_outen,
					     output wire [(AV_BYTEENABLE_W  ? AV_BYTEENABLE_W  - 1 : 0) :0]  tcm0_writebyteenable,
					     output wire [(AV_BYTEENABLE_W  ? AV_BYTEENABLE_W  - 1 : 0) :0]  tcm0_writebyteenable_n,
					     output wire                                                     tcm0_outputenable,
					     output wire                                                     tcm0_outputenable_n,
					     output wire                                                     tcm0_chipselect,
					     output wire                                                     tcm0_chipselect_n,
					     input  wire                                                     tcm0_waitrequest,
					     input  wire                                                     tcm0_waitrequest_n,
					     output wire                                                     tcm0_lock,
					     output wire                                                     tcm0_lock_n,
					     input wire                                                      tcm0_resetrequest,
					     input wire                                                      tcm0_resetrequest_n,
					     input wire                                                      tcm0_irq_in,
					     input wire                                                      tcm0_irq_in_n,
					     output wire                                                     tcm0_reset_output,
					     output wire                                                     tcm0_reset_output_n,
					     
					     //Declare Internal Conduit Interface
					     input  wire                                                     c0_request,
					     output wire                                                     c0_grant,
                                             input  wire                           			     c0_uav_write,
					     
					     //Declare IRQ Interface
                                             output wire						     irq_out,

					     //Declare Reset Interface
					     output wire                                                     reset_out,

					     //Declare Clock Interface
					     input  wire                                                     clk,
                                             input  wire	                    			     reset
					     );

   
   wire[(AV_BYTEENABLE_W ? AV_BYTEENABLE_W - 1 : 0) : 0 ] tcm0_writebyteenable_pre;
   wire[(AV_BYTEENABLE_W ? AV_BYTEENABLE_W - 1 : 0) : 0 ] tcm0_byteenable_pre;


   //Reset Output
   assign  tcm0_reset_output = reset;
   
   //Conduit Interface Assignments
   assign  c0_grant     = tcm0_grant;
   assign  tcm0_request = c0_request;   

   //Tristate Conduit Master Interface Assignments
   assign tcm0_address          [(AV_ADDRESS_W ? AV_ADDRESS_W - 1 : 0) : 0 ]         = av_address[(AV_ADDRESS_W ? AV_ADDRESS_W - 1 : 0) : 0 ];
   assign tcm0_read                                                                  = av_read;
   assign tcm0_write                                                                 = av_write;
   assign tcm0_byteenable       [(AV_BYTEENABLE_W ? AV_BYTEENABLE_W - 1 : 0) : 0 ]   = av_byteenable[(AV_BYTEENABLE_W ? AV_BYTEENABLE_W - 1 : 0) : 0 ];
   assign tcm0_writebyteenable  [(AV_BYTEENABLE_W ? AV_BYTEENABLE_W - 1 : 0) : 0 ]   = av_writebyteenable[(AV_BYTEENABLE_W ? AV_BYTEENABLE_W - 1 : 0) : 0 ];
   assign tcm0_writedata        [(AV_DATA_W ? AV_DATA_W - 1 : 0) : 0 ]               = av_writedata[(AV_DATA_W ? AV_DATA_W - 1 : 0) : 0 ];   
   assign tcm0_lock                                                           = av_lock;
   assign tcm0_chipselect                                                            = av_chipselect;
   assign tcm0_outputenable                                                          = av_outputenable;
   assign tcm0_data_outen                                                            = c0_uav_write;
   assign tcm0_begintransfer                                                         = av_begintransfer;
   

      //Negation Assignments
   
   assign tcm0_read_n                                                                =  ~av_read;   
   assign tcm0_write_n                                                               =  ~av_write;
   assign tcm0_chipselect_n                                                          =  ~av_chipselect;
   assign tcm0_byteenable_n                                                          =  ~av_byteenable;
   assign tcm0_outputenable_n                                                        =  ~av_outputenable;
   assign tcm0_writebyteenable_n                                                     =  ~av_writebyteenable;
   assign tcm0_begintransfer_n                                                       =  ~av_begintransfer;
   assign tcm0_lock_n                                                         =  ~av_lock;
   assign tcm0_reset_output_n                                                        =  ~reset;
   
   //Reset and IRQ Inputs
   assign reset_out                                                                  = tcm0_resetrequest | ~tcm0_resetrequest_n;
   assign irq_out                                                                    = tcm0_irq_in       | ~tcm0_irq_in_n;
   
   //Avalon MM Slave Interface Assignment
   assign av_readdata        [(AV_DATA_W ? AV_DATA_W - 1 : 0) : 0 ]                  = tcm0_readdata[(AV_DATA_W ? AV_DATA_W - 1 : 0) : 0 ];
   assign av_waitrequest                                                             = tcm0_waitrequest  | ~tcm0_waitrequest_n;
   

   
endmodule

   
