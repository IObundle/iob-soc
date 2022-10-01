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


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                   //
//    altpcie_tlp_monitor : Miscellaneous TLP analysis                                                                                               //
//                                                                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                   //
//    ____________________________________________________________________________________________________________________________________________   //
//    |                                                                                                                                          |   //
//    |                                                       PCIe TLP Header                                                                    |   //
//    |__________________________________________________________________________________________________________________________________________|   //
//    |31  30  29  |28  27  26  25  24  |23  |22  21  20  |19  |18  |17  |16  |15  |14  |13  12  |11  10  |9   8   7   6   5   4   3   2   1   0 |   //
//    |7   6   5   |4   3   2   1   0   |7   |6   5   4   |3   |2   |1   |0   |7   |6   |5   4   |3   2   |1   0   7   6   5   4   3   2   1   0 |   //
// h1 |FMT         |TYPE                |R   |TC          |R   |A   |R   |TH  |TD  |EP  |Attr    |ATT     |Length                                |   //
// h2 |                                                                                                            | Last BE        |First BE    |   //
// h3 |                                                                                                                                          |   //
// h4 |__________________________________________________________________________________________________________________________________________|   //
//    |                                                                                                                                          |   //
//    |                                                     MEMORY TLP                                                                           |   //
//    |__________________________________________________________________________________________________________________________________________|   //
// h2 |            Requester ID                                               |    TAG                             | Last BE        |First BE    |   //
// h3 |               Address                                                                                                                    |   //
// h4 |__________________________________________________________________________________________________________________________________________|   //
//    |                                                                                                                                          |   //
//    |                                                     COMPLETION TLP                                                                       |   //
//    |__________________________________________________________________________________________________________________________________________|   //
// h2 |            Completer ID                                               |Cpl Status     |  |    Byte Count                                 |   //
// h3 |            Requester ID                                               |    TAG                             | R | Lower Address           |   //
// h4 |__________________________________________________________________________________________________________________________________________|   //
//                                                                                                                                                   //
//    _______________________________                                                                                                                //
//    |                    |        |                                                                                                                //
//    |  {FMT,TYPE}        |        |                                                                                                                //
//    |____________________|________|                                                                                                                //
//    | 8'b0000_0000       | MRd    |                                                                                                                //
//    | 8'b0010_0000       | MRd    |                                                                                                                //
//    | 8'b0000_0001       | MRdLk  |                                                                                                                //
//    | 8'b0010_0001       | MRdLk  |                                                                                                                //
//    | 8'b0100_0000       | MWr    |                                                                                                                //
//    | 8'b0110_0000       | MWr    |                                                                                                                //
//    | 8'b0000_0010       | IORd   |                                                                                                                //
//    | 8'b0100_0010       | IOWr   |                                                                                                                //
//    | 8'b0000_0100       | CfgRd0 |                                                                                                                //
//    | 8'b0100_0100       | CfgWr0 |                                                                                                                //
//    | 8'b0000_0101       | CfgRd1 |                                                                                                                //
//    | 8'b0100_0101       | CfgWr1 |                                                                                                                //
//    | 8'b0011_0XXX       | Msg    |                                                                                                                //
//    | 8'b0111_0XXX       | MsgD   |                                                                                                                //
//    | 8'b0000_1010       | Cpl    |                                                                                                                //
//    | 8'b0100_1010       | CplD   |                                                                                                                //
//    | 8'b0000_1011       | CplLk  |                                                                                                                //
//    | 8'b0100_1011       | CplDLk |                                                                                                                //
//    |_____________________________|                                                                                                                //
//                                                                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                   //
//    INSPECTOR MONITOR ADDRESS MAP                                                                                                                  //
//    _________________________________________________ ___________________________________________________________________________________________  //
//    |             |                                  |                                                                                           | //
//    |  VSEC_ADDR  |   VSEC_DATA                      |       Description                                                                         | //
//    |_____________|__________________________________|___________________________________________________________________________________________| //
//    | 8'h18       |   INSP_ADDRREADY_SOP_RX          | {ast_cnt_rx_ready, ast_cnt_rx_sop}                                                        | //
//    | 8'h1C       |   INSP_ADDRREADY_SOP_TX          | {ast_cnt_tx_ready, ast_cnt_tx_sop}                                                        | //
//    | 8'h20       |   INSP_ADDRLATENCY_MRD_UPSTREAM  | {(PLD_CLK_IS_250MHZ==1)?2'b01:2'b00,ast_max_read_latency_cnt, ast_min_read_latency_cnt}   | //
//    | 8'h24       |   INSP_ADDRMWR_THROUGHPUT_CLK    | {(PLD_CLK_IS_250MHZ==1)?2'b01:2'b00,10'h0,ast_cnt_mwr_clk}                                | //
//    | 8'h28       |   INSP_ADDRMWR_THROUGHPUT_DWORD  | {12'h0                                   ,ast_cnt_mwr_dword}                              | //
//    | 8'h2C       |   INSP_ADDRMRD_THROUGHPUT_CLK    | {(PLD_CLK_IS_250MHZ==1)?2'b01:2'b00,10'h0,ast_cnt_mrd_clk}                                | //
//    | 8'h30       |   INSP_ADDRMRD_THROUGHPUT_DWORD  | {12'h0                                   ,ast_cnt_mrd_dword}                              | //
//    | 8'h34       |   Read LTSSM FIFO                | Push output LTSSM Black Box FIFO DWORD                                                    | //
//    |             |                                  | lane_act[1:0], rate[1:0], signaldetect, is_lockedtodata[7:0],npor_perstn, ltssmstate[4:0] | //
//    |             |                                  | 10'h0,                                                    ltssm_blackbox_used[7:0]        | //
//    | 8'hFF:07    |   RESERVED                       | RESERVED                                                                                  | //
//    |_____________|__________________________________|___________________________________________________________________________________________| //
//                                                                                                                                                   //
//                                                                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                   //
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcie_tlp_inspector_monitor # (

      parameter ST_DATA_WIDTH                  = 64,
      parameter ST_BE_WIDTH                    = 8,
      parameter ST_CTRL_WIDTH                  = 1,
      parameter LANES                          = 8,
      parameter INSP_ADDRNUM_WORD              = 20,
      parameter PLD_CLK_IS_250MHZ              = 0,
      parameter MONITOR_READYVALID_RATIO       = 1,
      parameter UPSTREAM_READ_LATENCY          = 1,
      parameter UPSTREAM_THROUGHPUT_MEASUREMENT= 1,
      parameter BLACKBOX_LTSSM                 = 1,
      parameter BLACKBOX_LTSSM_DEPTH32_BLOCK   = 2,  // Number of 32 Deep FIFO
      parameter BLACKBOX_AST_TLP               = 1,
      parameter BLACKBOX_AST_TLP_DEPTH32_BLOCK = 4,  // Number of 32 Deep FIFO
      parameter BLACKBOX_AST_TLP_WIDTH_FIFO    = 100  // 3 32 bit TLP
) (
      input [127:0]                    trigger_ast,
      input [ST_BE_WIDTH-1 : 0]        rx_ast_be,
      input [ST_DATA_WIDTH-1 : 0]      rx_ast_data,
      input [1 : 0]                    rx_ast_empty,
      input [ST_CTRL_WIDTH-1 : 0]      rx_ast_eop,
      input [ST_CTRL_WIDTH-1 : 0]      rx_ast_sop,
      input [ST_CTRL_WIDTH-1 : 0]      rx_ast_valid,
      input                            rx_ast_ready,

      input  [ST_DATA_WIDTH-1 : 0]     tx_ast_data,
      input  [1 :0]                    tx_ast_empty,
      input  [ST_CTRL_WIDTH-1 :0]      tx_ast_eop,
      input  [ST_CTRL_WIDTH-1 :0]      tx_ast_sop,
      input                            tx_ast_valid,
      input                            tx_ast_ready,

      input                            trigger_on,
      input                            rx_h_val,
      input [31:0]                     rx_h1,
      input [31:0]                     rx_h2,
      input [31:0]                     rx_h3,
      input [31:0]                     rx_h4,
      input                            tx_h_val,
      input [31:0]                     tx_h1,
      input [31:0]                     tx_h2,
      input [31:0]                     tx_h3,
      input [31:0]                     tx_h4,

      input [3 : 0]                    lane_act,
      input [4 : 0]                    ltssmstate,
      input [1 : 0]                    rate,
      input [LANES-1:0]                signaldetect,
      input [LANES-1:0]                is_lockedtodata,
      input                            npor_perstn,

      // TLP Analysis output
      input   [7:0]                    monitor_addr /* synthesis preserve */,
      input                            monitor_rd_pulse ,
      output  reg  [31:0]              monitor_data,

      input clk,
      input sclr

      );

