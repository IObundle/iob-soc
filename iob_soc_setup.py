#!/usr/bin/env python3

import os, sys

sys.path.insert(0, os.path.dirname(__file__) + "/scripts")
sys.path.insert(0, os.getcwd() + "/submodules/LIB/scripts")

import setup
from mk_configuration import update_define
import iob_soc

name = "iob_soc"
version = "V0.70"
flows = "pc-emul emb sim doc fpga"
if setup.is_top_module(sys.modules[__name__]):
    setup_dir = os.path.dirname(__file__)
    build_dir = f"../{name}_{version}"

submodules = {
    "hw_setup": {
        "headers": [
            "iob_wire",
            "axi_wire",
            "axi_m_m_portmap",
            "axi_m_port",
            "axi_m_m_portmap",
            "axi_m_portmap",
        ],
        "modules": [
            "PICORV32",
            "CACHE",
            "UART",
            "iob_merge",
            "iob_split",
            "iob_rom_sp.v",
            "iob_ram_dp_be.v",
            "iob_ram_dp_be_xil.v",
            "iob_pulse_gen.v",
            "iob_counter.v",
            "iob_ram_2p_asym.v",
            "iob_reg.v",
            "iob_reg_re.v",
            "iob_ram_sp_be.v",
            "iob_ram_dp.v",
            "iob_reset_sync",
        ],
    },
    "sim_setup": {
        "headers": ["axi_s_portmap", "iob_tasks.vh"],
        "modules": ["axi_ram.v"],
    },
    "sw_setup": {"headers": [], "modules": ["CACHE", "UART", "iob_str"]},
}

blocks = [
    {
        "name": "cpu",
        "descr": "CPU module",
        "blocks": [
            {"name": "cpu", "descr": "PicoRV32 CPU"},
        ],
    },
    {
        "name": "bus_split",
        "descr": "Split modules for buses",
        "blocks": [
            {
                "name": "ibus_split",
                "descr": "Split CPU instruction bus into internal and external memory buses",
            },
            {
                "name": "dbus_split",
                "descr": "Split CPU data bus into internal and external memory buses",
            },
            {
                "name": "int_dbus_split",
                "descr": "Split internal data bus into internal memory and peripheral buses",
            },
            {
                "name": "pbus_split",
                "descr": "Split peripheral bus into a bus for each peripheral",
            },
        ],
    },
    {
        "name": "memories",
        "descr": "Memory modules",
        "blocks": [
            {"name": "int_mem0", "descr": "Internal SRAM memory"},
            {"name": "ext_mem0", "descr": "External DDR memory"},
        ],
    },
    {
        "name": "peripherals",
        "descr": "peripheral modules",
        "blocks": [
            {
                "name": "UART0",
                "type": "UART",
                "descr": "Default UART interface",
                "params": {},
            },
        ],
    },
]

confs = [
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
]

regs = []

ios = [
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
            {"name": "trap_o", "type": "O", "n_bits": "1", "descr": "CPU trap signal"},
        ],
    },
    {
        "name": "axi_m_port",
        "descr": "General interface signals",
        "ports": [],
        "if_defined": "USE_EXTMEM",
    },
]

# Add IOb-SoC modules. These will copy and generate common files from the IOb-SoC repository.
iob_soc.add_iob_soc_modules(sys.modules[__name__])


def custom_setup():
    # Add the following arguments:
    # "INIT_MEM": if should setup with init_mem or not
    # "USE_EXTMEM": if should setup with extmem or not
    for arg in sys.argv[1:]:
        if arg == "INIT_MEM":
            update_define(confs, "INIT_MEM", True)
        if arg == "USE_EXTMEM":
            update_define(confs, "USE_EXTMEM", True)

    for conf in confs:
        if (conf["name"] == "USE_EXTMEM") and conf["val"]:
            submodules["hw_setup"]["headers"].append(
                {
                    "file_prefix": "ddr4_",
                    "interface": "axi_wire",
                    "wire_prefix": "ddr4_",
                    "port_prefix": "ddr4_",
                }
            )


# Main function to setup this system and its components
def main():
    custom_setup()
    # Setup this system
    setup.setup(sys.modules[__name__])


if __name__ == "__main__":
    main()
