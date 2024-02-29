import sys

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class iob_regfile_sp(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.previous_version = "V0.09"
        self.submodule_list = [
            iob_reg_re(),
        ]


if __name__ == "__main__":
    # Create an iob_regfile_sp ip core
    iob_regfile_sp_core = iob_regfile_sp()
    if "clean" in sys.argv:
        iob_regfile_sp_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_regfile_sp_core.print_build_dir()
    else:
        iob_regfile_sp_core._setup()
