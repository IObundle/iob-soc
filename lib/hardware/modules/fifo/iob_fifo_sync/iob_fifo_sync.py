from iob_core import iob_core


class iob_fifo_sync(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_reg_r",
            "iob_reg_r_inst",
        )

        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )

        self.create_instance(
            "iob_counter",
            "iob_counter_inst",
        )

        self.create_instance(
            "iob_asym_converter",
            "iob_asym_converter_inst",
        )

        self.create_instance(
            "iob_utils",
            "iob_utils_inst",
        )

        # self.create_instance(
        #     "iob_ram_2p",
        #     "iob_ram_2p_inst",
        # )

        super().__init__(*args, **kwargs)

if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_fifo_sync.clean_build_dir()
    elif "print" in sys.argv:
        iob_fifo_sync.print_build_dir()
    else:
        iob_fifo_sync()
