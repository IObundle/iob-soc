import sys

from iob_module import iob_module

from iob_reg import iob_reg
from iob_counter import iob_counter


class iob_pulse_gen(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reg(),
            iob_counter(),
        ]


if __name__ == "__main__":
    # Create an iob_pulse_gen ip core
    iob_pulse_gen_core = iob_pulse_gen()
    if "clean" in sys.argv:
        iob_pulse_gen_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_pulse_gen_core.print_build_dir()
    else:
        iob_pulse_gen_core._setup()
