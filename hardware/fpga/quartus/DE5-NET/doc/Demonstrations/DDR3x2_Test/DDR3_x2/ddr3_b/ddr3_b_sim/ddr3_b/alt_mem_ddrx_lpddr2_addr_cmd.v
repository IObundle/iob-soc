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


///////////////////////////////////////////////////////////////////////////////
// Title         : LPDDR2 controller address and command decoder
//
// File          : alt_mem_ddrx_lpddr2_addr_cmd.v
//
// Abstract      : LPDDR2 Address and command decoder
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
module alt_mem_ddrx_lpddr2_addr_cmd
    # (parameter
    
        // Global parameters
        CFG_PORT_WIDTH_OUTPUT_REGD    = 1,
        CFG_MEM_IF_CHIP               = 1,
        CFG_MEM_IF_CKE_WIDTH          = 1,    // same width as CS_WIDTH
        CFG_MEM_IF_ADDR_WIDTH         = 20,
        CFG_MEM_IF_ROW_WIDTH          = 15,   // max supported row bits
        CFG_MEM_IF_COL_WIDTH          = 12,   // max supported column bits  
        CFG_MEM_IF_BA_WIDTH           = 3,    // max supported bank bits
        CFG_DWIDTH_RATIO              = 2
    )
    (
        ctl_clk,
        ctl_reset_n,
        ctl_cal_success,

        //run-time configuration interface
        cfg_output_regd,
        cfg_enable_chipsel_for_sideband,

        // AFI interface (Signals from Arbiter block)
        do_write,
        do_read,
        do_auto_precharge,
        do_activate,
        do_precharge,
        do_precharge_all,
        do_refresh,
        do_self_refresh,
        do_power_down,
        do_lmr,
        
        do_lmr_read,         //Currently does not exist in arbiter
        do_refresh_1bank,     //Currently does not exist in arbiter
        do_burst_terminate,     //Currently does not exist in arbiter
        do_deep_pwrdwn,     //Currently does not exist in arbiter
        
        // address information
        to_chip,                 // active high input (one hot)
        to_bank,
        to_row,
        to_col,
        to_lmr,
        lmr_opcode,
        
        //output
        afi_cke,
        afi_cs_n,
        afi_addr,
        afi_rst_n
    );
    
    input ctl_clk;
    input ctl_reset_n;
    input ctl_cal_success;

    //run-time  configuration input
    input [CFG_PORT_WIDTH_OUTPUT_REGD -1:0] cfg_output_regd;
    input                                   cfg_enable_chipsel_for_sideband;

    //  Arbiter command inputs
    input do_write;
    input do_read;
    input do_auto_precharge;
    input do_activate;
    input do_precharge;

    input [CFG_MEM_IF_CHIP-1:0]    do_precharge_all;
    input [CFG_MEM_IF_CHIP-1:0]    do_refresh;
    input [CFG_MEM_IF_CHIP-1:0]    do_self_refresh;
    input [CFG_MEM_IF_CHIP-1:0]    do_power_down;
    input [CFG_MEM_IF_CHIP-1:0]    do_deep_pwrdwn;


    input do_lmr;

    
    input do_lmr_read;
    input do_refresh_1bank;
    input do_burst_terminate;
    
    input   [CFG_MEM_IF_CHIP-1:0]       to_chip;
    input   [CFG_MEM_IF_BA_WIDTH-1:0]   to_bank;
    input   [CFG_MEM_IF_ROW_WIDTH-1:0]  to_row;
    input   [CFG_MEM_IF_COL_WIDTH-1:0]  to_col;
    input   [7:0]                       to_lmr;
    input   [7:0]                       lmr_opcode;
    
    //output
    output  [(CFG_MEM_IF_CKE_WIDTH * (CFG_DWIDTH_RATIO/2)) - 1:0]   afi_cke;
    output  [(CFG_MEM_IF_CHIP * (CFG_DWIDTH_RATIO/2)) - 1:0]        afi_cs_n;
    output  [(CFG_MEM_IF_ADDR_WIDTH * (CFG_DWIDTH_RATIO/2)) - 1:0]  afi_addr;
    output  [(CFG_DWIDTH_RATIO/2) - 1:0]                            afi_rst_n;
    
    wire do_write;
    wire do_read;
    wire do_auto_precharge;
    wire do_activate;
    wire do_precharge;

    wire  [CFG_MEM_IF_CHIP-1:0]    do_precharge_all;
    wire  [CFG_MEM_IF_CHIP-1:0]    do_refresh;
    wire  [CFG_MEM_IF_CHIP-1:0]    do_self_refresh;
    wire  [CFG_MEM_IF_CHIP-1:0]    do_power_down;
    wire  [CFG_MEM_IF_CHIP-1:0]    do_deep_pwrdwn;

    wire do_lmr;

    wire do_lmr_read;
    wire do_refresh_1bank;
    wire do_burst_terminate;
    
    reg   [2:0]    temp_bank_addr;
    reg   [14:0]   temp_row_addr;
    reg   [11:0]   temp_col_addr;

    
    wire    [(CFG_MEM_IF_CKE_WIDTH * (CFG_DWIDTH_RATIO/2)) - 1:0]   afi_cke;
    wire    [(CFG_MEM_IF_CHIP * (CFG_DWIDTH_RATIO/2)) - 1:0]        afi_cs_n;
    wire    [(CFG_MEM_IF_ADDR_WIDTH * (CFG_DWIDTH_RATIO/2)) - 1:0]  afi_addr;
    wire    [(CFG_DWIDTH_RATIO/2) - 1:0]                            afi_rst_n;
    
    reg [(CFG_MEM_IF_CKE_WIDTH) - 1:0]      int_cke;
    reg [(CFG_MEM_IF_CKE_WIDTH) - 1:0]      int_cke_r;
    reg [(CFG_MEM_IF_CHIP) - 1:0]           int_cs_n;
    reg [(CFG_MEM_IF_ADDR_WIDTH) - 1:0]     int_addr;
    
    reg [(CFG_MEM_IF_CKE_WIDTH) - 1:0]      combi_cke;
    reg [(CFG_MEM_IF_CHIP) - 1:0]           combi_cs_n;
    reg [(CFG_MEM_IF_ADDR_WIDTH) - 1:0]     combi_addr;
    reg [(CFG_MEM_IF_CKE_WIDTH) - 1:0]      combi_cke_r;
    reg [(CFG_MEM_IF_CHIP) - 1:0]           combi_cs_n_r;
    reg [(CFG_MEM_IF_ADDR_WIDTH) - 1:0]     combi_addr_r;
    
    reg   [CFG_MEM_IF_CHIP - 1:0]           do_power_down_r;
    reg   [CFG_MEM_IF_CHIP - 1:0]           do_self_refresh_r;
    reg   [CFG_MEM_IF_CHIP - 1:0]           do_deep_pwrdwn_r;
    reg   [CFG_MEM_IF_CHIP - 1:0]           int_do_power_down;
    reg   [CFG_MEM_IF_CHIP - 1:0]           int_do_self_refresh;
    reg   [CFG_MEM_IF_CHIP - 1:0]           int_do_deep_pwrdwn;
    
    assign afi_rst_n    = {(CFG_DWIDTH_RATIO/2){1'b1}};
    
    
    generate
        if (CFG_DWIDTH_RATIO == 2) begin
            assign afi_cke      = int_cke;
            assign afi_cs_n     = int_cs_n;
            assign afi_addr     = int_addr;
        end
        else begin
            assign afi_cke      = {int_cke,int_cke};
            assign afi_cs_n     = (do_burst_terminate)? {int_cs_n,int_cs_n} :{int_cs_n,{CFG_MEM_IF_CHIP{1'b1}}};
            assign afi_addr     = {int_addr,int_addr};
        end        
    endgenerate
    
// need half rate code to adjust for half rate cke or cs
   
    always @(posedge ctl_clk, negedge ctl_reset_n)            // toogles cs_n for only one cyle when state machine continues to stay in slf rfsh mode or DPD
        begin
            if (!ctl_reset_n)
                begin
                    do_power_down_r   <= {(CFG_MEM_IF_CHIP){1'b0}};
                    do_self_refresh_r <= {(CFG_MEM_IF_CHIP){1'b0}};
                    do_deep_pwrdwn_r  <= {(CFG_MEM_IF_CHIP){1'b0}};
                end
            else
                begin
                    do_power_down_r   <= ~do_power_down;
                    do_self_refresh_r <= ~do_self_refresh;
                    do_deep_pwrdwn_r  <= ~do_deep_pwrdwn;
                end
        end
    
    always @(*)
        begin
            int_do_power_down   = do_power_down   & do_power_down_r;
            int_do_self_refresh = do_self_refresh & do_self_refresh_r;
            int_do_deep_pwrdwn  = do_deep_pwrdwn  & do_deep_pwrdwn_r;
        end
    
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            combi_cke_r   <= {CFG_MEM_IF_CKE_WIDTH{1'b1}} ;
            combi_cs_n_r  <= {CFG_MEM_IF_CHIP{1'b1}}  ;
            combi_addr_r  <= {CFG_MEM_IF_ADDR_WIDTH{1'b0}};
        end
        else
        begin
            combi_cke_r   <= combi_cke  ;
            combi_cs_n_r  <= combi_cs_n ;
            combi_addr_r  <= combi_addr ;
        end
    end

    always @(*)
        begin
            if (cfg_output_regd)
                begin
                    int_cke     =  combi_cke_r;
                    int_cs_n    =  combi_cs_n_r;
                    int_addr    =  combi_addr_r;
                end
            else
                begin
                    int_cke     =  combi_cke;
                    int_cs_n    =  combi_cs_n;
                    int_addr    =  combi_addr;
                end
        end
    
    
    always @ (*) 
    begin
        temp_row_addr    = {CFG_MEM_IF_ROW_WIDTH{1'b0}} ;
        temp_col_addr    = {CFG_MEM_IF_COL_WIDTH{1'b0}} ;
        temp_bank_addr   = {CFG_MEM_IF_BA_WIDTH {1'b0}} ;
        temp_row_addr    = to_row ;
        temp_col_addr    = to_col ;
        temp_bank_addr   = to_bank;
    end
    
    //CKE generation block
    always @(*)
        begin
            if (ctl_cal_success)
               begin 
                    combi_cke = ~(do_self_refresh | do_power_down | do_deep_pwrdwn);
               end
            else
               begin
                    combi_cke = {(CFG_MEM_IF_CKE_WIDTH){1'b1}};
               end
        end
    
    
    always @(*)
        begin
            if (ctl_cal_success)
                begin
                    combi_cs_n    =   {(CFG_MEM_IF_CHIP){1'b1}};
                    combi_addr    =   {(CFG_MEM_IF_ADDR_WIDTH){1'b0}};
                    
                    if (|do_refresh)
                        begin
                            combi_cs_n                                          =  ~do_refresh;
                            combi_addr[3:0]                                     =   4'b1100;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {(CFG_MEM_IF_ADDR_WIDTH/2 - 4){1'b0}};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {(CFG_MEM_IF_ADDR_WIDTH/2){1'b0}};
                        end

                    if (do_refresh_1bank)
                        begin
                            combi_cs_n                                          =  ~to_chip;
                            combi_addr[3:0]                                     =   4'b0100;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {(CFG_MEM_IF_ADDR_WIDTH/2 - 4){1'b0}};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {(CFG_MEM_IF_ADDR_WIDTH/2){1'b0}};
                        end

                    if (|do_precharge_all)
                        begin
                            combi_cs_n                                          = ~do_precharge_all;
                            combi_addr[3:0]                                     =  4'b1011;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       = {temp_bank_addr,2'b00,(|do_precharge_all)};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          = {(CFG_MEM_IF_ADDR_WIDTH/2){1'b0}};
                        end
                   
                    if (do_activate)
                        begin
                            combi_cs_n                                          =  ~to_chip;
                            combi_addr[3:0]                                     =  {temp_row_addr[9:8],2'b10};
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {temp_bank_addr,temp_row_addr[12:10]};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {temp_row_addr[14:13],temp_row_addr[7:0]};
                        end
                    
                    if (do_precharge)
                        begin
                            combi_cs_n                                          = ~to_chip;
                            combi_addr[3:0]                                     = 4'b1011;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       = {temp_bank_addr,3'b000};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          = {temp_row_addr[14:13],temp_row_addr[7:0]};
                        end
                    
                    if (do_write)
                        begin
                            combi_cs_n                                          =  ~to_chip;
                            combi_addr[3:0]                                     =  4'b0001;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {temp_bank_addr,temp_col_addr[2:1],1'b0};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {temp_col_addr[11:3],do_auto_precharge};
                        end
                   
                    if (do_read)
                        begin
                            combi_cs_n                                          =  ~to_chip;
                            combi_addr[3:0]                                     =  4'b0101;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {temp_bank_addr,temp_col_addr[2:1],1'b0};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {temp_col_addr[11:3],do_auto_precharge};
                        end
                    
                    if (|int_do_power_down)
                        begin
                            combi_cs_n                                          =  {(CFG_MEM_IF_CHIP){1'b1}};
                            combi_addr[3:0]                                     =  4'b0000;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {(CFG_MEM_IF_ADDR_WIDTH/2 - 4){1'b0}};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {(CFG_MEM_IF_ADDR_WIDTH/2){1'b0}};
                        end
                    
                    if (|int_do_deep_pwrdwn)
                        begin
                            if (cfg_enable_chipsel_for_sideband)
                                begin
                                    combi_cs_n                                  = ~int_do_deep_pwrdwn; // toogles cs_n for only one cyle when state machine continues to stay in deep power down;
                                end
                            else
                                begin
                                    combi_cs_n                                  =  {(CFG_MEM_IF_CHIP){1'b1}};
                                end
                            
                            combi_addr[3:0]                                     =  4'b0011;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {(CFG_MEM_IF_ADDR_WIDTH/2 - 4){1'b0}};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {(CFG_MEM_IF_ADDR_WIDTH/2){1'b0}};
                        end

                    if (|int_do_self_refresh)
                        begin
                            if (cfg_enable_chipsel_for_sideband)
                                begin
                                    combi_cs_n                                  = ~int_do_self_refresh; // toogles cs_n for only one cyle when state machine continues to stay in deep power down;
                                end
                            else
                                begin
                                    combi_cs_n                                  =  {(CFG_MEM_IF_CHIP){1'b1}};
                                end
                            
                            combi_addr[3:0]                                     =  4'b0100;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {(CFG_MEM_IF_ADDR_WIDTH/2 - 4){1'b0}};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {(CFG_MEM_IF_ADDR_WIDTH/2){1'b0}};
                        end
                   
                    if (do_lmr)
                        begin
                            combi_cs_n                                          =  ~to_chip;
                            combi_addr[3:0]                                     =  4'b0000;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  to_lmr[5:0];
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {to_lmr[7:6],lmr_opcode};
                        end

                    if (do_lmr_read)
                        begin
                            combi_cs_n                                          =  ~to_chip;
                            combi_addr[3:0]                                     =  4'b1000;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  to_lmr[5:0];
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {to_lmr[7:6],{8{1'b0}}};
                        end
                   
                    if (do_burst_terminate)
                        begin
                            combi_cs_n                                          =  ~to_chip;
                            combi_addr[3:0]                                     =  4'b0011;
                            combi_addr[(CFG_MEM_IF_ADDR_WIDTH/2) - 1 : 4]       =  {(CFG_MEM_IF_ADDR_WIDTH/2 - 4){1'b0}};
                            combi_addr[CFG_MEM_IF_ADDR_WIDTH - 1 : 10]          =  {(CFG_MEM_IF_ADDR_WIDTH/2){1'b0}};
                        end
            
                           
                end
            else
                begin
                    combi_cs_n                                                  =  {(CFG_MEM_IF_CHIP){1'b1}};
                    combi_addr                                                  =  {(CFG_MEM_IF_ADDR_WIDTH){1'b0}};
                end
        end

endmodule
