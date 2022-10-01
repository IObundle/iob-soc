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


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altpcieav_arbiter

(
    input  logic                                     Clk_i,
    input  logic                                     Rstn_i,

    input  logic                                     TxsArbReq_i,
    input  logic                                     RxmArbReq_i,
    input  logic                                     HPRxmArbReq_i,
    input  logic                                     DMAWrArbReq_i,
    input  logic                                     DMARdArbReq_i,

    output logic                                     TxsArbGrant_o,
    output logic                                     RxmArbGrant_o,
    output logic                                     DMAWrArbGrant_o,
    output logic                                     DMARdArbGrant_o,
    output logic                                     HPRxmArbGrant_o

);

    logic  [4:0]          arb_state;
    logic  [4:0]          arb_nxt_state;
    logic  [1:0]          arb_burst_state;
    logic  [1:0]          arb_burst_nxt_state;

      //state machine encoding
     localparam  ARB_IDLE                    = 5'h01;
     localparam  ARB_TXS_GRANT               = 5'h02;
     localparam  ARB_RD_GRANT                = 5'h04;
     localparam  ARB_WR_GRANT                = 5'h08;
     localparam  ARB_RXM_GRANT               = 5'h10;

     localparam  ARB_BURST_IDLE              = 2'h0;
     localparam  ARB_BURST_WR_GRANT          = 2'h1;
     localparam  ARB_BURST_HPRXM_GRANT       = 2'h2;


/// Arbiter state machine

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           arb_state <= ARB_IDLE;
         else
           arb_state <= arb_nxt_state;
     end

 always_comb
  begin
    case(arb_state)
      ARB_IDLE :
        if(TxsArbReq_i)
          arb_nxt_state <= ARB_TXS_GRANT;
        else if(DMARdArbReq_i)
          arb_nxt_state <= ARB_RD_GRANT;
        else if(RxmArbReq_i)
          arb_nxt_state <= ARB_RXM_GRANT;
        else
           arb_nxt_state <= ARB_IDLE;

       ARB_TXS_GRANT :
         if(DMARdArbReq_i & ~TxsArbReq_i)
          arb_nxt_state <= ARB_RD_GRANT;
        else if(RxmArbReq_i & ~TxsArbReq_i)
          arb_nxt_state <= ARB_RXM_GRANT;
        else if(TxsArbReq_i)
          arb_nxt_state <= ARB_TXS_GRANT;
        else
           arb_nxt_state <= ARB_IDLE;

      ARB_RD_GRANT:
        if(RxmArbReq_i &  ~DMARdArbReq_i)
          arb_nxt_state <= ARB_RXM_GRANT;
        else if(TxsArbReq_i &  ~DMARdArbReq_i)
          arb_nxt_state <= ARB_TXS_GRANT;
        else if(DMARdArbReq_i)
          arb_nxt_state <= ARB_RD_GRANT;
        else
           arb_nxt_state <= ARB_IDLE;

      ARB_WR_GRANT:
        if(DMARdArbReq_i)
            arb_nxt_state <= ARB_RD_GRANT;
        else if(RxmArbReq_i)
          arb_nxt_state <= ARB_RXM_GRANT;
        else if(TxsArbReq_i)
          arb_nxt_state <= ARB_TXS_GRANT;
        else
           arb_nxt_state <= ARB_IDLE;

      ARB_RXM_GRANT:
        if(TxsArbReq_i & ~RxmArbReq_i)
          arb_nxt_state <= ARB_TXS_GRANT;
        else if(DMARdArbReq_i & ~RxmArbReq_i)
          arb_nxt_state <= ARB_RD_GRANT;
        else if(RxmArbReq_i)
          arb_nxt_state <= ARB_RXM_GRANT;
        else
          arb_nxt_state <= ARB_IDLE;

      default:
          arb_nxt_state <= ARB_IDLE;
    endcase
end

/// Assign grant outputs
     assign TxsArbGrant_o   = arb_state[1];
     assign DMARdArbGrant_o = arb_state[2];
     assign RxmArbGrant_o   = arb_state[4];


//// second state machine arbitrating between WrDMA and HP RXM (bursting TLP)

  always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
           arb_burst_state <= ARB_BURST_IDLE;
         else
           arb_burst_state <= arb_burst_nxt_state;
     end

 always_comb
  begin
    case(arb_burst_state)
      ARB_BURST_IDLE :
        if(DMAWrArbReq_i)
          arb_burst_nxt_state <= ARB_BURST_WR_GRANT;
        else if(HPRxmArbReq_i)
          arb_burst_nxt_state <= ARB_BURST_HPRXM_GRANT;
        else
           arb_burst_nxt_state <= ARB_BURST_IDLE;

       ARB_BURST_WR_GRANT:
        if(HPRxmArbReq_i & ~DMAWrArbReq_i)
          arb_burst_nxt_state <= ARB_BURST_HPRXM_GRANT;
        else if(DMAWrArbReq_i)
          arb_burst_nxt_state <= ARB_BURST_WR_GRANT;
        else
           arb_burst_nxt_state <= ARB_BURST_IDLE;

       ARB_BURST_HPRXM_GRANT:
        if(DMAWrArbReq_i & ~HPRxmArbReq_i)
          arb_burst_nxt_state <= ARB_BURST_WR_GRANT;
        else if(HPRxmArbReq_i)
          arb_burst_nxt_state <= ARB_BURST_HPRXM_GRANT;
        else
           arb_burst_nxt_state <= ARB_BURST_IDLE;

       default:
            arb_burst_nxt_state <= ARB_BURST_IDLE;
    endcase
  end

assign DMAWrArbGrant_o = (arb_burst_state == ARB_BURST_WR_GRANT) | ( arb_burst_state == ARB_BURST_IDLE);
assign HPRxmArbGrant_o = (arb_burst_state == ARB_BURST_HPRXM_GRANT);

endmodule
