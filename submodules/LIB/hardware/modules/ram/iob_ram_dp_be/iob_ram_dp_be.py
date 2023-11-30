import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_ram_dp import iob_ram_dp


class iob_ram_dp_be(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_ram_dp_be"
        cls.version = "V0.10"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            iob_ram_dp,
        ]


if __name__ == "__main__":
    iob_ram_dp_be.setup_as_top_module()
