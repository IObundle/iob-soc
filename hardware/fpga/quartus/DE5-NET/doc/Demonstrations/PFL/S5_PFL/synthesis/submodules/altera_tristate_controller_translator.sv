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



// $Id$
// $Revision$
// $Date$
// $Author$

`timescale 1 ns / 1 ns

module altera_tristate_controller_translator 
#(
    parameter 
        UAV_DATA_W              = 32,
        UAV_BYTEENABLE_W        = 4,
        UAV_ADDRESS_W           = 32,
        UAV_BURSTCOUNT_W        = 4,
        TURNAROUND_TIME_CYCLES  = 0,
        READLATENCY_CYCLES      = 0,
        ZERO_READ_DELAY         = 0,
        ZERO_WRITE_DELAY        = 0
) 
(
    // Universal Slave
    input  wire [(UAV_ADDRESS_W    ? UAV_ADDRESS_W    - 1 : 0) : 0] s0_uav_address,
    input  wire [(UAV_BURSTCOUNT_W ? UAV_BURSTCOUNT_W - 1 : 0) : 0] s0_uav_burstcount,
    input  wire                                                     s0_uav_read,
    input  wire                                                     s0_uav_write,
    output wire                                                     s0_uav_waitrequest,
    output wire                                                     s0_uav_readdatavalid,
    input  wire [(UAV_BYTEENABLE_W ? UAV_BYTEENABLE_W - 1 : 0) :0]  s0_uav_byteenable,
    output wire [(UAV_DATA_W       ? UAV_DATA_W       - 1 : 0) :0]  s0_uav_readdata,
    input  wire [(UAV_DATA_W       ? UAV_DATA_W       - 1 : 0) :0]  s0_uav_writedata,
    input  wire                                                     s0_uav_lock,
    input  wire                                                     s0_uav_debugaccess,

    // Universal Master
    output wire [(UAV_ADDRESS_W    ? UAV_ADDRESS_W    - 1 : 0) : 0] m0_uav_address,
    output wire [(UAV_BURSTCOUNT_W ? UAV_BURSTCOUNT_W - 1 : 0) : 0] m0_uav_burstcount,
    output wire                                                     m0_uav_read,
    output wire                                                     m0_uav_write,
    input  wire                                                     m0_uav_waitrequest,
    input  wire                                                     m0_uav_readdatavalid,
    output wire [(UAV_BYTEENABLE_W ? UAV_BYTEENABLE_W - 1 : 0) :0]  m0_uav_byteenable,
    input  wire [(UAV_DATA_W       ? UAV_DATA_W       - 1 : 0) :0]  m0_uav_readdata,
    output wire [(UAV_DATA_W       ? UAV_DATA_W       - 1 : 0) :0]  m0_uav_writedata,
    output wire                                                     m0_uav_lock,
    output wire                                                     m0_uav_debugaccess,

    // Conduit Interface
    output wire                                                     c0_request,
    input  wire                                                     c0_grant,
    output wire                                                     c0_uav_write,

    input wire clk,
    input wire reset

);
   
    localparam TRUE_TURNAROUND_TIME_CYCLES = TURNAROUND_TIME_CYCLES + READLATENCY_CYCLES;
   
    function integer clog2;
        input [31:0] Depth;
        integer i;
        begin
            i = Depth;        
            for(clog2 = 0; i > 0; clog2 = clog2 + 1)
                i = i >> 1;
        end
    endfunction 

    reg [clog2(TRUE_TURNAROUND_TIME_CYCLES) - 1 : 0] turnaround_counter;
    
        
    assign m0_uav_address       [(UAV_ADDRESS_W ? UAV_ADDRESS_W - 1 : 0) : 0 ]       = s0_uav_address[(UAV_ADDRESS_W ? UAV_ADDRESS_W - 1 : 0) : 0 ];
    assign m0_uav_burstcount    [(UAV_BURSTCOUNT_W ? UAV_BURSTCOUNT_W - 1 : 0) : 0 ] = s0_uav_burstcount[(UAV_BURSTCOUNT_W ? UAV_BURSTCOUNT_W - 1 : 0) : 0 ];
    assign m0_uav_read                                                               = s0_uav_read & c0_grant;
    assign m0_uav_write                                                              = ( s0_uav_write && turnaround_counter == 0 ) && c0_grant;
    assign s0_uav_waitrequest                                                        = m0_uav_waitrequest | ~c0_grant | (turnaround_counter != 0 && s0_uav_write);
    assign s0_uav_readdatavalid                                                      = m0_uav_readdatavalid;
    assign m0_uav_byteenable    [(UAV_BYTEENABLE_W ? UAV_BYTEENABLE_W - 1 : 0) : 0 ] = s0_uav_byteenable[(UAV_BYTEENABLE_W ? UAV_BYTEENABLE_W - 1 : 0) : 0 ];
    assign s0_uav_readdata      [(UAV_DATA_W ? UAV_DATA_W - 1 : 0) : 0 ]             = m0_uav_readdata[(UAV_DATA_W ? UAV_DATA_W - 1 : 0) : 0 ];
    assign m0_uav_writedata     [(UAV_DATA_W ? UAV_DATA_W - 1 : 0) : 0 ]             = s0_uav_writedata[(UAV_DATA_W ? UAV_DATA_W - 1 : 0) : 0 ];
    assign m0_uav_lock                                                               = s0_uav_lock;
    
    assign c0_uav_write                                                              = ( s0_uav_write && turnaround_counter == 0);
    assign m0_uav_debugaccess                                                        = 0;
   
   
    generate
       
        if (ZERO_WRITE_DELAY == 0 && ZERO_READ_DELAY == 0)
            assign c0_request           = turnaround_counter != 0 || ( ( s0_uav_read | s0_uav_write ) & m0_uav_waitrequest );
        else if (ZERO_WRITE_DELAY == 0)
            assign c0_request           = turnaround_counter != 0 || s0_uav_read || ( s0_uav_write & m0_uav_waitrequest) ;
        else if (ZERO_READ_DELAY == 0)
            assign c0_request           = turnaround_counter != 0 || ( s0_uav_read & m0_uav_waitrequest) || s0_uav_write ;
        else
            assign c0_request           = turnaround_counter != 0 || s0_uav_read || s0_uav_write;
         
    endgenerate
   
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            turnaround_counter <= '0;
        end
        else begin
 
            turnaround_counter <= 0;
       
            if (turnaround_counter != 0) begin
                turnaround_counter <= turnaround_counter - 1'h1;
            end
       
            if (s0_uav_read) begin
                turnaround_counter <= TRUE_TURNAROUND_TIME_CYCLES;
            end
        end
    end
   

endmodule // altera_tristate_driver_translator

   
