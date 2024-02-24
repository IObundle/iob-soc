import os

from iob_module import iob_module


class iob_add2(iob_module):
    def __init__(self):
        self.name = "iob_add2"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
