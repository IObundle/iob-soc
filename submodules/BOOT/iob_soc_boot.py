#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e
from iob_pulse_gen import iob_pulse_gen
from iob_rom_dp import iob_rom_dp


class iob_soc_boot(iob_module):
    name = "iob_soc_boot"
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
                    "name": "ADDR_W",
                    "type": "F",
                    "val": "`IOB_SOC_BOOT_SWREG_ADDR_W",
                    "min": "NA",
                    "max": "NA",
                    "descr": "Address bus width",
                },
                {
                    "name": "FULL_ROM_ADDR_W",
                    "type": "F",
                    "val": "12",
                    "min": "NA",
                    "max": "24",
                    "descr": "Boot ROM address width",
                },
                {
                    "name": "BOOT_ROM_ADDR_W",
                    "type": "F",
                    "val": "11",
                    "min": "NA",
                    "max": "24",
                    "descr": "Boot ROM address width",
                },
                {
                    "name": "PREBOOT_ROM_ADDR_W",
                    "type": "F",
                    "val": "8",
                    "min": "NA",
                    "max": "24",
                    "descr": "Boot ROM address width",
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
                        "name": "cpu_rst_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "CPU sync reset.",
                    },
                    {
                        "name": "boot_ctr_o",
                        "type": "O",
                        "n_bits": "2",
                        "descr": "Boot control register access.",
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
                        "addr": -1,
                        "log2n_items": "FULL_ROM_ADDR_W - 2",
                        "autologic": False,
                        "descr": "Bootloader ROM.",
                    },
                    {
                        "name": "CTR",
                        "type": "W",
                        "n_bits": 2,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Boot control register (write). The register has the following values: 0: select preboot, 1: select bootloader, 2: select firmware",
                    },
                    {
                        "name": "RST",
                        "type": "W",
                        "n_bits": 2,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "CPU reset control register (write). The register has the following fields: 0: reboot after preboot enable, 1: reboot after bootloader",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
