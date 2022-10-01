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

module altpcie_dynamic_control #(
      parameter                                    READ_CONTROL = 1,
      parameter                                    dma_use_scfifo_ext = 0,
      parameter                                    DMA_WIDTH = 256
 ) (
      input logic                                   Clk_i,
      input logic                                   Rstn_i,
      input logic   [81:0]                          MsiInterface_i,

      // AVMM Register Slave Port (Write only)
      input  logic                                  DCSChipSelect_i,
      input  logic                                  DCSWrite_i,
      input  logic  [7:0]                           DCSAddress_i,
      input  logic  [31:0]                          DCSWriteData_i,
      input  logic  [3:0]                           DCSByteEnable_i,
      input  logic                                  DCSRead_i,
      output logic  [31:0]                          DCSReadData_o,
      output logic                                  DCSWaitRequest_o,


      // AVMM Register Master Port (Write only)

      output   logic [63:0]                         DCMAddress_o,
      output                                        DCMWrite_o,
      output   logic [31:0]                         DCMWriteData_o,
      output                                        DCMRead_o,
      output   logic [3:0]                          DCMByteEnable_o,
      input    logic                                DCMWaitRequest_i,
      input    logic [31:0]                         DCMReadData_i,
      input    logic                                DCMReadDataValid_i,

      /// DT 256-bit slave interface (Write only)

      input  logic                                  DTSChipSelect_i,
      input  logic                                  DTSWrite_i,
      input  logic  [4:0]                           DTSBurstCount_i,
      input  logic  [7:0]                           DTSAddress_i,
      input  logic  [255:0]                         DTSWriteData_i,
      output logic                                  DTSWaitRequest_o,

      /// DMA programming interface
      output   logic  [159:0]                       DmaTxData_o,
      output   logic                                DmaTxValid_o,
      input    logic                                DmaTxReady_i,

     // DMA Status Interface
      input   logic  [31:0]                         DmaRxData_i,
      input   logic                                 DmaRxValid_i,

      /// Exclusive Descriptor Fetch AST

      output   logic  [159:0]                       WrDescTxData_o,
      output   logic                                WrDescTxReq_o,
      input    logic                                WrDescTxAck_i,
      output   logic                                WrDescTxAck_o,
      input    logic                                WrDescTxReq_i,
      input    logic [159:0]                        WrDescTxData_i
 );

 localparam      DTS_IDLE          = 3'h1;
 localparam      DTS_BURST         = 3'h2;
 localparam      DTS_WAIT          = 3'h4;


 localparam       DCM_IDLE         = 3'h1;
 localparam       DCM_WR           = 3'h2;
 localparam       DCM_MSI_WR       = 3'h4;

 localparam       DMA_TX_IDLE     = 6'h01;
 localparam       DMA_TX_FIFO_RD  = 6'h02;
 localparam       DMA_TX_WAIT     = 6'h04;
 localparam       DMA_TX_PROGRAM  = 6'h08;
 localparam       DMA_TX_DT_SEND  = 6'h10;
 localparam       DMA_WRDESC_SEND = 6'h20;

 localparam       [3:0] DCS_IDLE        = 4'b0001;
 localparam       [3:0] DCS_PIPE        = 4'b0010;
 localparam       [3:0] DCS_WRITE_ACK   = 4'b0100;
 localparam       [3:0] DCS_READ_ACK    = 4'b1000;

 logic        [3:0]  dcs_current_state;
 logic        [3:0]  dcs_next_state;
 logic      [159:0]  dt_fifo_data_in;
 logic               dt_fifo_wrreq_reg;
 logic               dt_fifo_wrreq_reg1;
 logic      [7:0]    addr_decode;
 logic               dt_low_src_addr_wen;
 logic               dt_hi_src_addr_wen;
 logic               dt_low_dest_addr_wen;
 logic               dt_hi_dest_addr_wen;
 logic               table_id_size_wen;
 logic               ctrl_wen;
 logic               ep_last_pntr_wen;
 logic      [31:0]   dt_low_src_addr_reg;
 logic      [31:0]   dt_hi_src_addr_reg;
 logic      [31:0]   dt_low_dest_addr_reg;
 logic      [31:0]   dt_hi_dest_addr_reg;
 logic      [31:0]   ep_last_pntr_reg;
 logic      [31:0]   table_id_size_reg;
 logic      [31:0]   ctrl_reg;
 logic      [63:0]   dt_header_base;
 logic      [63:0]   dt_desc_base;
 logic               register_ready_reg;
 logic               dt_fifo_ok;
 logic     [7:0]     dt_fifo_count;
 logic     [2:0]     dts_state;
 logic     [2:0]     dts_nxt_state;
 logic     [4:0]     burst_counter;
 logic               dts_idle;
 logic               dts_ready;
 logic               dt_fifo_wrreq;
 logic               dt_fifo_rdreq;
 logic               dt_fifo_empty;
 logic     [159:0]   dt_fifo_dataq;
 logic     [5:0]     dma_tx_state;
 logic     [5:0]     dma_tx_nxt_state;
 logic               fetch_desc_pending_sreg;
 logic     [159:0]   dt_tx_data;
 logic               desc_fetch_send;
 logic     [7:0]     current_desc_id;
 logic     [7:0]     prev_desc_id_reg;
 logic     [7:0]     sent_dt_size;
 logic     [63:0]    current_dt_address_reg;
 logic               ep_last_fifo_wrreq;
 logic               ep_last_fifo_rdreq;
 logic     [7:0]     ep_last_from_dma;
 logic     [7:0]     ep_last_from_dma_r;
 logic     [8:0]     ep_last_data;
 logic     [8:0]     ep_last_to_rc;
 logic     [7:0]     ep_last_fifo_count;
 logic     [127:0]   pending_desc_update_array;
 logic     [127:0]   ep_last_fifo_wrreq_array;
 logic               ep_last_fifo_wrreq_array_or1;
 logic               ep_last_fifo_wrreq_array_or2;
 logic     [127:0]   msi_array;
 logic               msi_array_or1;
 logic               msi_array_or2;
 logic     [2:0]     dcm_state;
 logic     [2:0]     dcm_nxt_state;
 logic               is_rd_controller;
 logic               is_wr_controller;
 logic               current_desc_poimter_127_flag_reg;
 logic     [63:0]    ep_last_update_address_reg;

 logic     [7:0]     pending_desc_id_reg;
 logic               pending_desc_id_stored;
 logic               pending_desc_id_wen;
 logic     [7:0]     true_desc_id;
 logic               ep_last_pntr_not_from_pending_wen;
 logic               ep_last_pntr_from_pending_wen;
