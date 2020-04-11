`timescale 1ns / 1ps
`include "system.vh"

`define N_MASTERS 2

module mm2ss_interconnect
   (
    //masters interface
    input [`N_MASTERS*`ADDR_W-1:0] m_addr,
    input [`N_MASTERS-1:0]         m_valid,
    output reg [`N_MASTERS-1:0]    m_ready,
    input [`N_MASTERS*`DATA_W-1:0] m_wdata,
    
    //slave interface
    input [`ADDR_W-1:0]            s_addr,
    output reg                     s_valid,
    input                          s_ready,
    output reg [`DATA_W-1:0]       s_wdata
    );

   integer                          i;
   always @* begin
      s_valid = 1'b0;
      for (i=0; i<`N_SLAVES; i++)
        if(m_valid[i]) begin
           s_valid  = 1'b1;
           m_ready[i] = s_ready;
           s_wdata = m_wdata[i];
        end
   end
                     
endmodule
