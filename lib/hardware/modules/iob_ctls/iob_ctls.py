import sys

from iob_module import iob_module

from iob_reverse import iob_reverse
from iob_prio_enc import iob_prio_enc


class iob_ctls(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reverse(),
            iob_prio_enc(),
        ]


if __name__ == "__main__":
    # Create an iob_ctls ip core
    iob_ctls_core = iob_ctls()
    if "clean" in sys.argv:
        iob_ctls_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_ctls_core.print_build_dir()
    else:
        iob_ctls_core._setup()
