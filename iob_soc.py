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
                "val": "7",
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
                "descr": "Bootloader ROM address width",
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
                    "width": "BOOTROM_ADDR_W-2",
                },
                {
                    "name": "boot_rom_rdata",
                    "direction": "input",
                    "width": params["data_w"],
                },
            ],
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
                "ADDR_W": params["addr_w"] - 1,
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
    ]
    attributes_dict["wires"] += [
        # External memory wires
        {
            "name": "mem_i",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_mem_i_",
                "wire_prefix": "mem_i_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 1,
            },
            "descr": "iob-soc external memory instruction interface",
        },
        {
            "name": "mem_d",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_mem_d_",
                "wire_prefix": "mem_d_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 1,
            },
            "descr": "iob-soc external memory data interface",
        },
        {
            "name": "mem_clk_en_rst",
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
            "name": "bootrom_i",
            "interface": {
                "type": "iob",
                "file_prefix": "bootrom_i_",
                "wire_prefix": "bootrom_i_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 1,
            },
            "descr": "iob-soc boot controller instruction interface",
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
            "name": "bootrom_swreg",
            "interface": {
                "type": "iob",
                "file_prefix": "iob_soc_bootrom_swreg_",
                "wire_prefix": "bootrom_swreg_",
                "DATA_W": params["data_w"],
                "ADDR_W": params["addr_w"] - 3,
            },
            "descr": "BOOTROM swreg bus",
        },
        # TODO: Auto add peripheral wires
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_picorv32",
            "instance_name": "cpu",
            "instance_description": "RISC-V CPU instance",
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
    attributes_dict["blocks"] += [
        {
            "core_name": "iob_soc_mem",
            "instance_name": "mem",
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
                "clk_en_rst": "mem_clk_en_rst",
                "i_bus": "mem_i",
                "d_bus": "mem_d",
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
            "name": "iob_mem_split",
            "instance_name": "iob_mem_split",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "split_reset",
                "input": "cpu_d",
                "output_0": "mem_d",
                "output_1": "cpu_pbus",
            },
            "num_outputs": 2,
            "addr_w": params["addr_w"],
        },
        {
            "core_name": "iob_split",
            "name": "iob_pbus_split",
            "instance_name": "iob_pbus_split",
            "instance_description": "Split between peripherals",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "split_reset",
                "input": "cpu_pbus",
                "output_0": "uart_swreg",
                "output_1": "timer_swreg",
                "output_2": "bootrom_swreg",
                # TODO: Connect peripherals automatically
            },
            "num_outputs": N_SLAVES,
            "addr_w": params["addr_w"] - 1,
        },
        {
            "core_name": "iob_split",
            "name": "iob_instr_split",
            "instance_name": "iob_instr_split",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "split_reset",
                "input": "cpu_i",
                "output_0": "mem_i",
                "output_1": "bootrom_i",
            },
            "num_outputs": 2,
            "addr_w": params["addr_w"],
        },
    ]
    peripherals = [
        # Peripherals
        {
            "core_name": "iob_uart",
            "instance_name": "UART0",
            "instance_description": "UART peripheral",
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
            "instance_description": "Timer peripheral",
            "parameters": {},
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "timer_swreg",
            },
        },
        {
            "core_name": "iob_bootrom",
            "instance_name": "BOOTROM0",
            "parameters": {},
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "iob": "bootrom_swreg",
                "bootrom_i_bus": "bootrom_i",
                "boot_rom_bus": "rom_bus",
            },
        },
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
        {
            "core_name": "iob_pulse_gen",
            "instance_name": "iob_pulse_gen_inst",
            "instantiate": False,
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
        # NOTE: Disabled temporarily.
        # Since cyclonev and ku040 wrappers have the same "name" attribute,
        # the py2hwsw generated verilog snippets will also have the same name.
        # Therefore, this one is disabled until either:
        # 1) Py2hwsw generates modules directly without using verilog snippets.
        # 2) We change the wrapper names to be unique.
        # {
        #     "core_name": "iob_soc_ku040_wrapper",
        #     "instance_name": "iob_soc_ku040_wrapper",
        #     "instantiate": False,
        #     "dest_dir": "hardware/fpga/vivado/AES-KU040-DB-G",
        #     "iob_soc_params": params,
        # },
        {
            "core_name": "iob_soc_cyclonev_wrapper",
            "instance_name": "iob_soc_cyclonev_wrapper",
            "instantiate": False,
            "dest_dir": "hardware/fpga/quartus/CYCLONEV-GT-DK",
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
// Reset pulse generator //

wire low_after_1st_rst;
iob_reg #(
    .DATA_W (1),
    .RST_VAL(1'b1)
) low_after_1st_rst_reg (
    .clk_i (clk_i),
    .cke_i (cke_i),
    .arst_i(arst_i),
    .data_i(1'b0),
    .data_o(low_after_1st_rst)
);

wire cpu_rst_start_pulse;
assign cpu_rst_start_pulse = low_after_1st_rst;
iob_pulse_gen #(
    .START   (0),
    .DURATION(100)
) reset_pulse (
    .clk_i  (clk_i),
    .arst_i (arst_i),
    .cke_i  (cke_i),
    .start_i(cpu_rst_start_pulse),
    .pulse_o(cpu_reset)
);
            """,
        },
    ]

    # Pre-setup specialized IOb-SoC functions
    pre_setup_iob_soc(attributes_dict, peripherals, params)
    iob_soc_sw_setup(attributes_dict, peripherals, params["addr_w"])

    return attributes_dict
