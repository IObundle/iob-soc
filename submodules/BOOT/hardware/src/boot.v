`timescale 1 ns / 1 ps
`include "iob_lib.vh"
`include "boot_swreg_def.vh"

module boot
  #(
`include "boot_params.vh"
 )
  (
`include "boot_io.vh"
   );

`include "boot_swreg_inst.vh"
   
   //cpu interface: rdata, rvalid and ready
   assign iob_rdata = {{(DATA_W-1){1'b0}},boot_o};
   iob_reg #(1,0) rvalid_reg (clk_i, arst_i, cke_i, iob_avalid & ~(|iob_wstrb), iob_rvalid);
   assign iob_ready = 1'b1;
       
   //boot control register: {cpu_reset, boot, preboot}
   wire                       bootctr_wr = iob_avalid & (iob_addr_i == `BOOT_CTR_ADDR) |iob_wstrb; 
   iob_reg_e #(2,1) bootnxt (clk_i, arst_i, cke_i, boot_wr, iob_wdata[1:0], CTR);



   //create CPU reset pulse
   wire                       cpu_rst_req;
   assign cpu_rst_req = iob_avalid & (|iob_wstrb) & iob_wdata[2];
   
   iob_pulse_gen #(
       .START(0),
       .DURATION(100)
       ) 
   reset_pulse
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .start_i(cpu_rst_req),
      .pulse_o(cpu_rst_o)
      );


   //
   //INSTANTIATE ROM
   //
   iob_rom_dp #(
       .DATA_W(DATA_W),
       .ADDR_W(BOOTROM_ADDR_W-2),
       .HEXFILE(HEXFILE)
       )
   sp_rom0 
     (
      .clk_i(clk_i),

      //instruction memory interface
      .r_en_a_i(ibus_avalid_i),
      .addr_a_i(ibus_addr_i),
      .r_data_a_o(ibus_rdata_o),

      //data memory interface
      .r_en_b_i(dbus_avalid_i),
      .addr_b_i(iob_addr_i),
      .w_data_b_i(iob_wdata_i)
      
      );

endmodule
