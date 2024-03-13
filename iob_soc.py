#!/usr/bin/env python3

import sys

from iob_module import iob_module
from iob_block_group import iob_block_group
from iob_soc_utils import pre_setup_iob_soc, post_setup_iob_soc

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
from iob_split2 import iob_split2
from iob_merge2 import iob_merge2


class iob_soc(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.70"
        self.rw_overlap = True
        self.is_system = True
        self.board_list = ["CYCLONEV-GT-DK", "AES-KU040-DB-G"]
        cpu = iob_picorv32()
        uart = iob_uart()
        timer = iob_timer()
        merge = iob_merge()
        split = iob_split()
        self.submodule_list = [
            cpu,
            iob_cache(),
            uart,
            timer,
            iob_utils(),
            merge,
            split,
            iob_rom_sp(),
            iob_ram_dp_be(),
            iob_ram_dp_be_xil(),
            iob_pulse_gen(),
            iob_counter(),
            iob_reg(),
            iob_reg_re(),
            iob_ram_sp_be(),
            iob_ram_dp(),
            iob_reset_sync(),
            iob_ctls(),
            axi_interconnect(),
            # Simulation headers & modules
            (axi_ram(), {"purpose": "simulation"}),
            (iob_tasks(), {"purpose": "simulation"}),
            # Software modules
            printf(),
            # Modules required for CACHE
            (iob_ram_2p(), {"purpose": "simulation"}),
            (iob_ram_2p(), {"purpose": "fpga"}),
            (iob_ram_sp(), {"purpose": "simulation"}),
            (iob_ram_sp(), {"purpose": "fpga"}),
        ]
        self.confs = [
            # macros
            {
                "name": "INIT_MEM",
                "type": "M",
                "val": "INIT_MEM" in sys.argv,
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {
                "name": "USE_EXTMEM",
                "type": "M",
                "val": "USE_EXTMEM" in sys.argv,
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
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
        int_mem_i_io = {
            "name": "iob",
            "type": "slave",
            "file_prefix": "iob_soc_int_mem_i_",
            "port_prefix": "i_",
            "wire_prefix": "int_mem_i_",
            "param_prefix": "",
            "descr": "iob-soc internal memory instruction interface",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }
        int_mem_d_io = {
            "name": "iob",
            "type": "slave",
            "file_prefix": "iob_soc_int_mem_d_",
            "port_prefix": "d_",
            "wire_prefix": "int_mem_d_",
            "param_prefix": "",
            "descr": "iob-soc internal memory data interface",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }
        int_mem_d_io = {
            "name": "iob",
            "type": "slave",
            "file_prefix": "iob_soc_int_mem_d_",
            "port_prefix": "d_",
            "wire_prefix": "int_mem_d_",
            "param_prefix": "",
            "descr": "iob-soc internal memory data interface",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }
        int_mem_boot_ctr_io = {
            "name": "iob",
            "type": "master",
            "file_prefix": "iob_soc_int_mem_boot_ctr_",
            "port_prefix": "boot_ctr_",
            "wire_prefix": "boot_ctr_",
            "param_prefix": "",
            "descr": "iob-soc internal memory boot controler interface",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }
        int_mem_ram_d_io = {
            "name": "iob",
            "type": "master",
            "file_prefix": "iob_soc_int_mem_ram_d_",
            "port_prefix": "ram_d_",
            "wire_prefix": "ram_d_",
            "param_prefix": "",
            "descr": "iob-soc internal memory ram data interface",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }
        int_mem_ram_w_io = {
            "name": "iob",
            "type": "slave",
            "file_prefix": "iob_soc_int_mem_ram_w_",
            "port_prefix": "ram_w_",
            "wire_prefix": "ram_w_",
            "param_prefix": "",
            "descr": "iob-soc internal memory sram write interface",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }

        int_mem_ram_r_io = {
            "name": "iob",
            "type": "slave",
            "file_prefix": "iob_soc_int_mem_ram_r_",
            "port_prefix": "ram_r_",
            "wire_prefix": "ram_r_",
            "param_prefix": "",
            "descr": "iob-soc internal ram r bus",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }

        int_mem_ram_i_io = {
            "name": "iob",
            "type": "master",
            "file_prefix": "iob_soc_int_mem_ram_i_",
            "port_prefix": "ram_i_",
            "wire_prefix": "ram_i_",
            "param_prefix": "",
            "descr": "iob-soc internal ram i bus",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        }

        self.ios = [
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
                "wire_prefix": "",
                "port_prefix": "",
                "mult": "",  # Will be filled automatically
                "widths": {
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
                "descr": "Bus of AXI master interfaces for external memory. One interface for this system and others optionally for peripherals.",
                "if_defined": "USE_EXTMEM",
                "ports": [],
            },
            # iob_soc_int_mem.v
            int_mem_i_io,
            int_mem_d_io,
            int_mem_boot_ctr_io,
            int_mem_ram_d_io,
            int_mem_ram_w_io,
            int_mem_ram_r_io,
            int_mem_ram_i_io,
        ]
        self.submodule_list += [
            iob_split2(
                name_prefix="data_boot_ctr",
                data_w="DATA_W",
                addr_w="ADDR_W",
                split_ptr="B_BIT",
                input_io=int_mem_d_io,
                output_ios=[
                    int_mem_boot_ctr_io,
                    int_mem_ram_d_io,
                ],
            ),
            iob_merge2(
                name_prefix="ibus",
                data_w="DATA_W",
                addr_w="ADDR_W",
                input_ios=[
                    int_mem_ram_w_io,
                    int_mem_ram_r_io,
                ],
                output_io=int_mem_ram_i_io,
            ),
        ]

        # IOb-SoC has the following set of non standard attributes:
        self.peripherals = [
            uart.instance("UART0"),
            timer.instance("TIMER0"),
        ]  # List of peripherals
        self.peripheral_portmap = (
            [  # List of tuples, each tuple corresponds to a port map
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
        )
        # Number of external memory connections (will be filled automatically)
        self.num_extmem_connections = -1
        # This is a standard iob_module attribute, but needs to be defined after 'peripherals' because it depends on it
        self.block_groups = [
            iob_block_group(
                name="cpu", description="CPU module", blocks=[cpu.instance("cpu_0")]
            ),
            iob_block_group(
                name="bus_split",
                description="Split modules for buses",
                blocks=[
                    split.instance("ibus_split_0"),
                    split.instance("dbus_split_0"),
                    split.instance("int_dbus_split_0"),
                    split.instance("pbus_split_0"),
                ],
            ),
            iob_block_group(
                name="mem",
                description="Memory module",
                blocks=[merge.instance("iob_merge_0"), merge.instance("iob_merge_1")],
            ),
            iob_block_group(
                name="peripheral",
                description="Peripheral module",
                blocks=self.peripherals,
            ),
        ]

    def _setup(self, *args, is_top=True, **kwargs):
        self.is_top_module = is_top
        self.set_default_build_dir()
        # Pre-setup specialized IOb-SoC functions
        pre_setup_iob_soc(self)
        # Call the superclass _setup
        super()._setup(*args, is_top=is_top, **kwargs)
        # Post-setup specialized IOb-SoC functions
        post_setup_iob_soc(self)


if __name__ == "__main__":
    # Create an iob-soc ip core
    iob_soc_core = iob_soc()
    if "clean" in sys.argv:
        iob_soc_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_soc_core.print_build_dir()
    else:
        iob_soc_core._setup()
