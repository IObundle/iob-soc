#!/usr/bin/env python3

import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./submodules/LIB/scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

# Submodules
from iob_utils import iob_utils
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e


class iob_uart(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_uart"
        cls.version = "V0.10"
        cls.flows = "sim emb doc"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            iob_utils,
            iob_reg,
            iob_reg_e,
        ]

        cls.confs = [
            # Macros
            # Parameters
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "F",
                "val": "`IOB_UART_SWREG_ADDR_W",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
        ]

        cls.ios += [
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
                    {
                        "name": "txd",
                        "direction": "output",
                        "width": 1,
                        "descr": "transmit line",
                    },
                    {
                        "name": "rxd",
                        "direction": "input",
                        "width": 1,
                        "descr": "receive line",
                    },
                    {
                        "name": "cts",
                        "direction": "input",
                        "width": 1,
                        "descr": "to send; the destination is ready to receive a transmission sent by the UART",
                    },
                    {
                        "name": "rts",
                        "direction": "output",
                        "width": 1,
                        "descr": "to send; the UART is ready to receive a transmission from the sender.",
                    },
                ],
            },
        ]

        cls.regs += [
            {
                "name": "uart",
                "descr": "UART software accessible registers.",
                "regs": [
                    {
                        "name": "SOFTRESET",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Soft reset.",
                    },
                    {
                        "name": "DIV",
                        "type": "W",
                        "n_bits": 16,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Bit duration in system clock cycles.",
                    },
                    {
                        "name": "TXDATA",
                        "type": "W",
                        "n_bits": 8,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "TX data.",
                    },
                    {
                        "name": "TXEN",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "TX enable.",
                    },
                    {
                        "name": "RXEN",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 6,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "RX enable.",
                    },
                    {
                        "name": "TXREADY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "TX ready to receive data.",
                    },
                    {
                        "name": "RXREADY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "RX data is ready to be read.",
                    },
                    {
                        "name": "RXDATA",
                        "type": "R",
                        "n_bits": 8,
                        "rst_val": 0,
                        "addr": 4,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "RX data.",
                    },
                ],
            }
        ]

        cls.block_groups += []


if __name__ == "__main__":
    iob_uart.setup_as_top_module()
