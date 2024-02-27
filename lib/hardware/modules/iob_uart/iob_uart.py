#!/usr/bin/env python3

import os
import sys

from iob_module import iob_module

# Submodules
from iob_utils import iob_utils
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e


class iob_uart(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.rw_overlap = True
        self.board_list = ["CYCLONEV-GT-DK", "AES-KU040-DB-G"]
        self.submodule_list = [
            iob_utils(),
            iob_reg(),
            iob_reg_e(),
        ]
        self.confs = [
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
            {
                "name": "UART_DATA_W",
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "8",
                "descr": "",
            },
        ]
        self.ios = [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "ports": [],
            },
            {
                "name": "iob",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "CPU native interface",
                "ports": [],
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
                "ports": [
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
        ]
        self.autoaddr = False
        self.regs = [
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
                        "n_bits": "UART_DATA_W",
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
                        "n_bits": "UART_DATA_W",
                        "rst_val": 0,
                        "addr": 4,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "RX data.",
                    },
                ],
            }
        ]
        self.block_groups = []
        # FIXME: Init attributes no longer exists
        # iob_reg.init_attributes()
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


if __name__ == "__main__":
    # Create an iob-uart ip core
    iob_uart_core = iob_uart()
    if "clean" in sys.argv:
        iob_uart_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_uart_core.print_build_dir()
    else:
        iob_uart_core._setup()
