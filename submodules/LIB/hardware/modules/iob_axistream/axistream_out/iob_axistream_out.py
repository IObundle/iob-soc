#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_fifo_async import iob_fifo_async
from iob_reg_re import iob_reg_re
from iob_ram_t2p import iob_ram_t2p
from iob_sync import iob_sync
from iob_counter import iob_counter


class iob_axistream_out(iob_module):
    name = "iob_axistream_out"
    version = "V0.30"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "iob_s_port"},
                {"interface": "iob_s_portmap"},
                iob_fifo_async,
                iob_sync,
                iob_reg_re,
                iob_ram_t2p,
                iob_counter,
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
                    "min": "32",
                    "max": "32",
                    "descr": "CPU data bus width",
                },
                {
                    "name": "ADDR_W",
                    "type": "P",
                    "val": "`IOB_AXISTREAM_OUT_SWREG_ADDR_W",
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
            ]
        )

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "general",
                "descr": "System general interface signals",
                "ports": [
                    {
                        "name": "clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock input",
                    },
                    {
                        "name": "cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "IOb clock enable signal.",
                    },
                    {
                        "name": "arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "IOb reset, asynchronous and active high",
                    },
                    {
                        "name": "interrupt_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "FIFO threshold interrupt signal",
                    },
                ],
            },
            {
                "name": "axistream",
                "descr": "AXI Stream interface signals",
                "ports": [
                    {
                        "name": "axis_clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Clock.",
                    },
                    {
                        "name": "axis_cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Clock enable.",
                    },
                    {
                        "name": "axis_arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Aynchronous and active high reset.",
                    },
                    {
                        "name": "axis_tdata_o",
                        "type": "O",
                        "n_bits": "TDATA_W",
                        "descr": "Data.",
                    },
                    {
                        "name": "axis_tvalid_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Valid.",
                    },
                    {
                        "name": "axis_tready_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Ready.",
                    },
                    {
                        "name": "axis_tlast_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Last word.",
                    },
                ],
            },
            {
                "name": "sys_axis",
                "descr": "System AXI Stream interface.",
                "ports": [
                    {
                        "name": "sys_tdata_i",
                        "type": "I",
                        "n_bits": "DATA_W",
                        "descr": "Data.",
                    },
                    {
                        "name": "sys_tvalid_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Valid.",
                    },
                    {
                        "name": "sys_tready_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Ready.",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.regs += [
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
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "Data input.",
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
                        "type": "W",
                        "n_bits": "DATA_W",
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Set the number of words (with TDATA_W bits) to be written to the FIFO.",
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
                        "n_bits": "FIFO_ADDR_W+1",
                        "rst_val": 8,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "FIFO threshold level for interrupt signal",
                    },
                    {
                        "name": "FIFO_LEVEL",
                        "type": "R",
                        "n_bits": "FIFO_ADDR_W+1",
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Current FIFO level",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
