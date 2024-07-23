import os

from submodule_utils import add_prefix_to_parameters_in_string
from iob_soc_peripherals import get_pio_signals
from if_gen import get_portmap_string


# Creates the Verilog Snippet (.vs) files required by wrappers
def create_wrapper_files(build_dir, name, ios, confs, num_extmem_connections):
    out_dir = os.path.join(build_dir, "hardware/simulation/src/")
    pwires_str = ""
    pportmaps_str = ""

    # Insert wires and connect them to system
    for table in ios:
        # If table has 'doc_only' attribute set to True, skip it
        if "doc_only" in table.keys() and table["doc_only"]:
            continue

        pio_signals = get_pio_signals(table["ports"])

        # Insert system IOs for peripheral
        if pio_signals and "if_defined" in table.keys():
            pwires_str += f"`ifdef {table['if_defined']}\n"
        for signal in pio_signals:
            # check if width (a string) is only an integer or a parameter
            if signal["width"].isdigit():
                width = int(signal["width"])
                # If width is 1, do not add [0:0] to the wire
                if width == 1:
                    pwires_str += "   wire {};\n".format(signal["name"])
                else:
                    pwires_str += "   wire [{}-1:0] {};\n".format(width, signal["name"])
            else:
                pwires_str += "   wire [{}-1:0] {};\n".format(
                    add_prefix_to_parameters_in_string(
                        signal["width"], confs, "`" + name.upper() + "_"
                    ),
                    signal["name"],
                )
        if pio_signals and "if_defined" in table.keys():
            pwires_str += "`endif\n"

        # Connect wires to soc port
        if pio_signals and "if_defined" in table.keys():
            pportmaps_str += f"`ifdef {table['if_defined']}\n"
        for signal in pio_signals:
            pportmaps_str += "               {signal_portmap}".format(
                signal_portmap=get_portmap_string(
                    port_prefix="",
                    wire_prefix="",
                    direction=signal["direction"],
                    port=signal,
                    connect_to_port=False,
                )
            )
        if pio_signals and "if_defined" in table.keys():
            pportmaps_str += "`endif\n"

    # Add extmem wires for system
    pwires_str += f"""
   //DDR AXI interface signals
`ifdef {name.upper()}_USE_EXTMEM
   // Wires for the system and its peripherals
   `include "iob_bus_{num_extmem_connections}_axi_wire.vs"
   // Wires to connect the interconnect with the memory
   `include "iob_memory_axi_wire.vs"
`endif
"""

    fd_periphs = open(f"{out_dir}/{name}_wrapper_pwires.vs", "w")
    fd_periphs.write(pwires_str)
    fd_periphs.close()

    # Add extmem portmap for system
    pportmaps_str += f"""
`ifdef {name.upper()}_USE_EXTMEM
      `include "iob_bus_0_{num_extmem_connections}_axi_m_portmap.vs"
`endif
"""

    fd_pportmaps = open(f"{out_dir}/{name}_pportmaps.vs", "w")
    fd_pportmaps.write(pportmaps_str)
    fd_pportmaps.close()

    create_interconnect_instance(out_dir, name, num_extmem_connections)
    create_cyclonev_interconnect_s_portmap(out_dir, name, num_extmem_connections)
    # If CYCLONEV-GT-DK directory exists, modify_alt_ddr3_qsys
    if os.path.exists(os.path.join(build_dir, "hardware/fpga/quartus/CYCLONEV-GT-DK")):
        modify_alt_ddr3_qsys(
            os.path.join(
                build_dir, "hardware/fpga/quartus/CYCLONEV-GT-DK/alt_ddr3.qsys"
            ),
            num_extmem_connections,
        )
    # If KU040 directory exists, create ku040_interconnect_s_portmap and ku040_rstn
    if os.path.exists(os.path.join(build_dir, "hardware/fpga/vivado/AES-KU040-DB-G")):
        create_ku040_interconnect_s_portmap(out_dir, name, num_extmem_connections)
        create_ku040_rstn(out_dir, name, num_extmem_connections)

    # Wires for extmem portmaps
    src_dir = os.path.join(build_dir, "hardware/src")
    mwrap_extmem_wires_str = f"""
      `include "iob_bus_{num_extmem_connections}_axi_wire.vs"
    """
    with open(f"{src_dir}/iob_mwrap_extmem_wires.vs", "w") as fd_mwrap_extmem_wires:
        fd_mwrap_extmem_wires.write(mwrap_extmem_wires_str)


