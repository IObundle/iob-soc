import os

from iob_module import iob_module


class iob_mux(iob_module):
    name = "iob_mux"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
