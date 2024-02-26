import os

from iob_module import iob_module


class altddion_out(iob_module):
    def __init__(self):
        super().__init__()
        self.name = "altddion_out"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
