import os

from iob_module import iob_module
from iob_bfifo import iob_bfifo
from iob_utils import iob_utils


class iob_pack(iob_module):
    def __init__(self):
        self.name = "iob_pack"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_bfifo(),
            iob_utils(),
        ]
