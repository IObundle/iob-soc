import sys
import os

# Add iob-soc scripts folder to python path
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "scripts"))

from iob_soc_utils import pre_setup_iob_soc, iob_soc_sw_setup


def setup(py_params_dict):
    params = {
        "init_mem": False,
        "use_extmem": False,
        "use_spram": False,
        "use_ethernet": False,
        "addr_w": 32,
        "data_w": 32,
        "mem_addr_w": 24,
        "use_compressed": True,
        "use_mul_div": True,
    }

    # Update params with py_params_dict
    for name, default_val in params.items():
        if name not in py_params_dict:
            continue
        if type(default_val) == bool and py_params_dict[name] == "0":
            params[name] = False
        else:
            params[name] = type(default_val)(py_params_dict[name])

    # Number of peripherals
    N_SLAVES = 3

    attributes_dict = {
        "original_name": "iob_soc",
        "name": "iob_soc",
        "version": "0.7",
        "is_system": True,
        "board_list": ["CYCLONEV-GT-DK", "AES-KU040-DB-G"],
        "confs": [
            # macros
            {  # Needed for testbench
                "name": "ADDR_W",
                "type": "M",
                "val": params["addr_w"],
                "min": "1",
                "max": "32",
                "descr": "Address bus width",
            },
            {  # Needed for testbench
                "name": "DATA_W",
                "type": "M",
                "val": params["data_w"],
                "min": "1",
                "max": "32",
                "descr": "Data bus width",
            },
            {  # Needed for makefile and software
                "name": "INIT_MEM",
                "type": "M",
                "val": params["init_mem"],
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {  # Needed for makefile and software
                "name": "USE_EXTMEM",
                "type": "M",
                "val": params["use_extmem"],
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {  # Needed for makefile
                "name": "USE_MUL_DIV",
                "type": "M",
                "val": params["use_mul_div"],
                "min": "0",
                "max": "1",
                "descr": "Enable MUL and DIV CPU instructions",
            },
            {  # Needed for makefile
                "name": "USE_COMPRESSED",
                "type": "M",
                "val": params["use_compressed"],
                "min": "0",
                "max": "1",
                "descr": "Use compressed CPU instructions",
            },
            {  # Needed for software
                "name": "MEM_ADDR_W",
                "type": "M",
                "val": params["mem_addr_w"],
                "min": "0",
                "max": "32",
                "descr": "Memory bus address width",
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
            # mandatory parameters (do not change them!)
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
                "val": params["mem_addr_w"],
                "min": "1",
                "max": "32",
                "descr": "AXI address bus width",
            },
            {
                "name": "AXI_DATA_W",
                "type": "F",
                "val": params["data_w"],
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
                    "width": params["data_w"],
                },
            ],
        },
    ]
    if params["use_spram"]:
        attributes_dict["ports"] += [
            {
                "name": "spram_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "spram_",
                    "DATA_W": params["data_w"],
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
        ]
    else:  # Not params["use_spram"]
        attributes_dict["ports"] += [
            {
                "name": "sram_i_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "sram_i_",
                    "DATA_W": params["data_w"],
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
            {
                "name": "sram_d_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "sram_d_",
                    "DATA_W": params["data_w"],
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
    if params["use_extmem"]:
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
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"],
            },
            "descr": "cpu instruction bus",
        },
        {
            "name": "cpu_d",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_cpu_d_",
                "wire_prefix": "cpu_d_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"],
            },
            "descr": "cpu data bus",
        },
        {
            "name": "cpu_pbus",
            "interface": {
                "type": "iob",
                "wire_prefix": "cpu_pbus_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 2,
            },
            "descr": "cpu peripheral bus",
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
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 1,
            },
            "descr": "iob-soc internal memory instruction interface",
        },
        {
            "name": "int_mem_general",
            "descr": "General signals for internal memory",
            "signals": [
                {"name": "boot"},
                {"name": "int_mem_cpu_reset"},
            ],
        },
        {
            "name": "bootctr",
            "descr": "Boot controller interface",
            "signals": [
                {"name": "bootctr_cpu_reset", "width": "1"},
                {"name": "bootctr_ctr_reg", "width": "2"},
            ],
        },
    ]
    if params["use_extmem"]:
        attributes_dict["wires"] += [
            {
                "name": "int_d",
                "interface": {
                    "type": "iob",
                    "file_prefix": "iob_soc_int_d_",
                    "wire_prefix": "int_d_",
                    "DATA_W": params["data_w"],
                    "ADDR_W": params["addr_w"] - 1,
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
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 2,
            },
            "descr": "iob-soc internal memory data interface",
        },
    ]
    if params["use_extmem"]:
        attributes_dict["wires"] += [
            # External memory wires
            {
                "name": "ext_mem_i",
                "interface": {
                    "type": "iob",
                    "file_prefix": "iob_soc_ext_mem_i_",
                    "wire_prefix": "ext_mem_i_",
                    "DATA_W": params["data_w"],
                    "ADDR_W": params["addr_w"] - 1,
                },
                "descr": "iob-soc external memory instruction interface",
            },
            {
                "name": "ext_mem_d",
                "interface": {
                    "type": "iob",
                    "file_prefix": "iob_soc_ext_mem_d_",
                    "wire_prefix": "ext_mem_d_",
                    "DATA_W": params["data_w"],
                    "ADDR_W": params["addr_w"] - 1,
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
        {
            "name": "bootctr_i",
            "interface": {
                "type": "iob",
                "file_prefix": "bootctr_i_",
                "wire_prefix": "bootctr_i_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"],
            },
            "descr": "iob-soc internal data interface",
        },
    ]
    attributes_dict["wires"] += [
        # Peripheral wires
        {
            "name": "uart_swreg",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_uart_swreg_",
                "wire_prefix": "uart_swreg_",
                "DATA_W": params["data_w"],
                # TODO: How to trim ADDR_W to match swreg addr width?
                "ADDR_W": params["addr_w"] - 3,
            },
            "descr": "UART swreg bus",
        },
        {
            "name": "timer_swreg",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_timer_swreg_",
                "wire_prefix": "timer_swreg_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 3,
            },
            "descr": "TIMER swreg bus",
        },
        {
            "name": "bootctr_swreg",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_bootctr_swreg_",
                "wire_prefix": "bootctr_swreg_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"],
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
                "ADDR_W": params["addr_w"],
                "DATA_W": params["data_w"],
                "USE_COMPRESSED": int(params["use_compressed"]),
                "USE_MUL_DIV": int(params["use_mul_div"]),
                "USE_EXTMEM": int(params["use_extmem"]),
            },
            "connect": {
                "clk_en_rst": "cpu_clk_en_rst",
                "general": "cpu_general",
                "i_bus": "cpu_i",
                "d_bus": "cpu_d",
            },
        },
    ]
    if params["use_extmem"]:
        attributes_dict["blocks"] += [
            {
                "core_name": "iob_split",
                "name": "iob_ibus_split",
                "instance_name": "iob_ibus_split",
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "reset": "split_reset",
                    "input": "cpu_i",
                    "output_0": "int_mem_i",
                    "output_1": "ext_mem_i",
                },
                "num_outputs": 2,
                "addr_w": params["addr_w"],
            },
            {
                "core_name": "iob_split",
                "name": "iob_dbus_split",
                "instance_name": "iob_dbus_split",
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "reset": "split_reset",
                    "input": "cpu_d",
                    "output_0": "int_d",
                    "output_1": "ext_mem_d",
                },
                "num_outputs": 2,
                "addr_w": params["addr_w"],
            },
        ]
    attributes_dict["blocks"] += [
        {
            "core_name": "iob_soc_int_mem",
            "instance_name": "int_mem",
            "parameters": {
                "HEXFILE": '"iob_soc_firmware"',
                "BOOT_HEXFILE": '"iob_soc_boot"',
                "SRAM_ADDR_W": "SRAM_ADDR_W",
                "BOOTROM_ADDR_W": "BOOTROM_ADDR_W",
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "general": "int_mem_general",
                # FIXME: This below was not commented out
                "i_bus": "int_mem_i",  # if params["use_extmem"] else "cpu_i",
                "d_bus": "int_mem_d",
                "rom_bus": "rom_bus",
            },
            "USE_SPRAM": int(params["use_spram"]),
            "USE_EXTMEM": int(params["use_extmem"]),
            "INIT_MEM": int(params["init_mem"]),
            "addr_w": params["addr_w"] - 1,
            "data_w": params["data_w"],
        },
    ]
    if params["use_spram"]:
        attributes_dict["blocks"][-1]["connect"].update(
            {
                "spram_bus": "spram_bus",
            }
        )
    else:  # Not params["use_spram"]
        attributes_dict["blocks"][-1]["connect"].update(
            {
                "sram_i_bus": "sram_i_bus",
                "sram_d_bus": "sram_d_bus",
            }
        )
    if params["use_extmem"]:
        attributes_dict["blocks"] += [
            {
                "core_name": "iob_soc_ext_mem",
                "instance_name": "ext_mem",
                "parameters": {
                    "FIRM_ADDR_W": params["mem_addr_w"],
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
                "addr_w": params["addr_w"] - 1,
                "data_w": params["data_w"],
                "mem_addr_w": params["mem_addr_w"],
            },
        ]
    attributes_dict["blocks"] += [
        {
            "core_name": "iob_split",
            "name": "iob_intmem_split",
            "instance_name": "iob_intmem_split",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "split_reset",
                "input": "int_d" if params["use_extmem"] else "cpu_d",
                "output_0": "int_mem_d",
                "output_1": "cpu_pbus",
            },
            "num_outputs": 2,
            "addr_w": params["addr_w"] - 1,
        },
        {
            "core_name": "iob_split",
            "name": "iob_pbus_split",
            "instance_name": "iob_pbus_split",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "split_reset",
                "input": "cpu_pbus",
                "output_0": "uart_swreg",
                "output_1": "timer_swreg",
                "output_2": "bootctr_swreg",
                # TODO: Connect peripherals automatically
            },
            "num_outputs": N_SLAVES,
            "addr_w": params["addr_w"] - 2,
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
                "bootctr_i_bus": "bootctr_i",
                "swregs_read_out": "bootctr",
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
        {
            "core_name": "iob_bus_demux",
            "instance_name": "iob_bus_demux_inst",
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
assign cpu_reset = int_mem_cpu_reset | bootctr_cpu_reset;

iob_bus_demux #(
    .ADDR_W("""
            + str(params["addr_w"])
            + """),
    .DATA_W("""
            + str(params["data_w"])
            + """),
    .N     (2)
) cpu_ibus_split (
    .clk_i     (clk_i),
    .arst_i    (cpu_reset),

    // Master's interface
    .m_avalid_i(cpu_i_iob_valid),
    .m_addr_i  (bootctr_ctr_reg == 2'b00 ? cpu_i_iob_addr : cpu_i_iob_addr + 32'h00FFF000),
    .m_wdata_i (cpu_i_iob_wdata),
    .m_wstrb_i (cpu_i_iob_wstrb),
    .m_rdata_o (cpu_i_iob_rdata),
    .m_rvalid_o(cpu_i_iob_rvalid),
    .m_ready_o (cpu_i_iob_ready),

    // Followers' interface
    .f_avalid_o({int_mem_i_iob_valid,  bootctr_i_iob_valid }),
    .f_addr_o  ({int_mem_i_iob_addr,   bootctr_i_iob_addr  }),
    .f_wdata_o ({int_mem_i_iob_wdata,  bootctr_i_iob_wdata }),
    .f_wstrb_o ({int_mem_i_iob_wstrb,  bootctr_i_iob_wstrb }),
    .f_rdata_i ({int_mem_i_iob_rdata,  bootctr_i_iob_rdata }),
    .f_rvalid_i({int_mem_i_iob_rvalid, bootctr_i_iob_rvalid}),
    .f_ready_i ({int_mem_i_iob_ready,  bootctr_i_iob_ready }),

    // Follower selection
    .f_sel_i   (bootctr_ctr_reg == 2'b00 ? 1'b0 : 1'b1)
);
            """,
        },
    ]

    # Pre-setup specialized IOb-SoC functions
    pre_setup_iob_soc(attributes_dict, peripherals)
    iob_soc_sw_setup(attributes_dict, peripherals, params["addr_w"])

    return attributes_dict
