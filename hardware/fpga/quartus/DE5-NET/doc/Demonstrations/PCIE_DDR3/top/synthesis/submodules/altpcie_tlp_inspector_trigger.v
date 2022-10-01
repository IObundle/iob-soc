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
//    altpcie_tlp_inspector_trigger : Submodule of altpcie_tlp_inspector managing trigger logic                                                      //
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
//         [11]     | Enable Trigger ON  : When set activate trigger logic                                                                           //
//         [12   ]  | Use CSEB trigger                                                                                                               //
//         [31:13]  | RESERVED                                                                                                                       //
//                  |                                                                                                                                //
// ---------------Trigger Second Dword : 63:32 : Data Compare-----------------------------------------                                               //
//                  |                                                                                                                                //
// trigger [39:32]  | FMT TYPE: When trigger[2] set, trigger on                                                                                      //
//                  |    _______________________________                                                                                             //
//                  |    |                    |        |                                                                                             //
//                  |    |  {FMT,TYPE}        |        |                                                                                             //
//                  |    |____________________|________|                                                                                             //
//                  |    | 8'b0000_0000       | MRd    |                                                                                             //
//                  |    | 8'b0010_0000       | MRd    |                                                                                             //
//                  |    | 8'b0000_0001       | MRdLk  |                                                                                             //
//                  |    | 8'b0010_0001       | MRdLk  |                                                                                             //
//                  |    | 8'b0100_0000       | MWr    |                                                                                             //
//                  |    | 8'b0110_0000       | MWr    |                                                                                             //
//                  |    | 8'b0000_0010       | IORd   |                                                                                             //
//                  |    | 8'b0100_0010       | IOWr   |                                                                                             //
//                  |    | 8'b0000_0100       | CfgRd0 |                                                                                             //
//                  |    | 8'b0100_0100       | CfgWr0 |                                                                                             //
//                  |    | 8'b0000_0101       | CfgRd1 |                                                                                             //
//                  |    | 8'b0100_0101       | CfgWr1 |                                                                                             //
//                  |    | 8'b0011_0XXX       | Msg    |                                                                                             //
//                  |    | 8'b0111_0XXX       | MsgD   |                                                                                             //
//                  |    | 8'b0000_1010       | Cpl    |                                                                                             //
//                  |    | 8'b0100_1010       | CplD   |                                                                                             //
//                  |    | 8'b0000_1011       | CplLk  |                                                                                             //
//                  |    | 8'b0100_1011       | CplDLk |                                                                                             //
//                  |    |_____________________________|                                                                                             //
//                  |                                                                                                                                //
//                  |                                                                                                                                //
//         [47:40]  | TAG : When trigger[3] set, trigger on TAG value                                                                                //
//         [51:48]  | First BE : When trigger[6] set, trigger on Last BE                                                                             //
//         [51:48]  | Last BE : When trigger[7] set, trigger on Last BE                                                                              //
//         [63:52]  | RESERVED                                                                                                                       //
//         [95:64]  | when trigger[5:4]>0 32 bit lower address trigger                                                                               //
//                  |                                                                                                                                //
// ---------------Stop Trigger [127:96]------------------------------------------------------------------------------------------------------------- //
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
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcie_tlp_inspector_trigger # (

      parameter ST_DATA_WIDTH       = 64,
      parameter ST_BE_WIDTH         = 8,
      parameter ST_CTRL_WIDTH       = 1,
      parameter POWER_UP_TRIGGER    = 1,
      parameter SIMPLE_TRIGGER      = 0
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

      output reg                       trigger_on,
      output reg                       rx_h_val,
      output reg [31:0]                rx_h1,
      output reg [31:0]                rx_h2,
      output reg [31:0]                rx_h3,
      output reg [31:0]                rx_h4,
      output reg                       tx_h_val,
      output reg [31:0]                tx_h1,
      output reg [31:0]                tx_h2,
      output reg [31:0]                tx_h3,
      output reg [31:0]                tx_h4,

      input clk,
      input sclr

      );

localparam ZEROS                       = 512'h0;

localparam TRIGGER_BIT_FIRST_SOP       = 0,
           TRIGGER_BIT_RXTX            = 1,
           TRIGGER_BIT_FMTTLP          = 2,
           TRIGGER_BIT_TAG             = 3,
           TRIGGER_BIT_RESET_TRIGGER   = 9,
           TRIGGER_BIT_RESET_INSPECTOR = 10,
           TRIGGER_BIT_ENABLE_TRIGGER  = 11;

wire rx_mem_tlp;
wire rx_4dw_tlp;
wire tx_mem_tlp;
wire tx_4dw_tlp;

reg trigger_lastbe;
reg trigger_firstbe;

