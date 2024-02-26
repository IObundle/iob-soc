import os

from iob_module import iob_module

from iob_reverse import iob_reverse


class iob_prio_enc(iob_module):
    def __init__(self):
        self.name = "iob_prio_enc"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_reverse(),
        ]
