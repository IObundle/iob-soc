import os

from iob_module import iob_module

from iob_reg import iob_reg
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_split2(iob_module):
    def __init__(self):
        super().__init__()
        self.name = "iob_split2"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            {"interface": "iob_s_port"},
            {"interface": "iob_m_port"},
            iob_reg(),
            iob_mux(),
            iob_demux(),
        ]
