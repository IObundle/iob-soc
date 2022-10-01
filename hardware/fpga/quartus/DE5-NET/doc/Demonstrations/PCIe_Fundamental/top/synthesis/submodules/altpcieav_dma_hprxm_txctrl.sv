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

module altpcieav_dma_hprxm_txctrl

# (
           parameter AVMM_WIDTH        = 256,     
           parameter TX_FIFO_WIDTH    = (AVMM_WIDTH == 256) ? 260 : 131,   //Data+Sop+Eop+Empty    
           parameter DMA_BRST_CNT_W   = 5
  )

   
  (
      input logic                                  Clk_i,
      input logic                                  Rstn_i,
      
       // Command Fifo interface
      input   logic [98:0]                         CmdFifoDat_i,
      input   logic [4:0]                          CmdFifoCount_i,
      output  logic                                CmdFifoRdReq_o,
      
        // Completion buffer interface
      output  logic [8:0]                          CplBuffRdAddr_o,
      input   logic [AVMM_WIDTH-1:0]               TxCplDat_i,
      
      
            // Tx fifo Interface
      output logic                                 TxFifoWrReq_o,
      output logic [TX_FIFO_WIDTH-1:0]             TxFifoData_o,          //Data+Sop+Eop+Empty
      input  logic [3:0]                           TxFifoCount_i,               
      
     // Arbiter Interface                     
      input   logic  [3:0]                         SideFifoCount_i,                            
      output  logic                                HpRxmArbReq_o,          
      input   logic                                HpRxmArbGranted_i,  
     /// read burst count fifo interface
     output  logic                                 ReadBcntFifoRdreq_o,  
     input logic  [7:0]                            ReadBcntFifoq_i, 
     
  // cfg register
      input  [12:0]  BusDev_i
      
   );
 
localparam      TXCPL_IDLE            = 3'h0; 
localparam      TXCPL_ARB_REQ         = 3'h1;
localparam      TXCPL_ARB_PIPE        = 3'h2;
localparam      TXCPL_HEADER          = 3'h3;
localparam      TXCPL_DATA            = 3'h4;
localparam      TXCPL_WAIT            = 3'h5;

logic           sm_cpl_idle;
logic   [98:0]  cpl_cmd_reg;
logic           is_abort_cpl_reg; 

logic   [15:0]  requestor_id; 
logic   [15:0]  cpl_cplter_id; 
logic   [4:0]   tx_address_lsb_reg;
logic   [9:0]   dw_len_reg; 
logic   [11:0]  cpl_remain_bytes_reg; 
logic   [1:0]   cpl_attr_reg; 
logic   [2:0]   cpl_tc_reg;
logic           tx_fifo_ok;
logic   [5:0]   tx_modlen_sel;
logic   [7:0]   tx_modlen_lines;
logic           sm_arb_req_rise;   
logic           sm_arb_req_rise_reg;   
logic           sm_arb_req_reg;            
logic   [7:0]   cpl_dat_cntr; 
logic   [2:0]   txcpl_state; 
logic   [2:0]   txcpl_nxt_state;           
logic           sm_cpl_hdr; 
logic           sm_cpl_data;
logic           sm_cpl_wait;   
logic           sm_arb_req;
logic           cpl_dat_clken; 
logic           output_fifo_ok_reg;         
logic           is_flush_cpl_reg;
logic   [8:0]   cpl_addr_reg;                                                                      
logic   [255:0] tlp_buff_data;
logic   [31:0]  cpl_data_dw0;
logic   [31:0]  cpl_data_dw1;
logic   [31:0]  cpl_data_dw2;
logic   [31:0]  cpl_data_dw3;
logic   [31:0]  cpl_data_dw4;
logic   [31:0]  cpl_data_dw5;
logic   [31:0]  cpl_data_dw6;
logic   [31:0]  cpl_data_dw7;
logic   [255:0]  tlp_holding_reg;
logic   [31:0]  cpl_holding_reg_dw2;
logic   [31:0]  cpl_holding_reg_dw3;
logic   [31:0]  cpl_holding_reg_dw4;
logic   [31:0]  cpl_holding_reg_dw5;
logic   [31:0]  cpl_holding_reg_dw6;
logic   [31:0]  cpl_holding_reg_dw7;
logic   [AVMM_WIDTH-1:0] tx_data;
logic   [63:0]  cpl_header_qw0;
logic   [63:0]  cpl_header_qw1;
logic   [63:0]  cpl_header_qw2;
logic   [63:0]  cpl_header_qw3;
logic   [AVMM_WIDTH-1:0] tlp_data;  
logic           tlp_sop;
logic           tlp_eop;
logic   [3:0]   tlp_emp_sel;
logic   [1:0]   tx_empty_int;
logic   [1:0]   tlp_emp;
logic   [TX_FIFO_WIDTH-1:0] output_fifo_data_in;
logic           output_fifo_wrreq;     
logic   [15:0] cpl_req_id_reg; 
logic   [7:0]  cpl_tag_reg;  
logic   [6:0]  lower_adr_reg; 
logic          cmd_fifo_empty;     
logic          cpl_tlp_in_one_clk;          
logic  [1:0]   tlp_empty;
logic          last_cpl;
logic          first_cpl;
logic  [7:0]   cpl_buff_lines_cntr;
logic          load_buff_lines_count;
logic  [7:0]   first_valid_dw_address_reg;
logic          prefetch_cpl_buff;
logic [9:0]    dw_len;  
logic          all_dw_consumed_per_line_reg;
logic          data_2_arb_req;
logic          wait_2_arb_req;      
logic          side_fifo_empty;