localparam ZEROS = 512'h0;

//////////////////////////////////////////////////////////////////////////////////
//
// Inspector Info Result (TDM)
//
wire [15:0] ast_cnt_rx_sop;     // Count the number of SOP
wire [15:0] ast_cnt_rx_ready;   // Count the number of times when ready goes to 0 when valid goes to 0
wire [15:0] ast_cnt_tx_sop;     // Count the number of SOP
wire [15:0] ast_cnt_tx_ready;   // Count the number of times when ready goes to 0 when valid goes to 0

wire [19:0] ast_cnt_mwr_clk  ;  // Number of clock cycles required during the transfer
wire [19:0] ast_cnt_mwr_dword;  // Number of DWORD transfered
wire [19:0] ast_cnt_mrd_clk  ;  // Number of clock cycles required during the transfer
wire [19:0] ast_cnt_mrd_dword;  // Number of DWORD transfered

wire [14:0] ast_min_read_latency_cnt;
wire [14:0] ast_max_read_latency_cnt;

wire [19:0] ltssm_blackbox;
wire [7:0]  ltssm_blackbox_used;

wire [127:0] tlp_blackbox;
wire [7:0]   tlp_blackbox_used;

wire [127:0]   tlp_h1h2;

reg [31:0] monitor_data_bb;
localparam INSP_ADDRREADY_SOP_RX         = 0,
           INSP_ADDRREADY_SOP_TX         = 1,
           INSP_ADDRLATENCY_MRD_UPSTREAM = 2,
           INSP_ADDRMWR_THROUGHPUT_CLK   = 3,
           INSP_ADDRMWR_THROUGHPUT_DWORD = 4,
           INSP_ADDRMRD_THROUGHPUT_CLK   = 5,
           INSP_ADDRMRD_THROUGHPUT_DWORD = 6,
           INSP_ADDR_LTSSM_BLACKBOX      = 7,
           INSP_ADDR_TLP_BB              = 8,
           INSP_ADDR_TLP_BB_H1           = 9,
           INSP_ADDR_TLP_BB_H2           = 10,
           INSP_ADDR_TLP_BB_H3           = 11;
reg [INSP_ADDRNUM_WORD-1:0] monitor_addr_predec; //Pre-decode VSEC ADDR

localparam LTSSM_BB_USED_WIDTH = 5;

