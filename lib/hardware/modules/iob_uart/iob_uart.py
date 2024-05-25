def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_uart",
        "name": "iob_uart",
        "version": "0.1",
        "generate_hw": False,
        "rw_overlap": True,
        "board_list": ["CYCLONEV-GT-DK", "AES-KU040-DB-G"],
        "autoaddr": False,
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width.",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "`IOB_UART_SWREG_ADDR_W",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
            {
                "name": "iob",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "CPU native interface",
                "signals": [],
                "widths": {
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
            },
            {
                "name": "rs232",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "RS232 interface",
                "signals": [
                    # {'name':'interrupt', 'type':'O', 'n_bits':'1', 'descr':'be done'},
                    {
                        "name": "txd",
                        "direction": "output",
                        "width": "1",
                        "descr": "transmit line",
                    },
                    {
                        "name": "rxd",
                        "direction": "input",
                        "width": "1",
                        "descr": "receive line",
                    },
                    {
                        "name": "cts",
                        "direction": "input",
                        "width": "1",
                        "descr": "to send; the destination is ready to receive a transmission sent by the UART",
                    },
                    {
                        "name": "rts",
                        "direction": "output",
                        "width": "1",
                        "descr": "to send; the UART is ready to receive a transmission from the sender.",
                    },
                ],
            },
        ],
        "csrs": [
            {
                "name": "uart",
                "descr": "UART software accessible registers.",
                "regs": [
                    {
                        "name": "SOFTRESET",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Soft reset.",
                    },
                    {
                        "name": "DIV",
                        "type": "W",
                        "n_bits": 16,
                        "rst_val": 0,
                        "addr": 2,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Bit duration in system clock cycles.",
                    },
                    {
                        "name": "TXDATA",
                        "type": "W",
                        "n_bits": 8,
                        "rst_val": 0,
                        "addr": 4,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "TX data.",
                    },
                    {
                        "name": "TXEN",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 5,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "TX enable.",
                    },
                    {
                        "name": "RXEN",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 6,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "RX enable.",
                    },
                    {
                        "name": "TXREADY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "TX ready to receive data.",
                    },
                    {
                        "name": "RXREADY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 1,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "RX data is ready to be read.",
                    },
                    # NOTE: RXDATA needs to be the only Read register in a CPU Word
                    # RXDATA_ren access is used to change UART state machine
                    {
                        "name": "RXDATA",
                        "type": "R",
                        "n_bits": 8,
                        "rst_val": 0,
                        "addr": 4,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "RX data.",
                    },
                ],
            }
        ],
        # FIXME: Init attributes no longer exists
        #        Here we are trying to change the (project wide) values of iob_reg
        #        Main branch implementation: https://github.com/IObundle/iob-soc/blob/e1623e1bedab1ca6ee8087ae0903f0618f1a6c68/submodules/UART/iob_uart.py
        # iob_reg.confs = [
        #    {
        #        "name": "DATA_W",
        #        "type": "P",
        #        "val": "1",
        #        "min": "NA",
        #        "max": "NA",
        #        "descr": "Data bus width",
        #    },
        #    {
        #        "name": "RST_VAL",
        #        "type": "P",
        #        "val": "{DATA_W{1'b0}}",
        #        "min": "NA",
        #        "max": "NA",
        #        "descr": "Reset value.",
        #    },
        #    {
        #        "name": "RST_POL",
        #        "type": "M",
        #        "val": "1",
        #        "min": "0",
        #        "max": "1",
        #        "descr": "Reset polarity.",
        #    },
        # ]
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
            {
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
            },
            {
                "core_name": "iob_reset",
                "instance_name": "iob_reset_inst",
            },
        ],
    }

    return attributes_dict
