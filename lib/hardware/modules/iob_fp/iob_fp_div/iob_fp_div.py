import os

from iob_module import iob_module

from iob_fp_special import iob_fp_special
from iob_div_subshift import iob_div_subshift
from iob_fp_clz import iob_fp_clz
from iob_fp_round import iob_fp_round


class iob_fp_div(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_fp_special(),
            iob_div_subshift(),
            iob_fp_clz(),
            iob_fp_round(),
        ]
