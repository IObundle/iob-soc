def setup(py_params_dict):
    ADDR_W = py_params_dict["addr_w"] if "addr_w" in py_params_dict else 31
    DATA_W = py_params_dict["data_w"] if "data_w" in py_params_dict else 32
    USE_SPRAM = py_params_dict["USE_SPRAM"] if "USE_SPRAM" in py_params_dict else False
    USE_EXTMEM = (
        py_params_dict["USE_EXTMEM"] if "USE_EXTMEM" in py_params_dict else False
    )
    INIT_MEM = py_params_dict["INIT_MEM"] if "INIT_MEM" in py_params_dict else False

    attributes_dict = {
        "original_name": "iob_soc_int_mem",
        "name": "iob_soc_int_mem",
        "version": "0.1",
        "confs": [
            {
                "name": "HEXFILE",
                "type": "P",
                "val": '"none"',
                "min": "NA",
                "max": "NA",
                "descr": "Name of the firmware hex file",
            },
            {
                "name": "BOOT_HEXFILE",
                "type": "P",
                "val": '"none"',
                "min": "NA",
                "max": "NA",
                "descr": "Name of the boot hex file",
            },
            {
                "name": "SRAM_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of sram address interface",
            },
            {
                "name": "BOOTROM_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of bootrom address interface",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "general",
                "descr": "General signals for internal memory",
                "signals": [
                    {"name": "boot", "width": 1, "direction": "output"},
                    {"name": "cpu_reset", "width": 1, "direction": "output"},
                ],
            },
            {
                "name": "i_bus",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "i_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W,
                },
                "descr": "Instruction bus",
            },
            {
                "name": "d_bus",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "d_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W - 1,
                },
                "descr": "Data bus",
            },
        ],
    }
    if USE_SPRAM:
        attributes_dict["ports"] += [
            # SPRAM
            {
                "name": "spram_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "spram_",
                    "DATA_W": DATA_W,
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
        ]
    else:  # Not USE_SPRAM
        attributes_dict["ports"] += [
            # SRAM
            {
                "name": "sram_i_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "sram_i_",
                    "DATA_W": DATA_W,
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
            {
                "name": "sram_d_bus",
                "interface": {
                    "type": "iob",
                    "port_prefix": "sram_d_",
                    "DATA_W": DATA_W,
                    "ADDR_W": "SRAM_ADDR_W-2",
                },
                "descr": "Data bus",
            },
        ]
    attributes_dict["ports"] += [
        # ROM
        {
            "name": "rom_bus",
            "descr": "Data bus",
            "signals": [
                {"name": "rom_r_valid", "width": 1, "direction": "output"},
                {
                    "name": "rom_r_addr",
                    "width": "BOOTROM_ADDR_W-2",
                    "direction": "output",
                },
                {"name": "rom_r_rdata", "width": DATA_W, "direction": "input"},
            ],
        },
    ]
    attributes_dict["wires"] = [
        {
            "name": "never_reset",
            "descr": "Reset signal for common components (always low)",
            "signals": [
                {"name": "always_low", "width": 1},
            ],
        },
        {
            "name": "boot_ctr_bus",
            "interface": {
                "type": "iob",
                "wire_prefix": "boot_ctr_",
                "DATA_W": DATA_W,
                "ADDR_W": ADDR_W - 2,
            },
            "descr": "Boot controller IOb native interface wires",
        },
        {
            "name": "ram_d",
            "interface": {
                "type": "iob",
                "wire_prefix": "ram_d_",
                "DATA_W": DATA_W,
                "ADDR_W": ADDR_W - 2,
            },
            "descr": "Ram IOb native interface wires",
        },
        {
            "name": "ram_w",
            "interface": {
                "type": "iob",
                "wire_prefix": "ram_w_",
                "DATA_W": DATA_W,
                "ADDR_W": ADDR_W,
            },
            "descr": "iob-soc internal memory sram write interface",
        },
        {
            "name": "ram_r",
            "interface": {
                "type": "iob",
                "wire_prefix": "ram_r_",
                "DATA_W": DATA_W,
                "ADDR_W": ADDR_W,
            },
            "descr": "iob-soc internal ram r bus",
        },
        {
            "name": "ram_i",
            "interface": {
                "type": "iob",
                "wire_prefix": "ram_i_",
                "DATA_W": DATA_W,
                "ADDR_W": ADDR_W,
            },
            "descr": "iob-soc internal ram i bus",
        },
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_split",
            "name": "iob_data_boot_ctr_split",
            "instance_name": "iob_data_boot_ctr_split",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "never_reset",
                "input": "d_bus",
                "output_0": "ram_d",
                "output_1": "boot_ctr_bus",
            },
            "num_outputs": 2,
            "addr_w": ADDR_W - 1,
        },
        {
            "core_name": "iob_merge",
            "name": "iob_ibus_merge",
            "instance_name": "iob_ibus_merge",
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "reset": "never_reset",
                "input_0": "ram_r",
                "input_1": "ram_w",
                "output": "ram_i",
            },
            "num_inputs": 2,
            "addr_w": ADDR_W,
        },
    ]
    attributes_dict["snippets"] = [
        {
            "verilog_code": f"""
    assign always_low = 1'b0;

    //modified ram address during boot
    wire [{ADDR_W-2}-1:0] ram_d_addr;


"""
            + (
                """
    assign ram_d_iob_rdata = spram_iob_rdata_i;
    assign ram_i_iob_rdata = spram_iob_rdata_i;
"""
                if USE_SPRAM
                else """
    assign ram_i_iob_rdata = sram_i_iob_rdata_i;
    assign ram_d_iob_rdata = sram_d_iob_rdata_i;

    assign sram_i_iob_valid_o  = ram_i_iob_valid;
    assign sram_i_iob_addr_o   = ram_i_iob_addr[SRAM_ADDR_W-1:2];
    assign sram_i_iob_wdata_o  = ram_i_iob_wdata;
    assign sram_i_iob_wstrb_o  = ram_i_iob_wstrb;

    assign sram_d_iob_valid_o  = ram_d_iob_valid;
    assign sram_d_iob_addr_o   = ram_d_addr;
    assign sram_d_iob_wdata_o  = ram_d_iob_wdata;
    assign sram_d_iob_wstrb_o  = ram_d_iob_wstrb;
"""
            )
            + f"""

    //
    // BOOT CONTROLLER
    //

    iob_soc_boot_ctr #(
       .HEXFILE       ({{BOOT_HEXFILE, ".hex"}}),
       .DATA_W        ({DATA_W}),
       .ADDR_W        ({ADDR_W}),
       .BOOTROM_ADDR_W(BOOTROM_ADDR_W),
       .SRAM_ADDR_W   (SRAM_ADDR_W)
    ) boot_ctr0 (
       .clk_i    (clk_i),
       .arst_i   (arst_i),
       .cke_i    (cke_i),
       .cpu_rst_o(cpu_reset_o),
       .boot_o   (boot_o),

       //cpu slave interface
       //no address bus since single address
       .cpu_valid_i(boot_ctr_iob_valid),
       .cpu_wdata_i (boot_ctr_iob_wdata[1:0]),
       .cpu_wstrb_i (boot_ctr_iob_wstrb),
       .cpu_rdata_o (boot_ctr_iob_rdata),
       .cpu_rvalid_o(boot_ctr_iob_rvalid),
       .cpu_ready_o (boot_ctr_iob_ready),

       //sram write master interface
       .sram_valid_o(ram_w_iob_valid),
       .sram_addr_o  (ram_w_iob_addr),
       .sram_wdata_o (ram_w_iob_wdata),
       .sram_wstrb_o (ram_w_iob_wstrb),
       //rom
       .rom_r_valid_o(rom_r_valid_o),
       .rom_r_addr_o(rom_r_addr_o),
       .rom_r_rdata_i(rom_r_rdata_i)
    );

    //
    //MODIFY INSTRUCTION READ ADDRESS DURING BOOT
    //

    //instruction read bus
    wire [     {ADDR_W}-1:0] boot_i_addr;
    wire [     {ADDR_W}-1:0] sram_i_iob_addr;
    wire [SRAM_ADDR_W-3:0] boot_ram_d_addr;

    //
    //modify addresses to run boot program
    //
    localparam boot_offset = -('b1 << BOOTROM_ADDR_W);

    //instruction bus: connect directly but address
    assign boot_i_addr = i_iob_addr_i + boot_offset;
    assign sram_i_iob_addr = i_iob_addr_i;

    assign ram_r_iob_valid = i_iob_valid_i;
    assign ram_r_iob_addr = boot_o ? boot_i_addr : sram_i_iob_addr;
    assign ram_r_iob_wdata = i_iob_wdata_i;
    assign ram_r_iob_wstrb = i_iob_wstrb_i;
    assign i_iob_rvalid_o = ram_r_iob_rvalid;
    assign i_iob_rdata_o = ram_r_iob_rdata;
    assign i_iob_ready_o = ram_r_iob_ready;

    //data bus: just replace address
    assign boot_ram_d_addr = ram_d_iob_addr[SRAM_ADDR_W-1:2] + boot_offset[SRAM_ADDR_W-1:2];
    assign ram_d_addr = boot_o ? boot_ram_d_addr : ram_d_iob_addr[SRAM_ADDR_W-1:2];

    //
    // INSTANTIATE RAM
    //
    iob_soc_sram #(
"""
            + (
                """
      .HEXFILE    (HEXFILE),
"""
                if not USE_EXTMEM and INIT_MEM
                else ""
            )
            + f"""
      .DATA_W     ({DATA_W}),
      .SRAM_ADDR_W(SRAM_ADDR_W)
    ) int_sram (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
"""
            + (
                """
      .valid_spram_o(spram_iob_valid_o),
      .addr_spram_o(spram_iob_addr_o),
      .wstrb_spram_o(spram_iob_wstrb_o),
      .wdata_spram_o(spram_iob_wdata_o),
      .rdata_spram_i(spram_iob_rdata_i),
"""
                if USE_SPRAM
                else ""
            )
            + """
      //instruction bus
      .i_valid_i(ram_i_iob_valid),
      .i_addr_i  (ram_i_iob_addr[SRAM_ADDR_W-1:2]),
      .i_wdata_i (ram_i_iob_wdata),
      .i_wstrb_i (ram_i_iob_wstrb),
      .i_rdata_o (),
      .i_rvalid_o(ram_i_iob_rvalid),
      .i_ready_o (ram_i_iob_ready),

      //data bus
      .d_valid_i(ram_d_iob_valid),
      .d_addr_i  (ram_d_addr[SRAM_ADDR_W-3:0]),
      .d_wdata_i (ram_d_iob_wdata),
      .d_wstrb_i (ram_d_iob_wstrb),
      .d_rdata_o (),
      .d_rvalid_o(ram_d_iob_rvalid),
      .d_ready_o (ram_d_iob_ready)
    );

""",
        },
    ]

    return attributes_dict
