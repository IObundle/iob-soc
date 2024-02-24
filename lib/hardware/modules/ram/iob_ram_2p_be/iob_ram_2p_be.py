import os

from iob_module import iob_module


class iob_ram_2p_be(iob_module):
    def __init__(self):
        self.name = "iob_ram_2p_be"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
