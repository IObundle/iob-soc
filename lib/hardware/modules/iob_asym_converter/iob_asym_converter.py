import os

from iob_module import iob_module
from iob_reg_r import iob_reg_r
from iob_reg_re import iob_reg_re
from iob_utils import iob_utils


class iob_asym_converter(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reg_r(),
            iob_reg_re(),
            iob_utils(),
        ]
