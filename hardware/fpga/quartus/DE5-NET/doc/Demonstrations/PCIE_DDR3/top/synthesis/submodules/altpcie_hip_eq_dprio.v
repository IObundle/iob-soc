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




// Module to access HIP DPRIO for CV and PTC
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on


module altpcie_hip_eq_dprio #(
   parameter MODE = "EP",
   parameter use_config_bypass_hwtcl = 0,
   parameter default_speed = 2'b11
)
(
   input   wire            pld_clk,
   input   wire            pld_reset_n,
   input   wire    [4:0]   ltssm_state,

   input [3 : 0]           tl_cfg_add,
   input [31 : 0]          tl_cfg_ctl,
   input [12:0]            cfglink2csrpld,

   input   wire            reconfig_clk,
   input   wire            reconfig_reset_n,

   output  wire            hip_reconfig_clk,
   output  wire            hip_reconfig_reset_n,
   output  reg             hip_reconfig_write,
   output  reg     [15:0]  hip_reconfig_writedata,
   output  wire    [1:0]   hip_reconfig_byteen,
   output  reg     [9:0]   hip_reconfig_address,
   output  reg             hip_reconfig_read,
   input   wire    [15:0]  hip_reconfig_readdata,
   output  reg             ser_shift_load,
   output  reg             interface_sel
);

//DPRIO INIT
localparam IDLE = 2'b00;
localparam SER  = 2'b01;
localparam SEL  = 2'b11;
localparam DONE = 2'b10;

//DPRIO R/W
localparam BYPASS_OFF = 3'b000;
localparam READ_PTC   = 3'b001;
localparam READ_CV    = 3'b010;
localparam WRITE_PTC  = 3'b11;
localparam WRITE_CV   = 3'b100;
localparam BYPASS_ON  = 3'b101;


//VEC SYNC
wire [4:0]      ltssm_sync;

//LTSSM
reg [4:0]       ltssm_sync_r;

//PHASE ENTRY/EXIT DETECT
wire            phase_entry;
wire            phase_exit;


reg [1:0]       init_state;
reg [2:0]       init_count;

reg [2:0]       state;
reg             k_g3_ltssm_eq_dbg;

//READ DATA VALID - 4 cycle latency from read
wire            readdata_valid;
reg [3:0]       read_reg;

// CV test related - Change TLS when in non L0 state
wire            tls_entry;
wire            tls_exit;
reg [1:0]       target_link_speed;
wire [1:0]      target_link_speed_sync;
reg [1:0]       program_tls;
wire [3:0]      tl_cfg_add_sync;
wire [31:0]     tl_cfg_ctl_sync;

//###############################################

//RECONFIG WIRE
assign hip_reconfig_byteen  = 2'b11;    //always enable both bytes
assign hip_reconfig_clk     = reconfig_clk;
assign hip_reconfig_reset_n = reconfig_reset_n;

altpcie_hip_vecsync2
#(
.DWIDTH         ( 5 )   // Sync Data input
)
vecsync_ltssm(
// Inputs
.wr_clk         ( pld_clk ),                    // write clock
.rd_clk         ( reconfig_clk ),               // read clock
.wr_rst_n       ( pld_reset_n ),                // async write reset
.rd_rst_n       ( reconfig_reset_n ),           // async read reset
.data_in        ( ltssm_state ),                // data in
// Outputs
.data_out       ( ltssm_sync )                  // data out
);


//LTSSM
always@( posedge reconfig_clk or negedge reconfig_reset_n )
begin
   if( ~reconfig_reset_n )
      ltssm_sync_r <= 0;
   else
      ltssm_sync_r <= ltssm_sync;
end



