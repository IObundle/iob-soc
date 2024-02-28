import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class iob_regfile_sp(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.previous_version = "V0.09"
        self.submodule_list = [
            iob_reg_re(),
        ]