def create_interconnect_instance(out_dir, name, num_extmem_connections):
    # Create strings for awlock and arlock
    awlock_str = arlock_str = " }"
    for i in range(num_extmem_connections):
        awlock_str = f", axi_awlock[{i*2}]" + awlock_str
        arlock_str = f", axi_arlock[{i*2}]" + arlock_str
    awlock_str = "{" + awlock_str[1:]
    arlock_str = "{" + arlock_str[1:]

    interconnect_str = f"""
`ifdef {name.upper()}_USE_EXTMEM
   //instantiate axi interconnect
   axi_interconnect #(
      .ID_WIDTH    (AXI_ID_W),
      .DATA_WIDTH  (AXI_DATA_W),
      .ADDR_WIDTH  (AXI_ADDR_W),
      .M_ADDR_WIDTH(AXI_ADDR_W),
      .S_COUNT     ({num_extmem_connections}),
      .M_COUNT     (1)
   ) system_axi_interconnect (
      .clk(clk_interconnect),
      .rst(arst_interconnect),

      // Need to use manually defined connections because awlock and arlock of interconnect is only on bit for each slave
      .s_axi_awid    (axi_awid),    //Address write channel ID.
      .s_axi_awaddr  (axi_awaddr),  //Address write channel address.
      .s_axi_awlen   (axi_awlen),   //Address write channel burst length.
      .s_axi_awsize  (axi_awsize),  //Address write channel burst size. This signal indicates the size of each transfer in the burst.
      .s_axi_awburst (axi_awburst), //Address write channel burst type.
      .s_axi_awlock  ({awlock_str}),//Address write channel lock type.
      .s_axi_awcache (axi_awcache), //Address write channel memory type. Transactions set with Normal, Non-cacheable, Modifiable, and Bufferable (0011).
      .s_axi_awprot  (axi_awprot),  //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      .s_axi_awqos   (axi_awqos),   //Address write channel quality of service.
      .s_axi_awvalid (axi_awvalid), //Address write channel valid.
      .s_axi_awready (axi_awready), //Address write channel ready.
      .s_axi_wdata   (axi_wdata),   //Write channel data.
      .s_axi_wstrb   (axi_wstrb),   //Write channel write strobe.
      .s_axi_wlast   (axi_wlast),   //Write channel last word flag.
      .s_axi_wvalid  (axi_wvalid),  //Write channel valid.
      .s_axi_wready  (axi_wready),  //Write channel ready.
      .s_axi_bid     (axi_bid),     //Write response channel ID.
      .s_axi_bresp   (axi_bresp),   //Write response channel response.
      .s_axi_bvalid  (axi_bvalid),  //Write response channel valid.
      .s_axi_bready  (axi_bready),  //Write response channel ready.
      .s_axi_arid    (axi_arid),    //Address read channel ID.
      .s_axi_araddr  (axi_araddr),  //Address read channel address.
      .s_axi_arlen   (axi_arlen),   //Address read channel burst length.
      .s_axi_arsize  (axi_arsize),  //Address read channel burst size. This signal indicates the size of each transfer in the burst.
      .s_axi_arburst (axi_arburst), //Address read channel burst type.
      .s_axi_arlock  ({arlock_str}),//Address read channel lock type.
      .s_axi_arcache (axi_arcache), //Address read channel memory type. Transactions set with Normal, Non-cacheable, Modifiable, and Bufferable (0011).
      .s_axi_arprot  (axi_arprot),  //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      .s_axi_arqos   (axi_arqos),   //Address read channel quality of service.
      .s_axi_arvalid (axi_arvalid), //Address read channel valid.
      .s_axi_arready (axi_arready), //Address read channel ready.
      .s_axi_rid     (axi_rid),     //Read channel ID.
      .s_axi_rdata   (axi_rdata),   //Read channel data.
      .s_axi_rresp   (axi_rresp),   //Read channel response.
      .s_axi_rlast   (axi_rlast),   //Read channel last word.
      .s_axi_rvalid  (axi_rvalid),  //Read channel valid.
      .s_axi_rready  (axi_rready),  //Read channel ready.

      // Used manually defined connections because awlock and arlock of interconnect is only on bit.
      .m_axi_awid    (memory_axi_awid[0+:AXI_ID_W]),         //Address write channel ID.
      .m_axi_awaddr  (memory_axi_awaddr[0+:AXI_ADDR_W]),     //Address write channel address.
      .m_axi_awlen   (memory_axi_awlen[0+:AXI_LEN_W]),       //Address write channel burst length.
      .m_axi_awsize  (memory_axi_awsize[0+:3]),              //Address write channel burst size. This signal indicates the size of each transfer in the burst.
      .m_axi_awburst (memory_axi_awburst[0+:2]),             //Address write channel burst type.
      .m_axi_awlock  (memory_axi_awlock[0+:1]),              //Address write channel lock type.
      .m_axi_awcache (memory_axi_awcache[0+:4]),             //Address write channel memory type. Transactions set with Normal, Non-cacheable, Modifiable, and Bufferable (0011).
      .m_axi_awprot  (memory_axi_awprot[0+:3]),              //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      .m_axi_awqos   (memory_axi_awqos[0+:4]),               //Address write channel quality of service.
      .m_axi_awvalid (memory_axi_awvalid[0+:1]),             //Address write channel valid.
      .m_axi_awready (memory_axi_awready[0+:1]),             //Address write channel ready.
      .m_axi_wdata   (memory_axi_wdata[0+:AXI_DATA_W]),      //Write channel data.
      .m_axi_wstrb   (memory_axi_wstrb[0+:(AXI_DATA_W/8)]),  //Write channel write strobe.
      .m_axi_wlast   (memory_axi_wlast[0+:1]),               //Write channel last word flag.
      .m_axi_wvalid  (memory_axi_wvalid[0+:1]),              //Write channel valid.
      .m_axi_wready  (memory_axi_wready[0+:1]),              //Write channel ready.
      .m_axi_bid     (memory_axi_bid[0+:AXI_ID_W]),          //Write response channel ID.
      .m_axi_bresp   (memory_axi_bresp[0+:2]),               //Write response channel response.
      .m_axi_bvalid  (memory_axi_bvalid[0+:1]),              //Write response channel valid.
      .m_axi_bready  (memory_axi_bready[0+:1]),              //Write response channel ready.
      .m_axi_arid    (memory_axi_arid[0+:AXI_ID_W]),         //Address read channel ID.
      .m_axi_araddr  (memory_axi_araddr[0+:AXI_ADDR_W]),     //Address read channel address.
      .m_axi_arlen   (memory_axi_arlen[0+:AXI_LEN_W]),       //Address read channel burst length.
      .m_axi_arsize  (memory_axi_arsize[0+:3]),              //Address read channel burst size. This signal indicates the size of each transfer in the burst.
      .m_axi_arburst (memory_axi_arburst[0+:2]),             //Address read channel burst type.
      .m_axi_arlock  (memory_axi_arlock[0+:1]),              //Address read channel lock type.
      .m_axi_arcache (memory_axi_arcache[0+:4]),             //Address read channel memory type. Transactions set with Normal, Non-cacheable, Modifiable, and Bufferable (0011).
      .m_axi_arprot  (memory_axi_arprot[0+:3]),              //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      .m_axi_arqos   (memory_axi_arqos[0+:4]),               //Address read channel quality of service.
      .m_axi_arvalid (memory_axi_arvalid[0+:1]),             //Address read channel valid.
      .m_axi_arready (memory_axi_arready[0+:1]),             //Address read channel ready.
      .m_axi_rid     (memory_axi_rid[0+:AXI_ID_W]),          //Read channel ID.
      .m_axi_rdata   (memory_axi_rdata[0+:AXI_DATA_W]),      //Read channel data.
      .m_axi_rresp   (memory_axi_rresp[0+:2]),               //Read channel response.
      .m_axi_rlast   (memory_axi_rlast[0+:1]),               //Read channel last word.
      .m_axi_rvalid  (memory_axi_rvalid[0+:1]),              //Read channel valid.
      .m_axi_rready  (memory_axi_rready[0+:1]),              //Read channel ready.

      //optional signals
      .s_axi_awuser({num_extmem_connections}'b0),
      .s_axi_wuser ({num_extmem_connections}'b0),
      .s_axi_aruser({num_extmem_connections}'b0),
      .s_axi_buser (),
      .s_axi_ruser (),
      .m_axi_awuser(),
      .m_axi_wuser (),
      .m_axi_aruser(),
      .m_axi_buser (1'b0),
      .m_axi_ruser (1'b0),
      .m_axi_awregion (),
      .m_axi_arregion ()
   );
`endif

"""

    fp_interconnect = open(f"{out_dir}/{name}_interconnect.vs", "w")
    fp_interconnect.write(interconnect_str)
    fp_interconnect.close()


