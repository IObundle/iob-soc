import os

from iob_module import iob_module

from iob_reverse import iob_reverse


class iob_prio_enc(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reverse(),
        ]
