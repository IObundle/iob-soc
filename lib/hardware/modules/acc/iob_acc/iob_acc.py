import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class iob_acc(iob_module):
    def __init__(self):
        self.name = "iob_acc"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_reg_re(),
        ]
