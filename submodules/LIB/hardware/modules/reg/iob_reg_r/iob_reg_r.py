import os

from iob_module import iob_module

from iob_reg import iob_reg


class iob_reg_r(iob_module):
    name = "iob_reg_r"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_reg,
            ]
        )
