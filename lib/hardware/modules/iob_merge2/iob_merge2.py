import os

from iob_module import iob_module

from iob_reg import iob_reg
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge2(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reg(),
            iob_mux(),
            iob_demux(),
        ]