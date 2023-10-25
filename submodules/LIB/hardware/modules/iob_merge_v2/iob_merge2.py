import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge2(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_merge2"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            iob_reg,
            iob_mux,
            iob_demux,
        ]


if __name__ == "__main__":
    iob_merge2.setup_as_top_module()
