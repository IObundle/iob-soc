import os

from iob_module import iob_module


class iob_demux(iob_module):
    name = "iob_demux"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)
