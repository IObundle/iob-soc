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
    USE_COMPRESSED = 1
    USE_MUL_DIV = 1
    USE_SPRAM = py_params_dict["USE_SPRAM"] if "USE_SPRAM" in py_params_dict else False

    # Number of peripherals + Bootctr
    N_SLAVES = 2 + 1

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
                "subtype": "slave",
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
            "name": "cpu_clk_rst",
            "descr": "",
            "signals": [
                {"name": "clk"},
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
        # TODO: Auto add peripheral wires
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_picorv32",
            "instance_name": "cpu",
            "parameters": {
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
                "USE_COMPRESSED": USE_COMPRESSED,
                "USE_MUL_DIV": USE_MUL_DIV,
                "USE_EXTMEM": USE_EXTMEM,
            },
            "connect": {
                "clk_rst": "cpu_clk_rst",
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
                "i_bus": "int_mem_i" if USE_EXTMEM else "cpu_i",
                "d_bus": "int_mem_d",
                "rom_bus": "rom_bus",
            },
            "USE_SPRAM": USE_SPRAM,
            "USE_EXTMEM": USE_EXTMEM,
            "INIT_MEM": INIT_MEM,
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
            "parameters": {
                "DATA_W": "UART0_DATA_W",
                "ADDR_W": "UART0_ADDR_W",
                "UART_DATA_W": "UART0_UART_DATA_W",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "uart_swreg",
                "rs232": "rs232",
            },
        },
        {
            "core_name": "iob_timer",
            "instance_name": "TIMER0",
            "parameters": {
                "DATA_W": "TIMER0_DATA_W",
                "ADDR_W": "TIMER0_ADDR_W",
                "TIMER_DATA_W": "TIMER0_WDATA_W",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "timer_swreg",
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
            "core_name": "axi_ram",
            "instance_name": "axi_ram_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_tasks",
            "instance_name": "iob_tasks_inst",
            "instantiate": False,
        },
        # Modules required for CACHE
        {
            "core_name": "iob_ram_2p",
            "instance_name": "iob_ram_2p_inst",
            "instantiate": False,
        },
        {
            "core_name": "iob_ram_sp",
            "instance_name": "iob_ram_sp_inst",
            "instantiate": False,
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


#######################################
# OLD IOb-SoC modules, wires, and instances
#######################################

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

# ###########################################################################
# TODO: Update lines below with new connections from local wires.
#       Also remove `_i` and `_o` suffixes.
#       Also use the new 'create_*' methods.
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

# if USE_EXTMEM:
#    self.create_instance(
#        "iob_split",
#        "ibus_split",
#        parameters={
#            "ADDR_W": "ADDR_W",
#            "DATA_W": "DATA_W",
#            "N_SLAVES": "2",
#            "P_SLAVES": "REQ_W - 2",
#        },
#        # connect={
#        #     "clk_i": clk,
#        #     "arst_i": cpu_reset,
#        #     # master interface
#        #     "m_bus": cpu_i_bus,
#        #     # slaves interface
#        #     "s_bus": [ext_mem_i_bus, int_mem_i_bus],
#        # },
#    )
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

# if USE_EXTMEM:
#    self.create_instance(
#        "iob_split",
#        "dbus_split",
#        parameters={
#            "ADDR_W": "ADDR_W",
#            "DATA_W": "DATA_W",
#            "N_SLAVES": "2",  # E,{P,I}
#            "P_SLAVES": "REQ_W - 2",
#        },
#        # connect={
#        #     "clk_i": clk,
#        #     "arst_i": cpu_reset,
#        #     # master interface
#        #     "m_bus": cpu_d_bus,
#        #     # slaves interface
#        #     "s_bus": [ext_mem_d_bus, int_d_bus],
#        # },
#    )
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

# self.create_instance(
#    "iob_split",
#    "pbus_split",
#    parameters={
#        "ADDR_W": "ADDR_W",
#        "DATA_W": "DATA_W",
#        "N_SLAVES": N_SLAVES,
#        "P_SLAVES": "REQ_W - 3",
#    },
#    # connect={
#    #    "clk_i": clk,
#    #    "arst_i": cpu_reset,
#    #    # master interface
#    #    "m_bus": int_d_bus,
#    #    # slaves interface
#    #    "s_bus": slaves_bus,
#    # },
# )
#
#
# INTERNAL SRAM MEMORY
#

# self.create_instance(
#    "iob_soc_int_mem",
#    "int_mem",
#    parameters={
#        "ADDR_W": "ADDR_W",
#        "DATA_W": "DATA_W",
#        "HEXFILE": "iob_soc_firmware",
#        "BOOT_HEXFILE": "iob_soc_boot",
#        "SRAM_ADDR_W": "SRAM_ADDR_W",
#        "BOOTROM_ADDR_W": "BOOTROM_ADDR_W",
#        "B_BIT": "REQ_W - (ADDR_W-`IOB_SOC_B+1)",
#    },
#    # connect={
#    #     "clk_en_rst": clk_en_rst,
#    #     "boot": boot,
#    #     "cpu_reset": cpu_reset,
#    #     # instruction bus
#    #     "i_bus": int_mem_i_bus,
#    #     # data bus
#    #     "d_bus": slaves_bus.part_sel(0, REQ_W or RESP_W?),  # .part(<part index>, <part width>)
#    # },
# )

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

# if USE_EXTMEM:
#    self.create_instance(
#        "iob_soc_ext_mem",
#        "ext_mem",
#        parameters={
#            "ADDR_W": "ADDR_W",
#            "DATA_W": "DATA_W",
#            "FIRM_ADDR_W": "MEM_ADDR_W",
#            "MEM_ADDR_W": "MEM_ADDR_W",
#            "DDR_ADDR_W": "`DDR_ADDR_W",
#            "DDR_DATA_W": "`DDR_DATA_W",
#            "AXI_ID_W": "AXI_ID_W",
#            "AXI_LEN_W": "AXI_LEN_W",
#            "AXI_ADDR_W": "AXI_ADDR_W",
#            "AXI_DATA_W": "AXI_DATA_W",
#        },
#        # connect={
#        #     # instruction bus
#        #     "i_req_i": ext_mem0_i_req,
#        #     "i_resp_o": ext_mem_i_bus.wires.ext_mem_i_resp,
#        #     # data bus
#        #     "d_req_i": ext_mem0_d_req,
#        #     "d_resp_o": ext_mem_d_bus.wires.ext_mem_d_resp,
#        #     # AXI INTERFACE
#        #     # address write
#        #     "axi_awid_o": axi.wires.axi_awid_o.part_sel(0, AXI_ID_W),
#        #     "axi_awaddr_o": internal_axi_awaddr_o.part_sel(0, AXI_ADDR_W),
#        #     "axi_awlen_o": axi.wires.axi_awlen_o.part_sel(0, AXI_LEN_W),
#        #     "axi_awsize_o": axi.wires.axi_awsize_o.part_sel(0, 3),
#        #     "axi_awburst_o": axi.wires.axi_awburst_o.part_sel(0, 2),
#        #     "axi_awlock_o": axi.wires.axi_awlock_o.part_sel(0, 2),
#        #     "axi_awcache_o": axi.wires.axi_awcache_o.part_sel(0, 4),
#        #     "axi_awprot_o": axi.wires.axi_awprot_o.part_sel(0, 3),
#        #     "axi_awqos_o": axi.wires.axi_awqos_o.part_sel(0, 4),
#        #     "axi_awvalid_o": axi.wires.axi_awvalid_o.part_sel(0, 1),
#        #     "axi_awready_i": axi.wires.axi_awready_i.part_sel(0, 1),
#        #     # write
#        #     "axi_wdata_o": axi.wires.axi_wdata_o.part_sel(0, AXI_DATA_W),
#        #     "axi_wstrb_o": axi.wires.axi_wstrb_o.part_sel(0, (AXI_DATA_W/8)),
#        #     "axi_wlast_o": axi.wires.axi_wlast_o.part_sel(0, 1),
#        #     "axi_wvalid_o": axi.wires.axi_wvalid_o.part_sel(0, 1),
#        #     "axi_wready_i": axi.wires.axi_wready_i.part_sel(0, 1),
#        #     # write response
#        #     "axi_bid_i": axi.wires.axi_bid_i.part_sel(0, AXI_ID_W),
#        #     "axi_bresp_i": axi.wires.axi_bresp_i.part_sel(0, 2),
#        #     "axi_bvalid_i": axi.wires.axi_bvalid_i.part_sel(0, 1),
#        #     "axi_bready_o": axi.wires.axi_bready_o.part_sel(0, 1),
#        #     # address read
#        #     "axi_arid_o": axi.wires.axi_arid_o.part_sel(0, AXI_ID_W),
#        #     "axi_araddr_o": internal_axi_araddr_o.part_sel(0, AXI_ADDR_W),
#        #     "axi_arlen_o": axi.wires.axi_arlen_o.part_sel(0, AXI_LEN_W),
#        #     "axi_arsize_o": axi.wires.axi_arsize_o.part_sel(0, 3),
#        #     "axi_arburst_o": axi.wires.axi_arburst_o.part_sel(0, 2),
#        #     "axi_arlock_o": axi.wires.axi_arlock_o.part_sel(0, 2),
#        #     "axi_arcache_o": axi.wires.axi_arcache_o.part_sel(0, 4),
#        #     "axi_arprot_o": axi.wires.axi_arprot_o.part_sel(0, 3),
#        #     "axi_arqos_o": axi.wires.axi_arqos_o.part_sel(0, 4),
#        #     "axi_arvalid_o": axi.wires.axi_arvalid_o.part_sel(0, 1),
#        #     "axi_arready_i": axi.wires.axi_arready_i.part_sel(0, 1),
#        #     # read
#        #     "axi_rid_i": axi.wires.axi_rid_i.part_sel(0, AXI_ID_W),
#        #     "axi_rdata_i": axi.wires.axi_rdata_i.part_sel(0, AXI_DATA_W),
#        #     "axi_rresp_i": axi.wires.axi_rresp_i.part_sel(0, 2),
#        #     "axi_rlast_i": axi.wires.axi_rlast_i.part_sel(0, 1),
#        #     "axi_rvalid_i": axi.wires.axi_rvalid_i.part_sel(0, 1),
#        #     "axi_rready_o": axi.wires.axi_rready_o.part_sel(0, 1),
#        #     "clk_i": clk,
#        #     "cke_i": cke,
#        #     "arst_i": cpu_reset,
#        # },
#    )

# # TODO: find a way to replace this. We don't to connect a wire to another.
# # Either inject verilog, or use module
# axi.wires.axi_awaddr_o.part_sel(0, AXI_ADDR_W).connect_to = internal_axi_awaddr_o + MEM_ADDR_OFFSET
# axi.wires.axi_araddr_o.part_sel(0, AXI_ADDR_W).connect_to = internal_axi_araddr_o + MEM_ADDR_OFFSET

#
# PERIPHERALS
#

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
