`timescale 1 ns / 1 ps

`include "system.vh"

module uncat #(
               parameter IREQ_ADDR_W = `ADDR_W,
               parameter DREQ_ADDR_W = `ADDR_W
               )
   (
    // Instruction request bus
    input [`IBUS_REQ_W-1:0]  i_req_bus_in,
    output                   i_req_valid,
    output [IREQ_ADDR_W-1:0] i_req_addr,

    // Data request bus
    input [`DBUS_REQ_W-1:0]  d_req_bus_in,
    output                   d_req_valid,
    output [DREQ_ADDR_W-1:0] d_req_addr,
    output [`DATA_W-1:0]     d_req_wdata,
    output [`DATA_W/8-1:0]   d_req_wstrb,

    // Response bus
    input [`BUS_RESP_W-1:0]  resp_bus_in,
    output                   resp_ready,
    output [`DATA_W-1:0]     resp_data
    );

   assign i_req_valid = i_req_bus_in[`IBUS_REQ_W-1];
   assign i_req_addr  = i_req_bus_in[IREQ_ADDR_W-1 : 0];

   assign d_req_valid = d_req_bus_in[`DBUS_REQ_W-1];
   assign d_req_addr  = d_req_bus_in[`DBUS_REQ_W-(`ADDR_W-DREQ_ADDR_W)-2 -: DREQ_ADDR_W];
   assign d_req_wdata = d_req_bus_in[`DBUS_REQ_W-`ADDR_W-2 -: `DATA_W];
   assign d_req_wstrb = d_req_bus_in[`DATA_W/8-1:0];

   assign resp_ready = bus_resp_in[`BUS_RESP_W-1];
   assign resp_data  = bus_resp_in[`DATA_W-1:0];

endmodule
