import os

from iob_module import iob_module
from iob_reg_r import iob_reg_r


class iob_bfifo(iob_module):
    def __init__(self):
        self.name = "iob_bfifo"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodules_list = [
            iob_reg_r,
        ]
