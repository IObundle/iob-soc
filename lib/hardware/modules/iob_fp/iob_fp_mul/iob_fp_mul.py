import os

from iob_module import iob_module

from iob_fp_special import iob_fp_special
from iob_fp_round import iob_fp_round


class iob_fp_mul(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [iob_fp_special(), iob_fp_round()]
