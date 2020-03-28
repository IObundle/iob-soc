`timescale 1ns / 1ps
`include "system.vh"

module iob_generic_interconnect
   (
    //master interface
    input [`N_SLAVES_W-1:0]       m_addr,
    input                        m_valid,
    output [`DATA_W-1:0]         m_rdata,
    output                       m_ready,

                                 //slaves interface
    output reg [`N_SLAVES-1:0]    s_valid,
    input [`N_SLAVES*`DATA_W-1:0] s_rdata,
    input [`N_SLAVES-1:0]         s_ready
    );

   reg [`N_SLAVES_W-1:0]          i;
      
   always @* begin : compute_slaves_valid
      for(i=0; i<`N_SLAVES_W'd`N_SLAVES; i=i+1'b1)
         s_valid[i] = (i == m_addr) & m_valid;
   end
                   
   assign    m_rdata = s_rdata[(m_addr+1)*`DATA_W-1 -: `DATA_W];
   assign    m_ready = (m_addr < `N_SLAVES_W'd`N_SLAVES)? s_ready[m_addr]: `N_SLAVES'd0;
   
                      
endmodule
