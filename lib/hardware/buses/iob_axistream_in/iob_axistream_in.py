def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_axistream_in",
        "name": "iob_axistream_in",
        "version": "0.3",
        "board_list": ["CYCLONEV-GT-DK", "AES-KU040-DB-G"],
        "generate_hw": False,  # TODO: Delele iob_axistream_in.v source and remove this line to generate core with py2hwsw
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "32",
                "max": "32",
                "descr": "CPU data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "`IOB_AXISTREAM_IN_CSRS_ADDR_W",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "TDATA_W",
                "type": "P",
                "val": "8",
                "min": "1",
                "max": "DATA_W",
                "descr": "AXI stream data width",
            },
            {
                "name": "FIFO_ADDR_W",
                "type": "P",
                "val": "4",
                "min": "NA",
                "max": "16",
                "descr": "FIFO depth (log2)",
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
                "name": "iob",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "interrupt",
                "descr": "Interrupt signal",
                "signals": [
                    {
                        "name": "interrupt",
                        "direction": "output",
                        "width": "1",
                        "descr": "FIFO threshold interrupt signal",
                    },
                ],
            },
            {
                "name": "axistream",
                "descr": "AXI Stream interface signals",
                "signals": [
                    {
                        "name": "axis_clk",
                        "direction": "input",
                        "width": "1",
                        "descr": "Clock.",
                    },
                    {
                        "name": "axis_cke",
                        "direction": "input",
                        "width": "1",
                        "descr": "Clock enable",
                    },
                    {
                        "name": "axis_arst",
                        "direction": "input",
                        "width": "1",
                        "descr": "Asynchronous and active high reset.",
                    },
                    {
                        "name": "axis_tdata",
                        "direction": "input",
                        "width": "TDATA_W",
                        "descr": "Data.",
                    },
                    {
                        "name": "axis_tvalid",
                        "direction": "input",
                        "width": "1",
                        "descr": "Valid.",
                    },
                    {
                        "name": "axis_tready",
                        "direction": "output",
                        "width": "1",
                        "descr": "Ready.",
                    },
                    {
                        "name": "axis_tlast",
                        "direction": "input",
                        "width": "1",
                        "descr": "Last word.",
                    },
                ],
            },
            {
                "name": "sys_axis",
                "descr": "System AXI Stream interface.",
                "signals": [
                    {
                        "name": "sys_tdata",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "Data.",
                    },
                    {
                        "name": "sys_tvalid",
                        "direction": "output",
                        "width": "1",
                        "descr": "Valid.",
                    },
                    {
                        "name": "sys_tready",
                        "direction": "input",
                        "width": "1",
                        "descr": "Ready.",
                    },
                ],
            },
        ],
        "wires": [
            # TODO: Create wires
        ],
        "blocks": [
            {
                "core_name": "csrs",
                "instance_name": "csrs_inst",
                "instance_description": "Control/Status Registers",
                "csrs": [
                    {
                        "name": "axistream",
                        "descr": "AXI Stream software accessible registers.",
                        "regs": [
                            {
                                "name": "SOFT_RESET",
                                "type": "W",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Soft reset.",
                            },
                            {
                                "name": "ENABLE",
                                "type": "W",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Enable peripheral.",
                            },
                            {
                                "name": "DATA",
                                "type": "R",
                                "n_bits": 32,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": False,
                                "descr": "Data output.",
                            },
                            {
                                "name": "MODE",
                                "type": "W",
                                "n_bits": "1",
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Sets the operation mode: (0) data is read using CSR; (1) data is read using system axistream interface.",
                            },
                            {
                                "name": "NWORDS",
                                "type": "R",
                                "n_bits": "DATA_W",
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Read the number of words (with TDATA_W bits) written to the FIFO.",
                            },
                            {
                                "name": "TLAST_DETECTED",
                                "type": "R",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Read the TLAST detected status.",
                            },
                        ],
                    },
                    {
                        "name": "fifo",
                        "descr": "FIFO related registers",
                        "regs": [
                            {
                                "name": "FIFO_FULL",
                                "type": "R",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Full (1), or non-full (0).",
                            },
                            {
                                "name": "FIFO_EMPTY",
                                "type": "R",
                                "n_bits": 1,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Full (1), or non-full (0).",
                            },
                            {
                                "name": "FIFO_THRESHOLD",
                                "type": "W",
                                # FIXME: Fix csrs.py block of py2hwsw to support these parameters
                                # "n_bits": "FIFO_ADDR_W+1",
                                "n_bits": "4+1",
                                "rst_val": 8,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "FIFO threshold level for interrupt signal",
                            },
                            {
                                "name": "FIFO_LEVEL",
                                "type": "R",
                                # FIXME: Fix csrs.py block of py2hwsw to support these parameters
                                # "n_bits": "FIFO_ADDR_W+1",
                                "n_bits": "4+1",
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "Current FIFO level",
                            },
                        ],
                    },
                ],
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "control_if": "iob",
                    # Register interfaces
                    # TODO: Connect register signals
                },
            },
            # TODO: Connect remaining blocks
            {
                "core_name": "iob_fifo_async",
                "instance_name": "iob_fifo_async_inst",
            },
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
            {
                "core_name": "iob_ram_at2p",
                "instance_name": "iob_ram_at2p_inst",
            },
            {
                "core_name": "iob_sync",
                "instance_name": "iob_sync_inst",
            },
            {
                "core_name": "iob_counter",
                "instance_name": "iob_counter_inst",
            },
            {
                "core_name": "iob_edge_detect",
                "instance_name": "iob_edge_detect_inst",
            },
        ],
    }

    return attributes_dict
