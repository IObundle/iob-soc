import os

from iob_module import iob_module


class altddion_out(iob_module):
    name = "altddion_out"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