always @(posedge clk) begin : p_insp_vsec
   if (sclr==1'b1) begin
      monitor_data         <= 32'h0;
      monitor_data_bb      <= 32'h0;
      monitor_addr_predec <= ZEROS[INSP_ADDRNUM_WORD-1:0];
   end
   else begin

      monitor_addr_predec[INSP_ADDRREADY_SOP_RX        ] <= (monitor_addr==8'h18)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDRREADY_SOP_TX        ] <= (monitor_addr==8'h1C)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDRLATENCY_MRD_UPSTREAM] <= (monitor_addr==8'h20)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDRMWR_THROUGHPUT_CLK  ] <= (monitor_addr==8'h24)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDRMWR_THROUGHPUT_DWORD] <= (monitor_addr==8'h28)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDRMRD_THROUGHPUT_CLK  ] <= (monitor_addr==8'h2C)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDRMRD_THROUGHPUT_DWORD] <= (monitor_addr==8'h30)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDR_LTSSM_BLACKBOX     ] <= (monitor_addr==8'h34)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDR_TLP_BB             ] <= (monitor_addr==8'h38)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDR_TLP_BB_H1          ] <= (monitor_addr==8'h3C)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDR_TLP_BB_H2          ] <= (monitor_addr==8'h40)?1'b1:1'b0;
      monitor_addr_predec[INSP_ADDR_TLP_BB_H3          ] <= (monitor_addr==8'h44)?1'b1:1'b0;

      if      (monitor_addr_predec[INSP_ADDRREADY_SOP_RX]==1'b1) begin
         monitor_data       <= {ast_cnt_rx_ready, ast_cnt_rx_sop};
      end
      else if      (monitor_addr_predec[INSP_ADDRREADY_SOP_TX]==1'b1) begin
         monitor_data       <= {ast_cnt_tx_ready, ast_cnt_tx_sop};
      end
      else if (monitor_addr_predec[INSP_ADDRLATENCY_MRD_UPSTREAM]==1'b1) begin
         monitor_data       <= {(PLD_CLK_IS_250MHZ==1)?2'b01:2'b00      , ast_max_read_latency_cnt, ast_min_read_latency_cnt};
      end
      else if (monitor_addr_predec[INSP_ADDRMWR_THROUGHPUT_CLK]==1'b1) begin
         monitor_data       <= {(PLD_CLK_IS_250MHZ==1)?2'b01:2'b00, 10'h0 , ast_cnt_mwr_clk};
      end
      else if (monitor_addr_predec[INSP_ADDRMWR_THROUGHPUT_DWORD]==1'b1) begin
         monitor_data       <= {12'h0                                     , ast_cnt_mwr_dword};
      end
      else if (monitor_addr_predec[INSP_ADDRMRD_THROUGHPUT_CLK]==1'b1) begin
         monitor_data       <= {(PLD_CLK_IS_250MHZ==1)?2'b01:2'b00, 10'h0 , ast_cnt_mrd_clk};
      end
      else if (monitor_addr_predec[INSP_ADDRMRD_THROUGHPUT_DWORD]==1'b1) begin
         monitor_data       <= {12'h0                                     , ast_cnt_mrd_dword};
      end
      else begin
         monitor_data       <= monitor_data_bb;
      end

      if (monitor_addr_predec[INSP_ADDR_LTSSM_BLACKBOX]==1'b1) begin
         monitor_data_bb    <= {4'h0,                              ltssm_blackbox_used , ltssm_blackbox};
      end
      else if (monitor_addr_predec[INSP_ADDR_TLP_BB]==1'b1) begin
         monitor_data_bb       <= tlp_h1h2[127:96];
      end
      else if (monitor_addr_predec[INSP_ADDR_TLP_BB_H1]==1'b1) begin
         monitor_data_bb       <= tlp_h1h2[31:0];
      end
      else if (monitor_addr_predec[INSP_ADDR_TLP_BB_H2]==1'b1) begin
         monitor_data_bb       <= tlp_h1h2[63:32];
      end
      else if (monitor_addr_predec[INSP_ADDR_TLP_BB_H3]==1'b1) begin
         monitor_data_bb       <= tlp_h1h2[95:64];
      end
   end
end
//
// END Inspector Info Result (TDM)
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//
// Testbench display only
//
// synthesis translate_off
function integer throughputMBps;
   input [19:0] nclk;
   input [19:0] ndword;
   reg   [31:0] nbytes;
   reg   [31:0] ellapse_timens;
   begin
      ellapse_timens = (PLD_CLK_IS_250MHZ==1)?nclk*4:nclk*8;
      nbytes         = ndword*4;
      throughputMBps = (ellapse_timens>32'h0)? (nbytes*1000)  / ellapse_timens :0;
   end
endfunction


reg [31:0] write_troughtput, read_troughtput;
initial begin
   write_troughtput = 32'h0;
   read_troughtput  = 32'h0;
end
always @(posedge clk) begin : p_sim_tpwr
   write_troughtput <= ((ast_cnt_mwr_clk>20'h0)&&(ast_cnt_mwr_dword>20'h0))?throughputMBps(ast_cnt_mwr_clk,ast_cnt_mwr_dword):32'h0;
   read_troughtput  <= ((ast_cnt_mrd_clk>20'h0)&&(ast_cnt_mrd_dword>20'h0))?throughputMBps(ast_cnt_mrd_clk,ast_cnt_mrd_dword):32'h0;
end

final begin
   if (UPSTREAM_THROUGHPUT_MEASUREMENT==1) begin
      $display("INFO: altpcie_tlp_inspector_monitor ::---------------------------------------------------------------------------------------------");
      $display("INFO: altpcie_tlp_inspector_monitor ::               Upstream memory Write Throughput                                              ");
      $display("INFO: altpcie_tlp_inspector_monitor ::---------------------------------------------------------------------------------------------");
      $display("INFO: altpcie_tlp_inspector_monitor :: Throughput               : %d MBytes/s  ",write_troughtput);
      $display("INFO: altpcie_tlp_inspector_monitor ::                            %d bytes have been sent within %d clock cycles at %s" ,ast_cnt_mwr_dword*4,ast_cnt_mwr_clk, (PLD_CLK_IS_250MHZ==1)?"250 Mhz":"125 Mhz");
      $display("INFO: altpcie_tlp_inspector_monitor ::---------------------------------------------------------------------------------------------");
      $display("INFO: altpcie_tlp_inspector_monitor ::               Upstream memory Read Throughput                                              ");
      $display("INFO: altpcie_tlp_inspector_monitor ::---------------------------------------------------------------------------------------------");
      $display("INFO: altpcie_tlp_inspector_monitor :: Throughput               : %d MBytes/s  ",read_troughtput);
      $display("INFO: altpcie_tlp_inspector_monitor ::                            %d bytes have been sent within %d clock cycles at %s" ,ast_cnt_mrd_dword*4,ast_cnt_mrd_clk, (PLD_CLK_IS_250MHZ==1)?"250 Mhz":"125 Mhz");
   end
   if (UPSTREAM_READ_LATENCY==1) begin
      $display("INFO: altpcie_tlp_inspector_monitor ::---------------------------------------------------------------------------------------------");
      $display("INFO: altpcie_tlp_inspector_monitor ::               Upstream read to completion latency                                           ");
      $display("INFO: altpcie_tlp_inspector_monitor ::---------------------------------------------------------------------------------------------");
      $display("INFO: altpcie_tlp_inspector_monitor :: Minimum measured latency : %d ns"  ,(PLD_CLK_IS_250MHZ==1)?ast_min_read_latency_cnt*4:ast_min_read_latency_cnt*8 );
      $display("INFO: altpcie_tlp_inspector_monitor :: Maximum measured latency : %d ns"  ,(PLD_CLK_IS_250MHZ==1)?ast_max_read_latency_cnt*4:ast_max_read_latency_cnt*8 );
   end
end
// synthesis translate_on
//
// END TB Display only
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//
// Analyze ready_valid
//
generate begin : g_monitor_ready
   if (MONITOR_READYVALID_RATIO==1) begin
      reg [15:0]                     count_rx_sop;  // Count the number of SOP
      reg [15:0]                     count_rx_ready;// Count the number of times when ready goes to 0 when valid goes to 0
      reg [15:0]                     count_tx_sop;   // Count the number of SOP
      reg [15:0]                     count_tx_ready; // Count the number of times when ready goes to 0 when valid goes to 0
      always @(posedge clk) begin : p_readyvalid
         if (sclr==1'b1) begin
            count_tx_ready <=16'h0; // Count how many times HIP de-assert ready when Valid Asserted
            count_tx_sop   <=16'h0; // Count how many SOP
            count_rx_ready <=16'h0; // Count how many times HIP de-assert ready when Valid Asserted
            count_rx_sop   <=16'h0; // Count how many SOP
         end
         else if (trigger_on == 1'b1) begin
            if (tx_ast_sop[ST_CTRL_WIDTH-1:0]>ZEROS[ST_CTRL_WIDTH-1:0]) begin
               count_tx_sop   <= count_tx_sop+16'h1;
            end
            if ((tx_ast_valid==1'b1)&&(tx_ast_ready==1'b0)) begin
               count_tx_ready <= count_tx_ready+16'h1;
            end
            if (rx_ast_sop[ST_CTRL_WIDTH-1:0]>ZEROS[ST_CTRL_WIDTH-1:0]) begin
               count_rx_sop   <= count_rx_sop+16'h1;
            end
            if ((rx_ast_valid[ST_CTRL_WIDTH-1:0]>ZEROS[ST_CTRL_WIDTH-1:0])&&(rx_ast_ready==1'b0)) begin
               count_rx_ready <= count_rx_ready+16'h1;
            end
         end
      end
      assign ast_cnt_rx_sop   = count_rx_sop  ;
      assign ast_cnt_rx_ready = count_rx_ready;
      assign ast_cnt_tx_sop   = count_tx_sop  ;
      assign ast_cnt_tx_ready = count_tx_ready;
   end
   if (MONITOR_READYVALID_RATIO==0) begin
      assign ast_cnt_rx_sop   = 16'h0;
      assign ast_cnt_rx_ready = 16'h0;
      assign ast_cnt_tx_sop   = 16'h0;
      assign ast_cnt_tx_ready = 16'h0;
   end
end
endgenerate

//
// END Analyze ready_valid
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//
// Analyze upstream_latency
//
generate begin : g_monitor_upstream_latency
   if (UPSTREAM_READ_LATENCY==1) begin
      reg [14:0] latency_cnt;
      reg [14:0] max_read_latency_cnt;
      reg [14:0] min_read_latency_cnt;
      reg [7:0]  mrdtag;
      always @(posedge clk) begin : p_latency
         if (sclr==1'b1) begin
            latency_cnt          <= 15'h0;
            max_read_latency_cnt <= 15'h0;
            min_read_latency_cnt <= 15'h0;
            mrdtag               <= 8'h0;
         end
         else if (trigger_on == 1'b1) begin
            // Check for AST TX MRd
            if ((tx_h_val==1'b1)&&((tx_h1[31:24]==8'h0)||(tx_h1[31:24]==8'b0010_0000))&&(latency_cnt==15'h0)) begin
               mrdtag      <= tx_h2[15:8];
               latency_cnt <= latency_cnt+15'h1;
            end
            // Check for AST RX CPL
            else if ((rx_h_val==1'b1)&&(rx_h1[28:24]==5'b01010)&&(mrdtag==rx_h3[15:8])) begin
               latency_cnt <= 15'h0;
               if (min_read_latency_cnt==15'h0) begin
                  min_read_latency_cnt<= latency_cnt;
               end
               else if (min_read_latency_cnt>latency_cnt) begin
                  min_read_latency_cnt<= latency_cnt;
               end
               if (max_read_latency_cnt==15'h0) begin
                  max_read_latency_cnt<= latency_cnt;
               end
               else if (max_read_latency_cnt<latency_cnt) begin
                  max_read_latency_cnt<= latency_cnt;
               end
            end
            else if (latency_cnt>15'h0) begin
               latency_cnt <= latency_cnt+15'h1;
            end
         end
      end
      assign ast_min_read_latency_cnt = min_read_latency_cnt;
      assign ast_max_read_latency_cnt = max_read_latency_cnt;
   end
   if (UPSTREAM_READ_LATENCY==0) begin
      assign ast_min_read_latency_cnt = 15'h0;
      assign ast_max_read_latency_cnt = 15'h0;
   end
end
endgenerate
//
// END Analyze upstream_latency
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//
// Analyze upstream_throughput
//
generate begin : g_monitor_upstream_throughput
   if (UPSTREAM_THROUGHPUT_MEASUREMENT==1) begin
      //
      // Write Throughput
      //
      reg [19:0] cnt_mwr_clk;        // Number of clock cycles required during the transfer
      reg [19:0] cnt_mwr_dword;      // Number of DWORD transfered
      reg [7:0]  cnt_mwr_inactive;
      reg [7:0]  cnt_tx_mwr_to_tx_eop;
      reg cnt_mwr_dword_eq_zero;
      reg cnt_mwr_dword_max;
      reg cnt_mwr_clk_eq_zero;
      reg cnt_mwr_inactive_eq_FE;
      reg cnt_mwr_inactive_eq_FF;
      reg tx_mwr_pulse;
      reg tx_eop_on_h;
      reg tx_eop_txmwr;
      reg tx_ast_valid_on_h;

      reg [19:0] cnt_mrd_clk;        // Number of clock cycles required during the transfer
      reg        cnt_mrd_clk_eq_zero;
      reg [19:0] cnt_mrd_dword;      // Number of DWORD transfered
      reg        cnt_mrd_dword_eq_zero;
      reg        cnt_mrd_dword_max;
      reg [7:0]  cnt_rx_cpl_to_eop;
      reg [7:0]  cnt_cpl_inactive;
      reg        cnt_cpl_inactive_eq_FE;
      reg        cnt_cpl_inactive_eq_FF;
      reg tx_mrd_pulse;
      reg rx_eop_on_h;
      reg rx_eop_cpl;
      reg rx_ast_valid_on_h;
      reg rx_cpl_pulse   ;

      always @(posedge clk) begin : p_mwr_throughput
         if (sclr==1'b1) begin

            rx_eop_on_h            <= 1'b0;
            rx_ast_valid_on_h      <= 1'b0;
            tx_eop_on_h            <= 1'b0;
            tx_ast_valid_on_h      <= 1'b0;

            cnt_mwr_clk            <= 20'h0;
            cnt_mwr_clk_eq_zero    <= 1'b0;
            cnt_mwr_dword          <= 20'h0;
            cnt_mwr_dword_max      <= 1'b0;
            cnt_mwr_dword_eq_zero  <= 1'b0;
            cnt_mwr_inactive       <= 8'h0;
            cnt_mwr_inactive_eq_FE <= 1'b0;
            cnt_mwr_inactive_eq_FF <= 1'b0;
            tx_mwr_pulse           <= 1'b0;
            cnt_tx_mwr_to_tx_eop   <= 8'h0;
            tx_eop_txmwr           <= 1'b0;

            cnt_mrd_clk            <= 20'h0;
            cnt_mrd_clk_eq_zero    <= 1'b0;
            cnt_mrd_dword          <= 20'h0;
            cnt_mrd_dword_max      <= 1'b0;
            cnt_mrd_dword_eq_zero  <= 1'b0;
            tx_mrd_pulse           <= 1'b0;
            cnt_cpl_inactive       <= 8'h0;
            cnt_cpl_inactive_eq_FE <= 1'b0;
            cnt_cpl_inactive_eq_FF <= 1'b0;
            cnt_rx_cpl_to_eop      <= 8'h0;
            rx_eop_cpl             <= 1'b1;
            rx_cpl_pulse           <= 1'b0;

         end
         else if (trigger_on == 1'b1) begin
            tx_eop_on_h            <= (tx_ast_eop[ST_CTRL_WIDTH-1 :0]>ZEROS[ST_CTRL_WIDTH-1 :0])?1'b1:1'b0;
            tx_ast_valid_on_h      <= tx_ast_valid;
            rx_eop_on_h            <= (rx_ast_eop[ST_CTRL_WIDTH-1 :0]>ZEROS[ST_CTRL_WIDTH-1 :0])?1'b1:1'b0;
            rx_ast_valid_on_h      <= (rx_ast_valid[ST_CTRL_WIDTH-1 : 0]>ZEROS[ST_CTRL_WIDTH-1 : 0])?1'b1:1'b0  ;

            // Compute MRd throughput
            cnt_mrd_dword_eq_zero  <= (cnt_mrd_dword    == 20'h0)?1'b1:1'b0;
            cnt_mrd_dword_max      <= (cnt_mrd_dword>20'hF_FF00 )?1'b1:1'b0;
            cnt_mrd_clk_eq_zero    <= (cnt_mrd_clk      == 20'h0)?1'b1:1'b0;
            cnt_cpl_inactive_eq_FE <= (cnt_cpl_inactive == 8'hFE)?1'b1:1'b0;
            cnt_cpl_inactive_eq_FF <= (cnt_cpl_inactive == 8'hFF)?1'b1:1'b0;
            tx_mrd_pulse           <= ((tx_h_val==1'b1)&&((tx_h1[31:24]==8'b0000_0000)||(tx_h1[31:24]==8'b0010_0000))&&(tx_h1[9:0]>10'h1))?1'b1: 1'b0;
            rx_cpl_pulse           <= ((rx_h_val==1'b1)&&((rx_h1[31:24]==8'b0000_1010)||(rx_h1[31:24]==8'b0100_1010))                    )?1'b1: 1'b0;

            // Count DWORD starting first TX MRd with a payload>2
            if ((cnt_mrd_dword_max==1'b0)&&(tx_h_val==1'b1)&&((tx_h1[31:24]==8'b0000_0000)||(tx_h1[31:24]==8'b0010_0000))&&(tx_h1[9:0]>10'h1)) begin
               cnt_mrd_dword <= cnt_mrd_dword+{10'h0, tx_h1[9:0]};
            end
            // Count Clock cycles, stop counting if inactive rx_valid for more than 256 cycles
            if ((cnt_mrd_dword_max==1'b0)&&(cnt_mrd_dword_eq_zero==1'b0)&&(cnt_cpl_inactive_eq_FF==1'b0)&&(cnt_cpl_inactive_eq_FE==1'b0)) begin
               cnt_mrd_clk <= cnt_mrd_clk+20'h1;
            end
            else if ((cnt_cpl_inactive_eq_FE==1'b1)&&(cnt_mrd_clk>20'hFD)) begin
               cnt_mrd_clk <= cnt_mrd_clk-cnt_rx_cpl_to_eop;
            end

            if ((tx_mrd_pulse==1'b1)||(rx_cpl_pulse==1'b1)) begin
               cnt_cpl_inactive <= 8'h0;
            end
            else if ((cnt_cpl_inactive<8'hFF)&&(cnt_mrd_dword_eq_zero==1'b0)) begin
               cnt_cpl_inactive <= cnt_cpl_inactive+8'h1;
            end

            if (rx_cpl_pulse==1'b1) begin
               cnt_rx_cpl_to_eop <= 8'hFE;
            end
            else if ((rx_eop_cpl==1'b0)&&(rx_ast_valid_on_h==1'b1)) begin
               cnt_rx_cpl_to_eop <= cnt_rx_cpl_to_eop-8'h1;
            end

            if (rx_eop_on_h==1'b1) begin
               rx_eop_cpl <= 1'b1;
            end
            else if ((rx_h_val==1'b1)&&((rx_h1[31:24]==8'b0000_1010)||(rx_h1[31:24]==8'b0100_1010)) ) begin
               rx_eop_cpl <= 1'b0;
            end

            // Compute Mwr throughput
            // Check for AST TX MWr
            cnt_mwr_dword_eq_zero  <= (cnt_mwr_dword    == 20'h0)?1'b1:1'b0;
            cnt_mwr_dword_max      <= (cnt_mwr_dword>20'hF_FF00 )?1'b1:1'b0;
            cnt_mwr_clk_eq_zero    <= (cnt_mwr_clk      == 20'h0)?1'b1:1'b0;
            cnt_mwr_inactive_eq_FE <= (cnt_mwr_inactive == 8'hFE)?1'b1:1'b0;
            cnt_mwr_inactive_eq_FF <= (cnt_mwr_inactive == 8'hFF)?1'b1:1'b0;
            tx_mwr_pulse           <= ((tx_h_val==1'b1)&&((tx_h1[31:24]==8'b0100_0000)||(tx_h1[31:24]==8'b0110_0000))&& (tx_h1[9:0]>10'h2))?1'b1: 1'b0;
            // Count DWORD starting first TX MWr with a payload>2
            if ((cnt_mwr_dword_max==1'b0)&&(tx_h_val==1'b1)&&((tx_h1[31:24]==8'b0100_0000)||(tx_h1[31:24]==8'b0110_0000)) && (tx_h1[9:0]>10'h2)) begin
               cnt_mwr_dword <= cnt_mwr_dword+{10'h0, tx_h1[9:0]};
            end
            // Count Clock cycles, stop counting if inactive tx_valid for more than 256 cycles
            if ((cnt_mwr_dword_max==1'b0)&&(cnt_mwr_dword_eq_zero==1'b0)&&(cnt_mwr_inactive_eq_FF==1'b0)&&(cnt_mwr_inactive_eq_FE==1'b0)) begin
               cnt_mwr_clk <= cnt_mwr_clk+20'h1;
            end
            else if ((cnt_mwr_inactive_eq_FE==1'b1)&&(cnt_mwr_clk>20'hFD)) begin
               cnt_mwr_clk <= cnt_mwr_clk-cnt_tx_mwr_to_tx_eop;
            end

            if (tx_mwr_pulse==1'b1) begin
               cnt_mwr_inactive <= 8'h0;
            end
            else if ((cnt_mwr_inactive<8'hFF)&&(cnt_mwr_dword_eq_zero==1'b0)&&(tx_ast_valid_on_h==1'b0)) begin
               cnt_mwr_inactive <= cnt_mwr_inactive+8'h1;
            end

            if (tx_mwr_pulse==1'b1) begin
               cnt_tx_mwr_to_tx_eop <= 8'hFE;
            end
            else if ((tx_eop_txmwr==1'b0)&&(tx_ast_valid_on_h==1'b1)) begin
               cnt_tx_mwr_to_tx_eop <= cnt_tx_mwr_to_tx_eop-8'h1;
            end

            if (tx_eop_on_h==1'b1) begin
               tx_eop_txmwr <= 1'b1;
            end
            else if ((tx_h_val==1'b1)&&((tx_h1[31:24]==8'b0100_0000)||(tx_h1[31:24]==8'b0110_0000))) begin
               tx_eop_txmwr <= 1'b0;
            end
         end
      end

      assign ast_cnt_mwr_clk  = cnt_mwr_clk  ;      // Number of clock cycles required during the transfer
      assign ast_cnt_mwr_dword= cnt_mwr_dword;      // Number of DWORD transfered

      assign ast_cnt_mrd_clk  = cnt_mrd_clk  ;      // Number of clock cycles required during the transfer
      assign ast_cnt_mrd_dword= cnt_mrd_dword;      // Number of DWORD transfered
   end

   if (UPSTREAM_THROUGHPUT_MEASUREMENT==0) begin
      assign ast_cnt_mwr_clk  = 20'h0;      // Number of clock cycles required during the transfer
      assign ast_cnt_mwr_dword= 20'h0;      // Number of DWORD transfered
      assign ast_cnt_mrd_clk  = 20'h0;      // Number of clock cycles required during the transfer
      assign ast_cnt_mrd_dword= 20'h0;      // Number of DWORD transfered
   end
end
endgenerate
//
// END Analyze upstream_throughput
//////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////
//
// LTSSM Blackbox
//
generate begin : g_blackbox_ltssm
   if (BLACKBOX_LTSSM==1) begin
      reg [1 : 0]                     lane_act_r;
      reg [4 : 0]                     ltssmstate_r;
      reg [1 : 0]                     rate_r;
      reg                             signaldetect_r;
      reg [7:0]                       is_lockedtodata_r;
      reg                             npor_perstn_r;
      reg                             ltssm_transit;
      wire                            ltssmfifo_full;
      wire                            ltssmfifo_empty;
      wire  [19:0]                    ltssmfifo_rddata;
      wire  [LTSSM_BB_USED_WIDTH-1:0] ltssmfifo_used;
      reg                             ltssmfifo_rreq;

      always @(posedge clk) begin : p_bb_ltssm
         if (sclr==1'b1) begin
            lane_act_r        <= ZEROS[1 : 0];
            ltssmstate_r      <= ZEROS[4 : 0];
            rate_r            <= ZEROS[1 : 0];
            signaldetect_r    <= 1'b0        ;
            is_lockedtodata_r <= ZEROS[7:0]  ;
            npor_perstn_r     <= 1'b0        ;
            ltssm_transit     <= 1'b0;
            ltssmfifo_rreq    <= 1'b0;
         end
         else begin
            lane_act_r                   <= (lane_act==4'b1000)?2'h3:
                                            (lane_act==4'b0100)?2'h2:
                                            (lane_act==4'b0010)?2'h1:2'h0;
            ltssmstate_r                 <= ltssmstate;
            rate_r                       <= rate      ;
            signaldetect_r               <= (signaldetect[LANES-1:0]>0)?1'b1:1'b0;
            is_lockedtodata_r[LANES-1:0] <= is_lockedtodata[LANES-1:0];
            npor_perstn_r                <= npor_perstn                   ;
            ltssm_transit                <= (ltssmstate==ltssmstate_r)?1'b0:(ltssmfifo_full==1'b1)?1'b0:1'b1;
            ltssmfifo_rreq               <= ((monitor_addr==8'h34) && (monitor_rd_pulse==1'b1) && (ltssmfifo_empty==1'b0))?1'b1:1'b0;
         end
      end
      altpcie_scfifo #(
         .WIDTH          (20),// typical 20,40,60,80
         .NUM_FIFO32     (BLACKBOX_LTSSM_DEPTH32_BLOCK )// Number of 32 DEEP FIFO
      ) ltssmfifo (
         .clk            (clk) ,  // input
         .sclr           (sclr) ,  // input
                          //                   2           2               1                      8              1             5
         .wdata          ({1'b0, lane_act_r[1:0], rate_r[1:0], signaldetect_r, is_lockedtodata_r[7:0],npor_perstn_r, ltssmstate_r[4:0]}) ,  // input [WIDTH-1:0]
         .wreq           (ltssm_transit)       ,  // input
         .full           (ltssmfifo_full)      ,  // output
         .rdata          (ltssmfifo_rddata)    ,  // output [WIDTH-1:0]
         .rreq           (ltssmfifo_rreq)      ,  // input
         .empty          (ltssmfifo_empty)     ,  // output
         .used           (ltssmfifo_used[LTSSM_BB_USED_WIDTH-1:0])    // output [4:0]
      );
      assign ltssm_blackbox      = ltssmfifo_rddata;
      assign ltssm_blackbox_used = {3'h0, ltssmfifo_used[LTSSM_BB_USED_WIDTH-1:0]};
   end
   if (BLACKBOX_LTSSM==0) begin
      assign ltssm_blackbox      = 20'h0;
      assign ltssm_blackbox_used = 8'h0;
   end
end
endgenerate
//
// END Analyze LTSSM Blackbox
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//
// AST TLP Blackbox
//
generate begin : g_bb_tlp
   if (BLACKBOX_AST_TLP==1) begin
      reg [3:0] tlp_cnt      ;
      wire full_tx           ;
      wire [BLACKBOX_AST_TLP_WIDTH_FIFO-1:0] rdata_tx          ;
      reg rreq_tx            ;
      wire empty_tx          ;
      wire [4:0] used_tx     ;

      wire full_rx           ;
      wire[BLACKBOX_AST_TLP_WIDTH_FIFO-1:0]  rdata_rx          ;
      reg rreq_rx            ;
      wire empty_rx          ;
      wire [4:0]  used_rx    ;

      reg txrxrreq;

      reg  wreq_ast_r        ;
      reg  txtlp_sel         ;
      wire full_ast          ;
      wire [BLACKBOX_AST_TLP_WIDTH_FIFO-1:0]  wdata_ast  ;
      wire [BLACKBOX_AST_TLP_WIDTH_FIFO-1:0]  rdata_ast  ;
      reg  rreq_ast          ;
      wire empty_ast         ;
      wire [4:0]  used_ast   ;

      always @(posedge clk) begin : p_bb_ltssm
         if (sclr==1'b1) begin
            tlp_cnt     <= 4'h0;
            wreq_ast_r  <= 1'b0;
            rreq_rx     <= 1'b0;
            rreq_tx     <= 1'b0;
            rreq_ast    <= 1'b0;
            txtlp_sel   <= 1'b0;
            txrxrreq    <= 1'b0;
         end
         else begin
            if ((rx_h_val==1'b1) || (tx_h_val==1'b1)) begin
               tlp_cnt <= (tlp_cnt<4'hF)?tlp_cnt+4'h1:4'h0;
            end
            if (full_ast==1'b0) begin
               if ((empty_tx==1'b0)&&(empty_rx==1'b1)) begin
                  rreq_tx  <= 1'b1;
                  rreq_rx  <= 1'b0;
               end
               else if ((empty_tx==1'b1)&&(empty_rx==1'b0)) begin
                  rreq_tx  <= 1'b0;
                  rreq_rx  <= 1'b1;
               end
               else if ((empty_tx==1'b1)&&(empty_rx==1'b0)) begin
                  txrxrreq <= (txrxrreq==1'b1)?1'b0:1'b1;
                  rreq_tx  <= txrxrreq;
                  rreq_rx  <= ~txrxrreq;
                  //TODO Read Counter to re-order RX/TX Fifo
               end
               else begin
                  rreq_tx  <= 1'b0;
                  rreq_rx  <= 1'b0;
               end
               wreq_ast_r  <= ((rreq_tx==1'b1)&&(empty_tx==1'b0))?1'b1:
                              ((rreq_rx==1'b1)&&(empty_rx==1'b0))?1'b1:1'b0;
               txtlp_sel   <= rreq_tx;
            end
            rreq_ast       <= ((monitor_addr==8'h38) && (monitor_rd_pulse==1'b1) && (empty_ast==1'b0))?1'b1:1'b0;
         end
      end

      altpcie_scfifo #(
         .WIDTH          (BLACKBOX_AST_TLP_WIDTH_FIFO),
         .NUM_FIFO32     (0 ) // 16 Deep only
      ) tlprxfifo (
         .clk            (clk) ,                               // input
         .sclr           (sclr) ,                              // input
         .wdata          ({tlp_cnt[2:0],1'b1, rx_h3, rx_h2, rx_h1}),//
         .wreq           (((full_rx==1'b0)&&(trigger_on==1'b1))?rx_h_val:1'b0)    ,                       // input
         .full           (full_rx)    ,   // output
         .rdata          (rdata_rx)    ,                       // output [WIDTH-1:0]
         .rreq           ((empty_rx==1'b0)?rreq_rx:1'b0)    ,                       // input
         .empty          (empty_rx)    ,                       // output
         .used           (used_rx )                            // output [4:0]
      );

      altpcie_scfifo #(
         .WIDTH          (BLACKBOX_AST_TLP_WIDTH_FIFO),
         .NUM_FIFO32     (0 ) // 16 Deep only
      ) tlptxfifo (
         .clk            (clk)            ,
         .sclr           (sclr)           ,
         .wdata          ({tlp_cnt[2:0],1'b0, tx_h3, tx_h2, tx_h1}) ,
         .wreq           ((full_tx==1'b0)?tx_h_val:1'b0)       ,
         .full           (full_tx  )      ,
         .rdata          (rdata_tx )      ,
         .rreq           ((empty_tx==1'b0)?rreq_tx:1'b0  )      ,
         .empty          (empty_tx )      ,
         .used           (used_tx  )
      );

      altpcie_scfifo #(
         .WIDTH          (BLACKBOX_AST_TLP_WIDTH_FIFO),
         .NUM_FIFO32     (4 ) // 128 deep
      ) tlpastfifo (
         .clk            (clk      ),
         .sclr           (sclr     ),
         .wdata          (wdata_ast),
         .wreq           (wreq_ast_r ),
         .full           (full_ast ),
         .rdata          (rdata_ast),
         .rreq           (rreq_ast ),
         .empty          (empty_ast),
         .used           (used_ast )
      );
      assign wdata_ast = (txtlp_sel==1'b1)?rdata_tx:rdata_rx;
      //                          106       105        104:100    , 99:0
      assign tlp_h1h2  = { empty_ast, full_ast, used_ast[4:0], 21'h0, rdata_ast};

   end
   if (BLACKBOX_AST_TLP==0) begin
      assign tlp_h1h2      = 128'h0;
   end
end
endgenerate
//
// END Analyze upstream_throughput
//////////////////////////////////////////////////////////////////////////////////
endmodule
