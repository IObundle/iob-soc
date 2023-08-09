#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e
from iob_pulse_gen import iob_pulse_gen
from iob_rom_dp import iob_rom_dp

# these 2 values should be passed from the top level but are hardcoded for now
BASE = 0x40000000
ROM_ADDR_W = 12


class boot(iob_module):
    name = "boot"
    version = "V0.70"
    flows = "sim emb"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "iob_s_port"},
                {"interface": "iob_s_portmap"},
                iob_reg,
                iob_reg_e,
                iob_pulse_gen,
                iob_rom_dp,
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
                    "type": "F",
                    "val": "32",
                    "min": "32",
                    "max": "32",
                    "descr": "Data bus width",
                },
                {
                    "name": "HEXFILE",
                    "type": "P",
                    "val": "0",
                    "min": "NA",
                    "max": "NA",
                    "descr": "",
                },
                {
                    "name": "ROM_ADDR_W",
                    "type": "P",
                    "val": str(ROM_ADDR_W),
                    "min": str(ROM_ADDR_W),
                    "max": str(ROM_ADDR_W),
                    "descr": "ROM address width",
                },
            ]
        )

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "ibus",
                "descr": "Instruction bus",
                "ports": [
                    {
                        "name": "ibus_avalid_1",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Address is valid.",
                    },
                    {
                        "name": "ibus_addr_i",
                        "type": "O",
                        "n_bits": "256",
                        "descr": "Address.",
                    },
                    {
                        "name": "ibus_rdata_o",
                        "type": "O",
                        "n_bits": "DATA_W",
                        "descr": "SRAM write data.",
                    },
                    {
                        "name": "ibus_rvalid_o",
                        "type": "O",
                        "n_bits": "DATA_W/8",
                        "descr": "SRAM write strobe.",
                    },
                    {
                        "name": "ibus_ready_o",
                        "type": "O",
                        "n_bits": "DATA_W/8",
                        "descr": "SRAM write strobe.",
                    },
                ],
            },
            {
                "name": "general",
                "descr": "GENERAL INTERFACE SIGNALS",
                "ports": [
                    {
                        "name": "cpu_rst_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "CPU sync reset.",
                    },
                    {
                        "name": "preboot_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "System preboot indicator.",
                    },
                    {
                        "name": "boot_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "System boot indicator.",
                    },
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
                        "descr": "System reset, asynchronous and active high",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.regs += [
            {
                "name": "boot",
                "descr": "Boot control register.",
                "regs": [
                    {
                        "name": "ROM",
                        "type": "R",
                        "n_bits": "DATA_W",
                        "rst_val": 0,
                        "addr": BASE,
                        "log2n_items": ROM_ADDR_W,
                        "autologic": False,
                        "descr": "Bootloader ROM.",
                    },
                    {
                        "name": "CTR",
                        "type": "W",
                        "n_bits": 3,
                        "rst_val": 0,
                        "addr": BASE + 2**ROM_ADDR_W,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "Boot control register (write). The register has the following fields: 0: preboot enable, 1: boot enable, 2: CPU reset",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
