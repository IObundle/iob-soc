import sys

from iob_core import iob_core


class iob_ctls(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_reverse",
            "iob_reverse_inst",
        )

        self.create_instance(
            "iob_prio_enc",
            "iob_prio_enc_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_ctls.clean_build_dir()
    elif "print" in sys.argv:
        iob_ctls.print_build_dir()
    else:
        iob_ctls()
