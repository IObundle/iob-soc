import sys

from iob_core import iob_core


class iob_fifo_async(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_utils",
            "iob_utils_inst",
        )

        self.create_instance(
            "iob_gray_counter",
            "iob_gray_counter_inst",
        )

        self.create_instance(
            "iob_gray2bin",
            "iob_gray2bin_inst",
        )

        self.create_instance(
            "iob_sync",
            "iob_sync_inst",
        )

        self.create_instance(
            "iob_asym_converter",
            "iob_asym_converter_inst",
        )

        # self.create_instance(
        #     "iob_ram_t2p",
        #     "iob_ram_t2p_inst",
        # )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_fifo_async.clean_build_dir()
    elif "print" in sys.argv:
        iob_fifo_async.print_build_dir()
    else:
        iob_fifo_async()
