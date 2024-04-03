from iob_core import iob_core


class iob_modcnt(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_modcnt",
            "iob_modcnt_inst",
        )

        self.create_instance(
            "iob_counter_ld",
            "iob_counter_ld_inst",
        )

        super().__init__(*args, **kwargs)
