import os

from iob_module import iob_module

from iob_fp_special import iob_fp_special
from iob_fp_clz import iob_fp_clz
from iob_fp_round import iob_fp_round


class iob_fp_add(iob_module):
    name = "iob_fp_add"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list([iob_fp_special, iob_fp_clz, iob_fp_round])
