#!/usr/bin/env python3

import os
from typing import List

from iob_module import iob_module

# Submodules
from iob_utils import iob_utils
from iob_reg import iob_reg
from iob_reg_e import iob_reg_e


class iob_uart(iob_module):
    name = "iob_uart"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)
    rw_overlap = True

    board_list: List = ["CYCLONEV-GT-DK", "AES-KU040-DB-G"]

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "iob_s_port"},
                {"interface": "iob_s_portmap"},
                {"interface": "iob_wire"},
                iob_utils,
                {"interface": "clk_en_rst_s_s_portmap"},
                {"interface": "clk_en_rst_s_port"},
                iob_reg,
                iob_reg_e,
            ]
        )

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs(
            [
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
        )

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {
                "name": "clk_en_rst_s_port",
                "descr": "Clock, clock enable and reset",
                "ports": [],
            },
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "rs232",
                "descr": "Cache invalidate and write-trough buffer IO chain",
                "ports": [
                    # {'name':'interrupt', 'type':'O', 'n_bits':'1', 'descr':'be done'},
                    {
                        "name": "txd_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "transmit line",
                    },
                    {
                        "name": "rxd_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "receive line",
                    },
                    {
                        "name": "cts_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "to send; the destination is ready to receive a transmission sent by the UART",
                    },
                    {
                        "name": "rts_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "to send; the UART is ready to receive a transmission from the sender.",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.autoaddr = False
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

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []

    @classmethod
    def _init_attributes(cls):
        iob_reg.init_attributes()
        iob_reg.confs = [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "1",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "RST_VAL",
                "type": "P",
                "val": "{DATA_W{1'b0}}",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
            {
                "name": "RST_POL",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Reset polarity.",
            },
        ]
