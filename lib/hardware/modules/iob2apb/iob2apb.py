import os

from iob_module import iob_module

from iob_reg import iob_reg


class iob2apb(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            {"interface": "iob_s_port"},
            {"interface": "apb_m_port"},
            # simulation
            ({"interface": "iob_s_s_portmap"}, {"purpose": "simulation"}),
            ({"interface": "iob_m_tb_wire"}, {"purpose": "simulation"}),
            iob_reg(),
        ]
