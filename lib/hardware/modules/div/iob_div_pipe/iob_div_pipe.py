import sys

from iob_module import iob_module


class iob_div_pipe(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"


if __name__ == "__main__":
    # Create an iob_div_pipe ip core
    iob_div_pipe_core = iob_div_pipe()
    if "clean" in sys.argv:
        iob_div_pipe_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_div_pipe_core.print_build_dir()
    else:
        iob_div_pipe_core._setup()
