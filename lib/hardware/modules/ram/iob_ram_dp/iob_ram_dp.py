import sys

from iob_module import iob_module


class iob_ram_dp(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.previous_version = "V0.09"


if __name__ == "__main__":
    # Create an iob_ram_dp ip core
    iob_ram_dp_core = iob_ram_dp()
    if "clean" in sys.argv:
        iob_ram_dp_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_ram_dp_core.print_build_dir()
    else:
        iob_ram_dp_core._setup()
