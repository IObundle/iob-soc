import os

from iob_module import iob_module


class alt_iobuf(iob_module):
    name = "alt_iobuf"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
