`timescale 1 ns / 1 ps
`include "system.vh"
`include "int_mem.vh"

module int_mem
  (
   input                       clk,
   input                       rst,
`ifdef USE_BOOT
   input                       boot,
`endif
   
   //CPU INTERFACE

   //instruction bus
   input                       i_valid,
   output                      i_ready,
   input [`BOOTRAM_ADDR_W-3:0] i_addr,
   output [`DATA_W-1:0]        i_rdata,

   //data bus
   input                       d_valid,
   output                      d_ready,
   input [`BOOTRAM_ADDR_W-3:0] d_addr,
   output [`DATA_W-1:0]        d_rdata,
   input [`DATA_W-1:0]         d_wdata,
   input [3:0]                 d_wstrb,

   //PERIPHERAL INTERFACE
   input                       p_valid,
   output                      p_ready,
   input [`BOOTRAM_ADDR_W-3:0] p_addr,
   output [`DATA_W-1:0]        p_rdata,
   input [`DATA_W-1:0]         p_wdata,
   input [3:0]                 p_wstrb
   );
   
`ifdef USE_BOOT
   //
   // BOOT ROM

   //read from rom interface
   reg                         rom_valid;
   wire                        rom_ready;
   reg [`BOOTROM_ADDR_W-3:0]   rom_addr;
   wire [`DATA_W-1:0]          rom_rdata;

   //generate rom address   
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_valid <= 1'b1;
        rom_addr <= `BOOTROM_ADDR_W'0;
     end else
       if (rom_addr != (2**(`BOOTROM_ADDR_W-2)-1)) begin
          rom_addr <= rom_addr + 1'b1;
          rom_valid <= 1'b1;
       end else
         rom_valid <= 1'b0;

   //instantiate rom
   rom #(
	 .ADDR_W(`BOOTROM_ADDR_W-2)
	 )
   boot_rom (
	     .clk           (clk),
	     .rst           (rst),
             .valid         (rom_valid),
             .ready         (rom_ready),
	     .addr          (rom_addr),
	     .rdata         (rom_rdata)
	     );

   //write to ram interface
   wire r_valid = rom_valid;
   wire r_ready;
   wire [`BOOTRAM_ADDR_W-3:0] r_addr = rom_addr+{`BOOTRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}};
   wire [`DATA_W-1:0] r_rdata; //unused
   wire [`DATA_W-1:0] r_wdata;
   wire [`DATA_W/8-1:0] r_wstrb;

`endif

   //
   // RAM
   //
   
   //INSTRUCTION BUS

   
`ifdef USE_BOOT
   wire                 ram_i_ready;
   assign i_ready = ram_i_ready & ~rom_valid;
   wire [`BOOTRAM_ADDR_W-3:0] ram_i_addr = boot? i_addr+{`BOOTRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: i_addr;
`endif
 
   //DATA BUS 
   // has 3 masters: rom, peripheral interface, mem interface

   // need interconnect
   
   // master signals
`ifdef USE_BOOT
   //shift data address during boot program execution
   wire [`BOOTRAM_ADDR_W-3:0] mod_d_addr = boot? d_addr+{`BOOTRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: d_addr;
`endif


     
   //slave interface 
   wire                       ram_d_valid;
   wire                       ram_d_ready;
   wire [`BOOTRAM_ADDR_W-3:0] ram_d_addr;
   wire [`DATA_W-1:0]         ram_d_rdata;
   wire [`DATA_W-1:0]         ram_d_wdata;
   wire [3:0]                 ram_d_wstrb;

   //instantiate multiple master to single slave interconnect
   mm2ss_interconnect
     #(
`ifdef USE_BOOT
       .N_MASTERS(3),
`else
       .N_MASTERS(2),
`endif       
       .ADDR_W(`BOOTRAM_ADDR_W-2)
       )  
   ram_d_intercon
     (
      //masters
`ifdef USE_BOOT
      .m_valid({d_valid,    p_valid, r_valid}),
      .m_ready({d_ready,    p_ready, r_ready}),
      .m_addr ({mod_d_addr, p_addr,  r_addr}),
      .m_rdata({d_rdata,    p_rdata, r_rdata}),
      .m_wdata({d_wdata,    p_wdata, r_wdata}),
      .m_wstrb({d_wstrb,    p_wstrb, 4'b1111}),
`else
      .m_valid({d_valid,    p_valid}),
      .m_ready({d_ready,    p_ready}),
      .m_addr ({d_addr,     p_addr}),
      .m_rdata({d_rdata,    p_rdata}),
      .m_wdata({d_wdata,    p_wdata}),
      .m_wstrb({d_wstrb,    p_wstrb}),
`endif       

     //slave
      .s_valid(ram_d_valid),
      .s_ready(ram_d_ready),
      .s_addr (ram_d_addr),
      .s_rdata(ram_d_rdata),
      .s_wdata(ram_d_wdata),
      .s_wstrb(ram_d_wstrb)
      );   
 
   // instantiate ram
   ram #(
	 .ADDR_W(`BOOTRAM_ADDR_W-2),
`ifdef INIT_RAM
         .FILE("firmware")
`else
         .FILE("none")
`endif
	 )
   boot_ram 
     (
      .clk           (clk),
      .rst           (rst),
      
      //instruction bus
      .i_valid       (i_valid),
`ifndef USE_BOOT
      .i_ready       (i_ready),
      .i_addr        (i_addr),
`else 
      .i_ready       (ram_i_ready),
      .i_addr        (ram_i_addr),
`endif
      .i_rdata       (i_rdata),
	     
      //data bus
      .d_valid       (ram_d_valid),
      .d_ready       (ram_d_ready),
      .d_addr        (ram_d_addr),
      .d_wdata       (ram_d_wdata),
      .d_wstrb       (ram_d_wstrb),
      .d_rdata       (ram_d_rdata)
      );
   
endmodule
