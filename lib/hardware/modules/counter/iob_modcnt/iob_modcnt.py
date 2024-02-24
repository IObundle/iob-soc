import os

from iob_module import iob_module

from iob_counter_ld import iob_counter_ld


class iob_modcnt(iob_module):
    def __init__(self):
        self.name = "iob_modcnt"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodules_list = [
            iob_modcnt,
            iob_counter_ld,
        ]
