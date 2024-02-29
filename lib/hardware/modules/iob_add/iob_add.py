import os

from iob_module import iob_module

from iob_add2 import iob_add2


class iob_add(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_add2(),
        ]
