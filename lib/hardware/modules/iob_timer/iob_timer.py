#!/usr/bin/env python3

import sys

from iob_core import iob_core


class iob_timer(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("autoaddr", True)

        self.create_conf(
            name="DATA_W",
            type="P",
            val="32",
            min="NA",
            max="NA",
            descr="Data bus width",
        )
        self.create_conf(
            name="ADDR_W",
            type="P",
            val="`IOB_TIMER_SWREG_ADDR_W",
            min="NA",
            max="NA",
            descr="Address bus width",
        )
        self.create_conf(
            name="WDATA_W",
            type="P",
            val="1",
            min="NA",
            max="8",
            descr="",
        )

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            signals=[],
        )
        self.create_port(
            name="iob",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="CPU native interface",
            signals=[],
            widths={
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
            },
        )

        self.create_csr_group(
            name="timer",
            descr="TIMER software accessible registers.",
            regs=[
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
        )

        self.create_instance(
            "iob_utils",
            "iob_utils_inst",
        )

        self.create_instance(
            "iob_reg_e",
            "iob_reg_e_inst",
        )

        self.create_instance(
            "iob_counter_inst",
        )

        self.create_instance(
            "iob_counter",
            "iob_counter_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_timer.clean_build_dir()
    elif "print" in sys.argv:
        iob_timer.print_build_dir()
    else:
        iob_timer()
