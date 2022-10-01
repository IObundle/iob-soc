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
//    ALTPCIE_TLP_INSPECTOR : Optional module to monitor TLP Performances on AvalonTream HIP Bus, added to ALTPCIE_HIP_256_PIPEn1B                   //
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
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                   //
// Trigger OP Codes input trigger [127:0] //                                                                                                         //
//                                                                                                                                                   //
// ---------------Trigger First Dword : 31:0 : Opcode-----------------------------------------                                                       //
//                                                                                                                                                   //
// trigger [0]      | SOP         : When 1 trigger on first SOP                                                                                      //
//         [1]      | TX/RX       : When 1 trigger on RX AST, When 0 Trigger on TX AST                                                               //
//         [2]      | FMT_TLP     : When check trigger FMT_TLP                                                                                       //
//         [3]      | TAG         : When check trigger TAG                                                                                           //
//         [5:4]    | Address     : When check trigger Address Lower 24 bits                                                                         //
//                  |                    5:4 =2'b01, 8-bit addr LSB                                                                                  //
//                  |                    5:4 =2'b10, 16-bit addr LSB                                                                                 //
//                  |                    5:4 =2'b11, 32-bit addr LSB                                                                                 //
//         [6]      | First BE    : When check trigger first BE                                                                                      //
//         [7]      | Last BE     : When check trigger last BE                                                                                       //
//         [8]      | Attr        : When check trigger Attr                                                                                          //
//         [9]      | Reset trigger only                                                                                                             //
//         [10]     | Reset reset Inspector                                                                                                          //
//         [11]     | Enable Trigger ON  : When set activate trigger logic  -                                                                        //
//         [31:12]  | RESERVED                                                                                                                       //
//                  |                                                                                                                                //
// ---------------Trigger Second Dword : 63:32 : Data Compare-----------------------------------------                                               //
//                  |                                                                                                                                //
// trigger [39:32]  | FMT TYPE: When trigger[2] set, trigger on                                                                                      //
//                  |    _________________________________________                                                                                   /
//                  |    |                               |        |                                                                                  //
//                  |    |  {FMT,TYPE}                   |        |                                                                                  //
//                  |    |_______________________________|________|                                                                                  //
//                  |    | 8'b0000_0000   8'h0     8'd0  | MRd    |                                                                                  //
//                  |    | 8'b0010_0000   8'h20    8'd32 | MRd    |                                                                                  //
//                  |    | 8'b0000_0001   8'h1     8'd1  | MRdLk  |                                                                                  //
//                  |    | 8'b0010_0001   8'h21    8'd33 | MRdLk  |                                                                                  //
//                  |    | 8'b0100_0000   8'h40    8'd64 | MWr    |                                                                                  //
//                  |    | 8'b0110_0000   8'h60    8'd96 | MWr    |                                                                                  //
//                  |    | 8'b0000_0010   8'h2     8'd2  | IORd   |                                                                                  //
//                  |    | 8'b0100_0010   8'h42    8'd66 | IOWr   |                                                                                  //
//                  |    | 8'b0000_0100   8'h4     8'd4  | CfgRd0 |                                                                                  //
//                  |    | 8'b0100_0100   8'h44    8'd68 | CfgWr0 |                                                                                  //
//                  |    | 8'b0000_0101   8'h5     8'd5  | CfgRd1 |                                                                                  //
//                  |    | 8'b0100_0101   8'h45    8'd69 | CfgWr1 |                                                                                  //
//                  |    | 8'b0011_0XXX   8'h30    8'd48 | Msg    |                                                                                  //
//                  |    | 8'b0111_0XXX   8'h70    8'd112| MsgD   |                                                                                  //
//                  |    | 8'b0000_1010   8'hA     8'd10 | Cpl    |                                                                                  //
//                  |    | 8'b0100_1010   8'h4A    8'd74 | CplD   |                                                                                  //
//                  |    | 8'b0000_1011   8'hB     8'd11 | CplLk  |                                                                                  //
//                  |    | 8'b0100_1011   8'h4B    8'd75 | CplDLk |                                                                                  //
//                  |    |________________________________________|                                                                                  //
//                  |                                                                                                                                //
//                  |                                                                                                                                //
//         [47:40]  | TAG : When trigger[3] set, trigger on TAG value                                                                                //
//         [51:48]  | First BE : When trigger[6] set, trigger on Last BE                                                                             //
//         [51:48]  | Last BE : When trigger[7] set, trigger on Last BE                                                                              //
//         [63:52]  | RESERVED                                                                                                                       //
//         [95:64]  | when trigger[5:4]>0 32 bit lower address trigger                                                                               //
//                  |                                                                                                                                //
// ---------------Stop Trigger [127:96]-----TODO---------------------------------------------------------------------------------------------------- //
//                  |                                                                                                                                //
//         [96]     | When set no stop trigger                                                                                                       //
//         [97]     | TX/RX       : When 1 stop-trigger on RX AST, When 0 Trigger on TX AST                                                          //
//         [98]     | FMT_TLP     : When check stop-trigger FMT_TLP                                                                                  //
//         [99]     | TAG         : When check stop-trigger TAG                                                                                      //
//         [101:100]| Address     : When check stop-trigger Address Lower 24 bits                                                                    //
//                  |                    [101:100] =2'b01, 8-bit addr LSB                                                                            //
//                  |                    [101:100] =2'b10, 16-bit addr LSB                                                                           //
//                  |                    [101:100] =2'b11, 32-bit addr LSB                                                                           //
//         [109:102]| FMT TYPE: When stop-trigger[98] set,                                                                                           //
//         [117:110]| TAG : When stop-trigger[99]                                                                                                    //
//                                                                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                   //
//     CSEB Bus Info                                                                                                                                 //
//                                                                                                                                                   //
//     |-----------------------------------------------------------------------|                                                                     //
//     | CSEB address Space                                                    |                                                                     //
//     |-----------------------------------------------------------------------|                                                                     //
//     | PCI/PCIe config space                              | Address value    |                                                                     //
//     |-----------------------------------------------------------------------|                                                                     //
//     |Type0 or Type1 Configuration Registers (PCI Header) | 32'h000-32'h03Ch |                                                                     //
//     |Reserved                                            | 32'h040          |                                                                     //
//     |Reserved                                            | 32'h044          |                                                                     //
//     |Reserved                                            | 32'h048-32'h04Ch |                                                                     //
//     |MSI Capability Structure                            | 32'h050-32'h05Ch |                                                                     //
//     |Reserved                                            | 32'h060-32'h064h |                                                                     //
//     |MSI-X Capability Structure                          | 32'h068-32'h070h |                                                                     //
//     |Power Management Capability Structure               | 32'h078-32'h07Ch |                                                                     //
//     |PCI Express Capability Structure                    | 32'h080-32'h0BCh |                                                                     //
//     |SSID/SSVID Capability Structure                     | 32'h0C0-32'h0C4h |                                                                     //
//     |PCI Extensions (CSEB)***                            | 32'h0C8-32'h0FCh |                                                                     //
//     |Virtual Channel Capability Structure                | 32'h100-32'h16Ch |                                                                     //
//     |Reserved                                            | 32'h170-32'h1FCh |                                                                     //
//     |Vendor Specific Extended Capability Structure       | 32'h200-32'h240h |                                                                     //
//     |Secondary PciE Extended Capability Structure        | 32'h300-32'h318h |                                                                     //
//     |Reserved                                            | 32'h31C-32'h7FCh |                                                                     //
//     |AER                                                 | 32'h800-32'h834h |                                                                     //
//     |PCI-E Extensions (CSEB)                             | 32'h900-32'hFFFh |                                                                     //
//     |-----------------------------------------------------------------------|                                                                     //
//                                                                                                                                                   //
//                                                                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on


