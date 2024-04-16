#!/usr/bin/env python3

import sys

from iob_core import iob_core
from iob_soc_utils import pre_setup_iob_soc, post_setup_iob_soc


class iob_soc(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.7")
        self.set_default_attribute("generate_hw", False)
        self.set_default_attribute("rw_overlap", True)
        self.set_default_attribute("is_system", True)
        self.set_default_attribute("board_list", ["CYCLONEV-GT-DK", "AES-KU040-DB-G"])

        INIT_MEM = int("INIT_MEM" in sys.argv)
        USE_EXTMEM = int("USE_EXTMEM" in sys.argv)
        USE_COMPRESSED = 1
        USE_MUL_DIV = 1

        # Number of peripherals + Bootctr
        N_SLAVES = 3

        # macros
        # This method creates a macro and adds it to the local module's `confs` list
        self.create_conf(
            name="INIT_MEM",
            type="M",
            val=INIT_MEM,
            min="0",
            max="1",
            descr="Enable MUL and DIV CPU instructions",
        ),
        self.create_conf(
            name="USE_EXTMEM",
            type="M",
            val=USE_EXTMEM,
            min="0",
            max="1",
            descr="Enable MUL and DIV CPU instructions",
        ),
        self.create_conf(
            name="USE_MUL_DIV",
            type="M",
            val=USE_MUL_DIV,
            min="0",
            max="1",
            descr="Enable MUL and DIV CPU instructions",
        ),
        self.create_conf(
            name="USE_COMPRESSED",
            type="M",
            val=USE_COMPRESSED,
            min="0",
            max="1",
            descr="Use compressed CPU instructions",
        ),
        self.create_conf(
            name="E",
            type="M",
            val="31",
            min="1",
            max="32",
            descr="Address selection bit for external memory",
        ),
        self.create_conf(
            name="B",
            type="M",
            val="20",
            min="1",
            max="32",
            descr="Address selection bit for boot ROM",
        ),
        # parameters
        self.create_conf(
            name="BOOTROM_ADDR_W",
            type="P",
            val="12",
            min="1",
            max="32",
            descr="Boot ROM address width",
        ),
        self.create_conf(
            name="SRAM_ADDR_W",
            type="P",
            val="15",
            min="1",
            max="32",
            descr="SRAM address width",
        ),
        self.create_conf(
            name="MEM_ADDR_W",
            type="P",
            val="24",
            min="1",
            max="32",
            descr="Memory bus address width",
        ),
        # mandatory parameters (do not change them!)
        self.create_conf(
            name="ADDR_W",
            type="F",
            val="32",
            min="1",
            max="32",
            descr="Address bus width",
        ),
        self.create_conf(
            name="DATA_W",
            type="F",
            val="32",
            min="1",
            max="32",
            descr="Data bus width",
        ),
        self.create_conf(
            name="AXI_ID_W",
            type="F",
            val="0",
            min="1",
            max="32",
            descr="AXI ID bus width",
        ),
        self.create_conf(
            name="AXI_ADDR_W",
            type="F",
            val="`IOB_SOC_MEM_ADDR_W",
            min="1",
            max="32",
            descr="AXI address bus width",
        ),
        self.create_conf(
            name="AXI_DATA_W",
            type="F",
            val="`IOB_SOC_DATA_W",
            min="1",
            max="32",
            descr="AXI data bus width",
        ),
        self.create_conf(
            name="AXI_LEN_W",
            type="F",
            val="4",
            min="1",
            max="4",
            descr="AXI burst length width",
        ),
        self.create_conf(
            name="MEM_ADDR_OFFSET",
            type="F",
            val="0",
            min="0",
            max="NA",
            descr="Offset of memory address",
        ),

        self.create_port(
            name="clk_en_rst",
            type="slave",
            wire_prefix="",
            port_prefix="",
            descr="Clock, enable, and reset",
        )
        if USE_EXTMEM:
            self.create_port(
                name="axi",
                type="master",
                wire_prefix="",
                port_prefix="",
                mult=1,
                widths={
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
                descr="Bus of AXI master interfaces for external memory. One interface for this system and others optionally for peripherals.",
            )
        # Internal memory ports for Memory Wrapper
        self.create_port(
            name="rom",
            descr="Ports for connection with ROM memory",
            signals=[
                {"name": "rom_r_valid", "width": 1, "direction": "output"},
                {
                    "name": "rom_r_addr",
                    "width": "BOOTROM_ADDR_W-2",
                    "direction": "output",
                },
                {"name": "rom_r_rdata", "width": "DATA_W", "direction": "input"},
            ],
        )
        self.create_port(
            name="spram",
            descr="Port for connection with SPRAM memory",
            if_defined="USE_SPRAM",
            signals=[
                {"name": "valid_spram", "width": 1, "direction": "output"},
                {"name": "addr_spram", "width": "SRAM_ADDR_W-2", "direction": "output"},
                {"name": "wdata_spram", "width": "DATA_W", "direction": "output"},
                {"name": "wstrb_spram", "width": "DATA_W/8", "direction": "output"},
                {"name": "rdata_spram", "width": "DATA_W", "direction": "input"},
            ],
        )
        self.create_port(
            name="i_sram",
            descr="Instruction port for connection with SRAM memory",
            signals=[
                {"name": "i_valid", "width": 1, "direction": "output"},
                {"name": "i_addr", "width": "SRAM_ADDR_W-2", "direction": "output"},
                {"name": "i_wdata", "width": "DATA_W", "direction": "output"},
                {"name": "i_wstrb", "width": "DATA_W/8", "direction": "output"},
                {"name": "i_rdata", "width": "DATA_W", "direction": "input"},
            ],
        )
        self.create_port(
            name="d_sram",
            descr="Data port for connection with SRAM memory",
            signals=[
                {"name": "d_valid", "width": 1, "direction": "output"},
                {"name": "d_addr", "width": "SRAM_ADDR_W-2", "direction": "output"},
                {"name": "d_wdata", "width": "DATA_W", "direction": "output"},
                {"name": "d_wstrb", "width": "DATA_W/8", "direction": "output"},
                {"name": "d_rdata", "width": "DATA_W", "direction": "input"},
            ],
        )
        # Peripheral IO ports
        self.create_port(
            name="rs232",
            type="",  # Neutral type. Neither master nor slave.
            wire_prefix="",
            port_prefix="",
            descr="iob-soc uart interface",
        ),

        #######################################
        # IOb-SoC modules, wires, and instances
        #######################################

        # TODO: Find a way to include verilog headers at the top of the generated module

        #
        # SYSTEM RESET
        #

        # # Create single wires, and automatically assign them to single wire groups
        # self.create_wire("boot", width=1)
        # self.create_wire("cpu_reset", width=1)

        # #
        # # CPU
        # #

        # self.create_bus(
        #     name="cpu_i_bus",
        #     descr="Cpu instruction bus",
        #     wires=[
        #         {"name": "cpu_i_req", "width": REQ_W},
        #         {"name": "cpu_i_resp", "width": RESP_W}
        #     ],
        # )
        # ### Alternative way to create wires and assign them to a group
        # # self.create_wire(
        # #     name="cpu_i_req",
        # #     width=REQ_W,
        # #     group="cpu_i_bus"
        # # )
        # # self.create_wire(
        # #     name="cpu_i_resp",
        # #     width=RESP_W,
        # #     group="cpu_i_bus"
        # # )

        # self.create_bus(
        #     name="cpu_d_bus",
        #     descr="Cpu data bus",
        #     wires=[
        #         {"name": "cpu_d_req", "width": REQ_W},
        #         {"name": "cpu_d_resp", "width": RESP_W}
        #     ],
        # )

        # self.create_bus(
        #     name="cpu_clk_en_rst",
        #     descr="Cpu clock, enable, and reset",
        #     wires=[
        #         get_wire_from_bus("clk_en_rst", "clk"),
        #         get_wire("cpu_reset"),
        #         get_wire_from_bus("clk_en_rst", "cke"),

        #     ],
        # )

        # This method creates a new module instance and adds it to the local module's `blocks` list
        self.create_instance(
            "iob_picorv32",
            "cpu",
            parameters={
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
                "USE_COMPRESSED": USE_COMPRESSED,
                "USE_MUL_DIV": USE_MUL_DIV,
                "USE_EXTMEM": USE_EXTMEM,
            },
            # Connect port groups to wire groups
            # connect={
            #     "clk_en_rst": "cpu_clk_en_rst",
            #     "boot": "boot",
            #     # instruction bus
            #     "i_bus": "cpu_i_bus",
            #     # data bus
            #     "d_bus": "cpu_d_bus",
            # },
        )

        # ###########################################################################
        # TODO: Update lines below with new connections from local wires and groups.
        #       Also remove `_i` and `_o` suffixes.
        # ###########################################################################

        #
        # SPLIT CPU BUSES TO ACCESS INTERNAL OR EXTERNAL MEMORY
        #

        # # internal memory instruction bus
        # int_mem_i_bus = wire_group(
        #     "int_mem_i_bus",
        #     descr="Internal memory instruction bus",
        #     wires=[
        #         wire("int_mem_i_req", width=REQ_W),
        #         wire("int_mem_i_resp", width=RESP_W),
        #     ],
        # )
        # # external memory instruction bus
        # ext_mem_i_bus = wire_group(
        #     "ext_mem_i_bus",
        #     descr="External memory instruction bus",
        #     wires=[
        #         wire("ext_mem_i_req", width=REQ_W),
        #         wire("ext_mem_i_resp", width=RESP_W),
        #     ],
        # )

        if USE_EXTMEM:
            self.create_instance(
                "iob_split",
                "ibus_split",
                parameters={
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                    "N_SLAVES": "2",
                    "P_SLAVES": "REQ_W - 2",
                },
                # connect={
                #     "clk_i": clk,
                #     "arst_i": cpu_reset,
                #     # master interface
                #     "m_bus": cpu_i_bus,
                #     # slaves interface
                #     "s_bus": [ext_mem_i_bus, int_mem_i_bus],
                # },
            )
        # else:  # no extmem
        #     int_mem_i_bus = cpu_i_bus

        # DATA BUS

        # # internal data bus
        # int_d_bus = wire_group(
        #     "int_d_bus",
        #     descr="Internal data bus",
        #     wires=[
        #         wire("int_d_req", width=REQ_W),
        #         wire("int_d_resp", width=RESP_W)
        #     ],
        # )
        # # external memory data bus
        # ext_mem_d_bus = wire_group(
        #     "ext_mem_d_bus",
        #     descr="External memory data bus",
        #     wires=[
        #         wire("ext_mem_d_req", width=REQ_W),
        #         wire("ext_mem_d_resp", width=RESP_W),
        #     ],
        # )

        if USE_EXTMEM:
            self.create_instance(
                "iob_split",
                "dbus_split",
                parameters={
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                    "N_SLAVES": "2",  # E,{P,I}
                    "P_SLAVES": "REQ_W - 2",
                },
                # connect={
                #     "clk_i": clk,
                #     "arst_i": cpu_reset,
                #     # master interface
                #     "m_bus": cpu_d_bus,
                #     # slaves interface
                #     "s_bus": [ext_mem_d_bus, int_d_bus],
                # },
            )
        # else:  # no extmem
        #     int_d_bus = cpu_d_bus

        #
        # SPLIT INTERNAL MEMORY AND PERIPHERALS BUS
        #

        # slaves bus (includes internal memory + periphrals)
        # slaves_bus = wire_group(
        #     "slaves_bus",
        #     descr="Slaves bus",
        #     wires=[
        #         wire("slaves_req", width=N_SLAVES*REQ_W),
        #         wire("slaves_resp", width=N_SLAVES*RESP_W)
        #     ],
        # )

        self.create_instance(
            "iob_split",
            "pbus_split",
            parameters={
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
                "N_SLAVES": N_SLAVES,
                "P_SLAVES": "REQ_W - 3",
            },
            # connect={
            #    "clk_i": clk,
            #    "arst_i": cpu_reset,
            #    # master interface
            #    "m_bus": int_d_bus,
            #    # slaves interface
            #    "s_bus": slaves_bus,
            # },
        )

        #
        # INTERNAL SRAM MEMORY
        #

        self.create_instance(
            "iob_soc_int_mem",
            "int_mem",
            parameters={
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
                "HEXFILE": "iob_soc_firmware",
                "BOOT_HEXFILE": "iob_soc_boot",
                "SRAM_ADDR_W": "SRAM_ADDR_W",
                "BOOTROM_ADDR_W": "BOOTROM_ADDR_W",
                "B_BIT": "REQ_W - (ADDR_W-`IOB_SOC_B+1)",
            },
            # connect={
            #     "clk_en_rst": clk_en_rst,
            #     "boot": boot,
            #     "cpu_reset": cpu_reset,
            #     # instruction bus
            #     "i_bus": int_mem_i_bus,
            #     # data bus
            #     "d_bus": slaves_bus.part_sel(0, REQ_W or RESP_W?),  # .part(<part index>, <part width>)
            # },
        )

        #
        # EXTERNAL DDR MEMORY
        #

        # # TODO: Find a way to merge these into buses?
        # ext_mem0_i_req = wire("ext_mem0_i_req", width=1+MEM_ADDR_W-2+DATA_W+DATA_W/8)
        # ext_mem0_d_req = wire("ext_mem0_d_req", width=1+MEM_ADDR_W+1-2+DATA_W+DATA_W/8)

        # # TODO: find a way to replace this. We don't to connect a wire to another.
        # # Either inject verilog, or use module
        # ext_mem_i_req.connect_to = [valid(ext_mem_i_req, 0), address(ext_mem_i_req, 0, MEM_ADDR_W, -2), write(ext_mem_i_req, 0)]
        # ext_mem_d_req.connect_to = [valid(ext_mem_d_req, 0), address(ext_mem_d_req, 0, MEM_ADDR_W+1, -2), write(ext_mem_d_req, 0)]

        # internal_axi_awaddr_o = wire("internal_axi_awaddr_o", width=AXI_ADDR_W)
        # internal_axi_araddr_o = wire("internal_axi_araddr_o", width=AXI_ADDR_W)

        if USE_EXTMEM:
            self.create_instance(
                "iob_soc_ext_mem",
                "ext_mem",
                parameters={
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                    "FIRM_ADDR_W": "MEM_ADDR_W",
                    "MEM_ADDR_W": "MEM_ADDR_W",
                    "DDR_ADDR_W": "`DDR_ADDR_W",
                    "DDR_DATA_W": "`DDR_DATA_W",
                    "AXI_ID_W": "AXI_ID_W",
                    "AXI_LEN_W": "AXI_LEN_W",
                    "AXI_ADDR_W": "AXI_ADDR_W",
                    "AXI_DATA_W": "AXI_DATA_W",
                },
                # connect={
                #     # instruction bus
                #     "i_req_i": ext_mem0_i_req,
                #     "i_resp_o": ext_mem_i_bus.wires.ext_mem_i_resp,
                #     # data bus
                #     "d_req_i": ext_mem0_d_req,
                #     "d_resp_o": ext_mem_d_bus.wires.ext_mem_d_resp,
                #     # AXI INTERFACE
                #     # address write
                #     "axi_awid_o": axi.wires.axi_awid_o.part_sel(0, AXI_ID_W),
                #     "axi_awaddr_o": internal_axi_awaddr_o.part_sel(0, AXI_ADDR_W),
                #     "axi_awlen_o": axi.wires.axi_awlen_o.part_sel(0, AXI_LEN_W),
                #     "axi_awsize_o": axi.wires.axi_awsize_o.part_sel(0, 3),
                #     "axi_awburst_o": axi.wires.axi_awburst_o.part_sel(0, 2),
                #     "axi_awlock_o": axi.wires.axi_awlock_o.part_sel(0, 2),
                #     "axi_awcache_o": axi.wires.axi_awcache_o.part_sel(0, 4),
                #     "axi_awprot_o": axi.wires.axi_awprot_o.part_sel(0, 3),
                #     "axi_awqos_o": axi.wires.axi_awqos_o.part_sel(0, 4),
                #     "axi_awvalid_o": axi.wires.axi_awvalid_o.part_sel(0, 1),
                #     "axi_awready_i": axi.wires.axi_awready_i.part_sel(0, 1),
                #     # write
                #     "axi_wdata_o": axi.wires.axi_wdata_o.part_sel(0, AXI_DATA_W),
                #     "axi_wstrb_o": axi.wires.axi_wstrb_o.part_sel(0, (AXI_DATA_W/8)),
                #     "axi_wlast_o": axi.wires.axi_wlast_o.part_sel(0, 1),
                #     "axi_wvalid_o": axi.wires.axi_wvalid_o.part_sel(0, 1),
                #     "axi_wready_i": axi.wires.axi_wready_i.part_sel(0, 1),
                #     # write response
                #     "axi_bid_i": axi.wires.axi_bid_i.part_sel(0, AXI_ID_W),
                #     "axi_bresp_i": axi.wires.axi_bresp_i.part_sel(0, 2),
                #     "axi_bvalid_i": axi.wires.axi_bvalid_i.part_sel(0, 1),
                #     "axi_bready_o": axi.wires.axi_bready_o.part_sel(0, 1),
                #     # address read
                #     "axi_arid_o": axi.wires.axi_arid_o.part_sel(0, AXI_ID_W),
                #     "axi_araddr_o": internal_axi_araddr_o.part_sel(0, AXI_ADDR_W),
                #     "axi_arlen_o": axi.wires.axi_arlen_o.part_sel(0, AXI_LEN_W),
                #     "axi_arsize_o": axi.wires.axi_arsize_o.part_sel(0, 3),
                #     "axi_arburst_o": axi.wires.axi_arburst_o.part_sel(0, 2),
                #     "axi_arlock_o": axi.wires.axi_arlock_o.part_sel(0, 2),
                #     "axi_arcache_o": axi.wires.axi_arcache_o.part_sel(0, 4),
                #     "axi_arprot_o": axi.wires.axi_arprot_o.part_sel(0, 3),
                #     "axi_arqos_o": axi.wires.axi_arqos_o.part_sel(0, 4),
                #     "axi_arvalid_o": axi.wires.axi_arvalid_o.part_sel(0, 1),
                #     "axi_arready_i": axi.wires.axi_arready_i.part_sel(0, 1),
                #     # read
                #     "axi_rid_i": axi.wires.axi_rid_i.part_sel(0, AXI_ID_W),
                #     "axi_rdata_i": axi.wires.axi_rdata_i.part_sel(0, AXI_DATA_W),
                #     "axi_rresp_i": axi.wires.axi_rresp_i.part_sel(0, 2),
                #     "axi_rlast_i": axi.wires.axi_rlast_i.part_sel(0, 1),
                #     "axi_rvalid_i": axi.wires.axi_rvalid_i.part_sel(0, 1),
                #     "axi_rready_o": axi.wires.axi_rready_o.part_sel(0, 1),
                #     "clk_i": clk,
                #     "cke_i": cke,
                #     "arst_i": cpu_reset,
                # },
            )

        # # TODO: find a way to replace this. We don't to connect a wire to another.
        # # Either inject verilog, or use module
        # axi.wires.axi_awaddr_o.part_sel(0, AXI_ADDR_W).connect_to = internal_axi_awaddr_o + MEM_ADDR_OFFSET
        # axi.wires.axi_araddr_o.part_sel(0, AXI_ADDR_W).connect_to = internal_axi_araddr_o + MEM_ADDR_OFFSET

        #
        # PERIPHERALS
        #

        self.create_instance(
            "iob_uart",
            "UART0",
            parameters={
                "DATA_W": "UART0_DATA_W",
                "ADDR_W": "UART0_ADDR_W",
                "UART_DATA_W": "UART0_UART_DATA_W",
            },
            # connect={
            #     "rs232": rs232,
            #     "clk_en_rst": clk_en_rst,
            #     "iob_interface": slaves_bus.part_sel(0, REQ_W or RESP_W?),  # .part(<part index>, <part width>)
            # },
        )
        self.create_instance(
            "iob_timer",
            "TIMER0",
            parameters={
                "DATA_W": "TIMER0_DATA_W",
                "ADDR_W": "TIMER0_ADDR_W",
                "TIMER_DATA_W": "TIMER0_WDATA_W",
            },
            # connect={
            #     "clk_en_rst": clk_en_rst,
            #     "iob_interface": slaves_bus.part_sel(0, REQ_W or RESP_W?),  # .part(<part index>, <part width>)
            # },
        )

        # iob_split(
        #     name_prefix="data_boot_ctr",
        #     data_w="DATA_W",
        #     addr_w="ADDR_W",
        #     split_ptr="B_BIT",
        #     input_io=int_mem_d_io,
        #     output_ios=[
        #         int_mem_ram_d_io,
        #         int_mem_boot_ctr_io,
        #     ],
        # ),
        # iob_merge(
        #     name_prefix="ibus",
        #     data_w="DATA_W",
        #     addr_w="ADDR_W",
        #     input_ios=[
        #         int_mem_ram_r_io,
        #         int_mem_ram_w_io,
        #     ],
        #     output_io=int_mem_ram_i_io,
        # ),
        # iob_merge(
        #     name_prefix="i_d_into_l2",
        #     data_w="DATA_W",
        #     addr_w="MEM_ADDR_W",
        #     input_ios=[
        #         ext_mem_dcache_merge_io,
        #         ext_mem_icache_merge_io,
        #     ],
        #     output_io=ext_mem_l2cache_merge_io,
        # ),
        # iob_split(
        #     name_prefix="ibus",
        #     data_w="DATA_W",
        #     addr_w="ADDR_W",
        #     split_ptr="ADDR_W-1",
        #     input_io=cpu_i_io,
        #     output_ios=[
        #         int_mem_i_split_io,
        #         ext_mem_i_split_io,
        #     ],
        # ),
        # iob_split(
        #     name_prefix="dbus",
        #     data_w="DATA_W",
        #     addr_w="ADDR_W",
        #     split_ptr="ADDR_W-1",
        #     input_io=cpu_d_io,
        #     output_ios=[
        #         int_d_dbus_split_io,
        #         ext_mem_d_split_io,
        #     ],
        # ),

        # int_mem_i_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_int_mem_i_",
        #     "port_prefix": "i_",
        #     "wire_prefix": "int_mem_i_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal memory instruction interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # int_mem_d_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_int_mem_d_",
        #     "port_prefix": "d_",
        #     "wire_prefix": "int_mem_d_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal memory data interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # int_mem_boot_ctr_io = {
        #     "name": "iob",
        #     "type": "master",
        #     "file_prefix": "iob_soc_int_mem_boot_ctr_",
        #     "port_prefix": "boot_ctr_",
        #     "wire_prefix": "boot_ctr_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal memory boot controler interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # int_mem_ram_d_io = {
        #     "name": "iob",
        #     "type": "master",
        #     "file_prefix": "iob_soc_int_mem_ram_d_",
        #     "port_prefix": "ram_d_",
        #     "wire_prefix": "ram_d_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal memory ram data interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # int_mem_ram_w_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_int_mem_ram_w_",
        #     "port_prefix": "ram_w_",
        #     "wire_prefix": "ram_w_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal memory sram write interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }

        # int_mem_ram_r_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_int_mem_ram_r_",
        #     "port_prefix": "ram_r_",
        #     "wire_prefix": "ram_r_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal ram r bus",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # int_mem_ram_i_io = {
        #     "name": "iob",
        #     "type": "master",
        #     "file_prefix": "iob_soc_int_mem_ram_i_",
        #     "port_prefix": "ram_i_",
        #     "wire_prefix": "ram_i_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal ram i bus",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # ext_mem_i_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_ext_mem_i_",
        #     "port_prefix": "i_",
        #     "wire_prefix": "ext_mem_i_",
        #     "param_prefix": "",
        #     "descr": "iob-soc external memory instruction interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # ext_mem_d_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_ext_mem_d_",
        #     "port_prefix": "d_",
        #     "wire_prefix": "ext_mem_d_",
        #     "param_prefix": "",
        #     "descr": "iob-soc external memory data interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # ext_mem_icache_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_ext_mem_icache_",
        #     "port_prefix": "icache_",
        #     "wire_prefix": "icache_be_",
        #     "param_prefix": "",
        #     "descr": "iob-soc external memory instruction cache interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "MEM_ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # ext_mem_icache_merge_io = ext_mem_icache_io.copy()
        # ext_mem_icache_merge_io["widths"]["ADDR_W"] = "ADDR_W"
        # ext_mem_dcache_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_ext_mem_dcache_",
        #     "port_prefix": "dcache_",
        #     "wire_prefix": "dcache_be_",
        #     "param_prefix": "",
        #     "descr": "iob-soc external memory data cache interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "MEM_ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # ext_mem_dcache_merge_io = ext_mem_dcache_io.copy()
        # ext_mem_dcache_merge_io["widths"]["ADDR_W"] = "ADDR_W"
        # ext_mem_l2cache_io = {
        #     "name": "iob",
        #     "type": "master",
        #     "file_prefix": "iob_soc_ext_mem_l2cache_",
        #     "port_prefix": "l2cache_",
        #     "wire_prefix": "l2cache_",
        #     "param_prefix": "",
        #     "descr": "iob-soc external memory l2 cache interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "MEM_ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # ext_mem_l2cache_merge_io = ext_mem_l2cache_io.copy()
        # ext_mem_l2cache_merge_io["widths"]["ADDR_W"] = "ADDR_W"
        # cpu_i_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_cpu_i_",
        #     "port_prefix": "cpu_i_",
        #     "wire_prefix": "cpu_i_",
        #     "param_prefix": "",
        #     "descr": "cpu instruction bus",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # cpu_d_io = {
        #     "name": "iob",
        #     "type": "slave",
        #     "file_prefix": "iob_soc_cpu_d_",
        #     "port_prefix": "dbus_",
        #     "wire_prefix": "cpu_d_",
        #     "param_prefix": "",
        #     "descr": "cpu data bus",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }
        # cpu_i_inst_io = cpu_i_io.copy()
        # cpu_i_inst_io["type"] = "master"
        # cpu_i_inst_io["file_prefix"] = "iob_soc_cpu_i_inst_"
        # cpu_i_inst_io["port_prefix"] = "ibus_"

        # cpu_d_inst_io = cpu_d_io.copy()
        # cpu_d_inst_io["type"] = "master"
        # cpu_d_inst_io["file_prefix"] = "iob_soc_cpu_d_inst_"
        # cpu_d_inst_io["wire_prefix"] = "cpu_d_"

        # ext_mem_i_split_io = ext_mem_i_io.copy()
        # ext_mem_i_split_io["type"] = "master"
        # ext_mem_i_split_io["file_prefix"] = "iob_soc_ext_mem_i_split_"
        # ext_mem_i_split_io["port_prefix"] = "ext_mem_i_"

        # int_mem_i_split_io = int_mem_i_io.copy()
        # int_mem_i_split_io["type"] = "master"
        # int_mem_i_split_io["file_prefix"] = "iob_soc_int_mem_i_split_"
        # int_mem_i_split_io["port_prefix"] = "int_mem_i_"

        # ext_mem_d_split_io = ext_mem_d_io.copy()
        # ext_mem_d_split_io["type"] = "master"
        # ext_mem_d_split_io["file_prefix"] = "iob_soc_ext_mem_d_split_"
        # ext_mem_d_split_io["port_prefix"] = "ext_mem_d_"

        # int_d_dbus_split_io = {
        #     "name": "iob",
        #     "type": "master",
        #     "file_prefix": "iob_soc_int_d_dbus_",
        #     "port_prefix": "int_d_",
        #     "wire_prefix": "int_d_",
        #     "param_prefix": "",
        #     "descr": "iob-soc internal data interface",
        #     "ports": [],
        #     "widths": {
        #         "DATA_W": "DATA_W",
        #         "ADDR_W": "ADDR_W",
        #     },
        #     "is_io": False,
        # }

        #######################################
        # End of IOb-SoC module
        #######################################

        # Modules that need to be setup, but are not instantiated inside iob_soc Verilog module
        self.create_instance(
            "iob_cache",
            "cache",
        )
        self.create_instance(
            "iob_rom_sp",
            "rom_sp",
        )
        self.create_instance(
            "iob_ram_dp_be",
            "ram_dp_be",
        )
        self.create_instance(
            "iob_ram_dp_be_xil",
            "ram_dp_be_xil",
        )
        self.create_instance(
            "iob_pulse_gen",
            "pulse_gen",
        )
        # iob_counter("counter")
        self.create_instance(
            "iob_reg",
            "reg",
        )
        self.create_instance(
            "iob_reg_re",
            "reg_re",
        )
        self.create_instance(
            "iob_ram_sp_be",
            "ram_sp_be",
        )
        # iob_ram_dp("ram_dp")
        # iob_ctls("ctls")
        self.create_instance(
            "axi_interconnect",
            "interconnect",
        )
        # Simulation headers & modules
        self.create_instance(
            "axi_ram",
            "ram",
        )
        self.create_instance(
            "iob_tasks",
            "tasks",
        )
        # Software modules
        self.create_instance(
            "printf",
            "printf_inst",
        )
        # Modules required for CACHE
        self.create_instance(
            "iob_ram_2p",
            "ram_2p",
        )
        self.create_instance(
            "iob_ram_sp",
            "ram_sp",
        )
        # FPGA modules
        self.create_instance(
            "iob_reset_sync",
            "reset_sync",
        )

        # Peripherals
        # self.peripherals = [UART0, TIMER0]

        # Number of external memory connections (will be filled automatically)
        # self.num_extmem_connections = -1

        # Pre-setup specialized IOb-SoC functions
        pre_setup_iob_soc(self)
        # Call the superclass setup
        super().__init__(*args, **kwargs)
        # Post-setup specialized IOb-SoC functions
        post_setup_iob_soc(self)


if __name__ == "__main__":
    # Create an iob-soc ip core
    if "clean" in sys.argv:
        iob_soc.clean_build_dir()
    elif "print" in sys.argv:
        iob_soc.print_build_dir()
    else:
        iob_soc()
