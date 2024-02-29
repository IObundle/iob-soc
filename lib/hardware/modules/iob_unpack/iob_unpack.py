import os

from iob_module import iob_module
from iob_bfifo import iob_bfifo
from iob_utils import iob_utils


class iob_unpack(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_bfifo(),
            iob_utils(),
        ]
