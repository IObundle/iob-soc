import os

from iob_module import iob_module

from iob_ctls import iob_ctls


class iob_regfile_2p(iob_module):
    def __init__(self):
        self.name = "iob_regfile_2p"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodules_list = [
            iob_ctls,
        ]
