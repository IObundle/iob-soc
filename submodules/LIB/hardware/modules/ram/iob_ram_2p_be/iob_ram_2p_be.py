import os

from iob_module import iob_module


class iob_ram_2p_be(iob_module):
    name = "iob_ram_2p_be"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
