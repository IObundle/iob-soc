from iob_core import iob_core


class iob_merge2(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )

        self.create_instance(
            "iob_mux",
            "iob_mux_inst",
        )

        self.create_instance(
            "iob_demux",
            "iob_demux_inst",
        )

        super().__init__(*args, **kwargs)
