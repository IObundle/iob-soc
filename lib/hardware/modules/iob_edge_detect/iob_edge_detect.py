import os

from iob_module import iob_module

from iob_reg_re import iob_reg_r


class iob_edge_detect(iob_module):
    def __init__(self):
        self.name = "iob_edge_detect"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodules_list = [
            iob_reg_r,
        ]
