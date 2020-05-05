`timescale 1ns / 1ps

`include "interconnect.vh"

module split
  #(
    parameter TYPE = `D,
    parameter N_SLAVES = 2,
    parameter ADDR_W = 32,
    parameter E_ADDR_W = 1
    )
   (
    //extra split bits 
    input                                              m_e_addr[E_ADDR_W-1:0];
    //masters interface
    input [`BUS_REQ_W(TYPE, ADDR_W)-1:0]               m_req,
    output reg [`BUS_RESP_W(ADDR_W)-1:0]               m_resp

    //slave interface
    output reg [N_SLAVES*`BUS_REQ_W(TYPE, ADDR_W)-1:0] s_req,
    input [N_SLAVES*`BUS_RESP_W(ADDR_W)-1:0]           s_resp
    );
   
   //insert extra address bits
   wire [`BUS_REQ_W(TYPE, ADDR_W)-1:0]                 m_req,
   
   integer                                             i;

   //build split bits;
   wire [E_ADDR_W+$clog2(N_SLAVES)-1:0]                split_bits = (! E_ADDR_W)?
                                                       m_req[`BUS_W(TYPE, ADDR_W)-2 -: $clog2(N_SLAVES)]:
                                                       {m_e_addr, m_req[`BUS_W(TYPE, ADDR_W)-2 -: $clog2(N_SLAVES)]};
   //do the split
   always @* begin
      //default outputs
      m_resp = {`BUS_RESP_W{1'b0}};
      s_req = {`BUS_REQ_W(TYPE,ADDR_W){1'b0}};

      //demux output
      for (i=0; i<(N_SLAVES*(2**E_ADDR_W)); i=i+1)
        if(i == split_bits) begin
           m_resp = `get_req(s_resp, i);
           m_req = `get_req(TYPE, s_resp, N_SLAVES, i);
        end
   end
   
endmodule
