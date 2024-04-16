import sys

from iob_core import iob_core


class iob_nco(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "iob_reg_r",
            "iob_reg_r_inst",
        )
        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )
        self.create_instance(
            "iob_modcnt",
            "iob_modcnt_inst",
        )
        self.create_instance(
            "iob_acc_ld",
            "iob_acc_ld_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_nco.clean_build_dir()
    elif "print" in sys.argv:
        iob_nco.print_build_dir()
    else:
        iob_nco()