assign side_fifo_empty =  SideFifoCount_i[3:0] == 4'h0;                      
                      
assign is_flush_cpl_reg = 1'b0;                            
assign CmdFifoRdReq_o = sm_cpl_idle & ~cmd_fifo_empty | data_2_arb_req | wait_2_arb_req;
assign cmd_fifo_empty = (CmdFifoCount_i == 0);

always @(posedge Clk_i)
     if(CmdFifoRdReq_o)
       cpl_cmd_reg <= CmdFifoDat_i;

assign is_abort_cpl_reg  =   cpl_cmd_reg[31] & cpl_cmd_reg[68];
assign dw_len = {1'b0, CmdFifoDat_i[93:85]};
assign requestor_id = {BusDev_i, 3'b000};
assign cpl_cplter_id = requestor_id;
assign tx_address_lsb_reg = {cpl_cmd_reg[4:2], 2'b00};
assign dw_len_reg = {1'b0, cpl_cmd_reg[93:85]};
assign cpl_remain_bytes_reg = cpl_cmd_reg[81:70];
assign cpl_attr_reg = cpl_cmd_reg[95:94];
assign cpl_tc_reg   = cpl_cmd_reg[84:82];    
assign cpl_req_id_reg = cpl_cmd_reg[30:15];    
assign cpl_tag_reg    = cpl_cmd_reg[14:7];    
assign lower_adr_reg  = cpl_cmd_reg[6:0]; 
assign first_cpl      = cpl_cmd_reg[68];


assign tx_fifo_ok = (TxFifoCount_i <= 4'hD);
// adjusted Dw Length for CPL 3-DW header only
/// this is the number adjusted for the PCIe TLP    included header and wasted holes

generate if(AVMM_WIDTH == 256)
   begin

assign tx_modlen_sel = {tx_address_lsb_reg[4:2], dw_len_reg[2:0]};
    
    always @ *
      begin
        case (tx_modlen_sel)   
          6'b000_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;       // data is 256-bit aligned and modulo-256, quad quadwords // dw[9:3] + 4dwh + 8*n modulo 8
          6'b000_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;       // 0 + 8*n modulo 8  
          6'b000_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;   
          6'b000_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b000_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;    
          6'b000_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;
          6'b000_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;
          6'b000_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;   
          6'b001_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;    // 8 dw : (x pr 1) + 1             
          6'b001_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;   // (1 or 9) dw: (x or 1) + 1
          6'b001_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // (2 or 10) dw: (x or 1) + 1
          6'b001_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;    // (3 or 11)dw : (x or 1) + 1
          6'b001_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;   // (4 or 12) dw: (x or 1) + 1
          6'b001_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  /// (5 or 13) dw : (0 or 1) + 1 
          6'b001_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; /// (6 or 14) dw : (0 or 1) + 2
          6'b001_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; //  (7 or 15) dw : (0 or 1) + 2       hit bug
          6'b010_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;     
          6'b010_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b010_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b010_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b010_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; //  (4 or 12) dw:( 0 or 1) + 1  
          6'b010_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; //  (5 or 13) dw:( 0 or 1) + 2
          6'b010_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;  // (6 or 14) dw:( 0 or 1) + 2
          6'b010_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;
          6'b011_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;   
          6'b011_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;   
          6'b011_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;   
          6'b011_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;   
          6'b011_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (4 or 12) dw:  (0 or 1) + 1 
          6'b011_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (5 or  13) dw: (0 or 1) + 1
          6'b011_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; // (6 or  14) dw: (0 or 1) + 2             
          6'b011_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;        
          6'b100_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b100_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b100_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b100_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b100_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; 
          6'b100_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; 
          6'b100_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; // (6 or 14) dw: (0 or 1) + 2
          6'b100_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; // (7 or 15) dw: (0 or 1) + 2
          6'b101_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // 8 dw       : 1 + 1
          6'b101_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (1 or 9) dw: (0 or 1) + 1 
          6'b101_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (2 or 10) dw: (0 or 1) + 1 
          6'b101_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (3 or 11) dw: (0 or 1) + 1
          6'b101_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // ( 4 or 12) dw: (0 or 1) + 1
          6'b101_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (5 or 13) dw: (0 or 1) + 1
          6'b101_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; // (6 or 14) dw: (0 or 1) + 2 
          6'b101_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; //  (7 or 15) dw: (0 or 1) + 2 
          6'b110_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // 8 or 16 dw :  (1 or 2) + 1          
          6'b110_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // 9 or 17 dw :   (1 or 2) + 1 
          6'b110_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // 10 or 18 dw:   (1 or 1) + 1
          6'b110_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // 11 or 19 dw:    (1 or 2) + 1
          6'b110_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // 12 or 20 dw : (1 or 2) + 1 
          6'b110_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;   // 13 or 21 dw:  (1 or 2) + 2
          6'b110_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;   // 14 or 22 dw : (1 or 2) + 2        
          6'b110_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2;  // 15 or 23 dw : (1 or 2) + 2
          6'b111_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // (8) dw: (0 or 1) + 1         
          6'b111_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (1 or 9) dw: (0 or 1) + 1
          6'b111_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;  // (2 or 10) dw: (0 or 1) + 1
          6'b111_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (3 or 11) dw: (0 or 1) + 1
          6'b111_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1; // (4 or 12) dw: (0 or 1) + 1
          6'b111_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd1;// (5 or 13) dw: (0 or 1) + 1 
          6'b111_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; // (6 or 14) dw: (0 or 1) + 2           
          6'b111_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 3'd2; // (7 or 15) dw: (0 or 1) + 2           
          
          default:     tx_modlen_lines[7:0] <= dw_len_reg[9:3];  
          
          
          
  /*        6'b000_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3];       // data is 256-bit aligned and modulo-256, quad quadwords
          6'b000_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;  
          6'b000_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;   
          6'b000_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b000_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;    
          6'b000_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;
          6'b000_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;
          6'b000_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;   

          6'b001_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;                 
          6'b001_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b001_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b001_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b001_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b001_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b001_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b001_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;

          6'b010_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;     
          6'b010_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b010_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b010_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b010_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b010_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b010_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b010_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;
          
          6'b011_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;   
          6'b011_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;   
          6'b011_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;   
          6'b011_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;   
          6'b011_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;   
          6'b011_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;   
          6'b011_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;              
          6'b011_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;        
          
          6'b100_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3]; 
          6'b100_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3]; 
          6'b100_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3]; 
          6'b100_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3]; 
          6'b100_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3]; 
          6'b100_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b100_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b100_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 

          6'b101_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b101_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b101_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b101_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b101_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b101_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b101_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b101_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 

          6'b110_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ;           
          6'b110_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b110_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] ; 
          6'b110_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b110_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b110_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b110_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;           
          6'b110_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
 
          6'b111_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:3];           
          6'b111_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:3]; 
          6'b111_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b111_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b111_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b111_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1; 
          6'b111_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;           
          6'b111_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:3] + 1;           
          
          default:     tx_modlen_lines[7:0] <= dw_len_reg[9:3];  
          
          */
        endcase
      end
   end
  else   /// 128-bit
    begin            
 logic dw_len_lt_4; 
 assign dw_len_lt_4  = dw_len_reg[6:0] < 4 ;
       assign tx_modlen_sel = {tx_address_lsb_reg[3:2], dw_len_lt_4, dw_len_reg[1:0]};
       
       always @ *
         begin
           case (tx_modlen_sel)   
      //       6'b00_00:  tx_modlen_lines[7:0] <= dw_len_reg[9:2];          // data is 128-bit aligned and modulo-128
      //       6'b00_01:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;   // data is 128-bit aligned
      //       6'b00_10:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;   // data is 128-bit aligned
      //       6'b00_11:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;   // data is 128-bit aligned
      //       6'b01_00:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
      //       6'b01_01:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;   
      //       6'b01_10:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2;
      //       6'b01_11:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2;
      //       6'b10_00:  tx_modlen_lines[7:0] <= dw_len_reg[9:2];  
      //       6'b10_01:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;
      //       6'b10_10:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;
      //       6'b10_11:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;
      //       6'b11_00:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;
      //       6'b11_01:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;
      //       6'b11_10:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2;
      //       6'b11_11:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2;          
             
//5'b00_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2;        
5'b00_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b00_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b00_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b01_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b01_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b01_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b01_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b10_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:2];        
5'b10_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b10_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b10_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b11_100:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b11_101:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b11_110:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b11_111:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2;

5'b00_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;        
5'b00_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b00_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b00_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b01_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b01_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b01_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 

5'b01_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b10_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1;     
5'b10_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b10_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b10_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b11_000:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b11_001:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd1; 
5'b11_010:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 
5'b11_011:  tx_modlen_lines[7:0] <= dw_len_reg[9:2] + 3'd2; 

                  
             default:     tx_modlen_lines[7:0] <= dw_len_reg[9:2];  
           endcase
         end
     
    end 
endgenerate



/// completion data counters      

// counter to count the number of burst count in the Cpl buffer to be advanced
 assign load_buff_lines_count = sm_arb_req_rise & first_cpl;
 
 always @(posedge Clk_i or  negedge Rstn_i)                          
  begin         
  	 if(~Rstn_i)
  	    cpl_buff_lines_cntr <= 0;                              
     else if(load_buff_lines_count)                         
       cpl_buff_lines_cntr <= (ReadBcntFifoq_i == 8'h0)? 8'h80 : ReadBcntFifoq_i;          
     else if(cpl_dat_clken) 
       cpl_buff_lines_cntr <= cpl_buff_lines_cntr - 1'b1;         
  end                                            


always @ (posedge Clk_i)
 begin
  sm_arb_req_reg <=   sm_arb_req;
  sm_arb_req_rise_reg <= sm_arb_req_rise;
 end
  
assign sm_arb_req_rise = sm_arb_req & ~sm_arb_req_reg;

generate if (AVMM_WIDTH == 256)
  begin
     always @(posedge Clk_i)
       begin
          if(sm_arb_req_rise)
            cpl_dat_cntr <= tx_modlen_lines;
          else if( (sm_cpl_hdr | sm_cpl_data) & cpl_dat_cntr != 0 |
                    ( sm_cpl_wait & output_fifo_ok_reg & cpl_dat_cntr != 0)) //    else if( cpl_dat_clken & !(tx_address_lsb_reg == 8 & sm_cpl_hdr) & cpl_dat_cntr != 0)
            cpl_dat_cntr <= cpl_dat_cntr - 1'b1;
       end    
  end
  else   // 128
   begin
     always @(posedge Clk_i)
       begin
          if(sm_arb_req_rise)
            cpl_dat_cntr <= tx_modlen_lines;
          else if( (sm_cpl_data | sm_cpl_hdr) & cpl_dat_cntr != 0 |
                    ( sm_cpl_wait & output_fifo_ok_reg & cpl_dat_cntr != 0)) //    else if( cpl_dat_clken & !(tx_address_lsb_reg == 8 & sm_cpl_hdr) & cpl_dat_cntr != 0)
            cpl_dat_cntr <= cpl_dat_cntr - 1'b1;
       end              
   end
  endgenerate

always @(posedge Clk_i)
      output_fifo_ok_reg <= TxFifoCount_i[3:0] <= 4'hA;

generate if(AVMM_WIDTH == 256)
  assign cpl_tlp_in_one_clk = (tx_address_lsb_reg[2] & dw_len_reg <= 5) | (~tx_address_lsb_reg[2] &  dw_len_reg <= 4); 
else 
  assign cpl_tlp_in_one_clk = tx_address_lsb_reg[2] & dw_len_reg == 1; 
endgenerate


generate if(AVMM_WIDTH == 256)
begin
 always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
          all_dw_consumed_per_line_reg <= 1'b0;
       else if(CmdFifoRdReq_o )
           all_dw_consumed_per_line_reg <= CmdFifoDat_i[4:0] == 5'h10 & dw_len[9:0] >= 10'h4  ||  CmdFifoDat_i[4:0] == 5'h0C & dw_len[9:0] >= 10'h5;
     end
 end
 
 else
   begin
      always_ff @ (posedge Clk_i or negedge Rstn_i)
     begin
       if(~Rstn_i)
          all_dw_consumed_per_line_reg <= 1'b0;
       else if(CmdFifoRdReq_o )
           all_dw_consumed_per_line_reg <= CmdFifoDat_i[4:0] == 5'h10 & dw_len[9:0] >= 10'h4  ||  CmdFifoDat_i[4:0] == 5'h0C & dw_len[9:0] >= 10'h5;
     end
  end
endgenerate
          
     


/// TX CPL state machine

always @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      txcpl_state <= TXCPL_IDLE;
    else
      txcpl_state <= txcpl_nxt_state;
  end

always @*
   begin
      case(txcpl_state)
       
         TXCPL_IDLE:           
           if(~cmd_fifo_empty)
               txcpl_nxt_state <= TXCPL_ARB_REQ;
            else
                txcpl_nxt_state <= TXCPL_IDLE;
         
         TXCPL_ARB_REQ:
             txcpl_nxt_state <= TXCPL_ARB_PIPE;
        
        TXCPL_ARB_PIPE:
           if(HpRxmArbGranted_i & output_fifo_ok_reg)
             txcpl_nxt_state <= TXCPL_HEADER;
           else
             txcpl_nxt_state <= TXCPL_ARB_PIPE;
            
         TXCPL_HEADER:
           if(cpl_tlp_in_one_clk)  // small payload, completed in 1 clock
             txcpl_nxt_state <= TXCPL_IDLE;
           else
             txcpl_nxt_state <= TXCPL_DATA;
             
         TXCPL_DATA:
            if((cpl_dat_cntr == 1) & (cmd_fifo_empty | ~side_fifo_empty))
               txcpl_nxt_state <= TXCPL_IDLE;
            else if(cpl_dat_cntr == 1 & ~cmd_fifo_empty)
                 txcpl_nxt_state <= TXCPL_ARB_REQ;
            else if(~output_fifo_ok_reg)
               txcpl_nxt_state <= TXCPL_WAIT;
            else
               txcpl_nxt_state <= TXCPL_DATA;
               
          TXCPL_WAIT:
            if(output_fifo_ok_reg & cpl_dat_cntr > 1)
                 txcpl_nxt_state <= TXCPL_DATA;
            else if(output_fifo_ok_reg & cmd_fifo_empty)
                 txcpl_nxt_state <= TXCPL_IDLE;
            else if(output_fifo_ok_reg & ~cmd_fifo_empty)
                  txcpl_nxt_state <= TXCPL_ARB_REQ;
            else
               txcpl_nxt_state <= TXCPL_WAIT;
         
         default:
            txcpl_nxt_state <= TXCPL_IDLE;
      endcase
end
  
assign sm_cpl_idle = (txcpl_state == TXCPL_IDLE);   
assign sm_cpl_hdr  = (txcpl_state == TXCPL_HEADER);
assign sm_cpl_data = (txcpl_state == TXCPL_DATA);
assign sm_cpl_wait = (txcpl_state == TXCPL_WAIT);       
assign sm_arb_req = (txcpl_state == TXCPL_ARB_REQ);
assign HpRxmArbReq_o = ~sm_cpl_idle;

assign data_2_arb_req = sm_cpl_data & ~((cpl_dat_cntr == 1) & (cmd_fifo_empty | ~side_fifo_empty)) & (cpl_dat_cntr == 1 & ~cmd_fifo_empty);
assign wait_2_arb_req = sm_cpl_wait & ~(output_fifo_ok_reg & cpl_dat_cntr > 1) & ~(output_fifo_ok_reg & cmd_fifo_empty) & (output_fifo_ok_reg & ~cmd_fifo_empty);

/// Completion Data Path
generate if(AVMM_WIDTH == 256)
 assign prefetch_cpl_buff = sm_arb_req_rise_reg & (first_valid_dw_address_reg[4:0] == 5'h1C | first_valid_dw_address_reg[4:0] == 5'h18 | first_valid_dw_address_reg[4:0] == 5'h14);  /// need 2 slices tp fill the first CPL TLP
 else
 assign prefetch_cpl_buff = sm_arb_req_rise_reg & (first_valid_dw_address_reg[3:0] == 4'hC | first_valid_dw_address_reg[3:0] == 4'h8 | first_valid_dw_address_reg[3:0] == 4'h4);  /// need 2 slices tp fill the first CPL TLP
endgenerate
  
 assign  last_cpl = (dw_len_reg[9:0] == cpl_remain_bytes_reg[11:2]) & tlp_eop;
 
 /// also move the cpl ram read-pointer when the full line is consuned at the end of every TLP.  
 
generate if(AVMM_WIDTH == 256)
  begin 
      assign cpl_dat_clken = (last_cpl & cpl_buff_lines_cntr != 0)| prefetch_cpl_buff | (sm_cpl_data | sm_cpl_hdr  | (sm_cpl_wait & output_fifo_ok_reg)) & cpl_dat_cntr != 1 | (sm_cpl_data  & all_dw_consumed_per_line_reg) |
                         (sm_cpl_wait & output_fifo_ok_reg) & all_dw_consumed_per_line_reg |
                         (sm_cpl_hdr  &all_dw_consumed_per_line_reg);   
  end
else   /// 128
  begin
     assign cpl_dat_clken =   //(last_cpl & cpl_buff_lines_cntr != 0)| 
                           ( 
                             (last_cpl & cpl_buff_lines_cntr != 0)| 
                            (sm_cpl_hdr & tx_address_lsb_reg[3:2] != 0) |
                            (sm_cpl_data &  cpl_dat_cntr > 1 & tx_address_lsb_reg[3:2] != 0) |   
                            (sm_cpl_data &  cpl_dat_cntr > 0 & (tx_address_lsb_reg[3:2] == 0 | tx_address_lsb_reg[3:2] == 3 ) ) | 
                            (sm_cpl_wait & output_fifo_ok_reg & cpl_dat_cntr > 1 & tx_address_lsb_reg[3:2] != 0) | 
                            (sm_cpl_wait & output_fifo_ok_reg & cpl_dat_cntr > 0 & (tx_address_lsb_reg[3:2] == 0 | tx_address_lsb_reg[3:2] == 3 )) | 
                            (sm_cpl_data  & all_dw_consumed_per_line_reg) 
                                                                         )   & cpl_buff_lines_cntr != 0   ;   
    
    
    
  /*  assign cpl_dat_clken = (sm_cpl_data &   cpl_dat_cntr != 1 & tx_address_lsb_reg[2]) | 
                           (sm_cpl_data  & ~tx_address_lsb_reg[2]) |
                            (sm_cpl_wait & output_fifo_ok_reg) |
                           (sm_cpl_hdr & tx_address_lsb_reg[2]);
                           */
                       
  end
endgenerate

 assign CplBuffRdAddr_o[8:0] = cpl_dat_clken & ~is_flush_cpl_reg? (cpl_addr_reg + 1'b1) : cpl_addr_reg;

always @(posedge Clk_i or negedge Rstn_i)
  begin
     if(~Rstn_i)
       cpl_addr_reg <= 9'h0;
     else
       cpl_addr_reg <= CplBuffRdAddr_o;
  end
  
  
assign tlp_buff_data =  TxCplDat_i;


assign cpl_data_dw0 = tlp_buff_data[31:0];
assign cpl_data_dw1 = tlp_buff_data[63:32];
assign cpl_data_dw2 = tlp_buff_data[95:64];
assign cpl_data_dw3 = tlp_buff_data[127:96];
assign cpl_data_dw4 = tlp_buff_data[159:128];
assign cpl_data_dw5 = tlp_buff_data[191:160];
assign cpl_data_dw6 = tlp_buff_data[223:192];
assign cpl_data_dw7 = tlp_buff_data[255:224];   


always @(posedge Clk_i or negedge Rstn_i)  // state machine registers  
   if(~Rstn_i)
      tlp_holding_reg <= 0; 
   else if(cpl_dat_clken)
      tlp_holding_reg <= tlp_buff_data;

assign cpl_holding_reg_dw2 = tlp_holding_reg[95:64];   
assign cpl_holding_reg_dw3 = tlp_holding_reg[127:96];  
assign cpl_holding_reg_dw4 = tlp_holding_reg[159:128]; 
assign cpl_holding_reg_dw5 = tlp_holding_reg[191:160]; 
assign cpl_holding_reg_dw6 = tlp_holding_reg[223:192]; 
assign cpl_holding_reg_dw7 = tlp_holding_reg[255:224]; 



// MUX the Data DW to the correct alignments based on Address      

/// first valid dw address position of the txbuff_data
always @(posedge Clk_i or negedge Rstn_i)  // state machine registers  
 begin
   if(~Rstn_i)
      first_valid_dw_address_reg <= 8'h0; 
   else if(load_buff_lines_count)  // at the first coompletion of each tag
      first_valid_dw_address_reg <= {1'b0, cpl_cmd_reg[6:0]};
   else if(sm_arb_req_rise)
      first_valid_dw_address_reg <= 8'h0;
end


generate if(AVMM_WIDTH == 256)
   begin
   	
   assign cpl_header_qw2 =  tx_data[191:128];
   assign cpl_header_qw3 =  tx_data[255:192];
      always @* 
         begin
                 case (first_valid_dw_address_reg[4:0]) 
                     5'h0:  tx_data = {cpl_data_dw3,cpl_data_dw2,cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw7, cpl_holding_reg_dw6, cpl_holding_reg_dw5, cpl_holding_reg_dw4};                // start addr is on 256-bit addr boundary
                     5'h4:  tx_data = {cpl_data_dw5,cpl_data_dw4,cpl_data_dw3,cpl_data_dw2,cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw7,cpl_holding_reg_dw6};                             
                     5'h8:  tx_data = {cpl_data_dw5,cpl_data_dw4,cpl_data_dw3,cpl_data_dw2,cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw7,cpl_holding_reg_dw6};    
                     5'hC:  tx_data = {cpl_data_dw7,cpl_data_dw6,cpl_data_dw5,cpl_data_dw4,cpl_data_dw3,cpl_data_dw2, cpl_data_dw1, cpl_data_dw0};             
                     5'h10: tx_data = {cpl_data_dw7,cpl_data_dw6,cpl_data_dw5,cpl_data_dw4,cpl_data_dw3,cpl_data_dw2, cpl_data_dw1, cpl_data_dw0}; 
                     5'h14: tx_data = {cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw7,cpl_holding_reg_dw6,cpl_holding_reg_dw5,cpl_holding_reg_dw4, cpl_holding_reg_dw3, cpl_holding_reg_dw2};   
                     5'h18: tx_data = {cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw7,cpl_holding_reg_dw6,cpl_holding_reg_dw5,cpl_holding_reg_dw4, cpl_holding_reg_dw3, cpl_holding_reg_dw2}; 
                     5'h1C: tx_data = {cpl_data_dw3,cpl_data_dw2,cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw7,cpl_holding_reg_dw6, cpl_holding_reg_dw5, cpl_holding_reg_dw4};     
                     default: tx_data = 256'h0;
                 endcase
         end           
   end
else    // 128-bit
   begin
      always @* 
         begin
                 case (tx_address_lsb_reg[3:0])
                     4'h0:  tx_data[127:0]   = {cpl_data_dw3,cpl_data_dw2,cpl_data_dw1,cpl_data_dw0};             
                     4'h4:  tx_data[127:0]   = {cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw3,cpl_holding_reg_dw2};                             
                     4'h8:  tx_data[127:0]   = {cpl_data_dw1,cpl_data_dw0,cpl_holding_reg_dw3,cpl_holding_reg_dw2}; 
                     4'hC:  tx_data[127:0]   = {cpl_data_dw3,cpl_data_dw2,cpl_data_dw1,cpl_data_dw0};             
                     default: tx_data[127:0] = {cpl_data_dw3,cpl_data_dw2,cpl_data_dw1,cpl_data_dw0};
                 endcase
         end 
   end
endgenerate
         

 /// Completion TLP Header assembling
assign cpl_header_qw0 = {cpl_cplter_id[15:0], is_abort_cpl_reg ,3'b000, cpl_remain_bytes_reg[11:0],             1'b0, ~is_abort_cpl_reg, 6'b001010, 1'b0, cpl_tc_reg[2:0], 4'h0, 2'h0, cpl_attr_reg[1:0], 2'b00, dw_len_reg[9:0]};
assign cpl_header_qw1 = { tx_data[127:96], cpl_req_id_reg, cpl_tag_reg, 1'b0, lower_adr_reg};


/// Muxing Header, Data    
generate if(AVMM_WIDTH == 256)
   assign tlp_data     = sm_cpl_hdr? {cpl_header_qw3, cpl_header_qw2,cpl_header_qw1, cpl_header_qw0} : tx_data;
else
    assign tlp_data[127:0]     = sm_cpl_hdr? {cpl_header_qw1, cpl_header_qw0} : tx_data[127:0];       
endgenerate

 // sop - eop - empty
assign tlp_sop =   sm_cpl_hdr;

generate if(AVMM_WIDTH == 256)
  begin
      assign tlp_eop = (sm_cpl_data & cpl_dat_cntr == 1) | 
                       (sm_cpl_wait & output_fifo_ok_reg &  cpl_dat_cntr == 1) |
                       (sm_cpl_hdr & (cpl_dat_cntr == 1 | is_abort_cpl_reg | cpl_tlp_in_one_clk));
       
      assign tlp_emp_sel = {tx_address_lsb_reg[2], dw_len_reg[2:0]}; 
       
           always @ *
            begin
              case (tlp_emp_sel)  
                4'b0_000:  tx_empty_int[1:0] <= 2'h2; 
                4'b0_001:  tx_empty_int[1:0] <= 2'h1;   
                4'b0_010:  tx_empty_int[1:0] <= 2'h1; 
                4'b0_011:  tx_empty_int[1:0] <= 2'h0;   
                4'b0_100:  tx_empty_int[1:0] <= 2'h0;    
                4'b0_101:  tx_empty_int[1:0] <= 2'h3;    
                4'b0_110:  tx_empty_int[1:0] <= 2'h3;    
                4'b0_111:  tx_empty_int[1:0] <= 2'h2;    

                  //   done up to here
                4'b1_000:  tx_empty_int[1:0] <= 2'h2;   
                4'b1_001:  tx_empty_int[1:0] <= 2'h2;   
                4'b1_010:  tx_empty_int[1:0] <= 2'h1; 
                4'b1_011:  tx_empty_int[1:0] <= 2'h1;   
                4'b1_100:  tx_empty_int[1:0] <= 2'h0;    
                4'b1_101:  tx_empty_int[1:0] <= 2'h0;    
                4'b1_110:  tx_empty_int[1:0] <= 2'h3;    
                4'b1_111:  tx_empty_int[1:0] <= 2'h3;   
                
          
                
                default:   tx_empty_int <= 2'b0;  
              endcase
            end                           
      
      assign tlp_empty = tlp_eop?  tx_empty_int : 2'b00;  
      assign output_fifo_data_in[TX_FIFO_WIDTH-1:0]  = {tlp_empty, tlp_eop, tlp_sop, tlp_data};      
  end

else
  begin
     assign tlp_eop = (sm_cpl_data & (cpl_dat_cntr == 1)) | (sm_cpl_wait & output_fifo_ok_reg &  (cpl_dat_cntr == 1)) |
                       (sm_cpl_hdr & ((dw_len_reg == 1 & tx_address_lsb_reg[2]) | is_abort_cpl_reg));
       
    assign tlp_emp_sel = {1'b0, tx_address_lsb_reg[2], dw_len_reg[1:0]};    
       
    always @ *
      begin
        case (tlp_emp_sel[2:0])   
          3'b000:  tx_empty_int <= 2'b00; 
          3'b001:  tx_empty_int <= 2'b01; 
          3'b010:  tx_empty_int <= 2'b01; 
          3'b011:  tx_empty_int <= 2'b00;      
          3'b100:  tx_empty_int <= 2'b00; 
          3'b101:  tx_empty_int <= 2'b00; 
          3'b110:  tx_empty_int <= 2'b01; 
          3'b111:  tx_empty_int <= 2'b01; 
          default: tx_empty_int <= 2'b00;  
        endcase
      end                                                               
      
      assign tlp_empty[0] = tlp_eop & tx_empty_int[0]; 
      assign output_fifo_data_in[130:0]  = {tlp_empty[0], tlp_eop, tlp_sop, tlp_data[127:0]}; 
  end         
endgenerate


assign output_fifo_wrreq = ( sm_cpl_data | sm_cpl_hdr ) | 
                           (sm_cpl_wait & output_fifo_ok_reg);

/// register fifo input and write request
always @(posedge Clk_i)  // state machine registers
      begin
        TxFifoWrReq_o   <= output_fifo_wrreq;    
        TxFifoData_o    <= output_fifo_data_in;
      end

assign ReadBcntFifoRdreq_o = last_cpl;      


endmodule

