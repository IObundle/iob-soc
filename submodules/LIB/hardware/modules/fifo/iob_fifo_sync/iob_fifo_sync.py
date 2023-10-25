import os

from iob_module import iob_module

from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_counter import iob_counter
from iob_asym_converter import iob_asym_converter
from iob_ram_2p import iob_ram_2p
from iob_utils import iob_utils


class iob_fifo_sync(iob_module):
    name = "iob_fifo_sync"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "clk_en_rst_s_s_portmap"},
                {"interface": "clk_en_rst_s_port"},
                iob_reg_r,
                iob_reg,
                iob_counter,
                iob_asym_converter,
                iob_utils,
                (iob_ram_2p, {"purpose": "simulation"}),
            ]
        )
