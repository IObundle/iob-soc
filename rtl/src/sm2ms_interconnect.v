`timescale 1ns / 1ps
`include "system.vh"

module sm2ms_interconnect
   (
    //master interface
    input [`N_SLAVES_W-1:0]       m_addr,
    input                         m_valid,
    output [`DATA_W-1:0]          m_rdata,
    output                        m_ready,

    //slaves interface
    output reg [`N_SLAVES-1:0]    s_valid,
    input [`N_SLAVES*`DATA_W-1:0] s_rdata,
    input [`N_SLAVES-1:0]         s_ready
    );

   //valid bits
   always @* begin
      s_valid = `N_SLAVES'b0;          
      s_valid[m_addr] = m_valid;
   end

   //ready bit 
   assign m_ready = s_ready[m_addr];

   //response data
   assign m_rdata = s_rdata[(m_addr+1)*`DATA_W-1 -: `DATA_W];
                      
endmodule
