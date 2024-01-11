`timescale 1ns / 1ps
`include "iob_timer_conf.vh"
`include "iob_timer_swreg_def.vh"

module iob_timer #(
   `include "iob_timer_params.vs"
) (
   `include "iob_timer_io.vs"
);

   `include "iob_wire.vs"

   assign iob_valid = iob_valid_i;
   assign iob_addr = iob_addr_i;
   assign iob_wdata = iob_wdata_i;
   assign iob_wstrb = iob_wstrb_i;
   assign iob_rvalid_o = iob_rvalid;
   assign iob_rdata_o = iob_rdata;
   assign iob_ready_o = iob_ready;

   //Dummy iob_ready_nxt_o and iob_rvalid_nxt_o to be used in swreg (unused ports)
   wire iob_ready_nxt;
   wire iob_rvalid_nxt;

   //BLOCK Register File & Configuration, control and status registers accessible by the sofware
   `include "iob_timer_swreg_inst.vs"

   //
   //BLOCK 64-bit time counter & Free-running 64-bit counter with enable and soft reset capabilities
   //
   wire [2*DATA_W-1:0] time_now;

   timer_core timer0 (
      .clk_i       (clk_i),
      .cke_i       (cke_i),
      .arst_i      (arst_i),
      .en_i        (ENABLE_wr),
      .rst_i       (RESET_wr),
      .rstrb_i     (SAMPLE_wr),
      .time_o      (time_now)
   );

   assign DATA_LOW_rd  = time_now[DATA_W-1:0];
   assign DATA_HIGH_rd = time_now[2*DATA_W-1:DATA_W];

endmodule
