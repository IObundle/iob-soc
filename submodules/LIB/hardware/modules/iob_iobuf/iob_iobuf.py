import os

from iob_module import iob_module


class iob_iobuf(iob_module):
    name = "iob_iobuf"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
