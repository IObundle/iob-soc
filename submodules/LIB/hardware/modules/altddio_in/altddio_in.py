import os

from iob_module import iob_module


class altddion_in(iob_module):
    name = "altddion_in"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
