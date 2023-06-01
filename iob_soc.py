#!/usr/bin/env python3

import os
import sys

from iob_module import iob_module
from iob_block_group import iob_block_group
from iob_soc_utils import setup_iob_soc

# Submodules
from iob_picorv32 import iob_picorv32
from iob_cache import iob_cache
from iob_uart import iob_uart
from iob_utils import iob_utils
from iob_clkenrst_portmap import iob_clkenrst_portmap
from iob_clkenrst_port import iob_clkenrst_port
from iob_merge import iob_merge
from iob_split import iob_split
from iob_rom_sp import iob_rom_sp
from iob_ram_dp_be import iob_ram_dp_be
from iob_ram_dp_be_xil import iob_ram_dp_be_xil
from iob_pulse_gen import iob_pulse_gen
from iob_counter import iob_counter
from iob_reg import iob_reg
from iob_reg_re import iob_reg_re
from iob_ram_sp_be import iob_ram_sp_be
from iob_ram_dp import iob_ram_dp
from iob_reset_sync import iob_reset_sync
from axi_ram import axi_ram
from iob_tasks import iob_tasks
from iob_str import iob_str
# Optional submodules
from axi_interconnect import axi_interconnect

class iob_soc(iob_module):
    name="iob_soc"
    version="V0.70"
    flows="pc-emul emb sim doc fpga"
    setup_dir=os.path.dirname(__file__)

    # IOb-SoC has the following list of non standard attributes:
    peripherals=[] # List with instances peripherals to include in system
    peripheral_portmap=[] # List of tuples, each tuple corresponds to a port map

    # Method that runs the setup process of this class
    @classmethod
    def _run_setup(cls):
        # Submodules
        iob_cache.setup()
        iob_uart.setup()

        # Hardware headers & modules
        iob_module.generate("iob_wire")
        iob_module.generate("axi_wire")
        iob_module.generate("axi_m_port")
        iob_module.generate("axi_m_m_portmap")
        iob_module.generate("axi_m_portmap")
        iob_utils.setup()
        iob_clkenrst_portmap.setup()
        iob_clkenrst_port.setup()

        iob_merge.setup()
        iob_split.setup()
        iob_rom_sp.setup()
        iob_ram_dp_be.setup()
        iob_ram_dp_be_xil.setup()
        iob_pulse_gen.setup()
        iob_counter.setup()
        iob_reg.setup()
        iob_reg_re.setup()
        iob_ram_sp_be.setup()
        iob_ram_dp.setup()
        iob_reset_sync.setup()

        # Simulation headers & modules
        axi_ram.setup(purpose="simulation")
        iob_module.generate("axi_s_portmap", purpose="simulation")
        iob_tasks.setup(purpose="simulation")

        # Software modules
        iob_str.setup(purpose="software")

        # Verilog modules instances
        cls.cpu = iob_picorv32.instance("cpu_0")
        cls.ibus_split = iob_split.instance("ibus_split_0")
        cls.dbus_split = iob_split.instance("dbus_split_0")
        cls.int_dbus_split = iob_split.instance("int_dbus_split_0")
        cls.pbus_split = iob_split.instance("pbus_split_0")
        cls.int_mem = iob_merge.instance("iob_merge_0")
        cls.ext_mem = iob_merge.instance("iob_merge_1")
        cls.peripherals.append(iob_uart.instance("iob_uart_0"))

        cls._setup_block_groups()
        cls._setup_confs()
        cls._setup_ios()

        cls.peripheral_portmap+=[
            (
                {"corename": "UART0", "if_name": "rs232", "port": "", "bits": []},
                {"corename": "external", "if_name": "UART", "port": "", "bits": []},
            ),  # Map UART0 of tester to external interface
        ],

        cls._custom_setup()
        # Setup this system using specialized iob-soc function
        setup_iob_soc(cls)


    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += [
            iob_block_group(
                name="cpu",
                description="CPU module",
                blocks=[cls.cpu]
            ),
            iob_block_group(
                name="bus_split",
                description="Split modules for buses",
                blocks=[cls.ibus_split, cls.dbus_split, cls.int_dbus_split, cls.pbus_split]
            ),
            iob_block_group(
                name="mem",
                description="Memory module",
                blocks=[cls.int_mem, cls.ext_mem]
            ),
            iob_block_group(
                name="peripheral",
                description="Peripheral module",
                blocks=cls.peripherals
            ),
        ]


    @classmethod
    def _setup_confs(cls):
        # Append confs or override them if they exist
        super()._setup_confs([
            # macros
            {
                "name": "USE_MUL_DIV",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {
                "name": "USE_COMPRESSED",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Use compressed CPU instructions",
            },
            {
                "name": "E",
                "type": "M",
                "val": "31",
                "min": "1",
                "max": "32",
                "descr": "Address selection bit for external memory",
            },
            {
                "name": "P",
                "type": "M",
                "val": "30",
                "min": "1",
                "max": "32",
                "descr": "Address selection bit for peripherals",
            },
            {
                "name": "B",
                "type": "M",
                "val": "29",
                "min": "1",
                "max": "32",
                "descr": "Address selection bit for boot ROM",
            },
            # parameters
            {
                "name": "BOOTROM_ADDR_W",
                "type": "P",
                "val": "12",
                "min": "1",
                "max": "32",
                "descr": "Boot ROM address width",
            },
            {
                "name": "SRAM_ADDR_W",
                "type": "P",
                "val": "15",
                "min": "1",
                "max": "32",
                "descr": "SRAM address width",
            },
            {
                "name": "MEM_ADDR_W",
                "type": "P",
                "val": "24",
                "min": "1",
                "max": "32",
                "descr": "Memory bus address width",
            },
            # mandatory parameters (do not change them!)
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "32",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "32",
                "descr": "Data bus width",
            },
            {
                "name": "AXI_ID_W",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "32",
                "descr": "AXI ID bus width",
            },
            {
                "name": "AXI_ADDR_W",
                "type": "P",
                "val": "`IOB_SOC_MEM_ADDR_W",
                "min": "1",
                "max": "32",
                "descr": "AXI address bus width",
            },
            {
                "name": "AXI_DATA_W",
                "type": "P",
                "val": "`IOB_SOC_DATA_W",
                "min": "1",
                "max": "32",
                "descr": "AXI data bus width",
            },
            {
                "name": "AXI_LEN_W",
                "type": "P",
                "val": "4",
                "min": "1",
                "max": "4",
                "descr": "AXI burst length width",
            },
        ])

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {
                "name": "general",
                "descr": "General interface signals",
                "ports": [
                    {
                        "name": "clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock input",
                    },
                    {
                        "name": "arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System reset, synchronous and active high",
                    },
                    {
                        "name": "trap_o",
                        "type": "O",
                        "n_bits": "2",
                        "descr": "CPU trap signal (One for iob-soc and one optionally for SUT)",
                    },
                ],
            },
            {
                "name": "axi_m_custom_port",
                "descr": "Bus of AXI master interfaces. One for iob_soc, one optionally from SUT",
                "if_defined": "USE_EXTMEM",
                "ports": [
                    {
                        "name": "axi_awid_o",
                        "type": "O",
                        "n_bits": "2*AXI_ID_W",
                        "descr": "Address write channel ID",
                    },
                    {
                        "name": "axi_awaddr_o",
                        "type": "O",
                        "n_bits": "2*AXI_ADDR_W",
                        "descr": "Address write channel address",
                    },
                    {
                        "name": "axi_awlen_o",
                        "type": "O",
                        "n_bits": "2*8",
                        "descr": "Address write channel burst length",
                    },
                    {
                        "name": "axi_awsize_o",
                        "type": "O",
                        "n_bits": "2*3",
                        "descr": "Address write channel burst size. This signal indicates the size of each transfer in the burst",
                    },
                    {
                        "name": "axi_awburst_o",
                        "type": "O",
                        "n_bits": "2*2",
                        "descr": "Address write channel burst type",
                    },
                    {
                        "name": "axi_awlock_o",
                        "type": "O",
                        "n_bits": "2*2",
                        "descr": "Address write channel lock type",
                    },
                    {
                        "name": "axi_awcache_o",
                        "type": "O",
                        "n_bits": "2*4",
                        "descr": "Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).",
                    },
                    {
                        "name": "axi_awprot_o",
                        "type": "O",
                        "n_bits": "2*3",
                        "descr": "Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).",
                    },
                    {
                        "name": "axi_awqos_o",
                        "type": "O",
                        "n_bits": "2*4",
                        "descr": "Address write channel quality of service",
                    },
                    {
                        "name": "axi_awvalid_o",
                        "type": "O",
                        "n_bits": "2*1",
                        "descr": "Address write channel valid",
                    },
                    {
                        "name": "axi_awready_i",
                        "type": "I",
                        "n_bits": "2*1",
                        "descr": "Address write channel ready",
                    },
                    {
                        "name": "axi_wdata_o",
                        "type": "O",
                        "n_bits": "2*AXI_DATA_W",
                        "descr": "Write channel data",
                    },
                    {
                        "name": "axi_wstrb_o",
                        "type": "O",
                        "n_bits": "2*(AXI_DATA_W/8)",
                        "descr": "Write channel write strobe",
                    },
                    {
                        "name": "axi_wlast_o",
                        "type": "O",
                        "n_bits": "2*1",
                        "descr": "Write channel last word flag",
                    },
                    {
                        "name": "axi_wvalid_o",
                        "type": "O",
                        "n_bits": "2*1",
                        "descr": "Write channel valid",
                    },
                    {
                        "name": "axi_wready_i",
                        "type": "I",
                        "n_bits": "2*1",
                        "descr": "Write channel ready",
                    },
                    {
                        "name": "axi_bid_i",
                        "type": "I",
                        "n_bits": "2*AXI_ID_W",
                        "descr": "Write response channel ID",
                    },
                    {
                        "name": "axi_bresp_i",
                        "type": "I",
                        "n_bits": "2*2",
                        "descr": "Write response channel response",
                    },
                    {
                        "name": "axi_bvalid_i",
                        "type": "I",
                        "n_bits": "2*1",
                        "descr": "Write response channel valid",
                    },
                    {
                        "name": "axi_bready_o",
                        "type": "O",
                        "n_bits": "2*1",
                        "descr": "Write response channel ready",
                    },
                    {
                        "name": "axi_arid_o",
                        "type": "O",
                        "n_bits": "2*AXI_ID_W",
                        "descr": "Address read channel ID",
                    },
                    {
                        "name": "axi_araddr_o",
                        "type": "O",
                        "n_bits": "2*AXI_ADDR_W",
                        "descr": "Address read channel address",
                    },
                    {
                        "name": "axi_arlen_o",
                        "type": "O",
                        "n_bits": "2*8",
                        "descr": "Address read channel burst length",
                    },
                    {
                        "name": "axi_arsize_o",
                        "type": "O",
                        "n_bits": "2*3",
                        "descr": "Address read channel burst size. This signal indicates the size of each transfer in the burst",
                    },
                    {
                        "name": "axi_arburst_o",
                        "type": "O",
                        "n_bits": "2*2",
                        "descr": "Address read channel burst type",
                    },
                    {
                        "name": "axi_arlock_o",
                        "type": "O",
                        "n_bits": "2*2",
                        "descr": "Address read channel lock type",
                    },
                    {
                        "name": "axi_arcache_o",
                        "type": "O",
                        "n_bits": "2*4",
                        "descr": "Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).",
                    },
                    {
                        "name": "axi_arprot_o",
                        "type": "O",
                        "n_bits": "2*3",
                        "descr": "Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).",
                    },
                    {
                        "name": "axi_arqos_o",
                        "type": "O",
                        "n_bits": "2*4",
                        "descr": "Address read channel quality of service",
                    },
                    {
                        "name": "axi_arvalid_o",
                        "type": "O",
                        "n_bits": "2*1",
                        "descr": "Address read channel valid",
                    },
                    {
                        "name": "axi_arready_i",
                        "type": "I",
                        "n_bits": "2*1",
                        "descr": "Address read channel ready",
                    },
                    {
                        "name": "axi_rid_i",
                        "type": "I",
                        "n_bits": "2*AXI_ID_W",
                        "descr": "Read channel ID",
                    },
                    {
                        "name": "axi_rdata_i",
                        "type": "I",
                        "n_bits": "2*AXI_DATA_W",
                        "descr": "Read channel data",
                    },
                    {
                        "name": "axi_rresp_i",
                        "type": "I",
                        "n_bits": "2*2",
                        "descr": "Read channel response",
                    },
                    {
                        "name": "axi_rlast_i",
                        "type": "I",
                        "n_bits": "2*1",
                        "descr": "Read channel last word",
                    },
                    {
                        "name": "axi_rvalid_i",
                        "type": "I",
                        "n_bits": "2*1",
                        "descr": "Read channel valid",
                    },
                    {
                        "name": "axi_rready_o",
                        "type": "O",
                        "n_bits": "2*1",
                        "descr": "Read channel ready",
                    },
                ],
            },
        ]


    @classmethod
    def _custom_setup(cls):
        # Add the following arguments:
        # "INIT_MEM": if should setup with init_mem or not
        # "USE_EXTMEM": if should setup with extmem or not
        for arg in sys.argv[1:]:
            if arg == "INIT_MEM":
                update_define(cls.confs, "INIT_MEM", True)
            if arg == "USE_EXTMEM":
                update_define(cls.confs, "USE_EXTMEM", True)

        for conf in cls.confs:
            if (conf["name"] == "USE_EXTMEM") and conf["val"]:
                iob_module.generate(
                    {
                        "file_prefix": "ddr4_",
                        "interface": "axi_wire",
                        "wire_prefix": "ddr4_",
                        "port_prefix": "ddr4_",
                    }
                )
                axi_interconnect.setup()
                iob_module.generate(
                    {
                        "file_prefix": "iob_bus_0_2_",
                        "interface": "axi_m_portmap",
                        "wire_prefix": "",
                        "port_prefix": "",
                        "bus_start": 0,
                        "bus_size": 2,
                    })
                iob_module.generate(
                    {
                        "file_prefix": "iob_bus_2_3_",
                        "interface": "axi_s_portmap",
                        "wire_prefix": "",
                        "port_prefix": "",
                        "bus_start": 2,
                        "bus_size": 1,
                    })
                iob_module.generate(
                    # Can't use portmaps below, because it creates axi_awlock and axi_arlock with 2 bits instead of 1 (these are used for axi_interconnect)
                    # { 'file_prefix':'iob_bus_0_2_s_', 'interface':'axi_portmap', 'wire_prefix':'', 'port_prefix':'s_', 'bus_start':0, 'bus_size':2 },
                    # { 'file_prefix':'iob_bus_2_3_m_', 'interface':'axi_portmap', 'wire_prefix':'', 'port_prefix':'m_', 'bus_start':2, 'bus_size':1 },
                    {
                        "file_prefix": "iob_bus_3_",
                        "interface": "axi_wire",
                        "wire_prefix": "",
                        "port_prefix": "",
                        "bus_size": 3,
                    })
                iob_module.generate(
                    {
                        "file_prefix": "iob_bus_2_",
                        "interface": "axi_wire",
                        "wire_prefix": "",
                        "port_prefix": "",
                        "bus_size": 2,
                    })
