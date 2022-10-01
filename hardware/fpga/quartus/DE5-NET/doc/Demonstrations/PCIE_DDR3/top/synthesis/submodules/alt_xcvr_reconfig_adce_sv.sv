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


// Top level ADCE file for Stratix V
// data will flow like
// User <=> UIF <=> DATA_CTRL <=> CIF <=> RECONFIG BASIC
//
// $Header: //acds/rel/16.1/ip/alt_xcvr_reconfig/alt_xcvr_reconfig_adce/alt_xcvr_reconfig_adce_sv.sv#1 $

`timescale 1 ns / 1 ps


module alt_xcvr_reconfig_adce_sv
#( 
   parameter number_of_reconfig_interfaces    =  1,
   parameter logic [number_of_reconfig_interfaces-1:0] AUTO_START = { number_of_reconfig_interfaces { 1'b0 } },
   parameter RECONFIG_BASIC_OFFSET_ADDR_WIDTH = 12
   )
   (
    input  wire        clk, // this will be the reconfig clk
    input  wire        reset,
    input  wire        hold,
       
    // User Avalon-MM slave
    input  wire [ 2:0] adce_address,
    input  wire [31:0] adce_writedata,
    input  wire        adce_write,
    input  wire        adce_read,
    output wire [31:0] adce_readdata,
    output wire        adce_waitrequest,
    
    output wire        adce_done,
    
    // basic block Avalon-MM master interface
    input  wire        adce_b_waitrequest, 
    output wire [2:0]  adce_b_address,
    output wire [31:0] adce_b_writedata, 
    output wire        adce_b_write,
    output wire        adce_b_read,
    input  wire [31:0] adce_b_readdata,
    input  wire        adce_b_irq,
       
    // basic block arbitration
    input wire         adce_b_arb_grant,
    output wire        adce_b_arb_req,
    // testbus
    input wire [7:0]   adce_testbus
    );
   
   localparam device_family = "StratixV";

   import alt_xcvr_reconfig_h::*; // alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
   //import sv_xcvr_h::*; //altera_xcvr_generic/sv/sv_xcvr_h.sv   

   wire [31:0] uif_writedata;
   wire [ 5:0] uif_addr_offset;
   wire [ 2:0] uif_mode;
   wire [ 9:0] uif_logical_ch_addr;
   wire        uif_go;
   wire [31:0] uif_readdata;
   wire        uif_illegal_pch_error;
   wire        uif_illegal_offset_error;   

   wire        ctrl_go;
   wire [ 2:0] ctrl_opcode;
   wire        ctrl_lock;
   wire [RECONFIG_BASIC_OFFSET_ADDR_WIDTH-1:0] ctrl_addr_offset;
   wire [31:0] ctrl_writedata;
   wire [31:0] ctrl_readdata;
   wire [31:0] ctrl_phreaddata;   
   wire        ctrl_illegal_phy_ch;
   wire        ctrl_waitrequest;
   wire        uif_busy;
   
   
// Common user interface block, this block talks with user
   alt_xreconf_uif
     #(
       .RECONFIG_USER_ADDR_WIDTH(3),
       .RECONFIG_USER_DATA_WIDTH(32),
       .RECONFIG_USER_OFFSET_WIDTH(6)
       ) 
   adce_alt_xreconf_uif 
   (
    .reconfig_clk              ( clk              ),
    .reset                     ( reset            ),

    // Avalon-MM slave interface from User
    .user_reconfig_address     ( adce_address     ),
    .user_reconfig_writedata   ( adce_writedata   ),
    .user_reconfig_write       ( adce_write       ),
    .user_reconfig_read        ( adce_read        ),
    .user_reconfig_readdata    ( adce_readdata    ),
    .user_reconfig_waitrequest ( adce_waitrequest ),
    .user_reconfig_done        ( adce_done        ),
    // to /from data control logic
    .uif_writedata             ( uif_writedata            ), // output
    .uif_addr_offset           ( uif_addr_offset          ), // output
    .uif_mode                  ( uif_mode                 ), // output
    .uif_logical_ch_addr       ( uif_logical_ch_addr      ), // output
    .uif_go                    ( uif_go                   ), // output
    .uif_ctrl                  ( /*unused*/               ), 
    .uif_readdata              ( uif_readdata             ), // input
    .uif_illegal_pch_error     ( uif_illegal_pch_error    ), // input
    .uif_illegal_offset_error  ( uif_illegal_offset_error ), // input
    .uif_busy                  ( uif_busy                 ), // input
    // From cif module
    .uif_phreaddata            ( ctrl_phreaddata          )  // input
    );
   

   // ADCE data control block, this block sits between uif and cif block
   alt_xcvr_reconfig_adce_datactrl_sv
   #(
     .NUMBER_OF_CHANNELS               (    number_of_reconfig_interfaces ),
     .AUTO_START                       (                       AUTO_START ),
     .RECONFIG_USER_ADDR_WIDTH         (                                3 ),
     .RECONFIG_USER_DATA_WIDTH         (                               32 ),
     .RECONFIG_USER_OFFSET_WIDTH       (                                6 ),
     .RECONFIG_BASIC_OFFSET_ADDR_WIDTH ( RECONFIG_BASIC_OFFSET_ADDR_WIDTH )
     ) 
   adce_datactrl
   (
    .clk                      ( clk                      ),
    .reset                    ( reset                    ),
    .hold                     ( hold                     ),
    
    // to/from alt_xreconf_uif user interface block
    .uif_go                   ( uif_go                   ), // input
    .uif_mode                 ( uif_mode                 ), // input
    .uif_logical_ch_addr      ( uif_logical_ch_addr      ), // input AA added
    .uif_addr_offset          ( uif_addr_offset          ), // input
    .uif_writedata            ( uif_writedata            ), // input
    .uif_readdata             ( uif_readdata             ), // output
    .uif_busy                 ( uif_busy                 ), // output
    .uif_illegal_pch_error    ( uif_illegal_pch_error    ), // output
    .uif_illegal_offset_error ( uif_illegal_offset_error ), // output
    
    // to/from alt_xreconf_cif control block
    .ctrl_go                  ( ctrl_go             ), // output
    .ctrl_opcode              ( ctrl_opcode         ), // output
    .ctrl_lock                ( ctrl_lock           ), // output
    .ctrl_addr_offset         ( ctrl_addr_offset    ), // output
    .ctrl_writedata           ( ctrl_writedata      ), // output
    .ctrl_readdata            ( ctrl_readdata       ), // input
    .ctrl_waitrequest         ( ctrl_waitrequest    ), // input

    .ctrl_illegal_phy_ch      ( ctrl_illegal_phy_ch ), // input

    // Straight from basic block
    .adce_b_waitrequest       ( adce_b_waitrequest  ),   // input // Not used.
    // Digital testbus straight from basic block
    .adce_testbus             ( adce_testbus        )
    );

   //Common interface block which talks with reconfig basic B Block
   // AA It takes care of acquiring exclusive access of the B Block
   // AA and does the multiple transfers required to access the registers.

   alt_xreconf_cif 
   #(
     .CIF_RECONFIG_ADDR_WIDTH   (                                3 ),
     .CIF_RECONFIG_DATA_WIDTH   (                               32 ),
     .CIF_OFFSET_ADDR_WIDTH     ( RECONFIG_BASIC_OFFSET_ADDR_WIDTH ),
     .CIF_MASTER_ADDR_WIDTH     (                                3 ),
     .CIF_RECONFIG_OFFSET_WIDTH (                                6 )
     )
   adce_alt_xreconf_cif
   (
    .reconfig_clk( clk ),
    .reset(reset),
    // To/From data/control block
    .ctrl_go             ( ctrl_go              ), // input
    .ctrl_opcode         ( ctrl_opcode          ), // input
    .ctrl_lock           ( ctrl_lock            ), // input
    .ctrl_addr_offset    ( ctrl_addr_offset     ), // input
    .ctrl_writedata      ( ctrl_writedata       ), // input
    .ctrl_readdata       ( ctrl_readdata        ), // output
    .ctrl_waitrequest    ( ctrl_waitrequest     ), // output

    .ctrl_illegal_phy_ch ( ctrl_illegal_phy_ch  ), // output

    // To/From uif block
    .ctrl_phreaddata     ( ctrl_phreaddata      ), // output
    .uif_logical_ch_addr (  uif_logical_ch_addr ), // input
    
    // Avalon-MM master interface to basic reconfig module
    .reconfig_address_base          ( adce_b_address     ),
    .reconfig_writedata_base        ( adce_b_writedata   ),
    .reconfig_write_base            ( adce_b_write       ),
    .reconfig_read_base             ( adce_b_read        ),
    .reconfig_readdata_base         ( adce_b_readdata    ),
    .reconfig_irq_from_base         ( adce_b_irq         ),
    .reconfig_waitrequest_from_base ( adce_b_waitrequest ),
    .arb_grant                      ( adce_b_arb_grant     ),
    .arb_req                        ( adce_b_arb_req       )
    );

endmodule : alt_xcvr_reconfig_adce_sv
