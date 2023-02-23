`timescale 1 ns / 1 ps

`include "iob_soc_conf.vh"
`include "iob_lib.vh"
  
module int_mem
  #(
    parameter ADDR_W = 0,
    parameter DATA_W = 0,
    parameter HEXFILE = "firmware",
    parameter BOOT_HEXFILE = "boot",
    parameter SRAM_ADDR_W = 0,
    parameter BOOTROM_ADDR_W = 0,
    parameter B_BIT = 0
    )
   (

    output               boot,
    output               cpu_reset,
    
    //instruction bus
    input [`REQ_W-1:0]   i_req,
    output [`RESP_W-1:0] i_resp,

    //data bus
    input [`REQ_W-1:0]   d_req,
    output [`RESP_W-1:0] d_resp,
    `include "iob_clkenrst_port.vh"
    );

   //sram data bus  interface
   wire [`REQ_W-1:0]     ram_d_req;
   wire [`RESP_W-1:0]    ram_d_resp;

   //modified ram address during boot
   wire [SRAM_ADDR_W-3:0] ram_d_addr;


   ////////////////////////////////////////////////////////
   // BOOT HARDWARE
   //
   //boot controller bus to write program in sram
   wire [`REQ_W-1:0]     boot_ctr_req;
   wire [`RESP_W-1:0]    boot_ctr_resp;

   //
   // SPLIT DATA BUS BETWEEN SRAM AND BOOT CONTROLLER
   //
   iob_split #(
       .ADDR_W(ADDR_W),
       .DATA_W(DATA_W),
       .N_SLAVES(2),
       .P_SLAVES(B_BIT)
       )
   data_bootctr_split (
        .clk_i  (clk_i),
        .arst_i (arst_i),
        // master interface
        .m_req_i  (d_req),
        .m_resp_o (d_resp),

        // slaves interface
        .s_req_o  ({boot_ctr_req, ram_d_req}),
        .s_resp_i ({boot_ctr_resp, ram_d_resp})
        );


   //
   // BOOT CONTROLLER
   //

   //sram instruction write bus
   wire [`REQ_W-1:0]     ram_w_req;
   wire [`RESP_W-1:0]    ram_w_resp;

   boot_ctr #(
        .HEXFILE({BOOT_HEXFILE,".hex"}),
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W),
        .BOOTROM_ADDR_W(BOOTROM_ADDR_W),
        .SRAM_ADDR_W(SRAM_ADDR_W)
		)
	boot_ctr0 
       (
        .clk_i(clk_i),
        .arst_i(arst_i),
        .cke_i(cke_i),
        .cpu_rst(cpu_reset),
        .boot(boot),
        
        //cpu slave interface
        //no address bus since single address
        .cpu_avalid(boot_ctr_req[`AVALID(0)]),
        .cpu_wdata(boot_ctr_req[`WDATA(0)-(DATA_W-2)]),
        .cpu_wstrb(boot_ctr_req[`WSTRB(0)]),
        .cpu_rdata(boot_ctr_resp[`RDATA(0)]),
        .cpu_rvalid(boot_ctr_resp[`RVALID(0)]),
        .cpu_ready(boot_ctr_resp[`READY(0)]),

        //sram write master interface
        .sram_avalid(ram_w_req[`AVALID(0)]),
        .sram_addr(ram_w_req[`ADDRESS(0, ADDR_W)]),
        .sram_wdata(ram_w_req[`WDATA(0)]),
        .sram_wstrb(ram_w_req[`WSTRB(0)])
        );
   
   //
   //MODIFY INSTRUCTION READ ADDRESS DURING BOOT
   //

   //instruction read bus
   wire [`REQ_W-1:0]  ram_r_req;
   wire [`RESP_W-1:0] ram_r_resp;

   //
   //modify addresses to run  boot program
   //

   localparam boot_offset = -('b1 << BOOTROM_ADDR_W);
   //instruction bus: connect directly but address
   assign ram_r_req[`AVALID(0)] = i_req[`AVALID(0)];
   assign ram_r_req[`ADDRESS(0, ADDR_W)] = boot? i_req[`ADDRESS(0, ADDR_W)] + boot_offset : i_req[`ADDRESS(0, ADDR_W)];
   assign ram_r_req[`WRITE(0)] = i_req[`WRITE(0)];
   assign i_resp[`RESP(0)] = ram_r_resp[`RESP(0)];

   //data bus: just replace address
   assign ram_d_addr = boot? 
                       ram_d_req[`ADDRESS(0, SRAM_ADDR_W)-2] + boot_offset[SRAM_ADDR_W-1:2]: 
                       ram_d_req[`ADDRESS(0, SRAM_ADDR_W)-2];

   
   //
   //MERGE BOOT WRITE BUS AND CPU READ BUS
   //

   //sram instruction bus
   wire [`REQ_W-1:0]     ram_i_req;
   wire [`RESP_W-1:0]    ram_i_resp;
   
   iob_merge #(
           .N_MASTERS(2)
           )
   ibus_merge (
        .clk_i  (clk_i),
        .arst_i (arst_i),

        //master
        .m_req_i  ({ram_w_req, ram_r_req}),
        .m_resp_o ({ram_w_resp, ram_r_resp}),

        //slave  
        .s_req_o  (ram_i_req),
        .s_resp_i (ram_i_resp)
        );
   
   //
   // INSTANTIATE RAM
   //
   sram #(
`ifdef IOB_SOC_INIT_MEM
        .HEXFILE(HEXFILE),
`endif
        .DATA_W(DATA_W),
        .SRAM_ADDR_W(SRAM_ADDR_W)
        ) 
    int_sram (
      .clk_i    (clk_i),
      .cke_i    (cke_i),
      .arst_i    (arst_i),
      
      //instruction bus
      .i_avalid (ram_i_req[`AVALID(0)]),
      .i_addr   (ram_i_req[`ADDRESS(0, SRAM_ADDR_W)-2]), 
      .i_wdata  (ram_i_req[`WDATA(0)]),
      .i_wstrb  (ram_i_req[`WSTRB(0)]),
      .i_rdata  (ram_i_resp[`RDATA(0)]),
      .i_rvalid (ram_i_resp[`RVALID(0)]),
      .i_ready  (ram_i_resp[`READY(0)]),
	     
      //data bus
      .d_avalid (ram_d_req[`AVALID(0)]),
      .d_addr   (ram_d_addr),
      .d_wdata  (ram_d_req[`WDATA(0)]),
      .d_wstrb  (ram_d_req[`WSTRB(0)]),
      .d_rdata  (ram_d_resp[`RDATA(0)]),
      .d_rvalid (ram_d_resp[`RVALID(0)]),
      .d_ready  (ram_d_resp[`READY(0)])
      );

endmodule
