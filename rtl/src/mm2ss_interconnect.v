`timescale 1ns / 1ps

module mm2ss_interconnect
  #(
    parameter N_MASTERS = 2,
    parameter ADDR_W = 32,
    parameter DATA_W = 32
    )
   (
    //master interface
    input [N_MASTERS*ADDR_W-1:0]      m_addr,
    input [N_MASTERS-1:0]             m_valid,
    output reg [N_MASTERS-1:0]        m_ready ,
    output reg [N_MASTERS*DATA_W-1:0] m_rdata,
    input [N_MASTERS*DATA_W-1:0]      m_wdata,
    input [N_MASTERS*(DATA_W/8)-1:0]  m_wstrb,
    
    //slave interface
    output reg                        s_valid,
    input                             s_ready,
    output reg [ADDR_W-1:0]           s_addr,
    output reg [DATA_W-1:0]           s_rdata,
    output reg [DATA_W-1:0]           s_wdata,
    output reg [DATA_W/8-1:0]         s_wstrb
    );

   integer                            i;
   always @* begin
      s_valid = 1'b0;
      m_ready[i] = 1'b0;
      s_addr = {N_MASTERS*ADDR_W{1'b0}};
      m_rdata = {N_MASTERS*DATA_W{1'b0}};
      s_wdata = {DATA_W{1'b0}};
      s_wstrb = {DATA_W/8{1'b0}};
      
      for (i=0; i<N_MASTERS; i=i+1)
        if(m_valid[i]) begin
           s_valid  = 1'b1;
           m_ready[i] = s_ready;
           s_addr = m_addr[(i+1)*ADDR_W -: ADDR_W];
           m_rdata[(i+1)*DATA_W -: DATA_W] = s_rdata;
           s_wdata = m_wdata[(i+1)*DATA_W -: DATA_W];
           s_wstrb = m_wstrb[(i+1)*(DATA_W/8) -: DATA_W/8];
        end
   end
                     
endmodule
