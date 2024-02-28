#!/usr/bin/env python3

import sys

from iob_module import iob_module

# Submodules
from iob_utils import iob_utils
from iob_reg_re import iob_reg_re
from iob_reg_e import iob_reg_e
from iob_counter import iob_counter


class iob_timer(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            # Hardware headers & modules
            iob_utils(),
            iob_reg_re(),
            iob_reg_e(),
            iob_counter(),
        ]
        self.confs = [
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
                "type": "P",
                "val": "`IOB_TIMER_SWREG_ADDR_W",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "WDATA_W",
                "type": "P",
                "val": "1",
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
        ]
        self.autoaddr = True
        self.regs = [
            {
                "name": "timer",
                "descr": "TIMER software accessible registers.",
                "regs": [
                    {
                        "name": "RESET",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Timer soft reset",
                    },
                    {
                        "name": "ENABLE",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Timer enable",
                    },
                    {
                        "name": "SAMPLE",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Sample time counter value into a readable register",
                    },
                    {
                        "name": "DATA_LOW",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "High part of the timer value, which has twice the width of the data word width",
                    },
                    {
                        "name": "DATA_HIGH",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Low part of the timer value, which has twice the width of the data word width",
                    },
                ],
            }
        ]
        self.block_groups = []


if __name__ == "__main__":
    # Create an iob-uart ip core
    iob_timer_core = iob_timer()
    if "clean" in sys.argv:
        iob_timer_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_timer_core.print_build_dir()
    else:
        iob_timer_core._setup()
