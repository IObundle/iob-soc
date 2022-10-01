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

module altpcieav_cra 
  (
      input logic                                   Clk_i,
      input logic                                   Rstn_i,
      
      input  logic                                  CraChipSelect_i,
      input  logic                                  CraRead_i,           
      input  logic                                  CraWrite_i,          
      input  logic  [13:0]                          CraAddress_i,
      input  logic  [31:0]                          CraWriteData_i,
      input  logic  [3:0]                           CraByteEnable_i,
      output logic                                  CraWaitRequest_o,
      output logic  [31:0]                          CraReadData_o,
      input  logic  [3:0]                           CfgAddr_i,      
      input  logic  [31:0]                          CfgCtl_i,       
      input  logic  [4:0]                           Ltssm_i,        
      input  logic  [1:0]                           CurrentSpeed_i, 
      input  logic  [3:0]                           LaneAct_i       
            
   );

logic  [31:0]             cfg_dev_ctrl;
logic  [31:0]             cfg_slot_ctrl;
logic  [31:0]             cfg_link_ctrl;
logic  [31:0]             cfg_prm_root_ctrl;
logic  [31:0]             cfg_sec_bus;
logic  [31:0]             cfg_msi_addr_iobase;
logic  [31:0]             cfg_msi_addr_iolim;
logic  [31:0]             cfg_np_base_lim;
logic  [31:0]             cfg_pr_base;
logic  [31:0]             cfg_msi_add_pr_base;
logic  [31:0]             cfg_pr_lim;
logic  [31:0]             cfg_msi_addr_prlim;
logic  [31:0]             cfg_pm_csr;
logic  [31:0]             cfg_msix_msi_csr;
logic  [31:0]             cfg_ecrc_tcvc_map;
logic  [31:0]             cfg_msi_data_busdev;   
 
logic [31:0]             cfg_dev_ctrl_reg;     
logic [31:0]             cfg_dev_ctrl2_reg;    
logic [31:0]             cfg_link_ctrl_reg;    
logic [31:0]             cfg_link_ctrl2_reg;   
logic [31:0]             cfg_prm_cmd_reg;      
logic [31:0]             cfg_root_ctrl_reg;    
logic [31:0]             cfg_sec_ctrl_reg;     
logic [31:0]             cfg_secbus_reg;       
logic [31:0]             cfg_subbus_reg;       
logic [31:0]             cfg_msi_addr_low_reg; 
logic [31:0]             cfg_msi_addr_hi_reg;  
logic [31:0]             cfg_io_bas_reg;       
logic [31:0]             cfg_io_lim_reg;       
logic [31:0]             cfg_np_bas_reg;       
logic [31:0]             cfg_np_lim_reg;       
logic [31:0]             cfg_pr_bas_low_reg;   
logic [31:0]             cfg_pr_bas_hi_reg;    
logic [31:0]             cfg_pr_lim_low_reg;   
logic [31:0]             cfg_pr_lim_hi_reg;    
logic [31:0]             cfg_pmcsr_reg;        
logic [31:0]             cfg_msixcsr_reg;      
logic [31:0]             cfg_msicsr_reg;       
logic [31:0]             cfg_tcvcmap_reg;      
logic [31:0]             cfg_msi_data_reg;     
logic [31:0]             cfg_busdev_reg;       
logic                     rstn_r; 
logic                     rstn_reg; 
logic                     rstn_rr;         
logic [31:0]              ltssm_reg;         
logic [31:0]              current_speed_reg; 
logic [31:0]              lane_act_reg;    
logic                     register_access;        
logic                     register_access_sreg;   
logic                     register_access_reg;    
logic                     register_access_rise;   
logic  [31:0]             read_data_reg;    
logic  [31:0]             reg_mux_out;    
logic                     register_ready_reg;  

