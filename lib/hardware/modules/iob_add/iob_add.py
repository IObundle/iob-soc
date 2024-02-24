import os

from iob_module import iob_module

from iob_add2 import iob_add2


class iob_add(iob_module):
    def __init__(self):
        self.name = "iob_add"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodules_list = [
            iob_add2,
        ]