def create_ku040_rstn(out_dir, name, num_extmem_connections):
    rstn_str = ""
    for i in range(num_extmem_connections):
        rstn_str += f" ~rstn[{i}] ||"
    rstn_str = rstn_str[:-3]

    file_str = f"      wire [{num_extmem_connections}-1:0] rstn;"
    file_str += f"      assign arst ={rstn_str};"  # FIXME: This is probably wrong. Reset signals should not have logic

    fp_rstn = open(f"{out_dir}/{name}_ku040_rstn.vs", "w")
    fp_rstn.write(file_str)
    fp_rstn.close()


def create_ku040_interconnect_s_portmap(out_dir, name, num_extmem_connections):
    interconnect_str = ""
    for i in range(num_extmem_connections):
        interconnect_str += f"""
      //
      // External memory connection {i}
      //
      .S{i:02d}_AXI_ARESET_OUT_N(rstn[{i}]),  //to system reset
      .S{i:02d}_AXI_ACLK        (clk),      //from ddr4 controller PLL to be used by system

      //Write address
      .S{i:02d}_AXI_AWID   (axi_awid[{i}*AXI_ID_W+:1]),
      .S{i:02d}_AXI_AWADDR (axi_awaddr[{i}*AXI_ADDR_W+:AXI_ADDR_W]),
      .S{i:02d}_AXI_AWLEN  (axi_awlen[{i}*AXI_LEN_W+:AXI_LEN_W]),
      .S{i:02d}_AXI_AWSIZE (axi_awsize[{i}*3+:3]),
      .S{i:02d}_AXI_AWBURST(axi_awburst[{i}*2+:2]),
      .S{i:02d}_AXI_AWLOCK (axi_awlock[{i}*2+:1]),
      .S{i:02d}_AXI_AWCACHE(axi_awcache[{i}*4+:4]),
      .S{i:02d}_AXI_AWPROT (axi_awprot[{i}*3+:3]),
      .S{i:02d}_AXI_AWQOS  (axi_awqos[{i}*4+:4]),
      .S{i:02d}_AXI_AWVALID(axi_awvalid[{i}*1+:1]),
      .S{i:02d}_AXI_AWREADY(axi_awready[{i}*1+:1]),

      //Write data
      .S{i:02d}_AXI_WDATA (axi_wdata[{i}*AXI_DATA_W+:AXI_DATA_W]),
      .S{i:02d}_AXI_WSTRB (axi_wstrb[{i}*(AXI_DATA_W/8)+:(AXI_DATA_W/8)]),
      .S{i:02d}_AXI_WLAST (axi_wlast[{i}*1+:1]),
      .S{i:02d}_AXI_WVALID(axi_wvalid[{i}*1+:1]),
      .S{i:02d}_AXI_WREADY(axi_wready[{i}*1+:1]),

      //Write response
      .S{i:02d}_AXI_BID   (axi_bid[{i}*AXI_ID_W+:1]),
      .S{i:02d}_AXI_BRESP (axi_bresp[{i}*2+:2]),
      .S{i:02d}_AXI_BVALID(axi_bvalid[{i}*1+:1]),
      .S{i:02d}_AXI_BREADY(axi_bready[{i}*1+:1]),

      //Read address
      .S{i:02d}_AXI_ARID   (axi_arid[{i}*AXI_ID_W+:1]),
      .S{i:02d}_AXI_ARADDR (axi_araddr[{i}*AXI_ADDR_W+:AXI_ADDR_W]),
      .S{i:02d}_AXI_ARLEN  (axi_arlen[{i}*AXI_LEN_W+:AXI_LEN_W]),
      .S{i:02d}_AXI_ARSIZE (axi_arsize[{i}*3+:3]),
      .S{i:02d}_AXI_ARBURST(axi_arburst[{i}*2+:2]),
      .S{i:02d}_AXI_ARLOCK (axi_arlock[{i}*2+:1]),
      .S{i:02d}_AXI_ARCACHE(axi_arcache[{i}*4+:4]),
      .S{i:02d}_AXI_ARPROT (axi_arprot[{i}*3+:3]),
      .S{i:02d}_AXI_ARQOS  (axi_arqos[{i}*4+:4]),
      .S{i:02d}_AXI_ARVALID(axi_arvalid[{i}*1+:1]),
      .S{i:02d}_AXI_ARREADY(axi_arready[{i}*1+:1]),

      //Read data
      .S{i:02d}_AXI_RID   (axi_rid[{i}*AXI_ID_W+:1]),
      .S{i:02d}_AXI_RDATA (axi_rdata[{i}*AXI_DATA_W+:AXI_DATA_W]),
      .S{i:02d}_AXI_RRESP (axi_rresp[{i}*2+:2]),
      .S{i:02d}_AXI_RLAST (axi_rlast[{i}*1+:1]),
      .S{i:02d}_AXI_RVALID(axi_rvalid[{i}*1+:1]),
      .S{i:02d}_AXI_RREADY(axi_rready[{i}*1+:1]),

"""

    fp_interconnect = open(f"{out_dir}/{name}_ku040_interconnect_s_portmap.vs", "w")
    fp_interconnect.write(interconnect_str)
    fp_interconnect.close()


