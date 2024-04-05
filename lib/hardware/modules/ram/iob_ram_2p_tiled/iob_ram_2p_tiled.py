import sys

from iob_core import iob_core


class iob_ram_2p_tiled(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "iob_ram_2p",
            "iob_ram_2p_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_ram_2p_tiled.clean_build_dir()
    elif "print" in sys.argv:
        iob_ram_2p_tiled.print_build_dir()
    else:
        iob_ram_2p_tiled()