always @(posedge pld_clk or negedge pld_reset_n)
begin
  if (~pld_reset_n)
    target_link_speed <= 2'b00;
  else if ( use_config_bypass_hwtcl )
    target_link_speed <=  cfglink2csrpld[1:0];
  else if ((tl_cfg_add == 4'h2))
    target_link_speed <=  tl_cfg_ctl[1:0];
end

altpcie_hip_vecsync2
#(
.DWIDTH         ( 2 )                      // Sync Data input
)
vecsync_tls(
// Inputs
.wr_clk         ( pld_clk ),               // write clock
.rd_clk         ( reconfig_clk ),          // read clock
.wr_rst_n       ( pld_reset_n ),           // async write reset
.rd_rst_n       ( reconfig_reset_n ),      // async read reset
.data_in        ( target_link_speed ),     // data in
// Outputs
.data_out       ( target_link_speed_sync ) // data out
);


always@( posedge reconfig_clk or negedge reconfig_reset_n )
begin
   if( ~reconfig_reset_n )
      program_tls <= 2'b11;
   else
   begin
      if (ltssm_sync_r == 5'hf && ltssm_sync != 5'hf) // exit L0
         program_tls <= target_link_speed_sync;
      else if (ltssm_sync_r != 5'hf && ltssm_sync == 5'hf) // back to L0
         program_tls <= default_speed;
   end
end

//PHASE ENTRY/EXIT DETECT
generate
if( MODE == "EP" )                                      //detect ltssm == 1E    EP phase 3
begin
        assign phase_entry = ( ltssm_sync == 5'h1E && ltssm_sync_r != 5'h1E ) ? 1'b1 : 1'b0;
        assign phase_exit = ( ltssm_sync != 5'h1E && ltssm_sync_r == 5'h1E ) ? 1'b1 : 1'b0;
end

else                                                            //detect ltssm == 1D    RP phase 2
begin
        assign phase_entry = ( ltssm_sync == 5'h1D && ltssm_sync_r != 5'h1D ) ? 1'b1 : 1'b0;
        assign phase_exit = ( ltssm_sync != 5'h1D && ltssm_sync_r == 5'h1D ) ? 1'b1 : 1'b0;
end
endgenerate

assign tls_exit = ( ltssm_sync == 5'h0F && ltssm_sync_r != 5'h0F ) ? 1'b1 : 1'b0;
assign tls_entry = ( ltssm_sync != 5'h0F && ltssm_sync_r == 5'h0F ) ? 1'b1 : 1'b0;

//DPRIO INIT
always@( posedge reconfig_clk or negedge reconfig_reset_n )
begin
   if( ~reconfig_reset_n )
   begin
      init_state <= IDLE;
      init_count <= 0;
      ser_shift_load <= 1'b1;
      interface_sel <= 1'b1;
   end

   else
   begin
      init_count <= init_count + 1'b1;

      case( init_state )
         IDLE : begin
            if( &init_count )
            begin
               init_state <= SER;
               ser_shift_load <= 1'b0;
               interface_sel <= 1'b1;
            end
         end
         SER : begin
            if( &init_count )
            begin
               init_state <= SEL;
               ser_shift_load <= 1'b1;
               interface_sel <= 1'b1;
            end
         end
         SEL : begin
            if( &init_count )
            begin
               init_state <= DONE;
               ser_shift_load <= 1'b1;
               interface_sel <= 1'b0;
            end
         end
         DONE : begin
            init_state <= DONE;
            ser_shift_load <= 1'b1;
            interface_sel <= 1'b0;
         end
      endcase
   end
end


wire [9:0] hip_reconfig_address_ptc_sld;
wire [9:0] hip_reconfig_address_cv_sld;

lpm_constant #(
   .lpm_cvalue (10'h002),
   .lpm_hint   ("ENABLE_RUNTIME_MOD=YES, INSTANCE_NAME=PADR"),
   .lpm_type   ("LPM_CONSTANT"),
   .lpm_width  (10)
   ) dprio_ptc_addr( .result(hip_reconfig_address_cv_sld) );


lpm_constant #(
   .lpm_cvalue (10'h0B7),
   .lpm_hint   ("ENABLE_RUNTIME_MOD=YES, INSTANCE_NAME=CADR"),
   .lpm_type   ("LPM_CONSTANT"),
   .lpm_width  (10)
   ) dprio_cv_addr( .result(hip_reconfig_address_ptc_sld) );



//DPRIO R/W for PTC
always@( posedge reconfig_clk or negedge reconfig_reset_n )
begin
   if( ~reconfig_reset_n )
   begin
      state <= BYPASS_OFF;
      k_g3_ltssm_eq_dbg <= 0;
      hip_reconfig_write <= 0;
      hip_reconfig_writedata <= 0;
      hip_reconfig_address <= 10'h3FF;
      hip_reconfig_read <= 0;
   end

   else
   begin
      case( state )
         BYPASS_OFF     :       begin
            hip_reconfig_write <= 1'b0;
            hip_reconfig_address <= hip_reconfig_address_ptc_sld;       //10'h0B7;

            if( phase_entry )
            begin
               state <= READ_PTC;
               k_g3_ltssm_eq_dbg <= 1'b1;
            end
            else if (tls_entry | tls_exit)
            begin
               hip_reconfig_address <= hip_reconfig_address_cv_sld;     //10'h002;
               state <= READ_CV;
            end
      end
      READ_PTC  :       begin
         if( readdata_valid )
         begin
            hip_reconfig_read <= 0;
            hip_reconfig_writedata <= { hip_reconfig_readdata[15:8],
                                       k_g3_ltssm_eq_dbg,
                                       hip_reconfig_readdata[6:0] };

            state <= WRITE_PTC;
         end

         else
         begin
            hip_reconfig_read <= 1'b1;
            hip_reconfig_address <= hip_reconfig_address_ptc_sld;       //10'h0B7;
         end
      end

      READ_CV   :       begin
         if( readdata_valid )
         begin
            hip_reconfig_read <= 0;
            case (program_tls)
               2'b01: hip_reconfig_writedata <= { hip_reconfig_readdata[15:14], 1'b0,
                                                   hip_reconfig_readdata[12:3], 1'b0,
                                                   hip_reconfig_readdata[1:0]};
               2'b10: hip_reconfig_writedata <= { hip_reconfig_readdata[15:14], 1'b0,
                                                   hip_reconfig_readdata[12:3], 1'b1,
                                                   hip_reconfig_readdata[1:0]};
               2'b11: hip_reconfig_writedata <= { hip_reconfig_readdata[15:14], 1'b1,
                                                   hip_reconfig_readdata[12:3], 1'b0,
                                                   hip_reconfig_readdata[1:0]};
               2'b00: hip_reconfig_writedata <= { hip_reconfig_readdata[15:14], 1'b0,
                                                   hip_reconfig_readdata[12:3], 1'b0,
                                                   hip_reconfig_readdata[1:0]};
            endcase
            state <= WRITE_CV;
         end

         else
         begin
            hip_reconfig_read <= 1'b1;
            hip_reconfig_address <= hip_reconfig_address_cv_sld;        //10'h002;
         end
      end

      WRITE_PTC         :       begin
         hip_reconfig_write <= 1'b1;
         hip_reconfig_address <= hip_reconfig_address_ptc_sld;  //10'h0B7;

         if( k_g3_ltssm_eq_dbg )
            state <= BYPASS_ON;
         else
            state <= BYPASS_OFF;
      end

      WRITE_CV          :       begin
         hip_reconfig_write <= 1'b1;
         hip_reconfig_address <= hip_reconfig_address_cv_sld;   //10'h002;
         state <= BYPASS_OFF;
      end

      BYPASS_ON :       begin
         hip_reconfig_write <= 1'b0;
         hip_reconfig_address <= hip_reconfig_address_ptc_sld;  //10'h0B7;

         if( phase_exit )
         begin
            state <= READ_PTC;
            k_g3_ltssm_eq_dbg <= 1'b0;
         end
      end

      default: state <= BYPASS_OFF;

   endcase
   end
end


//READ DATA VALID - 4 cycle latency from read
assign readdata_valid = read_reg[3];

always@( posedge reconfig_clk or negedge reconfig_reset_n )
begin
        if( ~reconfig_reset_n )
        begin
                read_reg <= 0;
        end

        else
        begin
                read_reg <= {read_reg[2:0],hip_reconfig_read};
        end
end

endmodule

// End module for PTC CV
////////////////////////////////////////////////////////////////////////////
