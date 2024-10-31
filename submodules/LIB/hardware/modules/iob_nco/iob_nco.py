import os

from iob_module import iob_module

from iob_tasks import iob_tasks
from iob_reg import iob_reg
from iob_reg_r import iob_reg_r
from iob_reg_e import iob_reg_e
from iob_reg_re import iob_reg_re
from iob_modcnt import iob_modcnt
from iob_acc_ld import iob_acc_ld
from iob_utils import iob_utils
from iob_sync import iob_sync
from iob_fifo_async import iob_fifo_async
from iob_regfile_at2p import iob_regfile_at2p


class iob_nco(iob_module):
    name = "iob_nco"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_reg_r,
                iob_reg_re,
                iob_reg,
                iob_modcnt,
                iob_acc_ld,
                iob_sync,
                iob_regfile_at2p,
                iob_fifo_async,
                # simulation files
                (iob_utils, {"purpose": "simulation"}),
                (iob_tasks, {"purpose": "simulation"}),
                ({"interface": "clk_en_rst_s_portmap"}, {"purpose": "simulation"}),
                (iob_reg_e, {"purpose": "simulation"}),
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
                    "min": "0",
                    "max": "32",
                    "descr": "Data bus width",
                },
                {
                    "name": "ADDR_W",
                    "type": "P",
                    "val": "`IOB_NCO_SWREG_ADDR_W",
                    "min": "0",
                    "max": "32",
                    "descr": "Address bus width",
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
                "name": "clk_gen",
                "descr": "Generated clock interface",
                "ports": [
                    {
                        "name": "clk_in_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Clock input",
                    },
                    {
                        "name": "clk_in_arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Clock input asynchronous reset",
                    },
                    {
                        "name": "clk_in_cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Clock input enable",
                    },
                    {
                        "name": "clk_out_o",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Generated clock output",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.regs += [
            {
                "name": "nco",
                "descr": "NCO software accessible registers.",
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
                        "descr": "NCO enable",
                    },
                    {
                        "name": "PERIOD_INT",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 5,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "Integer part of the generated period. Period of the generated clock in terms of the number of system clock cycles + 1 implicit clock cycle. NOTE: need to write to both PERIOD_INT, PERIOD_FRAC registers to set internal period.",
                    },
                    {
                        "name": "PERIOD_FRAC",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "Fractional part of the generated period. NOTE: need to write to both PERIOD_INT, PERIOD_FRAC registers to set internal period.",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
