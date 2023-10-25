import os

from iob_module import iob_module

from iob_utils import iob_utils
from iob_gray_counter import iob_gray_counter
from iob_gray2bin import iob_gray2bin
from iob_sync import iob_sync
from iob_asym_converter import iob_asym_converter
from iob_ram_t2p import iob_ram_t2p


class iob_fifo_async(iob_module):
    name = "iob_fifo_async"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_utils,
                iob_gray_counter,
                iob_gray2bin,
                iob_sync,
                iob_asym_converter,
                (iob_ram_t2p, {"purpose": "simulation"}),
            ]
        )
