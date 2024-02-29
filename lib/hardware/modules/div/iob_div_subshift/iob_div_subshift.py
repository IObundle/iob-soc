import sys

from iob_module import iob_module

from iob_reg import iob_reg


class iob_div_subshift(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reg(),
        ]


if __name__ == "__main__":
    # Create an iob_div_subshift ip core
    iob_div_subshift_core = iob_div_subshift()
    if "clean" in sys.argv:
        iob_div_subshift_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_div_subshift_core.print_build_dir()
    else:
        iob_div_subshift_core._setup()
