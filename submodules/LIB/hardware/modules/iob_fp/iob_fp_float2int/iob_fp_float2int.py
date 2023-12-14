import os

from iob_module import iob_module

from iob_fp_dq import iob_fp_dq


class iob_fp_float2int(iob_module):
    name = "iob_fp_float2int"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list([iob_fp_dq])
