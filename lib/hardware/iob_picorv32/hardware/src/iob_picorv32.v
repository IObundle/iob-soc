// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1 ns / 1 ps
`include "iob_picorv32_conf.vh"

module iob_picorv32 #(
    `include "iob_picorv32_params.vs"
) (
    `include "iob_picorv32_io.vs"
);

  //picorv32 native interface wires
  wire                cpu_instr;
  wire                cpu_valid;
  wire [  ADDR_W-1:0] cpu_addr;
  wire [DATA_W/8-1:0] cpu_wstrb;
  wire [  DATA_W-1:0] cpu_wdata;
  wire [  DATA_W-1:0] cpu_rdata;
  wire                cpu_ready;

  //split cpu bus into ibus and dbus
  wire                iob_i_valid;
  wire                iob_d_valid;

  //iob interface wires
  wire                iob_i_rvalid;
  wire                iob_d_rvalid;
  wire                iob_d_ready;

  //compute the instruction bus request
  assign ibus_iob_valid_o = iob_i_valid;
  assign ibus_iob_addr_o = cpu_addr;
  assign ibus_iob_wdata_o = {DATA_W{1'b0}};
  assign ibus_iob_wstrb_o = {(DATA_W/8){1'b0}};

  //compute the data bus request
  assign dbus_iob_valid_o = iob_d_valid;
  assign dbus_iob_addr_o = cpu_addr;
  assign dbus_iob_wdata_o = cpu_wdata;
  assign dbus_iob_wstrb_o = cpu_wstrb;

  //split cpu bus into instruction and data buses
  assign iob_i_valid  = cpu_instr & cpu_valid;

  assign iob_d_valid  = (~cpu_instr) & cpu_valid & (~iob_d_rvalid);

  //extract iob interface wires from concatenated buses
  assign iob_d_rvalid = dbus_iob_rvalid_i;
  assign iob_i_rvalid = ibus_iob_rvalid_i;
  assign iob_d_ready  = dbus_iob_ready_i;

  //cpu rdata and ready
  assign cpu_rdata    = cpu_instr ? ibus_iob_rdata_i : dbus_iob_rdata_i;
  assign cpu_ready    = cpu_instr ? iob_i_rvalid : |cpu_wstrb? iob_d_ready : iob_d_rvalid;

  //intantiate the PicoRV32 CPU
  picorv32 #(
      .COMPRESSED_ISA (USE_COMPRESSED),
      .ENABLE_FAST_MUL(USE_MUL_DIV),
      .ENABLE_DIV     (USE_MUL_DIV),
      .BARREL_SHIFTER (1)
  ) picorv32_core (
      .clk         (clk_i),
      .resetn      (~rst_i),
      .trap        (trap_o),
      .mem_instr   (cpu_instr),
      //memory interface
      .mem_valid   (cpu_valid),
      .mem_addr    (cpu_addr),
      .mem_wdata   (cpu_wdata),
      .mem_wstrb   (cpu_wstrb),
      .mem_rdata   (cpu_rdata),
      .mem_ready   (cpu_ready),
      //lookahead interface
      .mem_la_read (),
      .mem_la_write(),
      .mem_la_addr (),
      .mem_la_wdata(),
      .mem_la_wstrb(),
      //co-processor interface (PCPI)
      .pcpi_valid  (),
      .pcpi_insn   (),
      .pcpi_rs1    (),
      .pcpi_rs2    (),
      .pcpi_wr     (1'b0),
      .pcpi_rd     (32'd0),
      .pcpi_wait   (1'b0),
      .pcpi_ready  (1'b0),
      // IRQ
      .irq         (32'd0),
      .eoi         (),
      .trace_valid (),
      .trace_data  ()
  );

endmodule
