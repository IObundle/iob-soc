import os

from iob_module import iob_module

from iob_reg_re import iob_reg_r


class iob_edge_detect(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reg_r(),
        ]
