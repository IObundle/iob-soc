import os

from iob_module import iob_module

from iob_fp_clz import iob_fp_clz


class iob_fp_round(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_fp_clz(),
        ]
