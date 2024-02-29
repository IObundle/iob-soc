import sys

from iob_module import iob_module

from iob_utils import iob_utils
from iob_gray_counter import iob_gray_counter
from iob_gray2bin import iob_gray2bin
from iob_sync import iob_sync
from iob_asym_converter import iob_asym_converter
from iob_ram_t2p import iob_ram_t2p


class iob_fifo_async(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.submodule_list = [
            iob_utils(),
            iob_gray_counter(),
            iob_gray2bin(),
            iob_sync(),
            iob_asym_converter(),
            (iob_ram_t2p(), {"purpose": "simulation"}),
        ]


if __name__ == "__main__":
    # Create an iob_fifo_async ip core
    iob_fifo_async_core = iob_fifo_async()
    if "clean" in sys.argv:
        iob_fifo_async_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_fifo_async_core.print_build_dir()
    else:
        iob_fifo_async_core._setup()
