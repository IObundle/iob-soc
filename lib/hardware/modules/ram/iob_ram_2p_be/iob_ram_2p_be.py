import os

from iob_module import iob_module


class iob_ram_2p_be(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
