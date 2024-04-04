from iob_core import iob_core


class iob_regfile_t2p(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_sync",
            "iob_sync_inst",
        )

        self.create_instance(
            "iob_reg_e",
            "iob_reg_e_inst",
        )

        super().__init__(*args, **kwargs)
