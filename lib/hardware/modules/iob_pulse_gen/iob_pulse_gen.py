import sys

from iob_core import iob_core


class iob_pulse_gen(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )

        self.create_instance(
            "iob_counter",
            "iob_counter_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_pulse_gen.clean_build_dir()
    elif "print" in sys.argv:
        iob_pulse_gen.print_build_dir()
    else:
        iob_pulse_gen()
