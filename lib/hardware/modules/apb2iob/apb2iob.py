import os

from iob_module import iob_module

from iob_reg_e import iob_reg_e


class apb2iob(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            {"interface": "iob_wire"},
            {"interface": "apb_s_port"},
            {"interface": "iob_s_portmap"},
            iob_reg_e(),
        ]