def create_cyclonev_interconnect_s_portmap(out_dir, name, num_extmem_connections):
    interconnect_str = ""
    for i in range(num_extmem_connections):
        interconnect_str += f"""
      //
      // External memory connection {i}
      //

      //Write address
      .axi_bridge_{i}_s0_awid   (axi_awid[{i}*AXI_ID_W+:1]),
      .axi_bridge_{i}_s0_awaddr (axi_awaddr[{i}*AXI_ADDR_W+:AXI_ADDR_W]),
      .axi_bridge_{i}_s0_awlen  (axi_awlen[{i}*AXI_LEN_W+:AXI_LEN_W]),
      .axi_bridge_{i}_s0_awsize (axi_awsize[{i}*3+:3]),
      .axi_bridge_{i}_s0_awburst(axi_awburst[{i}*2+:2]),
      .axi_bridge_{i}_s0_awlock (axi_awlock[{i}*2+:1]),
      .axi_bridge_{i}_s0_awcache(axi_awcache[{i}*4+:4]),
      .axi_bridge_{i}_s0_awprot (axi_awprot[{i}*3+:3]),
      .axi_bridge_{i}_s0_awvalid(axi_awvalid[{i}*1+:1]),
      .axi_bridge_{i}_s0_awready(axi_awready[{i}*1+:1]),

      //Write data
      .axi_bridge_{i}_s0_wdata  (axi_wdata[{i}*AXI_DATA_W+:AXI_DATA_W]),
      .axi_bridge_{i}_s0_wstrb  (axi_wstrb[{i}*(AXI_DATA_W/8)+:(AXI_DATA_W/8)]),
      .axi_bridge_{i}_s0_wlast  (axi_wlast[{i}*1+:1]),
      .axi_bridge_{i}_s0_wvalid (axi_wvalid[{i}*1+:1]),
      .axi_bridge_{i}_s0_wready (axi_wready[{i}*1+:1]),

      //Write response
      .axi_bridge_{i}_s0_bid    (axi_bid[{i}*AXI_ID_W+:1]),
      .axi_bridge_{i}_s0_bresp  (axi_bresp[{i}*2+:2]),
      .axi_bridge_{i}_s0_bvalid (axi_bvalid[{i}*1+:1]),
      .axi_bridge_{i}_s0_bready (axi_bready[{i}*1+:1]),

      //Read address
      .axi_bridge_{i}_s0_arid   (axi_arid[{i}*AXI_ID_W+:1]),
      .axi_bridge_{i}_s0_araddr (axi_araddr[{i}*AXI_ADDR_W+:AXI_ADDR_W]),
      .axi_bridge_{i}_s0_arlen  (axi_arlen[{i}*AXI_LEN_W+:AXI_LEN_W]),
      .axi_bridge_{i}_s0_arsize (axi_arsize[{i}*3+:3]),
      .axi_bridge_{i}_s0_arburst(axi_arburst[{i}*2+:2]),
      .axi_bridge_{i}_s0_arlock (axi_arlock[{i}*2+:1]),
      .axi_bridge_{i}_s0_arcache(axi_arcache[{i}*4+:4]),
      .axi_bridge_{i}_s0_arprot (axi_arprot[{i}*3+:3]),
      .axi_bridge_{i}_s0_arvalid(axi_arvalid[{i}*1+:1]),
      .axi_bridge_{i}_s0_arready(axi_arready[{i}*1+:1]),

      //Read data
      .axi_bridge_{i}_s0_rid    (axi_rid[{i}*AXI_ID_W+:1]),
      .axi_bridge_{i}_s0_rdata  (axi_rdata[{i}*AXI_DATA_W+:AXI_DATA_W]),
      .axi_bridge_{i}_s0_rresp  (axi_rresp[{i}*2+:2]),
      .axi_bridge_{i}_s0_rlast  (axi_rlast[{i}*1+:1]),
      .axi_bridge_{i}_s0_rvalid (axi_rvalid[{i}*1+:1]),
      .axi_bridge_{i}_s0_rready (axi_rready[{i}*1+:1]),

"""

    fp_interconnect = open(f"{out_dir}/{name}_cyclonev_interconnect_s_portmap.vs", "w")
    fp_interconnect.write(interconnect_str)
    fp_interconnect.close()


