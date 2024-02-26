import os

from iob_module import iob_module

from iob_reg_e import iob_reg_e


class apb2iob(iob_module):
    def __init__(self):
        self.name = "apb2iob"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            {"interface": "iob_wire"},
            {"interface": "apb_s_port"},
            {"interface": "iob_s_portmap"},
            iob_reg_e(),
        ]
