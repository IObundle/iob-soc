import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()


from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_modcnt import iob_modcnt
from iob_acc_ld import iob_acc_ld
from iob_utils import iob_utils


class iob_nco(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_nco"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "clk_en_rst"},
            iob_reg_r,
            iob_reg,
            iob_modcnt,
            iob_acc_ld,
            iob_utils,
        ]


if __name__ == "__main__":
    iob_nco.setup_as_top_module()