# Add slave ports to alt_ddr3.qsys, based on number of extmem connections
def modify_alt_ddr3_qsys(qsys_path, num_extmem_connections):
    with open(qsys_path, "r") as f:
        lines = f.readlines()
    new_lines = []

    for line in lines:
        new_lines.append(line)
        if "element clk_0" in line:
            for i in range(1, num_extmem_connections):
                new_lines.insert(
                    -1,
                    f"""
       element axi_bridge_{i}
       {{
          datum _sortIndex
          {{
             value = "{i+2}";
             type = "int";
          }}
       }}
                             \n""",
                )
        elif 'interface name="clk"' in line:
            for i in range(1, num_extmem_connections):
                new_lines.insert(
                    -1,
                    f"""
 <interface
   name="axi_bridge_{i}_s0"
   internal="axi_bridge_{i}.s0"
   type="axi4"
   dir="end" />
                             \n""",
                )
        elif 'module name="clk_0"' in line:
            for i in range(1, num_extmem_connections):
                new_lines.insert(
                    -1,
                    f"""
 <module
   name="axi_bridge_{i}"
   kind="altera_axi_bridge"
   version="20.1"
   enabled="1">
  <parameter name="ADDR_WIDTH" value="28" />
  <parameter name="AXI_VERSION" value="AXI4" />
  <parameter name="COMBINED_ACCEPTANCE_CAPABILITY" value="16" />
  <parameter name="COMBINED_ISSUING_CAPABILITY" value="16" />
  <parameter name="DATA_WIDTH" value="32" />
  <parameter name="M0_ID_WIDTH" value="1" />
  <parameter name="READ_ACCEPTANCE_CAPABILITY" value="16" />
  <parameter name="READ_ADDR_USER_WIDTH" value="64" />
  <parameter name="READ_DATA_REORDERING_DEPTH" value="1" />
  <parameter name="READ_DATA_USER_WIDTH" value="64" />
  <parameter name="READ_ISSUING_CAPABILITY" value="16" />
  <parameter name="S0_ID_WIDTH" value="1" />
  <parameter name="USE_M0_ARBURST" value="1" />
  <parameter name="USE_M0_ARCACHE" value="1" />
  <parameter name="USE_M0_ARID" value="1" />
  <parameter name="USE_M0_ARLEN" value="1" />
  <parameter name="USE_M0_ARLOCK" value="1" />
  <parameter name="USE_M0_ARQOS" value="0" />
  <parameter name="USE_M0_ARREGION" value="0" />
  <parameter name="USE_M0_ARSIZE" value="1" />
  <parameter name="USE_M0_ARUSER" value="0" />
  <parameter name="USE_M0_AWBURST" value="1" />
  <parameter name="USE_M0_AWCACHE" value="1" />
  <parameter name="USE_M0_AWID" value="1" />
  <parameter name="USE_M0_AWLEN" value="1" />
  <parameter name="USE_M0_AWLOCK" value="1" />
  <parameter name="USE_M0_AWQOS" value="0" />
  <parameter name="USE_M0_AWREGION" value="0" />
  <parameter name="USE_M0_AWSIZE" value="1" />
  <parameter name="USE_M0_AWUSER" value="0" />
  <parameter name="USE_M0_BID" value="1" />
  <parameter name="USE_M0_BRESP" value="1" />
  <parameter name="USE_M0_BUSER" value="0" />
  <parameter name="USE_M0_RID" value="1" />
  <parameter name="USE_M0_RLAST" value="1" />
  <parameter name="USE_M0_RRESP" value="1" />
  <parameter name="USE_M0_RUSER" value="0" />
  <parameter name="USE_M0_WSTRB" value="1" />
  <parameter name="USE_M0_WUSER" value="0" />
  <parameter name="USE_PIPELINE" value="1" />
  <parameter name="USE_S0_ARCACHE" value="1" />
  <parameter name="USE_S0_ARLOCK" value="1" />
  <parameter name="USE_S0_ARPROT" value="1" />
  <parameter name="USE_S0_ARQOS" value="0" />
  <parameter name="USE_S0_ARREGION" value="0" />
  <parameter name="USE_S0_ARUSER" value="0" />
  <parameter name="USE_S0_AWCACHE" value="1" />
  <parameter name="USE_S0_AWLOCK" value="1" />
  <parameter name="USE_S0_AWPROT" value="1" />
  <parameter name="USE_S0_AWQOS" value="0" />
  <parameter name="USE_S0_AWREGION" value="0" />
  <parameter name="USE_S0_AWUSER" value="0" />
  <parameter name="USE_S0_BRESP" value="1" />
  <parameter name="USE_S0_BUSER" value="0" />
  <parameter name="USE_S0_RRESP" value="1" />
  <parameter name="USE_S0_RUSER" value="0" />
  <parameter name="USE_S0_WLAST" value="1" />
  <parameter name="USE_S0_WUSER" value="0" />
  <parameter name="WRITE_ACCEPTANCE_CAPABILITY" value="16" />
  <parameter name="WRITE_ADDR_USER_WIDTH" value="64" />
  <parameter name="WRITE_DATA_USER_WIDTH" value="64" />
  <parameter name="WRITE_ISSUING_CAPABILITY" value="16" />
  <parameter name="WRITE_RESP_USER_WIDTH" value="64" />
 </module>
                             \n""",
                )
        elif 'end="axi_bridge_0.clk"' in line:
            for i in range(1, num_extmem_connections):
                new_lines.insert(
                    -1,
                    f"""
 <connection
   kind="avalon"
   version="20.1"
   start="axi_bridge_{i}.m0"
   end="mem_if_ddr3_emif_0.avl">
  <parameter name="arbitrationPriority" value="1" />
  <parameter name="baseAddress" value="0x0000" />
  <parameter name="defaultConnection" value="false" />
 </connection>
 <connection kind="clock" version="20.1" start="clk_0.clk" end="axi_bridge_{i}.clk" />
                             \n""",
                )
        elif 'name="qsys_mm.clockCrossingAdapter"' in line:
            for i in range(1, num_extmem_connections):
                new_lines.insert(
                    -1,
                    f"""
 <connection
   kind="reset"
   version="20.1"
   start="clk_0.clk_reset"
   end="axi_bridge_{i}.clk_reset" />
                             \n""",
                )

    with open(qsys_path, "w") as f:
        f.writelines(new_lines)
