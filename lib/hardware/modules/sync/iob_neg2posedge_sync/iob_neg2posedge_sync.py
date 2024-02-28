import os

from iob_module import iob_module

from iob_reg import iob_reg
from iob_regn import iob_regn


class iob_neg2posedge_sync(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            {"interface": "clk_rst_s_port"},
            iob_reg(),
            iob_regn(),
        ]
