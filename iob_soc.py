import sys
import os

# Add iob-soc scripts folder to python path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "scripts"))

from iob_soc_utils import update_params, iob_soc_scripts


def setup(py_params_dict):
    params = {
        "init_mem": False,
        "use_extmem": False,
        "use_ethernet": False,
        "addr_w": 32,
        "data_w": 32,
        "mem_addr_w": 24,
        "bootrom_addr_w": 12,
        "fw_addr": 0,
        "fw_addr_w": 15,
    }

    update_params(params, py_params_dict)

    # Number of peripherals
    num_peripherals = 3

    attributes_dict = {
        "original_name": "iob_soc",
        "name": "iob_soc",
        "version": "0.7",
        "is_system": True,
        "board_list": ["cyclonev_gt_dk", "aes_ku040_db_g"],
        "confs": [
            # macros
            {  # Needed for testbench
                "name": "ADDR_W",
                "descr": "Address bus width",
                "type": "M",
                "val": params["addr_w"],
                "min": "1",
                "max": "32",
            },
            {  # Needed for testbench
                "name": "DATA_W",
                "descr": "Data bus width",
                "type": "M",
                "val": params["data_w"],
                "min": "1",
                "max": "32",
            },
            {  # Needed for makefile and software
                "name": "INIT_MEM",
                "descr": "Enable MUL and DIV CPU instructions",
                "type": "M",
                "val": params["init_mem"],
                "min": "0",
                "max": "1",
            },
            {  # Needed for makefile and software
                "name": "USE_EXTMEM",
                "descr": "Enable MUL and DIV CPU instructions",
                "type": "M",
                "val": params["use_extmem"],
                "min": "0",
                "max": "1",
            },
            {  # Needed for software
                "name": "MEM_ADDR_W",
                "descr": "Memory bus address width",
                "type": "M",
                "val": params["mem_addr_w"],
                "min": "0",
                "max": "32",
            },
            {  # Needed for software
                "name": "FW_ADDR",
                "descr": "Firmware address",
                "type": "M",
                "val": params["fw_addr"],
                "min": "0",
                "max": "32",
            },
            {  # Needed for software
                "name": "FW_ADDR_W",
                "descr": "Firmware address",
                "type": "M",
                "val": params["fw_addr_w"],
                "min": "0",
                "max": "32",
            },
            {  # Needed for testbench
                "name": "RST_POL",
                "descr": "Reset polarity.",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
            },
            {  # Needed for software and makefiles
                "name": "BOOTROM_ADDR_W",
                "descr": "Bootloader ROM address width (byte addressable). Includes a pre-bootloader that uses the first 128 bytes. Bootloader starts at address 0x80 of this ROM.",
                "type": "M",
                "val": params["bootrom_addr_w"],
                "min": "1",
                "max": "32",
            },
            # mandatory parameters (do not change them!)
            {
                "name": "AXI_ID_W",
                "descr": "AXI ID bus width",
                "type": "F",
                "val": "0",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_ADDR_W",
                "descr": "AXI address bus width",
                "type": "F",
                "val": params["mem_addr_w"],
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_DATA_W",
                "descr": "AXI data bus width",
                "type": "F",
                "val": params["data_w"],
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_LEN_W",
                "descr": "AXI burst length width",
                "type": "F",
                "val": "4",
                "min": "1",
                "max": "4",
            },
        ],
    }
    attributes_dict["ports"] = [
        {
            "name": "clk_en_rst",
            "descr": "Clock, clock enable and reset",
            "interface": {
                "type": "clk_en_rst",
                "subtype": "slave",
            },
        },
        {
            "name": "rom_bus",
            "descr": "Ports for connection with ROM memory",
            "signals": [
                {
                    "name": "boot_rom_valid",
                    "direction": "output",
                    "width": "1",
                },
                {
                    "name": "boot_rom_addr",
                    "direction": "output",
                    "width": params["bootrom_addr_w"] - 2,
                },
                {
                    "name": "boot_rom_rdata",
                    "direction": "input",
                    "width": params["data_w"],
                },
            ],
        },
        # Peripheral IO ports
        {
            "name": "rs232",
            "descr": "iob-soc uart interface",
            "interface": {
                "type": "rs232",
            },
        },
        {
            "name": "axi",
            "descr": "AXI master interface for external memory",
            "interface": {
                "type": "axi",
                "subtype": "master",
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
                "LOCK_W": "AXI_LEN_W",
            },
        },
        # NOTE: Add ports for peripherals here
    ]

    attributes_dict["wires"] = [
        {
            "name": "clk",
            "descr": "Clock signal",
            "signals": [
                {"name": "clk"},
            ],
        },
        {
            "name": "rst",
            "descr": "Reset signal",
            "signals": [
                {"name": "arst"},
            ],
        },
        {
            "name": "cpu_ibus",
            "descr": "CPU instruction bus",
            "interface": {
                "type": "axi",
                "wire_prefix": "cpu_i_",
                "ID_W": "AXI_ID_W",
                "ADDR_W": params["addr_w"],
                "DATA_W": params["data_w"],
                "LEN_W": "AXI_LEN_W",
                "LOCK_W": "1",
            },
        },
        {
            "name": "cpu_dbus",
            "descr": "CPU data bus",
            "interface": {
                "type": "axi",
                "wire_prefix": "cpu_d_",
                "ID_W": "AXI_ID_W",
                "ADDR_W": params["addr_w"],
                "DATA_W": params["data_w"],
                "LEN_W": "AXI_LEN_W",
                "LOCK_W": "1",
            },
        },
        {
            "name": "periphs_axi",
            "descr": "AXI bus for peripheral CSRs",
            "interface": {
                "type": "axi",
                "wire_prefix": "periphs_",
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
        },
        {
            "name": "periphs_cbus",
            "descr": "Bus for peripherals Control/Status Register interfaces",
            "interface": {
                "type": "iob",
                "wire_prefix": "cpu_pbus_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 1,
            },
        },
        {
            "name": "split_reset",
            "descr": "Reset signal for iob_split components",
            "signals": [
                {"name": "arst"},
            ],
        },
        {
            "name": "bootrom_axi",
            "descr": "iob-soc boot controller data interface",
            "interface": {
                "type": "axi",
                "wire_prefix": "bootrom_",
                # "DATA_W": params["data_w"],
                # "ADDR_W": params["addr_w"] - 1,
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
        },
        {
            "name": "interrupts",
            "descr": "System interrupts",
            "signals": [
                {"name": "interrupts", "width": 32},
            ],
        },
        # Peripheral wires
        {
            "name": "clint_cbus",
            "descr": "CLINT Control/Status Registers bus",
            "interface": {
                "type": "axi",
                "wire_prefix": "clint_cbus_",
                # "DATA_W": params["data_w"],
                # "ADDR_W": params["addr_w"] - 3,
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
        },
        {
            "name": "plic_cbus",
            "descr": "PLIC Control/Status Registers bus",
            "interface": {
                "type": "axi",
                "wire_prefix": "plic_cbus_",
                # "DATA_W": params["data_w"],
                # "ADDR_W": params["addr_w"] - 3,
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
        },
        {
            "name": "uart_cbus",
            "descr": "UART Control/Status Registers bus",
            "interface": {
                "type": "iob",
                "wire_prefix": "uart_cbus_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 3,
            },
        },
        {
            "name": "timer_cbus",
            "descr": "TIMER Control/Status Registers bus",
            "interface": {
                "type": "iob",
                "wire_prefix": "timer_cbus_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 3,
            },
        },
        # NOTE: Add peripheral wires here
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_vexriscv",
            "instance_name": "cpu",
            "instance_description": "RISC-V CPU instance",
            "parameters": {
                "AXI_ID_W": "1",
                "AXI_ADDR_W": params["addr_w"],
                "AXI_DATA_W": params["data_w"],
                "AXI_LEN_W": "AXI_LEN_W",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "rst": "rst",
                "i_bus": "cpu_ibus",
                "d_bus": "cpu_dbus",
                "plic_interrupts": "interrupts",
                "plic_cbus": "plic_cbus",
                "clint_cbus": "clint_cbus",
            },
        },
        {
            "core_name": "axi_interconnect_wrapper",
            "instance_name": "axi_interconnect",
            "instance_description": "Interconnect instance",
            "parameters": {
                "AXI_ID_W": "AXI_ID_W",
                "AXI_ADDR_W": "AXI_ADDR_W",
                "AXI_DATA_W": "AXI_DATA_W",
            },
            "connect": {
                "clk": "clk",
                "rst": "rst",
                "s0_axi": "cpu_ibus",
                "s1_axi": "cpu_dbus",
                "m0_axi": "bootrom_axi",
                "m1_axi": "axi",
                "m2_axi": "periphs_axi",
                "m3_axi": "clint_cbus",
                "m4_axi": "plic_cbus",
            },
            "num_slaves": 2,
            "num_masters": 5,
            # FIXME: Size of each output
        },
        {
            "core_name": "axi2iob",
            "instance_name": "peripheral_axi2iob",
            "instance_description": "Convert AXI interface to IOb for peripheral CSRs bus",
            "parameters": {
                "ADDR_WIDTH": params["addr_w"] - 1,
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "axi": "periphs_axi",
                "iob": "periphs_cbus",
            },
        },
        {
            "core_name": "iob_split",
            "name": "iob_pbus_split",
            "instance_name": "iob_pbus_split",
            "instance_description": "Split between peripherals",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "split_reset",
                "input": "periphs_cbus",
                "output_0": "uart_cbus",
                "output_1": "timer_cbus",
                # NOTE: Connect other peripherals here
            },
            "num_outputs": num_peripherals - 1,  # Don't count bootloader
            "addr_w": params["addr_w"] - 2,  # FIXME:
        },
    ]
    peripherals = [
        {
            "core_name": "iob_uart",
            "instance_name": "UART0",
            "instance_description": "UART peripheral",
            "parameters": {},
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "cbus": "uart_cbus",
                "rs232": "rs232",
            },
        },
        {
            "core_name": "iob_timer",
            "instance_name": "TIMER0",
            "instance_description": "Timer peripheral",
            "parameters": {},
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "cbus": "timer_cbus",
            },
        },
        {
            "core_name": "iob_bootrom",
            "instance_name": "BOOTROM0",
            "instance_description": "Boot ROM peripheral",
            "parameters": {
                "AXI_ID_W": "AXI_ID_W",
                "AXI_ADDR_W": "AXI_ADDR_W",
                "AXI_DATA_W": "AXI_DATA_W",
                "AXI_LEN_W": "AXI_LEN_W",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "rom_bus": "bootrom_axi",
                "ext_rom_bus": "rom_bus",
            },
            "bootrom_addr_w": params["bootrom_addr_w"],
        },
        # NOTE: Instantiate other peripherals here
    ]
    attributes_dict["blocks"] += peripherals + [
        # Modules that need to be setup, but are not instantiated directly inside
        # 'iob_soc' Verilog module
        # Testbench
        {
            "core_name": "iob_tasks",
            "instance_name": "iob_tasks_inst",
            "instantiate": False,
            "dest_dir": "hardware/simulation/src",
        },
        # Simulation wrapper
        {
            "core_name": "iob_soc_sim_wrapper",
            "instance_name": "iob_soc_sim_wrapper",
            "instantiate": False,
            "dest_dir": "hardware/simulation/src",
            "iob_soc_params": params,
        },
        # FPGA wrappers
        {
            "core_name": "aes_ku040_db_g",
            "instance_name": "aes_ku040_db_g",
            "instantiate": False,
            "dest_dir": "hardware/fpga/vivado/aes_ku040_db_g",
            "iob_soc_params": params,
        },
        {
            "core_name": "cyclonev_gt_dk",
            "instance_name": "cyclonev_gt_dk",
            "instantiate": False,
            "dest_dir": "hardware/fpga/quartus/cyclonev_gt_dk",
            "iob_soc_params": params,
        },
    ]
    attributes_dict["sw_modules"] = [
        # Software modules
        {
            "core_name": "printf",
            "instance_name": "printf_inst",
        },
    ]
    attributes_dict["snippets"] = [
        {
            "verilog_code": """
   //assign interrupts = {{30{1'b0}}, uart_interrupt_o, 1'b0};
   assign interrupts = {{30{1'b0}}, 1'b0, 1'b0};
"""
        }
    ]

    iob_soc_scripts(attributes_dict, peripherals, params, py_params_dict)

    return attributes_dict
