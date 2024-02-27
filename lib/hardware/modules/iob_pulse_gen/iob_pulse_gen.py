import os

from iob_module import iob_module

from iob_reg import iob_reg
from iob_counter import iob_counter


class iob_pulse_gen(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_reg(),
            iob_counter(),
        ]