reg trigger_addr_rx;
reg trigger_fmttype_rx;
reg trigger_tag_rx;
reg trigger_addr_tx;
reg trigger_fmttype_tx;
reg trigger_tag_tx;

assign rx_mem_tlp = (rx_ast_data[28:25]==4'h0)?1'b1:1'b0;
assign rx_4dw_tlp = (rx_ast_data[29]==1'b1)   ?1'b1:1'b0;
assign tx_mem_tlp = (tx_ast_data[28:25]==4'h0)?1'b1:1'b0;
assign tx_4dw_tlp = (tx_ast_data[29]==1'b1)   ?1'b1:1'b0;

always @(posedge clk) begin : p_trigger
   if (sclr == 1'b1 ) begin
      trigger_on        <=  1'b0;
   end
   else begin
      if ((trigger_ast[0]==1'b1)||(SIMPLE_TRIGGER==1)) begin
         if (trigger_ast[1] == 1'b0) begin // Trigger on TX
            if (tx_ast_sop[ST_CTRL_WIDTH-1:0]>ZEROS[ST_CTRL_WIDTH-1:0]) begin
            // Start counting on the first TX SOP
               trigger_on <=1'b1;
            end
         end
         else begin // Trigger on Rx
            if (rx_ast_sop[ST_CTRL_WIDTH-1:0]>ZEROS[ST_CTRL_WIDTH-1:0]) begin
            // Start counting on the first RX SOP
               trigger_on <=1'b1;
            end
         end
      end
      else begin
         trigger_on <= trigger_tag_rx     |
                       trigger_addr_rx    |
                       trigger_fmttype_rx |
                       trigger_tag_tx     |
                       trigger_addr_tx    |
                       trigger_fmttype_tx |
                       trigger_lastbe     |
                       trigger_firstbe    ;
      end
   end
end

generate begin : g_trg
   if ((ST_DATA_WIDTH==256)||(ST_DATA_WIDTH==128)) begin : gp_trg128
      always @(posedge clk) begin : p_trg
         if (sclr == 1'b1 ) begin
            rx_h_val           <=  1'b0;
            rx_h1              <=  32'h0;
            rx_h2              <=  32'h0;
            rx_h3              <=  32'h0;
            rx_h4              <=  32'h0;
            tx_h_val           <=  1'b0;
            tx_h1              <=  32'h0;
            tx_h2              <=  32'h0;
            tx_h3              <=  32'h0;
            tx_h4              <=  32'h0;
            trigger_tag_rx     <=  1'b0;
            trigger_addr_rx    <=  1'b0;
            trigger_fmttype_rx <=  1'b0;
            trigger_tag_tx     <=  1'b0;
            trigger_addr_tx    <=  1'b0;
            trigger_fmttype_tx <=  1'b0;
            trigger_lastbe     <=  1'b0;
            trigger_firstbe    <=  1'b0;
         end
         else begin
            rx_h_val <= rx_ast_sop[0]&rx_ast_valid[0];
            if (rx_ast_valid[0]==1'b1) begin
               if (rx_ast_sop[0]==1'b1) begin
                  rx_h1 <=rx_ast_data[31:0];
                  rx_h2 <=rx_ast_data[63:32];
                  rx_h3 <=rx_ast_data[95:64];
                  rx_h4 <=rx_ast_data[127:96];
                  if ((trigger_ast[TRIGGER_BIT_ENABLE_TRIGGER]==1'b1)&&(trigger_ast[TRIGGER_BIT_RXTX]==1'b1)&&(trigger_on==1'b0)) begin // Trigger on RX
                     //FMT-TYPE
                     if ((trigger_ast[TRIGGER_BIT_FMTTLP]==1'b1)&&
                         ((trigger_ast[39:32]==rx_ast_data[31:24]))) begin
                        trigger_fmttype_rx <=1'b1;
                     end
                     //TAG
                     if ((trigger_ast[TRIGGER_BIT_TAG]==1'b1)&&
                         ((rx_ast_data[31:30]==2'b00)&&(trigger_ast[47:40]==rx_ast_data[47:40]))) begin
                        trigger_tag_rx <=1'b1;
                     end
                     //Address LSB
                     if ((trigger_ast[5:4]>2'b00)&&(rx_mem_tlp==1'b1)) begin //trigger memory TLP
                        if (rx_4dw_tlp==1'b1) begin
                           if ((trigger_ast[5:4]==2'b11)&&(rx_ast_data[127:96]==trigger_ast[95:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(rx_ast_data[111:96]==trigger_ast[79:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((rx_ast_data[105:96]==trigger_ast[72:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                        end
                        else begin
                           if ((trigger_ast[5:4]==2'b11)&&(rx_ast_data[95:64]==trigger_ast[95:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(rx_ast_data[79:64]==trigger_ast[79:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((rx_ast_data[72:64]==trigger_ast[72:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                        end
                     end
                  end
               end
            end

            tx_h_val <= tx_ast_sop[0]&tx_ast_valid;
            if (tx_ast_valid==1'b1) begin
               if (tx_ast_sop[0]==1'b1) begin
                  tx_h1 <=tx_ast_data[31:0];
                  tx_h2 <=tx_ast_data[63:32];
                  tx_h3 <=tx_ast_data[95:64];
                  tx_h4 <=tx_ast_data[127:96];
                  if ((trigger_ast[TRIGGER_BIT_ENABLE_TRIGGER]==1'b1)&&(trigger_ast[TRIGGER_BIT_RXTX]==1'b0)&&(trigger_on==1'b0)) begin // Trigger on RX
                     //FMT-TYPE
                     if ((trigger_ast[TRIGGER_BIT_FMTTLP]==1'b1)&&
                         ((trigger_ast[39:32]==tx_ast_data[31:24]))) begin
                        trigger_fmttype_tx <=1'b1;
                     end
                     //TAG
                     if ((trigger_ast[TRIGGER_BIT_TAG]==1'b1)&&
                         ((tx_ast_data[31:30]==2'b00)&&(trigger_ast[47:40]==tx_ast_data[47:40]))) begin
                        trigger_tag_tx <=1'b1;
                     end
                     //Address LSB
                     if ((trigger_ast[5:4]>2'b00)&&(tx_mem_tlp==1'b1)) begin //trigger memory TLP
                        if (tx_4dw_tlp==1'b1) begin
                           if ((trigger_ast[5:4]==2'b11)&&(tx_ast_data[127:96]==trigger_ast[95:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(tx_ast_data[111:96]==trigger_ast[79:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((tx_ast_data[105:96]==trigger_ast[72:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                        end
                        else begin
                           if ((trigger_ast[5:4]==2'b11)&&(tx_ast_data[95:64]==trigger_ast[95:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(tx_ast_data[79:64]==trigger_ast[79:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((tx_ast_data[72:64]==trigger_ast[72:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                        end
                     end
                  end
               end
            end
         end
      end
   end
   else begin : gp_trg64
      reg rx_mem_tlp_r;
      reg rx_4dw_tlp_r;
      reg tx_mem_tlp_r;
      reg tx_4dw_tlp_r;
      reg rx_ast_nsop ;
      reg tx_ast_nsop ;
      always @(posedge clk) begin : p_64_trg
         if (sclr == 1'b1 ) begin
            rx_h_val           <=  1'b0;
            rx_h1              <=  32'h0;
            rx_h2              <=  32'h0;
            rx_h3              <=  32'h0;
            rx_h4              <=  32'h0;
            tx_h_val           <=  1'b0;
            tx_h1              <=  32'h0;
            tx_h2              <=  32'h0;
            tx_h3              <=  32'h0;
            tx_h4              <=  32'h0;
            rx_ast_nsop        <=  1'b0; //next cycle after rx_ast_nsop
            tx_ast_nsop        <=  1'b0; //next cycle after tx_ast_nsop
            trigger_tag_rx     <=  1'b0;
            trigger_addr_rx    <=  1'b0;
            trigger_fmttype_rx <=  1'b0;
            trigger_tag_tx     <=  1'b0;
            trigger_addr_tx    <=  1'b0;
            trigger_fmttype_tx <=  1'b0;
            trigger_lastbe     <=  1'b0;
            trigger_firstbe    <=  1'b0;
            tx_mem_tlp_r       <=  1'b0;
            tx_4dw_tlp_r       <=  1'b0;
            rx_mem_tlp_r       <=  1'b0;
            rx_4dw_tlp_r       <=  1'b0;
         end
         else begin
            rx_h_val     <= rx_ast_nsop&rx_ast_valid[0];
            if (rx_ast_valid[0]==1'b1) begin
               if (rx_ast_sop[0]==1'b1) begin
                  rx_h1        <= rx_ast_data[31:0];
                  rx_h2        <= rx_ast_data[63:32];
                  rx_mem_tlp_r <= rx_mem_tlp;
                  rx_4dw_tlp_r <= rx_4dw_tlp;
                  rx_ast_nsop  <= 1'b1;
                  if ((trigger_ast[TRIGGER_BIT_ENABLE_TRIGGER]==1'b1)&&(trigger_ast[TRIGGER_BIT_RXTX]==1'b1)&&(trigger_on==1'b0)) begin // Trigger on RX
                     //FMT-TYPE
                     if ((trigger_ast[TRIGGER_BIT_FMTTLP]==1'b1)&&
                         ((trigger_ast[39:32]==rx_ast_data[31:24]))) begin
                        trigger_fmttype_rx <=1'b1;
                     end
                     //TAG
                     if ((trigger_ast[TRIGGER_BIT_TAG]==1'b1)&&
                         ((rx_ast_data[31:30]==2'b00)&&(trigger_ast[47:40]==rx_ast_data[47:40]))) begin
                        trigger_tag_rx <=1'b1;
                     end
                  end
               end
               if (rx_ast_nsop==1'b1) begin
                  rx_h3        <= rx_ast_data[31:0];
                  rx_h4        <= rx_ast_data[63:32];
                  rx_mem_tlp_r <= 1'b0;
                  rx_4dw_tlp_r <= 1'b0;
                  rx_ast_nsop  <= 1'b0;

                  if ((trigger_ast[TRIGGER_BIT_ENABLE_TRIGGER]==1'b1)&&(trigger_ast[TRIGGER_BIT_RXTX]==1'b1)&&(trigger_on==1'b0)) begin // Trigger on RX
                     //Address LSB
                     if ((trigger_ast[5:4]>2'b00)&&(rx_mem_tlp_r==1'b1)) begin //trigger memory TLP
                        if (rx_4dw_tlp==1'b1) begin
                           if ((trigger_ast[5:4]==2'b11)&&(rx_ast_data[63:32]==trigger_ast[95:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(rx_ast_data[47:32]==trigger_ast[79:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((rx_ast_data[39:32]==trigger_ast[71:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                        end
                        else begin
                           if ((trigger_ast[5:4]==2'b11)&&(rx_ast_data[31:0]==trigger_ast[95:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(rx_ast_data[15:0]==trigger_ast[79:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                           else if ((rx_ast_data[7:0]==trigger_ast[72:64])) begin
                              trigger_addr_rx <= 1'b1;
                           end
                        end
                     end
                  end
               end
            end
            tx_h_val <= tx_ast_nsop&tx_ast_valid;
            if (tx_ast_valid==1'b1) begin
               if (tx_ast_sop[0]==1'b1) begin
                  tx_h1             <=tx_ast_data[31:0];
                  tx_h2             <=tx_ast_data[63:32];
                  tx_mem_tlp_r      <= tx_mem_tlp;
                  tx_4dw_tlp_r      <= tx_4dw_tlp;
                  tx_ast_nsop       <= 1'b1;
                  if ((trigger_ast[TRIGGER_BIT_ENABLE_TRIGGER]==1'b1)&&(trigger_ast[TRIGGER_BIT_RXTX]==1'b0)&&(trigger_on==1'b0)) begin // Trigger on RX
                     //FMT-TYPE
                     if ((trigger_ast[TRIGGER_BIT_FMTTLP]==1'b1)&&
                         ((trigger_ast[39:32]==tx_ast_data[31:24]))) begin
                        trigger_fmttype_tx <=1'b1;
                     end
                     //TAG
                     if ((trigger_ast[TRIGGER_BIT_TAG]==1'b1)&&
                         ((tx_ast_data[31:30]==2'b00)&&(trigger_ast[47:40]==tx_ast_data[47:40]))) begin
                        trigger_tag_tx <=1'b1;
                     end
                  end
               end
               if (tx_ast_nsop==1'b1) begin
                  tx_h3             <= tx_ast_data[31:0];
                  tx_h4             <= tx_ast_data[63:32];
                  tx_ast_nsop       <= 1'b0;
                  tx_mem_tlp_r      <= 1'b0;
                  tx_4dw_tlp_r      <= 1'b0;
                  if ((trigger_ast[TRIGGER_BIT_ENABLE_TRIGGER]==1'b1)&&(trigger_ast[TRIGGER_BIT_RXTX]==1'b0)&&(trigger_on==1'b0)) begin // Trigger on TX
                     //Address LSB
                     if ((trigger_ast[5:4]>2'b00)&&(tx_mem_tlp_r==1'b1)) begin //trigger memory TLP
                        if (tx_4dw_tlp==1'b1) begin
                           if ((trigger_ast[5:4]==2'b11)&&(tx_ast_data[63:32]==trigger_ast[95:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(tx_ast_data[47:32]==trigger_ast[79:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((tx_ast_data[39:32]==trigger_ast[71:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                        end
                        else begin
                           if ((trigger_ast[5:4]==2'b11)&&(tx_ast_data[31:0]==trigger_ast[95:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((trigger_ast[5:4]==2'b10)&&(tx_ast_data[15:0]==trigger_ast[79:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                           else if ((tx_ast_data[7:0]==trigger_ast[72:64])) begin
                              trigger_addr_tx <= 1'b1;
                           end
                        end
                     end
                  end
               end
            end
         end
      end
   end
end
endgenerate

endmodule
