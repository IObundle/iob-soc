import os

from iob_core import iob_core


class iob_demux(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        super().__init__(*args, **kwargs)
