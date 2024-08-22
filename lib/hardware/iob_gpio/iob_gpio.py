#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e


class iob_gpio(iob_module):
    name = "iob_gpio"
    version = "V0.10"
    flows = "sim emb"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "iob_s_port"},
                {"interface": "iob_s_portmap"},
                {"interface": "iob_wire"},
                iob_reg,
                iob_reg_e,
            ]
        )

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs(
            [
                # Macros
                # Parameters
                {
                    "name": "DATA_W",
                    "type": "P",
                    "val": "32",
                    "min": "NA",
                    "max": "32",
                    "descr": "Data bus width",
                },
                {
                    "name": "ADDR_W",
                    "type": "P",
                    "val": "`IOB_GPIO_SWREG_ADDR_W",
                    "min": "NA",
                    "max": "NA",
                    "descr": "Address bus width",
                },
                {
                    "name": "GPIO_W",
                    "type": "P",
                    "val": "32",
                    "min": "NA",
                    "max": "DATA_W",
                    "descr": "Number of GPIO (can be up to DATA_W)",
                },
            ]
        )

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "general",
                "descr": "GENERAL INTERFACE SIGNALS",
                "ports": [
                    {
                        "name": "clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock input",
                    },
                    {
                        "name": "arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System reset, asynchronous and active high",
                    },
                    {
                        "name": "cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock enable signal.",
                    },
                ],
            },
            {
                "name": "gpio",
                "descr": "",
                "ports": [
                    {
                        "name": "input_ports",
                        "type": "I",
                        "n_bits": "GPIO_W",
                        "descr": "Input interface",
                    },
                    {
                        "name": "output_ports",
                        "type": "O",
                        "n_bits": "GPIO_W",
                        "descr": "Output interface",
                    },
                    {
                        "name": "output_enable",
                        "type": "O",
                        "n_bits": "GPIO_W",
                        "descr": "Output Enable interface can be used to tristate outputs on external module",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.regs += [
            {
                "name": "gpio",
                "descr": "GPIO software accessible registers.",
                "regs": [
                    {
                        "name": "GPIO_INPUT",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "32 bits: 1 bit for value of each GPIO input.",
                    },
                    {
                        "name": "GPIO_OUTPUT",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "32 bits: 1 bit for value of each GPIO output.",
                    },
                    {
                        "name": "GPIO_OUTPUT_ENABLE",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": '32 bits: 1 bit for each GPIO. Bits with "1" are driven with output value, bits with "0" are in tristate.',
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
