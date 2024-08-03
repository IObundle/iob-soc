import sys
import os

# Add iob-soc scripts folder to python path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "scripts"))

from iob_soc_utils import pre_setup_iob_soc, iob_soc_sw_setup


def setup(py_params_dict):
    INIT_MEM = py_params_dict["INIT_MEM"] if "INIT_MEM" in py_params_dict else False
    USE_EXTMEM = (
        py_params_dict["USE_EXTMEM"] if "USE_EXTMEM" in py_params_dict else False
    )
    USE_COMPRESSED = True
    USE_MUL_DIV = True
    USE_SPRAM = py_params_dict["USE_SPRAM"] if "USE_SPRAM" in py_params_dict else False

    # Number of peripherals + Bootctr
    N_SLAVES = 3 + 1

    attributes_dict = {
        "original_name": "iob_soc",
        "name": "iob_soc",
        "version": "0.7",
        "is_system": True,
        "board_list": ["CYCLONEV-GT-DK", "AES-KU040-DB-G"],
        "confs": [
            # macros
            {
                "name": "INIT_MEM",
                "type": "M",
                "val": INIT_MEM,
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {
                "name": "USE_EXTMEM",
                "type": "M",
                "val": USE_EXTMEM,
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {
                "name": "USE_MUL_DIV",
                "type": "M",
                "val": USE_MUL_DIV,
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {
                "name": "USE_COMPRESSED",
                "type": "M",
                "val": USE_COMPRESSED,
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
                "name": "PREBOOTROM_ADDR_W",
                "type": "P",
                "val": "8",
                "min": "1",
                "max": "32",
                "descr": "Preboot ROM address width",
            },
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
            # Needed for testbench
            {
                "name": "RST_POL",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Reset polarity.",
            },
        ],
    }
    attributes_dict["ports"] = [
        {
            "name": "clk_en_rst",
            "interface": {
                "type": "clk_en_rst",
                "subtype": "slave",
            },
            "descr": "Clock, clock enable and reset",
        },
        {
            "name": "cpu_trap",
            "descr": "CPU trap output",
            "signals": [
                {
                    "name": "trap",
                    "direction": "output",
                    "width": "1",
                },
            ],
        },
        # Internal memory ports for Memory Wrapper
        {
            "name": "rom_bus",
            "descr": "Ports for connection with ROM memory",
            "signals": [
                {
                    "name": "rom_r_valid",
                    "direction": "output",
                    "width": "1",
                },
                {
                    "name": "rom_r_addr",
                    "direction": "output",
                    "width": "BOOTROM_ADDR_W-2",
                },
                {
                    "name": "rom_r_rdata",
                    "direction": "input",
                    "width": "DATA_W",
                },
            ],
        },
    ]
    if USE_SPRAM:
        attributes_dict["ports"] += [
            {
                "name": "spram_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "spram_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
        ]
    else:  # Not USE_SPRAM
        attributes_dict["ports"] += [
            {
                "name": "sram_i_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "sram_i_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
            {
                "name": "sram_d_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "sram_d_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
        ]
    attributes_dict["ports"] += [
        # Peripheral IO ports
        {
            "name": "rs232",
            "interface": {
                "type": "rs232",
            },
            "descr": "iob-soc uart interface",
        },
    ]
    if USE_EXTMEM:
        attributes_dict["ports"] += [
            {
                "name": "axi",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
                "descr": "AXI master interface for external memory",
            },
            # TODO: Add axi interfaces automatically for peripherals with DMA
        ]

    attributes_dict["wires"] = [
        # CPU interface wires
        {
            "name": "cpu_clk_en_rst",
            "descr": "",
            "signals": [
                {"name": "clk"},
                {"name": "cke"},
                {"name": "cpu_reset", "width": "1"},
            ],
        },
        {
            "name": "cpu_general",
            "descr": "",
            "signals": [
                {"name": "boot", "width": "1"},
                {"name": "trap"},
            ],
        },
        {
            "name": "cpu_i",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_cpu_i_",
                "wire_prefix": "cpu_i_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "cpu instruction bus",
        },
        {
            "name": "cpu_d",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_cpu_d_",
                "wire_prefix": "cpu_d_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "cpu data bus",
        },
        {
            "name": "split_reset",
            "descr": "Reset signal for iob_split components",
            "signals": [
                {"name": "cpu_reset"},
            ],
        },
        # Internal memory wires
        {
            "name": "int_mem_i",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_int_mem_i_",
                "wire_prefix": "int_mem_i_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "iob-soc internal memory instruction interface",
        },
        {
            "name": "int_mem_general",
            "descr": "General signals for internal memory",
            "signals": [
                {"name": "boot"},
                {"name": "cpu_reset"},
            ],
        },
    ]
    if USE_EXTMEM:
        attributes_dict["wires"] += [
            {
                "name": "int_d",
                "interface": {
                    "type": "iob",
                    "file_prefix": "iob_soc_int_d_",
                    "wire_prefix": "int_d_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "iob-soc internal data interface",
            },
        ]
    attributes_dict["wires"] += [
        {
            "name": "int_mem_d",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_int_mem_d_",
                "wire_prefix": "int_mem_d_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "iob-soc internal memory data interface",
        },
    ]
    if USE_EXTMEM:
        attributes_dict["wires"] += [
            # External memory wires
            {
                "name": "ext_mem_i",
                "interface": {
                    "type": "iob",
                    "file_prefix": "iob_soc_ext_mem_i_",
                    "wire_prefix": "ext_mem_i_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "iob-soc external memory instruction interface",
            },
            {
                "name": "ext_mem_d",
                "interface": {
                    "type": "iob",
                    "file_prefix": "iob_soc_ext_mem_d_",
                    "wire_prefix": "ext_mem_d_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "iob-soc external memory data interface",
            },
            {
                "name": "ext_mem_clk_en_rst",
                "descr": "",
                "signals": [
                    {"name": "clk"},
                    {"name": "cke"},
                    {"name": "cpu_reset", "width": "1"},
                ],
            },
            # Verilog Snippets for other modules
        ]
    # Boot
    attributes_dict["wires"] += [
        {
            "name": "bootctr_i",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_int_i_",
                "wire_prefix": "bootctr_i_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "iob-soc internal data interface",
        },
    ]
    attributes_dict["wires"] += [
        # Split (for other modules?)
        {
            "name": "int_d_dbus_split",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_int_d_dbus_",
                "wire_prefix": "int_d_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "iob-soc internal data interface",
        },
        # Peripheral wires
        {
            "name": "uart_swreg",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_uart_swreg_",
                "wire_prefix": "uart_swreg_",
                "DATA_W": "DATA_W",
                # TODO: How to trim ADDR_W to match swreg addr width?
                "ADDR_W": "ADDR_W",
            },
            "descr": "UART swreg bus",
        },
        {
            "name": "timer_swreg",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_timer_swreg_",
                "wire_prefix": "timer_swreg_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "TIMER swreg bus",
        },
        {
            "name": "bootctr_swreg",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_bootctr_swreg_",
                "wire_prefix": "bootctr_swreg_",
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
            "descr": "BOOTCTR swreg bus",
        },
        # TODO: Auto add peripheral wires
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_picorv32",
            "instance_name": "cpu",
            "parameters": {
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
                "USE_COMPRESSED": int(USE_COMPRESSED),
                "USE_MUL_DIV": int(USE_MUL_DIV),
                "USE_EXTMEM": int(USE_EXTMEM),
            },
            "connect": {
                "clk_en_rst": "cpu_clk_en_rst",
                "general": "cpu_general",
                "i_bus": "cpu_i",
                "d_bus": "cpu_d",
            },
        },
    ]
    if USE_EXTMEM:
        attributes_dict["blocks"] += [
            {
                "core_name": "iob_split",
                "name": "iob_ibus_split",
                "instance_name": "iob_ibus_split",
                "parameters": {
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                    "SPLIT_PTR": "ADDR_W-1",
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "reset": "split_reset",
                    "input": "cpu_i",
                    "output_0": "int_mem_i",
                    "output_1": "ext_mem_i",
                },
                "num_outputs": 2,
            },
            {
                "core_name": "iob_split",
                "name": "iob_dbus_split",
                "instance_name": "iob_dbus_split",
                "parameters": {
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                    "SPLIT_PTR": "ADDR_W-1",
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "reset": "split_reset",
                    "input": "cpu_d",
                    "output_0": "int_d",
                    "output_1": "ext_mem_d",
                },
                "num_outputs": 2,
            },
        ]
    attributes_dict["blocks"] += [
        {
            "core_name": "iob_soc_int_mem",
            "instance_name": "int_mem",
            "parameters": {
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
                "HEXFILE": '"iob_soc_firmware"',
                "BOOT_HEXFILE": '"iob_soc_boot"',
                "SRAM_ADDR_W": "SRAM_ADDR_W",
                "BOOTROM_ADDR_W": "BOOTROM_ADDR_W",
                "B_BIT": "`IOB_SOC_B",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "general": "int_mem_general",
                "i_bus": "int_mem_i" if USE_EXTMEM else "bootctr_i",
                "d_bus": "int_mem_d",
                "rom_bus": "rom_bus",
            },
            "USE_SPRAM": int(USE_SPRAM),
            "USE_EXTMEM": int(USE_EXTMEM),
            "INIT_MEM": int(INIT_MEM),
        },
    ]
    if USE_SPRAM:
        attributes_dict["blocks"][-1]["connect"].update(
            {
                "spram_bus": "spram_bus",
            }
        )
    else:  # Not USE_SPRAM
        attributes_dict["blocks"][-1]["connect"].update(
            {
                "sram_i_bus": "sram_i_bus",
                "sram_d_bus": "sram_d_bus",
            }
        )
    if USE_EXTMEM:
        attributes_dict["blocks"] += [
            {
                "core_name": "iob_soc_ext_mem",
                "instance_name": "ext_mem",
                "parameters": {
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                    "FIRM_ADDR_W": "MEM_ADDR_W",
                    "MEM_ADDR_W ": "MEM_ADDR_W",
                    "DDR_ADDR_W ": "`DDR_ADDR_W",
                    "DDR_DATA_W ": "`DDR_DATA_W",
                    "AXI_ID_W   ": "AXI_ID_W",
                    "AXI_LEN_W  ": "AXI_LEN_W",
                    "AXI_ADDR_W ": "AXI_ADDR_W",
                    "AXI_DATA_W ": "AXI_DATA_W",
                },
                "connect": {
                    "clk_en_rst": "ext_mem_clk_en_rst",
                    "i_bus": "ext_mem_i",
                    "d_bus": "ext_mem_d",
                    "axi": "axi",
                },
            },
        ]
    attributes_dict["blocks"] += [
        {
            "core_name": "iob_split",
            "name": "iob_pbus_split",
            "instance_name": "iob_pbus_split",
            "parameters": {
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
                "SPLIT_PTR": "ADDR_W-2",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "split_reset",
                "input": "int_d" if USE_EXTMEM else "cpu_d",
                "output_0": "int_mem_d",
                "output_1": "uart_swreg",
                "output_2": "timer_swreg",
                "output_3": "bootctr_swreg",
                # TODO: Connect peripherals automatically
            },
            "num_outputs": N_SLAVES,
        },
    ]
    peripherals = [
        # Peripherals
        {
            "core_name": "iob_uart",
            "instance_name": "UART0",
            "parameters": {},
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "uart_swreg",
                "rs232": "rs232",
            },
        },
        {
            "core_name": "iob_timer",
            "instance_name": "TIMER0",
            "parameters": {},
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "timer_swreg",
            },
        },
        {
            "core_name": "iob_bootctr",
            "instance_name": "BOOTCTR0",
            "parameters": {},
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "bootctr_swreg",
                "cpu_i_bus": "cpu_i",
                "bootctr_i_bus": "bootctr_i",
                "int_mem_i_bus": "int_mem_i",
            },
        },
    ]
    attributes_dict["blocks"] += peripherals + [
        # Modules that need to be setup, but are not instantiated directly inside
        # 'iob_soc' Verilog module
        {
            "core_name": "iob_cache",
            "instance_name": "iob_cache_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_rom_sp",
            "instance_name": "iob_rom_sp_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_ram_dp_be",
            "instance_name": "iob_ram_dp_be_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_ram_dp_be_xil",
            "instance_name": "iob_ram_dp_be_xil_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_pulse_gen",
            "instance_name": "iob_pulse_gen_inst",
            "instantiate": False,
        },
        # iob_counter("counter")
        {
            "core_name": "iob_reg",
            "instance_name": "iob_reg_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_reg_re",
            "instance_name": "iob_reg_re_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_ram_sp_be",
            "instance_name": "iob_ram_sp_be_inst",
            "instantiate": False,
        },
        # iob_ram_dp("ram_dp")
        # iob_ctls("ctls")
        {
            "core_name": "axi_interconnect",
            "instance_name": "axi_interconnect_inst",
            "instantiate": False,
        },
        # Simulation headers & modules
        {
            "core_name": "iob_tasks",
            "instance_name": "iob_tasks_inst",
            "instantiate": False,
            "purpose": "simulation",
        },
        # FPGA modules
        {
            "core_name": "iob_reset_sync",
            "instance_name": "iob_reset_sync_inst",
            "instantiate": False,
        },
        # Simulation wrapper
        {
            "core_name": "iob_soc_sim_wrapper",
            "instance_name": "iob_soc_sim_wrapper",
            "instantiate": False,
            "purpose": "simulation",
        },
    ]
    attributes_dict["sw_modules"] = [
        # Software modules
        {
            "core_name": "printf",
            "instance_name": "printf_inst",
        },
    ]

    # Pre-setup specialized IOb-SoC functions
    pre_setup_iob_soc(attributes_dict, peripherals)
    iob_soc_sw_setup(attributes_dict, peripherals)

    return attributes_dict
