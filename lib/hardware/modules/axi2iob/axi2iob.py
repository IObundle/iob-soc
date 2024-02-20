import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class axi2iob(iob_module):
    name = "axi2iob"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_reg_re,
            ]
        )
