import sys

from iob_core import iob_core


class iob_div_pipe(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_div_pipe.clean_build_dir()
    elif "print" in sys.argv:
        iob_div_pipe.print_build_dir()
    else:
        iob_div_pipe()
