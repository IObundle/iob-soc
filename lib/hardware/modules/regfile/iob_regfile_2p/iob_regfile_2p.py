import os

from iob_module import iob_module

from iob_ctls import iob_ctls


class iob_regfile_2p(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_ctls(),
        ]
