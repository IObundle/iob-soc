import sys

from iob_module import iob_module

from iob_reverse import iob_reverse


class iob_prio_enc(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reverse(),
        ]


if __name__ == "__main__":
    # Create an iob_prio_enc ip core
    iob_prio_enc_core = iob_prio_enc()
    if "clean" in sys.argv:
        iob_prio_enc_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_prio_enc_core.print_build_dir()
    else:
        iob_prio_enc_core._setup()
