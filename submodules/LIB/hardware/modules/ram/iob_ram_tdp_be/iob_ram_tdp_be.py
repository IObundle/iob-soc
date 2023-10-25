import os

from iob_module import iob_module

from iob_ram_tdp import iob_ram_tdp


class iob_ram_tdp_be(iob_module):
    name = "iob_ram_tdp_be"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_ram_tdp,
            ]
        )
