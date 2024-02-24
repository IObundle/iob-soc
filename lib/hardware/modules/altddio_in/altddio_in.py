import os

from iob_module import iob_module


class altddion_in(iob_module):
    def __init__(self):
        self.name = "altddion_in"
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
