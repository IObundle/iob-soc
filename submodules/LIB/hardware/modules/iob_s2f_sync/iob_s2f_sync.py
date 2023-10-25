import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_sync import iob_sync


class iob_s2f_sync(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_s2f_sync"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            iob_sync,
            {"interface": "clk_rst_s_port"},
            {"interface": "clk_rst_s_s_portmap"},
        ]


if __name__ == "__main__":
    iob_s2f_sync.setup_as_top_module()
