`timescale 1 ns / 1 ps


`include "bsp.vh"
`include "iob_soc_conf.vh"
`include "iob_soc.vh"
`include "iob_utils.vh"



//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc_wrapper #(
   `include "iob_soc_params.vs"
) (
   parameter HEXFILE = "iob_soc_firmware",
   parameter BOOT_HEXFILE  = "iob_soc_boot",
   `include "iob_soc_io.vs"
);


iob_soc#(
   .BOOTROM_ADDR_W(           BOOTROM_ADDR_W),
   .SRAM_ADDR_W(                 SRAM_ADDR_W),
   .MEM_ADDR_W(                   MEM_ADDR_W),
   .ADDR_W(                           ADDR_W),
   .DATA_W(                           DATA_W),
   .AXI_ID_W(                       AXI_ID_W),
   .AXI_ADDR_W(                   AXI_ADDR_W),
   .AXI_DATA_W(                   AXI_DATA_W),
   .AXI_LEN_W(                     AXI_LEN_W),
   .MEM_ADDR_OFFSET(         MEM_ADDR_OFFSET),
   .UART0_DATA_W(               UART0_DATA_W),
   .UART0_ADDR_W(               UART0_ADDR_W),
   .UART0_UART_DATA_W(     UART0_UART_DATA_W),
   .TIMER0_DATA_W(             TIMER0_DATA_W),
   .TIMER0_ADDR_W(             TIMER0_ADDR_W),
   .TIMER0_WDATA_W(           TIMER0_WDATA_W)
) iob_soc(
   `ifdef USE_SPRAM
      output                            en_i,
      output             [DATA_W/8-1:0] we_i,
      output             [  ADDR_W-1:0] addr_i,
      output             [  DATA_W-1:0] d_i,
      input              [  DATA_W-1:0] d_o,
   `endif
   // Port A
   output                               enA_i,
   output                [DATA_W/8-1:0] weA_i,
   output                [  ADDR_W-1:0] addrA_i,
   output                [  DATA_W-1:0] dA_i,
   input                 [  DATA_W-1:0] dA_o,
   // Port B
   output                               enB_i,
   output                [DATA_W/8-1:0] weB_i,
   output                [  ADDR_W-1:0] addrB_i,
   output                [  DATA_W-1:0] dB_i,
   input                 [DATA_W-1 : 0] dB_o,

   //rom
   .rom_r_valid(rom_r_valid),
   .rom_r_addr(rom_r_addr),
   .rom_r_rdata(rom_r_rdata),
   `include "iob_soc_io.vs"
);

//rom wires
wire                         rom_r_valid;
wire  [BOOTROM_ADDR_W-3:0]   rom_r_addr;
wire [DATA_W-1:0]            rom_r_rdata;
//




//ram generation
`ifdef USE_SPRAM
   localparam COL_W = 8;
   localparam NUM_COL = DATA_W / COL_W;
   wire [DATA_W-1:0] d_o;
   `ifdef IOB_MEM_NO_READ_ON_WRITE
      localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};
       genvar i;
      generate
         for (i = 0; i < NUM_COL; i = i + 1) begin : ram_col
            localparam mem_init_file_int = (HEXFILE != "none") ?
               {HEXFILE, "_", file_suffix[8*(i+1)-1-:8], ".hex"} : "none";

            iob_ram_sp #(
               .HEXFILE(mem_init_file_int),
               .ADDR_W (ADDR_W),
               .DATA_W (COL_W)
            ) ram (
               .clk_i(clk_i),

               .en_i  (en_i),
               .addr_i(addr_i),
               .d_i   (d_i[i*COL_W+:COL_W]),
               .we_i  (we_i[i]),
               .d_o   (d_o[i*COL_W+:COL_W])
            );
         end
      endgenerate
   `else  // !IOB_MEM_NO_READ_ON_WRITE
      // this allows ISE 14.7 to work; do not remove
      localparam mem_init_file_int = {HEXFILE, ".hex"};
      // Core Memory
      reg [DATA_W-1:0] ram_block[(2**ADDR_W)-1:0];
      // Initialize the RAM
      initial
         if (mem_init_file_int != "none.hex")
            $readmemh(mem_init_file_int, ram_block, 0, 2 ** ADDR_W - 1);
      reg     [DATA_W-1:0] d_o_int;
      integer              i;
      always @(posedge clk_i) begin
         if (en_i) begin
            for (i = 0; i < NUM_COL; i = i + 1) begin
               if (we_i[i]) begin
                  ram_block[addr_i][i*COL_W+:COL_W] <= d_i[i*COL_W+:COL_W];
               end
            end
            d_o_int <= ram_block[addr_i];  // Send Feedback
         end
      end
      assign d_o = d_o_int;
   `endif
   `else  // !`ifdef USE_SPRAM

   `ifdef IOB_MEM_NO_READ_ON_WRITE
      localparam COL_W = DATA_W / 4;
      localparam NUM_COL = DATA_W / COL_W;
      localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};
      genvar index;
      generate
         for (index = 0; index < NUM_COL; index = index + 1) begin : ram_col
            localparam mem_init_file_int = (HEXFILE != "none") ?
               {HEXFILE, "_", file_suffix[8*(index+1)-1-:8], ".hex"} : "none";
            iob_ram_dp #(
               .HEXFILE             (mem_init_file_int),
               .ADDR_W              (ADDR_W),
               .DATA_W              (COL_W),
               .MEM_NO_READ_ON_WRITE(MEM_NO_READ_ON_WRITE)
            ) ram (
               .clk_i(clk_i),

               .enA_i  (enA_i),
               .addrA_i(addrA_i),
               .dA_i   (dA_i[index*COL_W+:COL_W]),
               .weA_i  (weA_i[index]),
               .dA_o   (dA_o[index*COL_W+:COL_W]),

               .enB_i  (enB_i),
               .addrB_i(addrB_i),
               .dB_i   (dB_i[index*COL_W+:COL_W]),
               .weB_i  (weB_i[index]),
               .dB_o   (dB_o[index*COL_W+:COL_W])
            );
         end
      endgenerate
   `else
      iob_ram_dp_be_xil #(
      .HEXFILE(HEXFILE),
      .ADDR_W (SRAM_ADDR_W - 2),
      .DATA_W (DATA_W)
      ) main_mem_byte (
         .clk_i(clk_i),

         // data port
         .enA_i  (enA_i),
         .addrA_i(addrA_i),
         .weA_i  (weA_i),
         .dA_i   (dA_i),
         .dA_o   (dA_o),

         // instruction port
         .enB_i  (enB_i),
         .addrB_i(addrB_i),
         .weB_i  (weB_i),
         .dB_i   (dB_i),
         .dB_o   (dB_o)
      );
   `endif
   

//rom generation

iob_rom_sp #(
   .DATA_W (DATA_W),
   .ADDR_W (BOOTROM_ADDR_W - 2),
   .HEXFILE(BOOT_HEXFILE)
) sp_rom0 (
   .clk_i   (clk_i),
   .r_en_i  (rom_r_valid),
   .addr_i  (rom_r_addr),
   .r_data_o(rom_r_rdata)
);

endmodule