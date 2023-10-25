import os


from iob_module import iob_module


class iob_rom_sp(iob_module):
    name = "iob_rom_sp"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
