import os

from iob_module import iob_module


class iob_div_pipe(iob_module):
    name = "iob_div_pipe"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
