import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class axi2iob(iob_module):
    def __init__(self):
        self.name = "axi2iob"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodules_list = [
            iob_reg_re,
        ]
