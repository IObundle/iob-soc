import os

from iob_module import iob_module
from iob_counter import iob_counter
from iob_edge_detect import iob_edge_detect


class axis2fifo(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.submodule_list = [
            iob_counter(),
            iob_edge_detect(),
        ]
