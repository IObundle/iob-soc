import os

from iob_module import iob_module


class iob_clkmux(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"