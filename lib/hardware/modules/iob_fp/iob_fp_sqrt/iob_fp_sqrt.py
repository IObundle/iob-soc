from iob_core import iob_core


class iob_fp_sqrt(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_int_sqrt",
            "iob_int_sqrt_inst",
        )

        super().__init__(*args, **kwargs)
