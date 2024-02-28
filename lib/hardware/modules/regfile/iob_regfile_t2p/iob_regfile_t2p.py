import os

from iob_module import iob_module
from iob_sync import iob_sync
from iob_reg_e import iob_reg_e


class iob_regfile_t2p(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [iob_sync(), iob_reg_e()]
