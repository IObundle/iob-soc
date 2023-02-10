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
   
   //cpu interface: rdata and ready
   assign iob_rdata = {{(DATA_W-1){1'b0}},boot_o};
   iob_reg #(1,0) rvalid_reg (clk_i, arst_i, cke_i, iob_avalid & ~(|iob_wstrb), iob_rvalid);
   assign iob_ready = 1'b1;
       
   //boot register: (1) load bootloader to memory and run it: (0) run the program in memory
   wire                       boot_wr = iob_avalid & |iob_wstrb; 
   reg                        boot_nxt;  
   iob_reg_re #(1,1) bootnxt (clk_i, arst_i, cke_i, 1'b0, boot_wr, iob_wdata[0], boot_nxt);
   iob_reg_r #(1,1) bootreg (clk_i, arst_i, cke_i, 1'b0, boot_nxt, boot_o);


   //create CPU reset pulse
   wire                       cpu_rst_req;
   assign cpu_rst_req = iob_avalid & (|iob_wstrb) & iob_wdata[1];
   wire                       cpu_rst_pulse;
   
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
      .pulse_o(cpu_rst_pulse)
      );

   wire                       loading;                   
   assign cpu_rst_o = loading | cpu_rst_pulse;
   
   //
   // READ BOOT ROM 
   //
   reg                       rom_r_avalid;
   reg [BOOTROM_ADDR_W-3: 0] rom_r_addr;
   wire [DATA_W-1: 0]        rom_r_rdata;

   always @(posedge clk_i, posedge arst_i)
     if(arst_i) begin
        rom_r_avalid <= 1'b1;
        rom_r_addr <= {(BOOTROM_ADDR_W-2){1'b0}};
     end else if (boot_o && rom_r_addr != (2**(BOOTROM_ADDR_W-2)-1))
       rom_r_addr <= rom_r_addr + 1'b1;
     else begin
        rom_r_avalid <= 1'b0;
        rom_r_addr <= {(BOOTROM_ADDR_W-2){1'b0}};
     end
   
   //
   // WRITE SRAM
   //
   reg sram_w_avalid;
   reg [DATA_W/8-1:0] sram_w_strb;
   reg [SRAM_ADDR_W-2-1:0] sram_w_addr;
   always @(posedge clk_i, posedge arst_i)
     if(arst_i) begin
        sram_w_avalid <= 1'b0;
        sram_w_addr <= -{1'b1,{(BOOTROM_ADDR_W-2){1'b0}}};
        sram_w_strb <= {DATA_W/8{1'b1}};
     end else if (boot_o) begin
        sram_w_avalid <= rom_r_avalid;
        sram_w_addr <= -{1'b1,{(BOOTROM_ADDR_W-2){1'b0}}} + rom_r_addr;
        sram_w_strb <= {DATA_W/8{rom_r_avalid}};
     end else begin
        sram_w_avalid <= 1'b0;
        sram_w_addr <= -{1'b1,{(BOOTROM_ADDR_W-2){1'b0}}};
        sram_w_strb <= {DATA_W/8{1'b1}};        
     end
   
   assign loading = rom_r_avalid | sram_w_avalid_o;

   assign sram_w_avalid_o = sram_w_avalid_o;
   assign sram_w_addr_o = {sram_w_addr_o, 2'b00};
   assign sram_w_data_o = rom_r_rdata;
   assign sram_w_strb_o = sram_w_strb;

   //
   //INSTANTIATE ROM
   //
   iob_rom_sp #(
       .DATA_W(DATA_W),
       .ADDR_W(BOOTROM_ADDR_W-2),
       .HEXFILE(HEXFILE)
       )
   sp_rom0 
     (
      .clk_i(clk_i),
      .r_en_i(rom_r_avalid),
      .addr_i(rom_r_addr),
      .r_data_o(rom_r_rdata)
      );

endmodule
