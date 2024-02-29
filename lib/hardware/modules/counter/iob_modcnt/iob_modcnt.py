import os

from iob_module import iob_module

from iob_counter_ld import iob_counter_ld


class iob_modcnt(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_modcnt(),
            iob_counter_ld(),
        ]
