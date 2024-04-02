import sys

from iob_core import iob_core


class iob_regfile_sp(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("version", "0.09")

        self.create_instance(
            "iob_reg_re",
            "iob_reg_re_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_regfile_sp.clean_build_dir()
    elif "print" in sys.argv:
        iob_regfile_sp.print_build_dir()
    else:
        iob_regfile_sp()
