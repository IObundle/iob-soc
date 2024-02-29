import sys

from iob_module import iob_module

from iob_and import iob_and
from iob_or import iob_or
from iob_inv import iob_inv


class iob_aoi(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_and(),
            iob_or(),
            iob_inv(),
        ]


if __name__ == "__main__":
    # Create an iob_aoi ip core
    iob_aoi_core = iob_aoi()
    if "clean" in sys.argv:
        iob_aoi_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_aoi_core.print_build_dir()
    else:
        iob_aoi_core._setup()
