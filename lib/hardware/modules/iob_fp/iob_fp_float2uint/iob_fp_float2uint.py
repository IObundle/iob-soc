import os

from iob_module import iob_module

from iob_fp_dq import iob_fp_dq


class iob_fp_float2uint(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [iob_fp_dq()]
