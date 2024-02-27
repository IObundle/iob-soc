import os

from iob_module import iob_module

from iob_reg_e import iob_reg_e
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_reg_e(),
            iob_mux(),
            iob_demux(),
        ]
