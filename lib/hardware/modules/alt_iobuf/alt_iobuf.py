import os

from iob_module import iob_module


class alt_iobuf(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