// 128 bit interface signals
 logic  [255:0]      DTSWriteData;
 logic               readvalid_128;
 logic  [5:0]        fetch_counter;
 logic  [31:0]       reg_mux_out;
 logic  [31:0]       reg_read_data_reg;
 logic  [31:0]       dma_status_reg;
 logic               dma_status_valid_reg;
 logic [7:0]         desc_controller_slave_address;


always_ff @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      dma_status_reg <= 32'h0;
      dma_status_valid_reg <= 1'b1;
    end
    else begin
      dma_status_reg       <= DmaRxData_i;
      dma_status_valid_reg <= DmaRxValid_i;
    end
end



 /// decoding the address
 generate if (READ_CONTROL == 0)
  begin
   assign is_wr_controller = 1'b1;
   assign is_rd_controller = 1'b0;
  end
  else
  begin
   assign is_wr_controller = 1'b0;
   assign is_rd_controller = 1'b1;
end
 endgenerate
 
 assign desc_controller_slave_address = {DCSAddress_i[7:2], 2'b00}; 

 always_comb
  begin
  case (desc_controller_slave_address)
     8'h00 : addr_decode[7:0] = 8'b0000_0001; 
     8'h04 : addr_decode[7:0] = 8'b0000_0010;
     8'h08 : addr_decode[7:0] = 8'b0000_0100;
     8'h0C : addr_decode[7:0] = 8'b0000_1000;
     8'h10 : addr_decode[7:0] = 8'b0001_0000;
     8'h14 : addr_decode[7:0] = 8'b0010_0000;
     8'h18 : addr_decode[7:0] = 8'b0100_0000;
     8'h1C : addr_decode[7:0] = 8'b1000_0000;
     default:addr_decode[7:0] = 8'b0000_0000;
    endcase
  end

assign dt_low_src_addr_wen                = addr_decode[0] & DCSWrite_i & DCSChipSelect_i & register_ready_reg;
assign dt_hi_src_addr_wen                 = addr_decode[1] & DCSWrite_i & DCSChipSelect_i & register_ready_reg;
assign dt_low_dest_addr_wen               = addr_decode[2] & DCSWrite_i & DCSChipSelect_i & register_ready_reg;
assign dt_hi_dest_addr_wen                = addr_decode[3] & DCSWrite_i & DCSChipSelect_i & register_ready_reg;
assign table_id_size_wen                  = addr_decode[5] & DCSWrite_i & DCSChipSelect_i & register_ready_reg;
assign ctrl_wen                           = addr_decode[6] & DCSWrite_i & DCSChipSelect_i & register_ready_reg;
assign ep_last_pntr_wen                   = ep_last_pntr_not_from_pending_wen | ep_last_pntr_from_pending_wen;

assign ep_last_pntr_not_from_pending_wen  = addr_decode[4] & DCSWrite_i & DCSChipSelect_i & register_ready_reg & ~current_desc_poimter_127_flag_reg;
assign pending_desc_id_wen                = addr_decode[4] & DCSWrite_i & DCSChipSelect_i & register_ready_reg & current_desc_poimter_127_flag_reg;

assign ep_last_pntr_from_pending_wen      = (~current_desc_poimter_127_flag_reg & pending_desc_id_stored) & ~ep_last_pntr_not_from_pending_wen;


assign true_desc_id          = (ep_last_pntr_not_from_pending_wen)? DCSWriteData_i[7:0] : pending_desc_id_reg;

//=================================
// Read functionality for registers
//=================================

always_comb begin
  case (addr_decode)
     8'b0000_0001: reg_mux_out = dt_low_src_addr_reg;
     8'b0000_0010: reg_mux_out = dt_hi_src_addr_reg;
     8'b0000_0100: reg_mux_out = dt_low_dest_addr_reg;
     8'b0000_1000: reg_mux_out = dt_hi_dest_addr_reg;
     8'b0001_0000: reg_mux_out = ep_last_pntr_reg;
     8'b0010_0000: reg_mux_out = table_id_size_reg;
     8'b0100_0000: reg_mux_out = ctrl_reg;
     default : reg_mux_out = 32'h0;
  endcase
end

always_ff @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      reg_read_data_reg <= 32'h0;
    end
    else if( DCSRead_i & DCSChipSelect_i) begin
      reg_read_data_reg <= reg_mux_out;
    end
    else begin
      reg_read_data_reg <= 32'h0;
    end
end

assign DCSReadData_o = reg_read_data_reg;

/// Register definition

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      fetch_counter <= 6'h0;
    else if (dma_tx_state[4] | WrDescTxAck_i)
      fetch_counter <= fetch_counter + 6'h1;
  end

/// DT source address reg
always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      dt_low_src_addr_reg <= 32'h0;
    else if(dt_low_src_addr_wen)
      dt_low_src_addr_reg <= DCSWriteData_i;
  end

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      dt_hi_src_addr_reg <= 32'h0;
    else if(dt_hi_src_addr_wen)
      dt_hi_src_addr_reg <= DCSWriteData_i;
  end

/// DT Dest address

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      dt_low_dest_addr_reg <= 32'h0;
    else if(dt_low_dest_addr_wen)
      dt_low_dest_addr_reg <= DCSWriteData_i;
  end

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      dt_hi_dest_addr_reg <= 32'h0;
    else if(dt_hi_dest_addr_wen)
      dt_hi_dest_addr_reg <= DCSWriteData_i;
  end

/// EP last pointer (Index)

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      ep_last_pntr_reg <= 32'hFF;
    else if(ep_last_pntr_wen)
      ep_last_pntr_reg <= true_desc_id;
  end


always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      table_id_size_reg <= 32'h7F;
    else if(table_id_size_wen)
      table_id_size_reg <= DCSWriteData_i;
  end

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      ctrl_reg <= 32'h0;
    else if(ctrl_wen)
      ctrl_reg <= DCSWriteData_i;
  end

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      pending_desc_id_reg <= 8'h0;
    else if(pending_desc_id_wen)
      pending_desc_id_reg <= DCSWriteData_i[7:0];
  end

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      pending_desc_id_stored <= 1'b0;
    else if(pending_desc_id_wen)
      pending_desc_id_stored <= 1'b1;
    else if (ep_last_pntr_from_pending_wen)
      pending_desc_id_stored <= 1'b0;
  end

assign dt_header_base[63:0] = {dt_hi_src_addr_reg, dt_low_src_addr_reg};
assign dt_desc_base[63:0]   = {dt_header_base + 10'h200};

always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      dcs_current_state <= DCS_IDLE;
    else
      dcs_current_state <= dcs_next_state;
  end

// DCS state machine next state gen
always_comb
  begin
    case(dcs_current_state)
      DCS_IDLE :
         if (DCSChipSelect_i & (DCSRead_i | DCSWrite_i))
            dcs_next_state <= DCS_PIPE;
         else
            dcs_next_state <= DCS_IDLE;
      DCS_PIPE :
         if (DCSRead_i == 1'b1)
            dcs_next_state <= DCS_READ_ACK;
         else if (DCSWrite_i == 1'b1)
            dcs_next_state <= DCS_WRITE_ACK;
      else
        dcs_next_state <= DCS_PIPE;
      DCS_READ_ACK, DCS_WRITE_ACK:
        dcs_next_state <= DCS_IDLE;
      default:
        dcs_next_state <= DCS_IDLE;
    endcase
end

assign register_ready_reg = (dcs_current_state[2] | dcs_current_state[3]);
assign DCSWaitRequest_o = ~register_ready_reg;

// The Descriptor Data Table Interface 256-bit Interface

// Tx control state machine

assign dt_fifo_ok = dt_fifo_count <= 250;

  always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      burst_counter <= 5'h0;
    else if(dts_idle)
      burst_counter <= DTSBurstCount_i[4:0];
    else if(dts_ready &  DTSWrite_i & DTSChipSelect_i)
      burst_counter <= burst_counter - 1'b1;
  end



always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      dts_state <= DTS_IDLE;
    else
      dts_state <= dts_nxt_state;
  end

// state machine next state gen
always_comb
  begin
    case(dts_state)
      DTS_IDLE :
        if(DTSChipSelect_i & DTSWrite_i & dt_fifo_ok)
          dts_nxt_state <= DTS_BURST;
        else
           dts_nxt_state <= DTS_IDLE;

     DTS_BURST:
       if(burst_counter == 1)
         dts_nxt_state <= DTS_IDLE;
       else if(~dt_fifo_ok)
         dts_nxt_state <= DTS_WAIT;
       else
         dts_nxt_state <= DTS_BURST;

     DTS_WAIT:
       if(dt_fifo_ok)
          dts_nxt_state <= DTS_BURST;
       else
         dts_nxt_state <= DTS_WAIT;

    default:
         dts_nxt_state <= DTS_IDLE;

    endcase
end

assign DTSWriteData = DTSWriteData_i;

assign dts_idle =  dts_state[0];
assign dts_ready =  dts_state[1];
assign DTSWaitRequest_o = ~dts_ready;
assign dt_fifo_wrreq = dts_ready &  DTSWrite_i & DTSChipSelect_i ;

//=====================================
// Fix timing on dt_fifo write paths
//=====================================
always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i) begin
      dt_fifo_wrreq_reg <= 1'b0;
      dt_fifo_wrreq_reg1 <= 1'b0;
    end else begin
      dt_fifo_wrreq_reg <= dt_fifo_wrreq;
      dt_fifo_wrreq_reg1 <= dt_fifo_wrreq_reg;
      dt_fifo_data_in   <= DTSWriteData[159:0];
    end
  end


/// DT fifo
generate begin : g_dt_fifo
   if (dma_use_scfifo_ext==1) begin
      altpcie_a10_scfifo_ext  #       (
         .add_ram_output_register     ("ON"        ),
         .intended_device_family      ("Stratix V" ),
         .lpm_numwords                (256         ),
         .lpm_showahead               ("OFF"       ),
         .lpm_type                    ("scfifo"    ),
         .lpm_width                   (160         ),
         .lpm_widthu                  (8           ),
         .overflow_checking           ("ON"        ),
         .underflow_checking          ("ON"        ),
         .use_eab                     ("ON"        )
      )  dt_fifo                      (
         .rdreq                       (dt_fifo_rdreq),
         .clock                       (Clk_i),
         .wrreq                       (dt_fifo_wrreq_reg),
         .data                        (dt_fifo_data_in[159:0]),
         .usedw                       (dt_fifo_count),
         .empty                       (dt_fifo_empty),
         .q                           (dt_fifo_dataq),
         .full                        (),
         .aclr                        (~Rstn_i),
         .almost_empty                (),
         .almost_full                 (),
         .sclr                        (1'b0)
      );
   end
   else if (dma_use_scfifo_ext==2) begin
      altpcie_sv_scfifo_ext  #        (
         .add_ram_output_register     ("ON"        ),
         .intended_device_family      ("Stratix V" ),
         .lpm_numwords                (256         ),
         .lpm_showahead               ("OFF"       ),
         .lpm_type                    ("scfifo"    ),
         .lpm_width                   (160         ),
         .lpm_widthu                  (8           ),
         .overflow_checking           ("ON"        ),
         .underflow_checking          ("ON"        ),
         .use_eab                     ("ON"        )
      )  dt_fifo                      (
         .rdreq                       (dt_fifo_rdreq),
         .clock                       (Clk_i),
         .wrreq                       (dt_fifo_wrreq_reg),
         .data                        (dt_fifo_data_in[159:0]),
         .usedw                       (dt_fifo_count),
         .empty                       (dt_fifo_empty),
         .q                           (dt_fifo_dataq),
         .full                        (),
         .aclr                        (~Rstn_i),
         .almost_empty                (),
         .almost_full                 (),
         .sclr                        (1'b0)
      );
   end
   else begin
      scfifo                  #       (
         .add_ram_output_register     ("ON"        ),
         .intended_device_family      ("Stratix V" ),
         .lpm_numwords                (256         ),
         .lpm_showahead               ("OFF"       ),
         .lpm_type                    ("scfifo"    ),
         .lpm_width                   (160         ),
         .lpm_widthu                  (8           ),
         .overflow_checking           ("ON"        ),
         .underflow_checking          ("ON"        ),
         .use_eab                     ("ON"        )
      )  dt_fifo                      (
         .rdreq                       (dt_fifo_rdreq),
         .clock                       (Clk_i),
         .wrreq                       (dt_fifo_wrreq_reg),
         .data                        (dt_fifo_data_in[159:0]),
         .usedw                       (dt_fifo_count),
         .empty                       (dt_fifo_empty),
         .q                           (dt_fifo_dataq),
         .full                        (),
         .aclr                        (~Rstn_i),
         .almost_empty                (),
         .almost_full                 (),
         .sclr                        (1'b0)
      );
   end
end
endgenerate


/// state machine to send descriptors to controller to transfer DMA data
// Descriptor TX

always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      dma_tx_state <= DMA_TX_IDLE;
    else
      dma_tx_state <= dma_tx_nxt_state;
  end

always_comb
  begin
    case(dma_tx_state)
      DMA_TX_IDLE :
        if(WrDescTxReq_i & DmaTxReady_i)
           dma_tx_nxt_state <= DMA_WRDESC_SEND;
        else if(fetch_desc_pending_sreg & DmaTxReady_i & is_rd_controller)
           dma_tx_nxt_state <= DMA_TX_DT_SEND;  /// send the desc fetch instruction
        else if(~dt_fifo_empty & DmaTxReady_i)
          dma_tx_nxt_state <= DMA_TX_FIFO_RD;
        else
           dma_tx_nxt_state <= DMA_TX_IDLE;

      DMA_TX_FIFO_RD:
        dma_tx_nxt_state <= DMA_TX_WAIT;

      DMA_TX_WAIT:
        dma_tx_nxt_state <= DMA_TX_PROGRAM;

      DMA_TX_PROGRAM:
        dma_tx_nxt_state <= DMA_TX_IDLE;

      DMA_TX_DT_SEND:
         dma_tx_nxt_state <= DMA_TX_IDLE;

      DMA_WRDESC_SEND:
          dma_tx_nxt_state <= DMA_TX_IDLE;

      default:
        dma_tx_nxt_state <= DMA_TX_IDLE;

  endcase
end

assign dt_fifo_rdreq = dma_tx_state[1];

generate if( READ_CONTROL == 1) /// READ combines both DESC + DATA to same port
 begin
   assign desc_fetch_send  =  dma_tx_state[4];
   assign DmaTxValid_o  =   dma_tx_state[3] |  dma_tx_state[4] | dma_tx_state[5];
   assign DmaTxData_o   =    dma_tx_state[4]? dt_tx_data : dma_tx_state[5]? WrDescTxData_i : dt_fifo_dataq;
   assign WrDescTxReq_o = 1'b0;
   assign WrDescTxAck_o =  dma_tx_state[5];
   assign WrDescTxData_o[159:0] = 160'h0;
 end
else   /// WRITE only fetch real data
 begin
    assign DmaTxValid_o  =   dma_tx_state[3];
    assign DmaTxData_o   =    dt_fifo_dataq;
 end
endgenerate

generate if( READ_CONTROL == 0)  /// Write control
  begin
   assign WrDescTxData_o[159:0] = dt_tx_data;
   assign WrDescTxReq_o         = fetch_desc_pending_sreg;
   assign WrDescTxAck_o         = 1'b0;
  end
endgenerate

/////////////////////////////////////////////////////////////////
/// fetching descriptor logic
/////////////////////////////////////////////////////////////////

/// desc fetch pending reg

generate if(READ_CONTROL == 1)
  begin
   always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
     begin
       if(~Rstn_i)
         fetch_desc_pending_sreg <= 1'b0;
     else if(ep_last_pntr_wen)
         fetch_desc_pending_sreg <= 1'b1;
       else if(desc_fetch_send)
         fetch_desc_pending_sreg <= 1'b0;
     end
  end
else
  begin
   always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
     begin
       if(~Rstn_i)
         fetch_desc_pending_sreg <= 1'b0;
       else if(ep_last_pntr_wen)
         fetch_desc_pending_sreg <= 1'b1;
       else if(WrDescTxAck_i)  // send write descriptor
         fetch_desc_pending_sreg <= 1'b0;
     end
  end
endgenerate


/// Store the last desc ID being fetch

generate if(READ_CONTROL == 1)
  begin
     always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
       begin
         if(~Rstn_i)
           prev_desc_id_reg <= 8'hFF;
         else if(desc_fetch_send)
           prev_desc_id_reg <= (current_desc_id == table_id_size_reg[7:0])? 8'hFF : current_desc_id;
       end
  end
else
  begin
     always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
       begin
         if(~Rstn_i)
           prev_desc_id_reg <= 8'hFF;
         else if(WrDescTxAck_i)
           prev_desc_id_reg <= (current_desc_id == table_id_size_reg[7:0])? 8'hFF : current_desc_id;
       end
  end
endgenerate

/// calculate the DT size

assign current_desc_id[7:0] = ep_last_pntr_reg[7:0];

assign sent_dt_size[7:0] =  current_desc_id[7:0] - prev_desc_id_reg[7:0];  /// software ensures no roll over

generate if(READ_CONTROL == 1)
  begin

     always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
       begin
         if(~Rstn_i)
           current_desc_poimter_127_flag_reg <= 1'b0;
         else if(ep_last_pntr_wen & true_desc_id[7:0] == table_id_size_reg[7:0])
           current_desc_poimter_127_flag_reg <= 1'b1;
         else if(desc_fetch_send & current_desc_id == table_id_size_reg[7:0] )
            current_desc_poimter_127_flag_reg <= 1'b0;
       end



     always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
       begin
         if(~Rstn_i)
           current_dt_address_reg <= 64'h0;
         else if(dt_low_dest_addr_wen) // high dest addr must be written before low (per design intent)
           current_dt_address_reg <= dt_desc_base[63:0];
         else if(desc_fetch_send)
           current_dt_address_reg <= (current_desc_id == table_id_size_reg[7:0])? dt_desc_base[63:0] : (current_dt_address_reg + {sent_dt_size[7:0], 5'h0});  // size in 8-dw (256-bit)
       end
  end
else
  begin

     always_ff @(posedge Clk_i or negedge Rstn_i)
     begin
         if(~Rstn_i)
           current_desc_poimter_127_flag_reg <= 1'b0;
         else if(ep_last_pntr_wen & true_desc_id[7:0]  == table_id_size_reg[7:0])
           current_desc_poimter_127_flag_reg <= 1'b1;
         else if(WrDescTxAck_i & current_desc_id == table_id_size_reg[7:0] )
           current_desc_poimter_127_flag_reg <= 1'b0;
       end


     always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
       begin
         if(~Rstn_i)
           current_dt_address_reg <= 64'h0;
         else if(dt_low_dest_addr_wen) // high dest addr must be written before low (per design intent)
           current_dt_address_reg <= dt_desc_base[63:0];
         else if(WrDescTxAck_i)
           current_dt_address_reg <= (current_desc_id == table_id_size_reg[7:0])? dt_desc_base[63:0] : (current_dt_address_reg + {sent_dt_size[7:0], 5'h0});  // size in 8-dw (256-bit)
       end
  end

endgenerate

// assemble the DT fetch instruction

assign dt_tx_data[159:0] = {   6'h0, {1'b1, is_wr_controller, fetch_counter[5:0]},//8'd128,                // Reserved, ID                     /// Desc fetch, use ID 128 (table_id_size_reg[7:0]-0) used for  DMA data
                               7'h0, sent_dt_size[7:0], 3'b000 , // size in DW , sent_dt_size in 256-bit
                               dt_hi_dest_addr_reg[31:0], dt_low_dest_addr_reg[31:0],
                               current_dt_address_reg[63:0]};


/// Queue to handle EP last update to software
/// Out of order is handled in software
     altpcie_fifo
   #(
    .FIFO_DEPTH(128),
    .DATA_WIDTH(9)
    )
 ep_last_fifo
(
      .clk(Clk_i),
      .rstn(Rstn_i),
      .srst(1'b0),
      .wrreq(ep_last_fifo_wrreq),
      .rdreq(ep_last_fifo_rdreq),
      .data(ep_last_data),
      .q(ep_last_to_rc),
      .fifo_count(ep_last_fifo_count)
);

assign ep_last_from_dma[7:0] = dma_status_reg[7:0];

 generate
  genvar i;
   begin
    for(i=0; i< 128; i=i+1)
      begin: ep_last_status_flag
     always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
       begin
         if(~Rstn_i)
           pending_desc_update_array[i] <= 1'b0;
         else if(DCSWriteData_i[7:0] == i & ep_last_pntr_not_from_pending_wen)
           pending_desc_update_array[i] <= 1'b1;
         else if(DCSWriteData_i[7:0] == i & pending_desc_id_wen)
           pending_desc_update_array[i] <= 1'b1;
         else if(ep_last_fifo_wrreq_array[i])
           pending_desc_update_array[i] <= 1'b0;
       end

         assign ep_last_fifo_wrreq_array[i] = dma_status_valid_reg & ~dma_status_reg[7] & dma_status_reg[6:0] == i;
         assign msi_array[i]                = pending_desc_update_array[i] & ep_last_fifo_wrreq_array[i];
      end
   end
 endgenerate

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
    begin
      ep_last_fifo_wrreq_array_or1 <= 1'h0;
      ep_last_fifo_wrreq_array_or2 <= 1'h0;

      msi_array_or1 <= 1'h0;
      msi_array_or2 <= 1'h0;

      ep_last_from_dma_r <= 8'h0;
    end
    else
    begin
      ep_last_fifo_wrreq_array_or1 <= |ep_last_fifo_wrreq_array[63:0];
      ep_last_fifo_wrreq_array_or2 <= |ep_last_fifo_wrreq_array[127:64];

      msi_array_or1 <= |msi_array[63:0];
      msi_array_or2 <= |msi_array[127:64];

      ep_last_from_dma_r <= ep_last_from_dma[7:0];
    end
  end

assign ep_last_data = {(msi_array_or1 | msi_array_or2), ep_last_from_dma_r[7:0]};
assign ep_last_fifo_wrreq = ctrl_reg[0] ? (ep_last_fifo_wrreq_array_or1 | ep_last_fifo_wrreq_array_or2) : (msi_array_or1 | msi_array_or2);

/// DT update EP last logic


// Avalon Master Port  dcm

always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      dcm_state <= DCM_IDLE;
    else
      dcm_state <= dcm_nxt_state;
  end


always_comb
  begin
    case(dcm_state)
      DCM_IDLE :
        if(ep_last_fifo_count != 0)
           dcm_nxt_state <= DCM_WR;  /// send the desc fetch instruction
        else
           dcm_nxt_state <= DCM_IDLE;

      DCM_WR:
        if(~DCMWaitRequest_i & MsiInterface_i[80] & ep_last_to_rc[8])
          dcm_nxt_state <= DCM_MSI_WR;
        else if (~DCMWaitRequest_i & (~MsiInterface_i[80] | ~ep_last_to_rc[8]))
          dcm_nxt_state <= DCM_IDLE;
        else
          dcm_nxt_state <= DCM_WR;

     DCM_MSI_WR:
      if(~DCMWaitRequest_i)
       dcm_nxt_state <= DCM_IDLE;
      else
       dcm_nxt_state <= DCM_MSI_WR;

      default:
        dcm_nxt_state <= DCM_IDLE;
    endcase
 end

assign   ep_last_fifo_rdreq   = dcm_state[1] & ~DCMWaitRequest_i;
assign   DCMWrite_o           = dcm_state[1] | dcm_state[2];
assign   DCMRead_o            = 1'b0;
assign   DCMWriteData_o[31:0] = (dcm_state[1])? 32'h1 : {16'h0, MsiInterface_i[79:64]};
assign   DCMByteEnable_o[3:0] = 4'hF;

always_ff @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      ep_last_update_address_reg <= 64'h0;
    else
      ep_last_update_address_reg <= {dt_hi_src_addr_reg, dt_low_src_addr_reg[31:0]} + {ep_last_to_rc[6:0], 2'b00};
  end


assign   DCMAddress_o[63:0]   = (dcm_state[1])? ep_last_update_address_reg : MsiInterface_i[63:0];

endmodule
