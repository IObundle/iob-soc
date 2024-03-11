#!/usr/bin/env python3

import sys
from dataclasses import dataclass

from iob_module import iob_module
from iob_soc_utils import pre_setup_iob_soc, post_setup_iob_soc

from iob_conf import iob_conf
from iob_port import iob_port, iob_interface
from iob_wire import iob_wire

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


@dataclass
class iob_soc(iob_module):
    version = "V0.70"
    rw_overlap = True
    is_system = True
    board_list = ["CYCLONEV-GT-DK", "AES-KU040-DB-G"]
    cpu = iob_picorv32()
    uart = iob_uart()
    timer = iob_timer()
    merge = iob_merge()
    split = iob_split()
    submodule_list = [
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
    confs: list = [
        # macros
        iob_conf(
            name="INIT_MEM",
            type="M",
            val="INIT_MEM" in sys.argv,
            min="0",
            max="1",
            descr="Enable MUL and DIV CPU instructions",
        ),
        iob_conf(
            name="USE_EXTMEM",
            type="M",
            val="USE_EXTMEM" in sys.argv,
            min="0",
            max="1",
            descr="Enable MUL and DIV CPU instructions",
        ),
        iob_conf(
            name="USE_MUL_DIV",
            type="M",
            val="1",
            min="0",
            max="1",
            descr="Enable MUL and DIV CPU instructions",
        ),
        iob_conf(
            name="USE_COMPRESSED",
            type="M",
            val="1",
            min="0",
            max="1",
            descr="Use compressed CPU instructions",
        ),
        iob_conf(
            name="E",
            type="M",
            val="31",
            min="1",
            max="32",
            descr="Address selection bit for external memory",
        ),
        iob_conf(
            name="B",
            type="M",
            val="20",
            min="1",
            max="32",
            descr="Address selection bit for boot ROM",
        ),
        # parameters
        iob_conf(
            name="BOOTROM_ADDR_W",
            type="P",
            val="12",
            min="1",
            max="32",
            descr="Boot ROM address width",
        ),
        iob_conf(
            name="SRAM_ADDR_W",
            type="P",
            val="15",
            min="1",
            max="32",
            descr="SRAM address width",
        ),
        iob_conf(
            name="MEM_ADDR_W",
            type="P",
            val="24",
            min="1",
            max="32",
            descr="Memory bus address width",
        ),
        # mandatory parameters (do not change them!)
        iob_conf(
            name="ADDR_W",
            type="F",
            val="32",
            min="1",
            max="32",
            descr="Address bus width",
        ),
        iob_conf(
            name="DATA_W",
            type="F",
            val="32",
            min="1",
            max="32",
            descr="Data bus width",
        ),
        iob_conf(
            name="AXI_ID_W",
            type="F",
            val="0",
            min="1",
            max="32",
            descr="AXI ID bus width",
        ),
        iob_conf(
            name="AXI_ADDR_W",
            type="F",
            val="`IOB_SOC_MEM_ADDR_W",
            min="1",
            max="32",
            descr="AXI address bus width",
        ),
        iob_conf(
            name="AXI_DATA_W",
            type="F",
            val="`IOB_SOC_DATA_W",
            min="1",
            max="32",
            descr="AXI data bus width",
        ),
        iob_conf(
            name="AXI_LEN_W",
            type="F",
            val="4",
            min="1",
            max="4",
            descr="AXI burst length width",
        ),
        iob_conf(
            name="MEM_ADDR_OFFSET",
            type="F",
            val="0",
            min="0",
            max="NA",
            descr="Offset of memory address",
        ),
    ]
    ios = [
        iob_interface(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, enable, and reset",
            ports=[],
        ),
        iob_interface(
            name="trap",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="iob-soc trap signal",
            ports=[
                iob_port(
                    name="trap",
                    direction="output",
                    width=1,
                    descr="CPU trap signal",
                ),
            ],
        ),
        iob_interface(
            name="axi",
            type="master",
            wire_prefix="",
            port_prefix="",
            mult="",  # Will be filled automatically
            widths={
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
            descr="Bus of AXI master interfaces for external memory. One interface for this system and others optionally for peripherals.",
            if_defined="USE_EXTMEM",
            ports=[],
        ),
        iob_interface(
            name="rs232",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="iob-soc uart interface",
            ports=[
                iob_port(
                    name="txd",
                    direction="output",
                    width=1,
                    descr="UART transmit data",
                ),
                iob_port(
                    name="rxd",
                    direction="input",
                    width=1,
                    descr="UART receive data",
                ),
                iob_port(
                    name="rts",
                    direction="output",
                    width=1,
                    descr="UART request to send",
                ),
                iob_port(
                    name="cts",
                    direction="input",
                    width=1,
                    descr="UART clear to send",
                ),
            ],
        ),
    ]

    # IOb-SoC has the following set of non standard attributes:
    uart0 = uart.instance("UART0"),
    timer0 = timer.instance("TIMER0"),
    peripherals = [uart0, timer0]
    # Number of external memory connections (will be filled automatically)
    num_extmem_connections = -1
    # Instances for py2hw
    cpu_0 = cpu.instance("cpu_0")
    ibus_split_0 = split.instance("ibus_split_0")
    dbus_split_0 = split.instance("dbus_split_0")
    int_dbus_split_0 = split.instance("int_dbus_split_0")
    pbus_split_0 = split.instance("pbus_split_0")
    iob_merge_0 = merge.instance("iob_merge_0")
    iob_merge_1 = merge.instance("iob_merge_1")
    # This is a standard iob_module attribute, but needs to be defined after 'peripherals' because it depends on it
    blocks = [
        cpu_0,
        ibus_split_0,
        dbus_split_0,
        int_dbus_split_0,
        pbus_split_0,
        iob_merge_0,
        iob_merge_1,
    ] + peripherals

    def __post_init__(self, *args, is_top=True, **kwargs):
        # Create wires for UART
        txd = iob_wire(name='txd', width=1)
        rxd = iob_wire(name='rxd', width=1)
        cts = iob_wire(name='cts', width=1)
        rts = iob_wire(name='rts', width=1)

        # Connect UART wires
        self.uart0.ios.txd = txd
        self.uart0.ios.rxd = rxd
        self.uart0.ios.cts = cts
        self.uart0.ios.rts = rts

        # Connect iob-soc IOs to uart wires
        self.ios.txd = txd
        self.ios.rxd = rxd
        self.ios.cts = cts
        self.ios.rts = rts

        # TODO: Wires and connections of other compoents
        # ibus = iob_wire(name='ibus', width=32)
        # dbus = iob_wire(name='dbus', width=32)
        #
        # self.cpu_0.ios.ibus = ibus
        # self.cpu_0.ios.dbus = dbus
        #
        # self.ibus_split_0.ios.m_bus = ibus
        # self.ibus_split_0.ios.s_bus = [ext_mem_bus, int_mem_bus]
        #
        # ...

        self.is_top_module = is_top
        self.set_default_build_dir()
        # Pre-setup specialized IOb-SoC functions
        pre_setup_iob_soc(self)
        # Call the superclass setup
        super().__post_init__(*args, is_top=is_top, **kwargs)
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
        iob_soc_core()
