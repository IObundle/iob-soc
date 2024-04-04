from iob_core import iob_core


class iob_pack(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_bfifo",
            "iob_bfifo_inst",
        )

        self.create_instance(
            "iob_utils",
            "iob_utils_inst",
        )

        super().__init__(*args, **kwargs)