module altpcie_tlp_inspector # (

      parameter ST_DATA_WIDTH                         = 64,
      parameter ST_BE_WIDTH                           = 8,
      parameter LANES                                 = 8,
      parameter ST_CTRL_WIDTH                         = 1,
      parameter USE_SIGNAL_PROBE                      = 0,         //When 1 The SignalProbe module drives the trigger inputs
      parameter POWER_UP_TRIGGER                      = 1,
      parameter SIMPLE_TRIGGER                        = 0,
      parameter USE_ADME                              = 0,
      parameter PLD_CLK_IS_250MHZ                     = 0,
      // CSEB Parameters
      parameter CSEB_ENA                              = 1,
      parameter CSEB_VSEC_BYTE_LEN                    = 12'h40,
      parameter CSEB_VSEC_REV                         = 4'h1,
      parameter CSEB_VSEC_ID                          = 16'hFACE,
      // MONITOR Parameters
      parameter MON_EN_INSP_ADDRNUM_WORD              = 16,
      parameter MON_EN_MONITOR_READYVALID_RATIO       = 1,
      parameter MON_EN_UPSTREAM_READ_LATENCY          = 1,
      parameter MON_EN_UPSTREAM_THROUGHPUT_MEASUREMENT= 1,
      parameter MON_EN_BLACKBOX_LTSSM                 = 1,
      parameter MON_EN_BLACKBOX_LTSSM_DEPTH32_BLOCK   = 4  // Number of 32 Deep FIFO
      ) (
      // Single clock domain clk (which is pld_clk in the level above)
      //    - All Inputs are synchronized to clk
      //    - All Outputs are synchronized to clk
      input  [127:0]                   trigger,
      input  [ST_BE_WIDTH-1 : 0]       rx_st_be,
      input  [ST_DATA_WIDTH-1 : 0]     rx_st_data,
      input  [1 : 0]                   rx_st_empty,
      input  [ST_CTRL_WIDTH-1 : 0]     rx_st_eop,
      input  [ST_CTRL_WIDTH-1 : 0]     rx_st_sop,
      input  [ST_CTRL_WIDTH-1 : 0]     rx_st_valid,
      input                            rx_st_ready,

      input  [ST_DATA_WIDTH-1 : 0]     tx_st_data,
      input  [1 :0]                    tx_st_empty,
      input  [ST_CTRL_WIDTH-1 :0]      tx_st_eop,
      input  [ST_CTRL_WIDTH-1 :0]      tx_st_sop,
      input                            tx_st_valid,
      input                            tx_st_ready,

      input [3 : 0]                    lane_act,
      input [4 : 0]                    ltssmstate,
      input [1 : 0]                    rate,
      input [LANES-1:0]                signaldetect,
      input [LANES-1:0]                is_lockedtodata,
      input                            npor_perstn,

      // Interface to HIP CSEB bus which is an extension of configuration space
      output  [31 : 0]                 csebrddata,
      output  [4 : 0]                  csebrdresponse,
      output                           csebwaitrequest,
      output  [4 : 0]                  csebwrresponse,
      output                           csebwrrespvalid,

      input [32 : 0]                   csebaddr,
      input [3 : 0]                    csebbe,
      input                            csebisshadow,
      input                            csebrden,
      input [31 : 0]                   csebwrdata,
      input                            csebwren,
      input                            csebwrrespreq,

      // TLP Analysis output
      output  [31:0]                   monitor_data  ,
      input  [7:0]                     monitor_addr ,
      input                            monitor_fifo_pop , // To retrieve data from a FIFO at a fix address monitor_addr

      input ev128ns,
      input ev1us,
      input clk,
      input sclr

      );

