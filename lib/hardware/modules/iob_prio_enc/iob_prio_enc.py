import sys

from iob_core import iob_core



class iob_prio_enc(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_reverse",
            "iob_reverse_inst",
        )

        super().__init__(*args, **kwargs)

if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_prio_enc.clean_build_dir()
    elif "print" in sys.argv:
        iob_prio_enc.print_build_dir()
    else:
        iob_prio_enc()
