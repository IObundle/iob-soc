import sys

from iob_module import iob_module


class iob_ram_sp(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"


if __name__ == "__main__":
    # Create an iob_ram_sp ip core
    iob_ram_sp_core = iob_ram_sp()
    if "clean" in sys.argv:
        iob_ram_sp_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_ram_sp_core.print_build_dir()
    else:
        iob_ram_sp_core._setup()
