from iob_core import iob_core


class apb2iob(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_reg_e",
            "iob_reg_e_inst",
        )

        super().__init__(*args, **kwargs)
