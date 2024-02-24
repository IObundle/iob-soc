import os

from iob_module import iob_module

from iob_reverse import iob_reverse
from iob_prio_enc import iob_prio_enc


class iob_ctls(iob_module):
    def __init__(self):
        self.name = "iob_ctls"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodules_list = [
            iob_reverse,
            iob_prio_enc,
        ]
