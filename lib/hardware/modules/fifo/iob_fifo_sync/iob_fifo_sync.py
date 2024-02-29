import sys

from iob_module import iob_module

from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_counter import iob_counter
from iob_asym_converter import iob_asym_converter
from iob_ram_2p import iob_ram_2p
from iob_utils import iob_utils


class iob_fifo_sync(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_reg_r(),
            iob_reg(),
            iob_counter(),
            iob_asym_converter(),
            iob_utils(),
            (iob_ram_2p(), {"purpose": "simulation"}),
        ]


if __name__ == "__main__":
    # Create an iob_fifo_sync ip core
    iob_fifo_sync_core = iob_fifo_sync()
    if "clean" in sys.argv:
        iob_fifo_sync_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_fifo_sync_core.print_build_dir()
    else:
        iob_fifo_sync_core._setup()
