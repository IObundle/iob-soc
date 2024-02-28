import os
import shutil

from iob_module import iob_module


class iob_utils(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
