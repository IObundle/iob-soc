from iob_core import iob_core


class iob_neg2posedge_sync(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )

        self.create_instance(
            "iob_regn",
            "iob_regn_inst",
        )

        super().__init__(*args, **kwargs)
