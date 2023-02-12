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

    // This mapping is required because "iob_uart_swreg_inst.vh" uses "iob_s_portmap.vh" (This would not be needed if mkregs used "iob_s_s_portmap.vh" instead)
    wire [1-1:0] iob_avalid = iob_avalid_i; //Request valid.
    wire [ADDR_W-1:0] iob_addr = iob_addr_i; //Address.
    wire [DATA_W-1:0] iob_wdata = iob_wdata_i; //Write data.
    wire [(DATA_W/8)-1:0] iob_wstrb = iob_wstrb_i; //Write strobe.
    wire [1-1:0] iob_rvalid; assign iob_rvalid_o = iob_rvalid; //Read data valid.
    wire [DATA_W-1:0] iob_rdata; assign iob_rdata_o = iob_rdata; //Read data.
    wire [1-1:0] iob_ready; assign iob_ready_o = iob_ready; //Interface ready.
   
`include "boot_swreg_inst.vh"
   
   //cpu interface: rdata, rvalid and ready
   assign iob_rdata = {{(DATA_W-1){1'b0}},boot_o};
   iob_reg #(1,0) rvalid_reg (clk_i, arst_i, cke_i, iob_avalid & ~(|iob_wstrb), iob_rvalid);
   assign iob_ready = 1'b1;
       
   //boot control register: {boot, preboot}
   wire                       boot_wr = iob_avalid & |iob_wstrb; 
   reg                        boot_nxt;  
   iob_reg_re #(1,1) bootnxt (clk_i, arst_i, cke_i, 1'b0, boot_wr, iob_wdata[0], boot_nxt);
   iob_reg_r #(1,1) bootreg (clk_i, arst_i, cke_i, 1'b0, boot_nxt, boot_o);


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
