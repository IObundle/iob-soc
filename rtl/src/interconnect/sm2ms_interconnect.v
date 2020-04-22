`timescale 1ns / 1ps

module sm2ms_interconnect
  #(
    parameter N_SLAVES = 2,
    parameter ADDR_W = 32,
    parameter DATA_W = 32
    )
   (
    // master interface
    input [`DBUS_REQ_W-1:0]  m_bus_in,
    output [`BUS_RESP_W-1:0] m_bus_out,

    // slaves interface
    input [`BUS_RESP_W-1:0]  s_bus_in,
    output [`DBUS_REQ_W-1:0] s_bus_out
    );
 
   parameter N_SLAVES_W = $clog2(N_SLAVES);
   parameter P_ADDR_W = ADDR_W-$clog2(N_SLAVES);

   // Master bus
   wire                                         m_valid;
   reg                                          m_ready;
   wire [ADDR_W-1:0]                            m_addr;
   reg [DATA_W-1:0]                             m_rdata;
   wire [DATA_W-1:0]                            m_wdata;
   wire [DATA_W/8-1:0]                          m_wstrb;

   // Slave bus
   reg [N_SLAVES-1:0]                           s_valid;
   wire [N_SLAVES-1:0]                          s_ready;
   reg [N_SLAVES*(ADDR_W-$clog2(N_SLAVES))-1:0] s_addr;
   wire [N_SLAVES*DATA_W-1:0]                   s_rdata;
   reg [N_SLAVES*DATA_W-1:0]                    s_wdata;
   reg [N_SLAVES*(DATA_W/8)-1:0]                s_wstrb;

   reg [N_SLAVES_W-1:0]                         i;

   uncat m_bus (
                .d_req_bus_in (m_bus_in),
                .d_req_valid  (m_valid),
                .d_req_addr   (m_addr),
                .d_req_wdata  (m_wdata),
                .d_req_wstrb  (m_wstrb)
                );

   assign m_bus_out = {m_ready, m_rdata};

   uncat s_bus (
                .resp_bus_in  (s_bus_in),
                .resp_ready   (s_ready),
                .resp_data    (s_rdata)
                );

   assign s_bus_out = {s_valid, s_addr, s_wdata, s_wstrb};

   always @* begin      
      if(N_SLAVES == 1) begin
         s_valid = m_valid;           
         m_ready = s_ready;
         s_addr = m_addr;
         m_rdata = s_rdata;
         s_wdata = m_wdata;
         s_wstrb = m_wstrb;
      end else
        for (i=0; i<N_SLAVES; i=i+1)
          if(i == m_addr[ADDR_W-1 -: N_SLAVES_W]) begin
             s_valid[i] = m_valid;           
             m_ready = s_ready[i];
             s_addr[(i+1)*P_ADDR_W-1 -: P_ADDR_W] = m_addr[P_ADDR_W-1:0];
             m_rdata = s_rdata[(i+1)*DATA_W-1 -: DATA_W];
             s_wdata[(i+1)*DATA_W-1 -: DATA_W] = m_wdata;
             s_wstrb[(i+1)*(DATA_W/8)-1 -: DATA_W/8] = m_wstrb;
          end else begin
             s_valid[i] = 1'b0;
             m_ready = 1'b0;
             s_addr[(i+1)*P_ADDR_W-1 -: P_ADDR_W] = {P_ADDR_W-1{1'b0}};
             m_rdata = {DATA_W{1'b0}};
             s_wdata[(i+1)*DATA_W-1 -: DATA_W] = {N_SLAVES*DATA_W{1'b0}};
             s_wstrb[(i+1)*(DATA_W/8)-1 -: DATA_W/8] = {N_SLAVES*(DATA_W/8){1'b0}};
          end
   end // always @ *
   
endmodule
