import os

from iob_module import iob_module


class iob_ram_dp_be_xil(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
