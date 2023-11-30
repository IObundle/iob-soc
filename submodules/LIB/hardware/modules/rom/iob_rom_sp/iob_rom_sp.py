import os


# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()


class iob_rom_sp(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_rom_sp"
        cls.version = "V0.10"
        cls.setup_dir = os.path.dirname(__file__)


if __name__ == "__main__":
    iob_rom_sp.setup_as_top_module()
