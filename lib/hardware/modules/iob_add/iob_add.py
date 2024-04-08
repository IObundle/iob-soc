from iob_core import iob_core


class iob_add(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "iob_add2",
            "iob_add2_inst",
        )

        super().__init__(*args, **kwargs)
