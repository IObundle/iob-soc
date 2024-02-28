import os

from iob_module import iob_module


class iob_ram_t2p(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
