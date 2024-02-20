import os

from iob_module import iob_module

from iob_int_sqrt import iob_int_sqrt


class iob_fp_sqrt(iob_module):
    name = "iob_fp_sqrt"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_int_sqrt,
            ]
        )