localparam ZEROS              = 512'h0;

reg  [ST_BE_WIDTH-1 : 0]       rx_ast_be;
reg  [ST_DATA_WIDTH-1 : 0]     rx_ast_data;
reg  [1 : 0]                   rx_ast_empty;
reg  [ST_CTRL_WIDTH-1 : 0]     rx_ast_eop;
reg  [ST_CTRL_WIDTH-1 : 0]     rx_ast_sop;
reg  [ST_CTRL_WIDTH-1 : 0]     rx_ast_valid;
reg                            rx_ast_ready;
wire                           rx_h_val;
wire [31:0]                    rx_h1;
wire [31:0]                    rx_h2;
wire [31:0]                    rx_h3;
wire [31:0]                    rx_h4;
reg  [ST_DATA_WIDTH-1 : 0]     tx_ast_data;
reg  [1 :0]                    tx_ast_empty;
reg  [ST_CTRL_WIDTH-1 :0]      tx_ast_eop;
reg  [ST_CTRL_WIDTH-1 :0]      tx_ast_sop;
reg                            tx_ast_valid;
reg                            tx_ast_ready;
wire                           tx_h_val;
wire [31:0]                    tx_h1;
wire [31:0]                    tx_h2;
wire [31:0]                    tx_h3;
wire [31:0]                    tx_h4;

