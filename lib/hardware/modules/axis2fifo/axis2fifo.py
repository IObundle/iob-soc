from iob_core import iob_core

class axis2fifo(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_counter",
            "iob_counter_inst",
        )

        self.create_instance(
            "iob_edge_detect",
            "iob_edge_detect_inst",
        )

        super().__init__(*args, **kwargs)
