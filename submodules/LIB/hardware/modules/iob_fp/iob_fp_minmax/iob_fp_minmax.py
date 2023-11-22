import os

from iob_module import iob_module


class iob_fp_minmax(iob_module):
    name = "iob_fp_minmax"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
