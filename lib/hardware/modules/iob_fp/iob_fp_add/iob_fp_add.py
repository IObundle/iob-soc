from iob_core import iob_core


class iob_fp_add(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "iob_fp_special",
            "iob_fp_special_inst",
        )

        self.create_instance(
            "iob_fp_clz",
            "iob_fp_clz_inst",
        )

        self.create_instance(
            "iob_fp_round",
            "iob_fp_round_inst",
        )

        super().__init__(*args, **kwargs)
