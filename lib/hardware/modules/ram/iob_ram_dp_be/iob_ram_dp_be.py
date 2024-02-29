import sys

from iob_module import iob_module
from iob_ram_dp import iob_ram_dp


class iob_ram_dp_be(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_ram_dp(),
        ]


if __name__ == "__main__":
    # Create an iob_ram_dp_be ip core
    iob_ram_dp_be_core = iob_ram_dp_be()
    if "clean" in sys.argv:
        iob_ram_dp_be_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_ram_dp_be_core.print_build_dir()
    else:
        iob_ram_dp_be_core._setup()
