`timescale 1 ns / 1 ps
`include "system.vh"
  
 //TODO USE CAT INTERFACE UNPACK INSIDE

module int_mem
  (
   input                       clk,
   input                       rst,
   input                       boot,
   
   //CPU INTERFACE

   //instruction bus
   input                       i_valid,
   output                      i_ready,
   input [`MAINRAM_ADDR_W-3:0] i_addr,
   output [`DATA_W-1:0]        i_rdata,

   //data bus
   input                       d_bus_in = {d_valid, d_addr, d_wdata, d_wstrb};
   output                      d_bus_out = {d_ready, d_rdata};


   input                       d_valid,
   output                      d_ready,
   input [`MAINRAM_ADDR_W-3:0] d_addr,
   output [`DATA_W-1:0]        d_rdata,
   input [`DATA_W-1:0]         d_wdata,
   input [3:0]                 d_wstrb,

   //PERIPHERAL INTERFACE
   wire                        p_bus_in = {p_valid, p_addr, p_wdata, p_wstrb};
   wire                        p_bus_out = {p_ready, p_rdata};



   input                       p_valid,
   output                      p_ready,
   input [`MAINRAM_ADDR_W-3:0] p_addr,
   output [`DATA_W-1:0]        p_rdata,
   input [`DATA_W-1:0]         p_wdata,
   input [3:0]                 p_wstrb
   );


   //
   // BOOT ROM AND COPY ENGINE MASTER
   //
   
`ifdef USE_BOOT

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
   wire [`MAINRAM_ADDR_W-3:0] r_addr = rom_addr+{`MAINRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}};
   wire [`DATA_W-1:0] r_rdata; //unused
   wire [`DATA_W-1:0] r_wdata;
   wire [`DATA_W/8-1:0] r_wstrb;
`else // !`ifdef USE_BOOT
   wire                 rom_valid = 0;
`endif



   
   //
   // RAM
   //

   
   //
   //INSTRUCTION BUS
   //
   
   wire                 ram_i_ready;
   assign i_ready = ram_i_ready & ~rom_valid;
 
   // modify instruction address during boot program execution
   wire [`MAINRAM_ADDR_W-3:0] ram_i_addr = boot? i_addr+{`MAINRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: i_addr;


   //
   //DATA BUS 
   //
   
   // modify data address during boot program execution
   wire [`MAINRAM_ADDR_W-3:0] mod_d_addr = boot? d_addr+{`MAINRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: d_addr;
     
   //interconnect data mem, peripheral and rom master buses to 
   //internal memory data bus single slave

   wire                       ram_d_valid;
   wire                       ram_d_ready;
   wire [`MAINRAM_ADDR_W-3:0] ram_d_addr;
   wire [`DATA_W-1:0]         ram_d_rdata;
   wire [`DATA_W-1:0]         ram_d_wdata;
   wire [3:0]                 ram_d_wstrb;

   
   wire                       r_bus_in  = {r_valid, r_addr, r_wdata, 4'b1111};
   wire                       r_bus_out = {r_ready, r_rdata};

  
  
   wire                       s_bus_in     = {s_valid, s_addr, s_wdata, s_wstrb};
   wire                       s_bus_out = {s_ready, s_rdata};


   parameter BUS_IN_LEN = 1+ADDR_W+DATA_W+DATA_W/8;
   parameter BUS_OUT_LEN = 1+DATA_W;
   wire [2*BUS_IN_LEN-1:0]    cat_bus_in_2 = {d_bus_in, p_bus_in};
   wire [3*BUS_IN_LEN-1:0]    cat_bus_in_3 = {r_bus_in, cat_bus_in_2};
   
   
   mm2ss_interconnect
     #(
`ifdef USE_BOOT
       .N_MASTERS(3),
`else
       .N_MASTERS(2),
`endif       
       .ADDR_W(`MAINRAM_ADDR_W-2)
       )  
   ram_d_intercon
     (
//      .clk(clk),
//      .rst(rst),
      
      //masters
`ifdef USE_BOOT
      .m_valid({r_valid, d_valid,    p_valid }),
      .m_ready({r_ready, d_ready,    p_ready }),
      .m_addr ({r_addr,  mod_d_addr, p_addr  }),
      .m_rdata({r_rdata, d_rdata,    p_rdata }),
      .m_wdata({r_wdata, d_wdata,    p_wdata }),
      .m_wstrb({4'b1111, d_wstrb,    p_wstrb }),
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
`ifndef USE_DDR
 `ifndef USE_BOOT
         .FILE("firmware"),
 `endif
`endif
	 .ADDR_W(`MAINRAM_ADDR_W-2)
	 )
   boot_ram 
     (
      .clk           (clk),
      .rst           (rst),
      
      //instruction bus
      .i_valid       (i_valid),
      .i_ready       (ram_i_ready), //to be masked by rom loading
      .i_addr        (ram_i_addr), //modified during boot
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
