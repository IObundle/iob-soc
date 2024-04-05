from iob_core import iob_core


class iob_unpack(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "iob_bfifo",
            "iob_bfifo_inst",
        )

        self.create_instance(
            "iob_utils",
            "iob_utils_inst",
        )

        super().__init__(*args, **kwargs)
