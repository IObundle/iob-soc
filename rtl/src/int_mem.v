`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"
  
module int_mem 
   (
    input                clk,
    input                rst,

`ifdef USE_BOOT
    output               boot,
    output               cpu_reset,
`endif
    
    //instruction bus
    input [`REQ_W-1:0]   i_req,
    output [`RESP_W-1:0] i_resp,

    //data bus
    input [`REQ_W-1:0]   d_req,
    output [`RESP_W-1:0] d_resp
    );

   //sram data bus  interface
   wire [`REQ_W-1:0]     ram_d_req;
   wire [`RESP_W-1:0]    ram_d_resp;

   //modified ram address during boot
   wire [`ADDR_W-1:0]    ram_d_addr;


   ////////////////////////////////////////////////////////
   // BOOT HARDWARE
   //
`ifdef USE_BOOT

   //boot controller bus to write program in sram
   wire [`REQ_W-1:0]     boot_ctr_req;
   wire [`RESP_W-1:0]    boot_ctr_resp;

   //
   // SPLIT DATA BUS BETWEEN SRAM AND BOOT CONTROLLER
   //
   split 
     #(
       .N_SLAVES(2)
       )
   ram_bootctr_demux
       (
        // master interface
        .m_req(d_req),
        .m_resp(d_resp),
        
        // slaves interface
`ifdef USE_SRAM_DDR //MSB is right shifted
        .s_sel(d_req[`section(0, `REQ_W-3, 2)]),
`else //using one memory only
        .s_sel(d_req[`section(0,  `REQ_W-2, 2)]),
`endif
        .s_req({boot_ctr_req, ram_d_req}),
        .s_resp({boot_ctr_resp, ram_d_resp})
        );


   //
   // BOOT CONTROLLER
   //

   //sram instruction write bus
   wire [`REQ_W-1:0]     ram_w_req;
   wire [`RESP_W-1:0]    ram_w_resp;

   boot_ctr boot_ctr0 
       (
        .clk(clk),
        .rst(rst),
        .cpu_rst(cpu_reset),
        .boot(boot),
        
        //cpu slave interface
        //no address bus since single address
        .cpu_valid(boot_ctr_req[`valid(0)]),
        .cpu_wdata(boot_ctr_req[`wdata(0)]),
        .cpu_wstrb(boot_ctr_req[`wstrb(0)]),
        .cpu_rdata(boot_ctr_resp[`rdata(0)]),
        .cpu_ready(boot_ctr_resp[`ready(0)]),

        //sram master write interface
        .sram_valid(ram_w_req[`valid(0)]),
        .sram_addr(ram_w_req[`address(0)]),
        .sram_wdata(ram_w_req[`wdata(0)]),
        .sram_wstrb(ram_w_req[`wstrb(0)])
        );
   
   //
   //MODIFY INSTRUCTION READ ADDRESS DURING BOOT
   //

   //instruction read bus
   wire [`REQ_W-1:0]  ram_r_req;
   wire [`RESP_W-1:0] ram_r_resp;

`define BOOT_OFFSET (2**`SRAM_ADDR_W-2**`BOOTROM_ADDR_W)

   //
   //modify addresses to run  boot program
   //

   //instruction bus: connect directly but address
   assign ram_r_req[`valid(0)] = i_req[`valid(0)];
   assign ram_r_req[`address(0)] = boot? i_req[`address(0)] + `BOOT_OFFSET : i_req[`address(0)];
   assign ram_r_req[`write(0)] = i_req[`write(0)];
   assign i_resp[`resp(0)] = ram_r_resp[`resp(0)];

   //debug addresses
   //wire [`ADDR_W-1:0]   addr_diff = ram_r_req[`address(0)] - i_req[`address(0)];

   //data bus: just replace address
   assign ram_d_addr = boot? 
                       ram_d_req[`section(0, `ADDR_P+`SRAM_ADDR_W-1, `SRAM_ADDR_W)] + `BOOT_OFFSET: 
                       ram_d_req[`section(0, `ADDR_P+`SRAM_ADDR_W-1, `SRAM_ADDR_W)];
`else // !`ifdef USE_BOOT: direct conection
   assign ram_d_req = d_req; 
   assign ram_d_addr = d_req[`section(0, `ADDR_P+`SRAM_ADDR_W-1, `SRAM_ADDR_W)];
   assign d_resp = ram_d_resp;
`endif // !`ifdef USE_BOOT

   
   //
   //MERGE BOOT WRITE BUS AND CPU READ BUS
   //

   //sram instruction bus
   wire [`REQ_W-1:0]     ram_i_req;
   wire [`RESP_W-1:0]    ram_i_resp;

   
   merge #(
`ifdef USE_BOOT
           .N_MASTERS(2)
`else
           .N_MASTERS(1)
`endif
           )
   ibus_merge
     (
      //master
`ifdef USE_BOOT
      .m_req({ram_w_req, ram_r_req}),
      .m_resp({ram_w_resp, ram_r_resp}),
`else
      .m_req(i_req),
      .m_resp(i_resp),
`endif
      //slave  
      .s_req(ram_i_req),
      .s_resp(ram_i_resp)
      );
   
   //
   // INSTANTIATE RAM
   //
   ram #(
`ifndef USE_BOOT
 `ifndef RUN_DDR
         .FILE("firmware")
 `endif
`endif
	 )
   boot_ram 
     (
      .clk           (clk),
      .rst           (rst),
      
      //instruction bus
      .i_valid       (ram_i_req[`valid(0)]),
      .i_addr        (ram_i_req[`section(0, `ADDR_P+`SRAM_ADDR_W-1, `SRAM_ADDR_W-2)]), 
      .i_wdata       (ram_i_req[`wdata(0)]),
      .i_wstrb       (ram_i_req[`wstrb(0)]),
      .i_rdata       (ram_i_resp[`rdata(0)]),
      .i_ready       (ram_i_resp[`ready(0)]),
	     
      //data bus
      .d_valid       (ram_d_req[`valid(0)]),
      .d_addr        (ram_d_addr[`SRAM_ADDR_W-1:2]),
      .d_wdata       (ram_d_req[`wdata(0)]),
      .d_wstrb       (ram_d_req[`wstrb(0)]),
      .d_rdata       (ram_d_resp[`rdata(0)]),
      .d_ready       (ram_d_resp[`ready(0)])
      );

endmodule