always @(posedge Clk_i or negedge Rstn_i)
  begin
  	if(~Rstn_i)
  	  begin
        rstn_r <= 1'b0; 
        rstn_rr <= 1'b0;
       end
    else
       begin
       	  rstn_r <= 1'b1;
          rstn_rr <= rstn_r;
       end
  end
 
 assign rstn_reg = rstn_rr;
 
    //Configuration Demux logic 
    always_ff @(posedge Clk_i or negedge rstn_reg)   
     begin
        if (rstn_reg == 0)
          begin
             cfg_dev_ctrl <= 32'h0;
             cfg_slot_ctrl <= 32'h0;
             cfg_link_ctrl <= 32'h0;
             cfg_prm_root_ctrl <= 32'h0;
             cfg_sec_bus <= 32'h0;
             cfg_msi_addr_iobase <= 32'h0;
             cfg_msi_addr_iolim <= 32'h0;
             cfg_np_base_lim <= 32'h0;
             cfg_pr_base <= 32'h0;
             cfg_msi_add_pr_base <= 32'h0;
             cfg_pr_lim <= 32'h0;
             cfg_msi_addr_prlim <= 32'h0;
             cfg_pm_csr <= 32'h0;
             cfg_msix_msi_csr <= 32'h0;
             cfg_ecrc_tcvc_map <= 32'h0;
             cfg_msi_data_busdev <= 32'h0;
          end
        else
          begin  /// dump the table
             cfg_dev_ctrl           <= (CfgAddr_i[3:0] == 4'h0) ? CfgCtl_i[31 : 0]  : cfg_dev_ctrl;
             cfg_slot_ctrl          <= (CfgAddr_i[3:0] == 4'h1) ? CfgCtl_i[31 : 0]  : cfg_slot_ctrl;
             cfg_link_ctrl          <= (CfgAddr_i[3:0] == 4'h2) ? CfgCtl_i[31 : 0]  : cfg_link_ctrl;
             cfg_prm_root_ctrl      <= (CfgAddr_i[3:0] == 4'h3) ? CfgCtl_i[31 : 0]  : cfg_prm_root_ctrl;
             cfg_sec_bus            <= (CfgAddr_i[3:0] == 4'h4) ? CfgCtl_i[31 : 0]  : cfg_sec_bus;
             cfg_msi_addr_iobase    <= (CfgAddr_i[3:0] == 4'h5) ? CfgCtl_i[31 : 0]  : cfg_msi_addr_iobase;
             cfg_msi_addr_iolim     <= (CfgAddr_i[3:0] == 4'h6) ? CfgCtl_i[31 : 0]  : cfg_msi_addr_iolim;
             cfg_np_base_lim        <= (CfgAddr_i[3:0] == 4'h7) ? CfgCtl_i[31 : 0]  : cfg_np_base_lim;
             cfg_pr_base            <= (CfgAddr_i[3:0] == 4'h8) ? CfgCtl_i[31 : 0]  : cfg_pr_base;
             cfg_msi_add_pr_base    <= (CfgAddr_i[3:0] == 4'h9) ? CfgCtl_i[31 : 0]  : cfg_msi_add_pr_base;
             cfg_pr_lim             <= (CfgAddr_i[3:0] == 4'hA) ? CfgCtl_i[31 : 0]  : cfg_pr_lim;
             cfg_msi_addr_prlim     <= (CfgAddr_i[3:0] == 4'hB) ? CfgCtl_i[31 : 0]  : cfg_msi_addr_prlim;
             cfg_pm_csr             <= (CfgAddr_i[3:0] == 4'hC) ? CfgCtl_i[31 : 0]  : cfg_pm_csr;
             cfg_msix_msi_csr       <= (CfgAddr_i[3:0] == 4'hD) ? CfgCtl_i[31 : 0]  : cfg_msix_msi_csr;
             cfg_ecrc_tcvc_map      <= (CfgAddr_i[3:0] == 4'hE) ? CfgCtl_i[31 : 0]  : cfg_ecrc_tcvc_map;
             cfg_msi_data_busdev    <= (CfgAddr_i[3:0] == 4'hF) ? CfgCtl_i[31 : 0]  : cfg_msi_data_busdev;
          end
     end          
 
/// Remap the table
    assign cfg_dev_ctrl_reg          = {16'h0, cfg_dev_ctrl[31:16]};
    assign cfg_dev_ctrl2_reg         = {16'h0, cfg_slot_ctrl[15:0]};
    assign cfg_link_ctrl_reg         = {16'h0, cfg_link_ctrl[31:16]};
    assign cfg_link_ctrl2_reg        = {16'h0, cfg_link_ctrl[15:0]};  
    assign cfg_prm_cmd_reg           = {16'h0, cfg_prm_root_ctrl[23:8]};
    assign cfg_root_ctrl_reg         = {24'h0, cfg_prm_root_ctrl[7:0]};
    assign cfg_sec_ctrl_reg          = {16'h0, cfg_sec_bus[31:16]};
    assign cfg_secbus_reg            = {16'h0, cfg_sec_ctrl_reg[23:8]};
    assign cfg_subbus_reg            = {24'h0, cfg_sec_ctrl_reg[7:0]};
    assign cfg_msi_addr_low_reg      = {cfg_msi_add_pr_base[31:12], cfg_msi_addr_iobase[31:20]}; 
    assign cfg_msi_addr_hi_reg       = {cfg_msi_addr_prlim[31:12] ,cfg_msi_addr_iolim[31:20]};
    assign cfg_io_bas_reg            = {12'h0, cfg_msi_addr_iobase[19:0]};
    assign cfg_io_lim_reg            = {12'h0, cfg_msi_addr_iolim[19:0]};
    assign cfg_np_bas_reg            =  {20'h0, cfg_np_base_lim[23:12]};
    assign cfg_np_lim_reg            =  {20'h0, cfg_np_base_lim[11:0]};  
    assign cfg_pr_bas_low_reg        =  cfg_pr_base;
    assign cfg_pr_bas_hi_reg         =  {20'h0, cfg_msi_add_pr_base[11:0]};
    assign cfg_pr_lim_low_reg        =  cfg_pr_lim;
    assign cfg_pr_lim_hi_reg         =  {20'h0, cfg_msi_addr_prlim[11:0]};
    assign cfg_pmcsr_reg             = cfg_pm_csr ;     
    assign cfg_msixcsr_reg           = {16'h0, cfg_msix_msi_csr[31:16]};
    assign cfg_msicsr_reg            = {16'h0, cfg_msix_msi_csr[15:0]};  
    assign cfg_tcvcmap_reg           = {8'h0, cfg_ecrc_tcvc_map[23:0]};
    assign cfg_msi_data_reg          = {16'h0, cfg_msi_data_busdev[31:16]};
    assign cfg_busdev_reg            = {19'h0, cfg_msi_data_busdev[12:0]};      
    assign ltssm_reg                 = {27'h0, Ltssm_i};
    assign current_speed_reg         = {30'h0, CurrentSpeed_i};
    assign lane_act_reg              = {28'h0, LaneAct_i}; 


always_comb                     
  begin               
    case(CraAddress_i[13:0])
       14'h0000 :  reg_mux_out =  cfg_dev_ctrl_reg     ;
       14'h0004 :  reg_mux_out =  cfg_dev_ctrl2_reg    ;
       14'h0008 :  reg_mux_out =  cfg_link_ctrl_reg    ;
       14'h000C :  reg_mux_out =  cfg_link_ctrl2_reg   ;
       14'h0010 :  reg_mux_out =  cfg_prm_cmd_reg      ;   
       14'h0014 :  reg_mux_out =  cfg_root_ctrl_reg    ;
       14'h0018 :  reg_mux_out =  cfg_sec_ctrl_reg     ;
       14'h001C :  reg_mux_out =  cfg_secbus_reg       ;
       14'h0020 :  reg_mux_out =  cfg_subbus_reg       ;
       14'h0024 :  reg_mux_out =  cfg_msi_addr_low_reg ;
       14'h0028 :  reg_mux_out =  cfg_msi_addr_hi_reg  ;
       14'h002C :  reg_mux_out =  cfg_io_bas_reg       ;
       14'h0030 :  reg_mux_out =  cfg_io_lim_reg       ;
       14'h0034 :  reg_mux_out =  cfg_np_bas_reg       ;
       14'h0038 :  reg_mux_out =  cfg_np_lim_reg       ;
       14'h003C :  reg_mux_out =  cfg_pr_bas_low_reg   ;
       14'h0040 :  reg_mux_out =  cfg_pr_bas_hi_reg    ;
       14'h0044 :  reg_mux_out =  cfg_pr_lim_low_reg   ;
       14'h0048 :  reg_mux_out =  cfg_pr_lim_hi_reg    ;
       14'h004C :  reg_mux_out =  cfg_pmcsr_reg        ;
       14'h0050 :  reg_mux_out =  cfg_msixcsr_reg      ;           
       14'h0054 :  reg_mux_out =  cfg_msicsr_reg       ;           
       14'h0058 :  reg_mux_out =  cfg_tcvcmap_reg      ;           
       14'h005C :  reg_mux_out =  cfg_msi_data_reg     ;           
       14'h0060 :  reg_mux_out =  cfg_busdev_reg       ;    
       14'h0064 :  reg_mux_out =  ltssm_reg            ;      
       14'h0068 :  reg_mux_out =  current_speed_reg    ;  
       14'h006C :  reg_mux_out =  lane_act_reg         ;
       default  :  reg_mux_out =   32'h0;
    endcase       
  end    	

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      read_data_reg <= 32'h0;
    else if( CraRead_i & CraChipSelect_i)
      read_data_reg <= reg_mux_out;
    else
      read_data_reg <= 32'h0;
  end   

assign CraReadData_o = read_data_reg;

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      register_access_sreg <= 1'b0;
    else if (register_ready_reg)
      register_access_sreg <= 1'b0;
     else if( (CraRead_i | CraWrite_i) & CraChipSelect_i)
      register_access_sreg <= 1'b1;
  end   

assign register_access = register_access_sreg;

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      register_access_reg <= 1'b0;
    else
      register_access_reg <= register_access;
  end   
  
assign register_access_rise = ~register_access_reg & register_access;

always_ff @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      register_ready_reg <= 1'b0;
    else
      register_ready_reg <= register_access_rise;
  end   

assign CraWaitRequest_o = ~register_ready_reg;


endmodule
  