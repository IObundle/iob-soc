import sys

from iob_core import iob_core


class iob_div_subshift_frac(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )

        self.create_instance(
            "iob_reg_e",
            "iob_reg_e_inst",
        )

        self.create_instance(
            "iob_div_subshift",
            "iob_div_subshift_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_div_subshift_frac.clean_build_dir()
    elif "print" in sys.argv:
        iob_div_subshift_frac.print_build_dir()
    else:
        iob_div_subshift_frac()
