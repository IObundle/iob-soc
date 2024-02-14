#!/usr/bin/env python3

import os
import sys

from iob_module import iob_module
from iob_block_group import iob_block_group
from iob_soc_utils import pre_setup_iob_soc, post_setup_iob_soc
from mk_configuration import update_define
from verilog_tools import inplace_change

# Submodules
from iob_picorv32 import iob_picorv32
from iob_cache import iob_cache
from iob_uart import iob_uart
from iob_timer import iob_timer
from iob_utils import iob_utils
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
from printf import printf
from iob_ctls import iob_ctls
from iob_ram_2p import iob_ram_2p
from iob_ram_sp import iob_ram_sp
from axi_interconnect import axi_interconnect


class iob_soc(iob_module):
    name = "iob_soc"
    version = "V0.70"
    setup_dir = os.path.dirname(__file__)
    rw_overlap = True
    is_system = True

    board_list = ["CYCLONEV-GT-DK", "AES-KU040-DB-G"]

    # IOb-SoC has the following list of non standard attributes:
    peripherals = None  # List with instances peripherals to include in system
    peripheral_portmap = None  # List of tuples, each tuple corresponds to a port map

    # Method that runs the setup process of this class
    @classmethod
    def _specific_setup(cls):
        cls._setup_portmap()
        cls._custom_setup()

    @classmethod
    def _generate_files(cls):
        """Setup this system using specialized iob-soc functions"""
        # Pre-setup specialized IOb-SoC functions
        num_extmem_connections = pre_setup_iob_soc(cls)
        # Remove `[0+:1]` part select in AXI connections of ext_mem0 in iob_soc.v template
        if num_extmem_connections == 1:
            inplace_change(
                os.path.join(cls.build_dir, "hardware/src", cls.name + ".v"),
                "[0+:1]",
                "",
            )
        # Generate hw, sw, doc files
        super()._generate_files()
        # Post-setup specialized IOb-SoC functions
        post_setup_iob_soc(cls, num_extmem_connections)

    @classmethod
    def _create_instances(cls):
        # Verilog modules instances if we have them in the setup list (they may not be in the list if a subclass decided to remove them).
        if iob_picorv32 in cls.submodule_list:
            cls.cpu = iob_picorv32("cpu_0")
        if iob_split in cls.submodule_list:
            cls.ibus_split = iob_split("ibus_split_0")
            cls.dbus_split = iob_split("dbus_split_0")
            cls.int_dbus_split = iob_split("int_dbus_split_0")
            cls.pbus_split = iob_split("pbus_split_0")
        if iob_merge in cls.submodule_list:
            cls.int_mem = iob_merge("iob_merge_0")
            cls.ext_mem = iob_merge("iob_merge_1")
        if iob_uart in cls.submodule_list:
            cls.peripherals.append(iob_uart("UART0"))
        if iob_timer in cls.submodule_list:
            cls.peripherals.append(iob_timer("TIMER0"))

    @classmethod
    def _create_submodules_list(cls, extra_submodules=[]):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_picorv32,
                iob_cache,
                iob_uart,
                iob_timer,
                # Hardware headers & modules
                {"interface": "iob_wire"},
                {"interface": "axi_wire"},
                {"interface": "axi_m_port"},
                {"interface": "axi_m_m_portmap"},
                {"interface": "axi_m_portmap"},
                iob_utils,
                {"interface": "clk_en_rst_s_s_portmap"},
                {"interface": "clk_en_rst_s_port"},
                iob_merge,
                iob_split,
                iob_rom_sp,
                iob_ram_dp_be,
                iob_ram_dp_be_xil,
                iob_pulse_gen,
                iob_counter,
                iob_reg,
                iob_reg_re,
                iob_ram_sp_be,
                iob_ram_dp,
                iob_reset_sync,
                iob_ctls,
                axi_interconnect,
                # Simulation headers & modules
                (axi_ram, {"purpose": "simulation"}),
                ({"interface": "axi_s_portmap"}, {"purpose": "simulation"}),
                (iob_tasks, {"purpose": "simulation"}),
                # Software modules
                printf,
                # Modules required for CACHE
                (iob_ram_2p, {"purpose": "simulation"}),
                (iob_ram_2p, {"purpose": "fpga"}),
                (iob_ram_sp, {"purpose": "simulation"}),
                (iob_ram_sp, {"purpose": "fpga"}),
            ]
            + extra_submodules
        )

    @classmethod
    def _setup_portmap(cls):
        cls.peripheral_portmap += [
            (
                {"corename": "UART0", "if_name": "rs232", "port": "txd_o", "bits": []},
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_txd_o",
                    "bits": [],
                },
            ),
            (
                {"corename": "UART0", "if_name": "rs232", "port": "rxd_i", "bits": []},
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_rxd_i",
                    "bits": [],
                },
            ),
            (
                {"corename": "UART0", "if_name": "rs232", "port": "cts_i", "bits": []},
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_cts_i",
                    "bits": [],
                },
            ),
            (
                {"corename": "UART0", "if_name": "rs232", "port": "rts_o", "bits": []},
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_rts_o",
                    "bits": [],
                },
            ),
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += [
            iob_block_group(name="cpu", description="CPU module", blocks=[cls.cpu]),
            iob_block_group(
                name="bus_split",
                description="Split modules for buses",
                blocks=[
                    cls.ibus_split,
                    cls.dbus_split,
                    cls.int_dbus_split,
                    cls.pbus_split,
                ],
            ),
            iob_block_group(
                name="mem",
                description="Memory module",
                blocks=[cls.int_mem, cls.ext_mem],
            ),
            iob_block_group(
                name="peripheral",
                description="Peripheral module",
                blocks=cls.peripherals,
            ),
        ]

    @classmethod
    def _setup_confs(cls, extra_confs=[]):
        # Append confs or override them if they exist
        super()._setup_confs(
            [
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
                    "name": "B",
                    "type": "M",
                    "val": "20",
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
                    "type": "F",
                    "val": "32",
                    "min": "1",
                    "max": "32",
                    "descr": "Address bus width",
                },
                {
                    "name": "DATA_W",
                    "type": "F",
                    "val": "32",
                    "min": "1",
                    "max": "32",
                    "descr": "Data bus width",
                },
                {
                    "name": "AXI_ID_W",
                    "type": "F",
                    "val": "0",
                    "min": "1",
                    "max": "32",
                    "descr": "AXI ID bus width",
                },
                {
                    "name": "AXI_ADDR_W",
                    "type": "F",
                    "val": "`IOB_SOC_MEM_ADDR_W",
                    "min": "1",
                    "max": "32",
                    "descr": "AXI address bus width",
                },
                {
                    "name": "AXI_DATA_W",
                    "type": "F",
                    "val": "`IOB_SOC_DATA_W",
                    "min": "1",
                    "max": "32",
                    "descr": "AXI data bus width",
                },
                {
                    "name": "AXI_LEN_W",
                    "type": "F",
                    "val": "4",
                    "min": "1",
                    "max": "4",
                    "descr": "AXI burst length width",
                },
                {
                    "name": "MEM_ADDR_OFFSET",
                    "type": "F",
                    "val": "0",
                    "min": "0",
                    "max": "NA",
                    "descr": "Offset of memory address",
                },
            ]
            + extra_confs
        )

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
                        "name": "cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock enable",
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
                        "n_bits": "1",
                        "descr": "CPU trap signal",
                    },
                ],
            },
            {
                "name": "extmem",
                "descr": "Bus of AXI master interfaces for external memory. One interface for this system and others optionally for peripherals.",
                "if_defined": "USE_EXTMEM",
                "ports": [],
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

    @classmethod
    def _init_attributes(cls):
        # Initialize empty lists for attributes (We can't initialize in the attribute declaration because it would cause every subclass to reference the same list)
        cls.peripherals = []
        cls.peripheral_portmap = []
