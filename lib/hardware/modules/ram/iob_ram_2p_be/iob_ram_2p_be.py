import sys

from iob_module import iob_module


class iob_ram_2p_be(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"


if __name__ == "__main__":
    # Create an iob_ram_2p_be ip core
    iob_ram_2p_be_core = iob_ram_2p_be()
    if "clean" in sys.argv:
        iob_ram_2p_be_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_ram_2p_be_core.print_build_dir()
    else:
        iob_ram_2p_be_core._setup()