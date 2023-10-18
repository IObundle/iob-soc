#!/usr/bin/env python3

import os
import sys

# Find python modules
if __name__ == "__main__":
    sys.path.append("./submodules/LIB/scripts")
    from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

from iob_block_group import iob_block_group
from iob_soc_utils import pre_setup_iob_soc, post_setup_iob_soc
from mk_configuration import update_define

# Submodules
from iob_picorv32 import iob_picorv32
from iob_cache import iob_cache
from iob_uart import iob_uart
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
from iob_str import iob_str
from printf import printf
from iob_ctls import iob_ctls
from iob_ram_2p import iob_ram_2p
from iob_ram_sp import iob_ram_sp
from axi_interconnect import axi_interconnect
import if_gen


class iob_soc(iob_module):
    name = "iob_soc"
    version = "V0.70"
    flows = "pc-emul emb sim doc fpga"
    setup_dir = os.path.dirname(__file__)

    # Configurable by subclasses
    cpu = iob_picorv32
    uart = iob_uart

    # IOb-SoC has the following list of non standard attributes:
    peripherals = None  # List with instances peripherals to include in system
    peripheral_portmap = None  # List of tuples, each tuple corresponds to a port map
    num_extmem_connections = None

    # Method that runs the setup process of this class
    # TODO: Check in other repositories if we really need the _pre_setup method. We may be able to remove it.
    @classmethod
    def _pre_setup(cls):
        # Add the following arguments:
        # "INIT_MEM=x": if should setup with init_mem or not
        # "USE_EXTMEM=x": if should setup with extmem or not
        for arg in sys.argv[1:]:
            if "INIT_MEM" in arg and arg.split("=")[1] == "1":
                update_define(cls.confs, "INIT_MEM", True)
            if "USE_EXTMEM" in arg and arg.split("=")[1] == "1":
                update_define(cls.confs, "USE_EXTMEM", True)
        # Pre-setup specialized IOb-SoC functions
        cls.num_extmem_connections = pre_setup_iob_soc(cls)
        # Update `axi` interface of `ios` dict with correct num_extmem_connections
        for table in cls.ios:
            if table["name"] == "axi":
                table["file_prefix"] = f"iob_bus_0_{cls.num_extmem_connections}_"
                table["mult"] = cls.num_extmem_connections
                break
        # Generate wires for tb
        if_gen.gen_if(
            "axi",  # Interface
            f"iob_bus_{cls.num_extmem_connections}_",  # file_prefix
            "",  # port_prefix
            "",  # wire_prefix
            [],  # ports
            cls.num_extmem_connections,  # mult (bus_size)
        )

    @classmethod
    def _post_setup(cls):
        post_setup_iob_soc(cls, cls.num_extmem_connections)

    @classmethod
    def _init_attributes(cls):
        # Initialize empty lists for attributes (We can't initialize in the attribute declaration because it would cause every subclass to reference the same list)
        cls.peripherals = []
        cls.peripheral_portmap = []

        cls.submodules = [
            # Hardware modules
            iob_utils,
            cls.cpu,
            iob_cache,
            cls.uart,
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
            (iob_ram_2p, {"purpose": "simulation"}),
            (iob_ram_2p, {"purpose": "fpga"}),
            (iob_ram_sp, {"purpose": "simulation"}),
            (iob_ram_sp, {"purpose": "fpga"}),
            {
                "interface": "axi",
                "file_prefix": "",
                "wire_prefix": "",
                "port_prefix": "",
            },
            {
                "interface": "axi",
                "file_prefix": "ddr4_",
                "wire_prefix": "ddr4_",
                "port_prefix": "ddr4_",
            },
            {
                "interface": "axi",
                "file_prefix": "iob_memory_",
                "wire_prefix": "memory_",
                "port_prefix": "",
            },
            # Simulation headers & modules
            (axi_ram, {"purpose": "simulation"}),
            (iob_tasks, {"purpose": "simulation"}),
            # Software modules
            iob_str,
            printf,
        ]

        cls.peripheral_portmap += [
            (
                {
                    "corename": "UART0",
                    "if_name": "rs232",
                    "port": "txd",
                    "bits": [],
                },
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_txd_o",
                    "bits": [],
                },
            ),
            (
                {
                    "corename": "UART0",
                    "if_name": "rs232",
                    "port": "rxd",
                    "bits": [],
                },
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_rxd_i",
                    "bits": [],
                },
            ),
            (
                {
                    "corename": "UART0",
                    "if_name": "rs232",
                    "port": "cts",
                    "bits": [],
                },
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_cts_i",
                    "bits": [],
                },
            ),
            (
                {
                    "corename": "UART0",
                    "if_name": "rs232",
                    "port": "rts",
                    "bits": [],
                },
                {
                    "corename": "external",
                    "if_name": "uart",
                    "port": "uart_rts_o",
                    "bits": [],
                },
            ),
        ]

        cls.peripherals.append(cls.uart("UART0"))

        cls.block_groups += [
            iob_block_group(
                name="cpu", description="CPU module", blocks=[cls.cpu("cpu_0")]
            ),
            iob_block_group(
                name="bus_split",
                description="Split modules for buses",
                blocks=[
                    iob_split("ibus_split_0"),
                    iob_split("dbus_split_0"),
                    iob_split("int_dbus_split_0"),
                    iob_split("pbus_split_0"),
                ],
            ),
            iob_block_group(
                name="mem",
                description="Memory module",
                blocks=[iob_merge("iob_merge_0"), iob_merge("iob_merge_1")],
            ),
            iob_block_group(
                name="peripheral",
                description="Peripheral module",
                blocks=cls.peripherals,
            ),
        ]

        cls.confs = [
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
            {
                "name": "MEM_ADDR_OFFSET",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Offset of memory address",
            },
        ]

        cls.ios += [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, enable, and reset",
                "ports": [],
            },
            {
                "name": "trap",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "iob-soc trap signal",
                "ports": [
                    {
                        "name": "trap",
                        "direction": "output",
                        "width": 1,
                        "descr": "CPU trap signal",
                    },
                ],
            },
            {
                "name": "axi",
                "type": "master",
                # "file_prefix": f"iob_bus_0_{cls.num_extmem_connections}_",
                "wire_prefix": "",
                "port_prefix": "",
                # "mult": cls.num_extmem_connections,
                "descr": "Bus of AXI master interfaces for external memory. One interface for this system and others optionally for peripherals.",
                "if_defined": "USE_EXTMEM",
                "ports": [],
            },
        ]


if __name__ == "__main__":
    iob_soc.setup_as_top_module()
