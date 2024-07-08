import os

from iob_module import iob_module

from iob_tasks import iob_tasks
from iob_reg_e import iob_reg_e
from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_modcnt import iob_modcnt
from iob_acc_ld import iob_acc_ld
from iob_utils import iob_utils


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
                iob_reg,
                iob_modcnt,
                iob_acc_ld,
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
                {
                    "name": "FRAC_W",
                    "type": "P",
                    "val": "8",
                    "min": "0",
                    "max": "32",
                    "descr": "Bit-width of the fractional part of the period value. Used to differentiate between the integer and fractional parts of the period. ",
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
                "descr": "Output generated clock interface",
                "ports": [
                    {
                        "name": "clk_o",
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
                        "name": "PERIOD",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 5,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "Period of the generated clock in terms of the number of system clock cycles + 1 implicit clock cycle. The period value is divided into integer and fractional parts where the lower FRAC_W bits represent the fractional part, and the remaining upper bits represent the integer part.",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
