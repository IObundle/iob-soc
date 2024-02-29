import sys

from iob_module import iob_module

from iob_ram_sp import iob_ram_sp


class iob_ram_sp_se(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_ram_sp(),
        ]


if __name__ == "__main__":
    # Create an iob_ram_sp_se ip core
    iob_ram_sp_se_core = iob_ram_sp_se()
    if "clean" in sys.argv:
        iob_ram_sp_se_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_ram_sp_se_core.print_build_dir()
    else:
        iob_ram_sp_se_core._setup()
