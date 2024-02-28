import os

from iob_module import iob_module

from iob_ram_dp import iob_ram_dp


class iob_ram_dp_be(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_ram_dp(),
        ]
