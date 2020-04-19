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

   //instruction interface
   input                       i_valid,
   output                      i_ready,
   input [`BOOTRAM_ADDR_W-3:0] i_addr,
   output [`DATA_W-1:0]        i_rdata,

   //data interface
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
              
   //read boot rom 
   wire                         rom_ready;
   reg [`BOOTROM_ADDR_W-3:0]    rom_addr;
   wire [`DATA_W-1:0]           rom_rdata;

`ifdef USE_BOOT
   reg                          rom_valid;
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_addr <= `BOOTROM_ADDR_W'0;
        rom_valid <= 1'b1;
     end else if (boot)
       if (rom_addr != (2**(`BOOTROM_ADDR_W-2)-1)) begin
          rom_addr <= rom_addr + 1'b1;
          rom_valid <= 1'b1;
       end else
         rom_valid <= 1'b0;
   
   rom #(
	 .ADDR_W(`BOOTROM_ADDR_W-2)
	 )
   boot_rom (
	     .clk           (clk),
	     .rst           (rst),
             .valid         (rom_valid),
             .valid         (rom_ready),
	     .addr          (rom_addr),
	     .rdata         (rom_rdata)
	     );
`endif


   //RAM INTERFACE SIGNALS

   //instruction bus
`ifdef USE_BOOT
   wire ram_i_valid = i_valid & ~rom_ready;
`else
   wire ram_i_valid = i_valid;
`endif
   wire ram_i_ready;
   wire [`BOOTRAM_ADDR_W-3:0] ram_i_addr = i_addr+{`BOOTRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}};
   wire [`DATA_W-1:0]         ram_i_rdata;

   //reponse
`ifdef USE_BOOT
   assign i_ready = ram_i_ready & ~rom_ready;
`else
   assign i_ready = ram_i_ready;
`endif
   assign i_rdata = ram_i_rdata;
   
   

   //data bus has 3 masters: rom, peripheral interface, mem interface
   //need interconnect
   
   //interconnect master signals
   wire [2:0]                 m_ready;
   wire [3*`DATA_W-1:0]       m_rdata;
   wire [`BOOTRAM_ADDR_W-3:0]  m_ram_addr = boot? d_addr+{`BOOTRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: d_addr;
   wire [`BOOTRAM_ADDR_W-3:0]  m_rom_addr = rom_addr+{`BOOTRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}};
     
   //interconnect slave signals
   wire ram_d_valid;
   wire ram_d_ready;
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
       .N_MASTERS(3),
`endif       
       .ADDR_W(`BOOTRAM_ADDR_W-2)
       )  ram_d_intercon
   (
`ifdef USE_BOOT
    .m_valid({d_valid, p_valid, rom_valid}),
    .m_ready(m_ready),
    .m_addr({d_addr, p_addr, m_rom_addr}),
    .m_rdata(m_rdata),
    .m_wdata({d_wdata, p_wdata, rom_rdata}),
    .m_wstrb({d_wstrb, p_wstrb, 4'b1111}),
`else
    .m_valid({d_valid, p_valid}),
    .m_ready(m_ready),
    .m_addr({m_ram_addr, p_addr}),
    .m_rdata(m_rdata),
    .m_wdata({d_wdata, p_wdata}),
    .m_wstrb({d_wstrb, p_wstrb}),
`endif       

    .s_valid(ram_d_valid),
    .s_ready(ram_d_ready),
    .s_addr(ram_d_addr),
    .s_rdata(ram_d_rdata),
    .s_wdata(ram_d_wdata),
    .s_wstrb(ram_d_wstrb)
    );   
 
   //data bus response
   assign d_ready = m_ready[2];
   assign d_rdata = m_rdata[3*`DATA_W-1 -: `DATA_W];
   
   //
   // INSTANTIATE RAM
   //

   ram #(
	 .ADDR_W(`BOOTRAM_ADDR_W-2),
`ifdef USE_BOOT
         .FILE("none")
`else
         .FILE("firmware")
`endif
	 )
   boot_ram (
	     .clk           (clk),
             .rst           (rst),

             //instruction bus
	     .i_valid       (ram_i_valid),
	     .i_ready       (ram_i_ready),
	     .i_addr        (ram_i_addr),
	     .i_rdata       (ram_i_rdata),
	     
             //data bus
             .d_valid       (ram_d_valid),
             .d_ready       (ram_d_ready),
	     .d_addr        (ram_d_addr),
	     .d_wdata       (ram_d_wdata),
	     .d_wstrb       (ram_d_wstrb),
	     .d_rdata       (ram_d_rdata)
	     );

endmodule