wire trigger_on;                // Global Trigger
wire reset_inspector;
wire reset_trigger;
wire [31:0]       cseb_trigger;
wire [1:0]        cseb_trigger_dw;
wire              use_cseb_trigger;
wire  [7:0]       monitor_addr_cseb ;

wire [127:0] trigger_signal_probe;
reg  [127:0] trigger_ast;

wire monitor_rd_pulse;

// synthesis translate_off
   initial begin
      $display("Info: altpcie_tlp_inspector :: ---------------------------------------------------------------------------------------------");
      $display("Info: altpcie_tlp_inspector ::                                                                                              ");
      $display("Info: altpcie_tlp_inspector ::  Instantiating TLP Inspector                                                                 ");
      $display("Info: altpcie_tlp_inspector ::                                                                                              ");
      $display("Info: altpcie_tlp_inspector ::--------------------------------------------------------------------------------------------- ");
   end
// synthesis translate_on


//////////////////////////////////////////////////////////////////////////////////
//
// Registering inputs
// Naming convention
//          Inputs _st_ --> registered _ast_
//
always @(posedge clk) begin : p_rast
   if (sclr == 1'b1 ) begin
      rx_ast_be        <= ZEROS[ST_BE_WIDTH-1 : 0]  ;
      rx_ast_data      <= ZEROS[ST_DATA_WIDTH-1 : 0];
      rx_ast_empty     <= ZEROS[1 : 0]              ;
      rx_ast_eop       <= ZEROS[ST_CTRL_WIDTH-1 : 0];
      rx_ast_sop       <= ZEROS[ST_CTRL_WIDTH-1 : 0];
      rx_ast_valid     <= ZEROS[ST_CTRL_WIDTH-1 : 0];
      rx_ast_ready     <= 1'b0                      ;
      tx_ast_data      <= ZEROS[ST_DATA_WIDTH-1 : 0];
      tx_ast_empty     <= ZEROS[1 :0]               ;
      tx_ast_eop       <= ZEROS[ST_CTRL_WIDTH-1 :0] ;
      tx_ast_sop       <= ZEROS[ST_CTRL_WIDTH-1 :0] ;
      tx_ast_valid     <= 1'b0                      ;
      tx_ast_ready     <= 1'b0                      ;
      trigger_ast      <= 128'h0;
   end
   else begin
      rx_ast_be        <= rx_st_be      ;
      rx_ast_data      <= rx_st_data    ;
      rx_ast_empty     <= rx_st_empty   ;
      rx_ast_eop       <= rx_st_eop     ;
      rx_ast_sop       <= rx_st_sop     ;
      rx_ast_valid     <= rx_st_valid   ;
      rx_ast_ready     <= rx_st_ready   ;
      tx_ast_data      <= tx_st_data    ;
      tx_ast_empty     <= tx_st_empty   ;
      tx_ast_eop       <= tx_st_eop     ;
      tx_ast_sop       <= tx_st_sop     ;
      tx_ast_valid     <= tx_st_valid   ;
      tx_ast_ready     <= tx_st_ready   ;
      if (use_cseb_trigger==1'b1) begin
         case (cseb_trigger_dw)
            2'b00   : trigger_ast<={trigger_ast[127:32],cseb_trigger[31:0] };
            2'b01   : trigger_ast<={trigger_ast[127:64],cseb_trigger[31:0], trigger_ast[31:0] };
            2'b10   : trigger_ast<={trigger_ast[127:96],cseb_trigger[31:0], trigger_ast[63:0] };
            2'b11   : trigger_ast<={cseb_trigger[31:0] ,trigger_ast[95:0] };
            default : trigger_ast<={trigger_ast[127:32],cseb_trigger[31:0] };
         endcase
      end
      else begin
         trigger_ast      <= (USE_SIGNAL_PROBE==1)?trigger_signal_probe:trigger;
      end
   end
end
assign reset_inspector = trigger_ast[10]|sclr;
assign reset_trigger   = trigger_ast[9]|sclr|reset_inspector;

//////////////////////////////////////////////////////////////////////////////////
//
// Trigger Section
//
altpcie_tlp_inspector_trigger # (
      .ST_DATA_WIDTH       (ST_DATA_WIDTH    ),
      .ST_BE_WIDTH         (ST_BE_WIDTH      ),
      .ST_CTRL_WIDTH       (ST_CTRL_WIDTH    ),
      .POWER_UP_TRIGGER    (POWER_UP_TRIGGER ),
      .SIMPLE_TRIGGER      (SIMPLE_TRIGGER   )
) altpcie_tlp_inspector_trigger (
      .trigger_ast        (trigger_ast        ), // In
      .rx_ast_be          (rx_ast_be          ), // In
      .rx_ast_data        (rx_ast_data        ), // In
      .rx_ast_empty       (rx_ast_empty       ), // In
      .rx_ast_eop         (rx_ast_eop         ), // In
      .rx_ast_sop         (rx_ast_sop         ), // In
      .rx_ast_valid       (rx_ast_valid       ), // In
      .rx_ast_ready       (rx_ast_ready       ), // In
      .tx_ast_data        (tx_ast_data        ), // In
      .tx_ast_empty       (tx_ast_empty       ), // In
      .tx_ast_eop         (tx_ast_eop         ), // In
      .tx_ast_sop         (tx_ast_sop         ), // In
      .tx_ast_valid       (tx_ast_valid       ), // In
      .tx_ast_ready       (tx_ast_ready       ), // In
      .trigger_on         (trigger_on         ), // Out trigger Enable result of triggering logic
      .rx_h_val           (rx_h_val           ), // Out
      .rx_h1              (rx_h1              ), // Out
      .rx_h2              (rx_h2              ), // Out
      .rx_h3              (rx_h3              ), // Out
      .rx_h4              (rx_h4              ), // Out
      .tx_h_val           (tx_h_val           ), // Out
      .tx_h1              (tx_h1              ), // Out
      .tx_h2              (tx_h2              ), // Out
      .tx_h3              (tx_h3              ), // Out
      .tx_h4              (tx_h4              ), // Out
      .clk                (clk                ), // Out
      .sclr               (reset_trigger      )  // Out
      );

altpcie_tlp_inspector_monitor # (
      .ST_DATA_WIDTH                  (ST_DATA_WIDTH                         ),
      .ST_BE_WIDTH                    (ST_BE_WIDTH                           ),
      .ST_CTRL_WIDTH                  (ST_CTRL_WIDTH                         ),
      .PLD_CLK_IS_250MHZ              (PLD_CLK_IS_250MHZ                     ),
      .LANES                          (LANES                                 ),
      .INSP_ADDRNUM_WORD              (MON_EN_INSP_ADDRNUM_WORD              ),
      .MONITOR_READYVALID_RATIO       (MON_EN_MONITOR_READYVALID_RATIO       ),
      .UPSTREAM_READ_LATENCY          (MON_EN_UPSTREAM_READ_LATENCY          ),
      .UPSTREAM_THROUGHPUT_MEASUREMENT(MON_EN_UPSTREAM_THROUGHPUT_MEASUREMENT),
      .BLACKBOX_LTSSM                 (MON_EN_BLACKBOX_LTSSM                 ),
      .BLACKBOX_LTSSM_DEPTH32_BLOCK   (MON_EN_BLACKBOX_LTSSM_DEPTH32_BLOCK   )  // Number of 32 Deep FIFO
) altpcie_tlp_inspector_monitor (
      .trigger_ast        (trigger_ast        ), // In [127:0]
      .trigger_on         (trigger_on         ), // In
      .rx_ast_be          (rx_ast_be          ), // In [ST_BE_WIDTH-1 : 0]
      .rx_ast_data        (rx_ast_data        ), // In [ST_DATA_WIDTH-1 : 0]
      .rx_ast_empty       (rx_ast_empty       ), // In [1 : 0]
      .rx_ast_eop         (rx_ast_eop         ), // In [ST_CTRL_WIDTH-1 : 0]
      .rx_ast_sop         (rx_ast_sop         ), // In [ST_CTRL_WIDTH-1 : 0]
      .rx_ast_valid       (rx_ast_valid       ), // In [ST_CTRL_WIDTH-1 : 0]
      .rx_ast_ready       (rx_ast_ready       ), // In
      .tx_ast_data        (tx_ast_data        ), // In
      .tx_ast_empty       (tx_ast_empty       ), // In [31:0]
      .tx_ast_eop         (tx_ast_eop         ), // In [31:0]
      .tx_ast_sop         (tx_ast_sop         ), // In [31:0]
      .tx_ast_valid       (tx_ast_valid       ), // In [31:0]
      .tx_ast_ready       (tx_ast_ready       ), // In [ST_DATA_WIDTH-1 : 0]
      .rx_h_val           (rx_h_val           ), // In [1 :0]
      .rx_h1              (rx_h1              ), // In [ST_CTRL_WIDTH-1 :0]
      .rx_h2              (rx_h2              ), // In [ST_CTRL_WIDTH-1 :0]
      .rx_h3              (rx_h3              ), // In
      .rx_h4              (rx_h4              ), // In
      .tx_h_val           (tx_h_val           ), // In
      .tx_h1              (tx_h1              ), // In [31:0]
      .tx_h2              (tx_h2              ), // In [31:0]
      .tx_h3              (tx_h3              ), // In [31:0]
      .tx_h4              (tx_h4              ), // In [31:0]
      .rate               (rate               ), // In [3 : 0]
      .lane_act           (lane_act           ), // In [3 : 0]
      .ltssmstate         (ltssmstate         ), // In [4 : 0]
      .signaldetect       (signaldetect       ), // In [LANES-1:0]
      .is_lockedtodata    (is_lockedtodata    ), // In [LANES-1:0]
      .npor_perstn        (npor_perstn        ), // In

      .monitor_addr       (((USE_ADME==0)||(use_cseb_trigger==1'b1))?monitor_addr_cseb:monitor_addr ),
      .monitor_rd_pulse   (((USE_ADME==0)||(use_cseb_trigger==1'b1))?monitor_rd_pulse:monitor_fifo_pop       ),
      .monitor_data       (monitor_data       ),

      .clk                (clk                ), // In
      .sclr               (reset_trigger      )  // In
      );

altpcie_tlp_inspector_cseb # (
      .CSEB_ENA              (CSEB_ENA          ),
      .VSEC_BYTE_LENGTH      (CSEB_VSEC_BYTE_LEN),
      .VSEC_REV              (CSEB_VSEC_REV     ),
      .VSEC_ID               (CSEB_VSEC_ID      )
) altpcie_tlp_inspector_cseb (
      .csebaddr                        (csebaddr          ),
      .csebbe                          (csebbe            ),
      .csebisshadow                    (csebisshadow      ),
      .csebrden                        (csebrden          ),
      .csebwrdata                      (csebwrdata        ),
      .csebwren                        (csebwren          ),
      .csebwrrespreq                   (csebwrrespreq     ),

      // Outputs
      .csebrddata                      (csebrddata        ),
      .csebrdresponse                  (csebrdresponse    ),
      .csebwaitrequest                 (csebwaitrequest   ),
      .csebwrresponse                  (csebwrresponse    ),
      .csebwrrespvalid                 (csebwrrespvalid   ),
      .use_cseb_trigger                (use_cseb_trigger  ),
      .cseb_trigger                    (cseb_trigger      ),
      .cseb_trigger_dw                 (cseb_trigger_dw   ),
      .current_trigger                 (trigger_ast       ),

      .monitor_addr                    (monitor_addr_cseb ),
      .monitor_data                    (monitor_data      ),
      .monitor_rd_pulse                (monitor_rd_pulse  ),
      //Input
      .clk                             (clk               ),
      .sclr                            (sclr              )
      );

//////////////// SIMULATION-ONLY CONTENTS
//synthesis translate_off
assign trigger_signal_probe     = trigger;
//////////////// END SIMULATION-ONLY CONTENTS
//synthesis translate_on


//////////////// SYNTHESIS-ONLY CONTENTS
// The section bellow is for synthesis only and is not used for simulation
// When reserved_debug_hwtcl=1, set SignalProbe access point to
// reservein and testin pins

//synthesis read_comments_as_HDL on
//generate begin : g_reserved_debug
//   if (USE_SIGNAL_PROBE==1) begin
//      sld_mod_ram_rom #(
//              .cvalue            (128'h1  ),
//              .is_data_in_ram    (0),
//              .is_readable       (0),
//              .node_name         (1397641039),
//              .numwords          (1),
//              .shift_count_bits  (8),
//              .width_word        (128),
//              .widthad           (1)
//            ) signalprobe_test_in_lsb ( .data_write(trigger_signal_probe[31:0]) );
//
//   end
//   else begin
//      assign trigger_signal_probe=128'h0;
//   end
//end
//endgenerate
//synthesis read_comments_as_HDL off

endmodule
