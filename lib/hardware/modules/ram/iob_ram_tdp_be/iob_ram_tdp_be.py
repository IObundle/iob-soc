import os

from iob_module import iob_module

from iob_ram_tdp import iob_ram_tdp


class iob_ram_tdp_be(iob_module):
    def __init__(self):
        self.name = "iob_ram_tdp_be"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_ram_tdp(),
        ]
