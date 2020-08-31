`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"
  
module int_mem
  #(
    parameter ADDR_W=32,
    parameter DATA_W=32
    )
   (
    input                clk,
    input                rst,

    output               boot,
    output               cpu_reset,
    
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
   wire [`SRAM_ADDR_W-3:0] ram_d_addr;


   ////////////////////////////////////////////////////////
   // BOOT HARDWARE
   //

   //boot controller bus to write program in sram
   wire [`REQ_W-1:0]     boot_ctr_req;
   wire [`RESP_W-1:0]    boot_ctr_resp;

   //
   // SPLIT DATA BUS BETWEEN SRAM AND BOOT CONTROLLER
   //
   split 
     #(
       .N_SLAVES(2),
       .P_SLAVES(`B_BIT)
       )
   data_bootctr_split
       (
        .clk    ( clk                         ),
        .rst    ( rst                         ),
        // master interface
        .m_req  ( d_req                       ),
        .m_resp ( d_resp                      ),
        
        // slaves interface
        .s_req  ( {boot_ctr_req, ram_d_req}   ),
        .s_resp ( {boot_ctr_resp, ram_d_resp} )
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
        .cpu_wdata(boot_ctr_req[`wdata(0)-(`DATA_W-2)]),
        .cpu_wstrb(boot_ctr_req[`wstrb(0)]),
        .cpu_rdata(boot_ctr_resp[`rdata(0)]),
        .cpu_ready(boot_ctr_resp[`ready(0)]),

        //sram write master interface
        .sram_valid(ram_w_req[`valid(0)]),
        .sram_addr(ram_w_req[`address(0, `ADDR_W)]),
        .sram_wdata(ram_w_req[`wdata(0)]),
        .sram_wstrb(ram_w_req[`wstrb(0)])
        );
   
   //
   //MODIFY INSTRUCTION READ ADDRESS DURING BOOT
   //

   //instruction read bus
   wire [`REQ_W-1:0]  ram_r_req;
   wire [`RESP_W-1:0] ram_r_resp;

   wire [`SRAM_ADDR_W-1:0] boot_offset = -(`SRAM_ADDR_W'b1 << `BOOTROM_ADDR_W);
   
//`define BOOT_OFFSET ((1'b1<<`SRAM_ADDR_W)-(1'b1<<`BOOTROM_ADDR_W))
//`define BOOT_OFFSET ((2**`SRAM_ADDR_W)-(2**`BOOTROM_ADDR_W))

   //
   //modify addresses to run  boot program
   //

   //instruction bus: connect directly but address
   assign ram_r_req[`valid(0)] = i_req[`valid(0)];
   assign ram_r_req[`address(0, `ADDR_W)] = boot? i_req[`address(0, `ADDR_W)] + boot_offset : i_req[`address(0, `ADDR_W)];
   assign ram_r_req[`write(0)] = i_req[`write(0)];
   assign i_resp[`resp(0)] = ram_r_resp[`resp(0)];

   //data bus: just replace address
   assign ram_d_addr = boot? 
                       ram_d_req[`address(0, `SRAM_ADDR_W)-2] + boot_offset[`SRAM_ADDR_W-1:2]: 
                       ram_d_req[`address(0, `SRAM_ADDR_W)-2];

   
   //
   //MERGE BOOT WRITE BUS AND CPU READ BUS
   //

   //sram instruction bus
   wire [`REQ_W-1:0]     ram_i_req;
   wire [`RESP_W-1:0]    ram_i_resp;
   
   merge #(
           .N_MASTERS(2)
           )
   ibus_merge
     (
      .clk    ( clk                      ),
      .rst    ( rst                      ),

      //master
      .m_req  ( {ram_w_req, ram_r_req}   ),
      .m_resp ( {ram_w_resp, ram_r_resp} ),

      //slave  
      .s_req  ( ram_i_req                ),
      .s_resp ( ram_i_resp               )
      );
   
   //
   // INSTANTIATE RAM
   //
   sram
`ifdef SRAM_INIT
        #(.FILE("firmware"))
`endif
   int_sram 
     (
      .clk           (clk),
      .rst           (rst),
      
      //instruction bus
      .i_valid       (ram_i_req[`valid(0)]),
      .i_addr        (ram_i_req[`address(0, `SRAM_ADDR_W)-2]), 
      .i_wdata       (ram_i_req[`wdata(0)]),
      .i_wstrb       (ram_i_req[`wstrb(0)]),
      .i_rdata       (ram_i_resp[`rdata(0)]),
      .i_ready       (ram_i_resp[`ready(0)]),
	     
      //data bus
      .d_valid       (ram_d_req[`valid(0)]),
      .d_addr        (ram_d_addr),
      .d_wdata       (ram_d_req[`wdata(0)]),
      .d_wstrb       (ram_d_req[`wstrb(0)]),
      .d_rdata       (ram_d_resp[`rdata(0)]),
      .d_ready       (ram_d_resp[`ready(0)])
      );

endmodule
