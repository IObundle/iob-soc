import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reverse import iob_reverse
from iob_prio_enc import iob_prio_enc


class iob_ctls(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_ctls"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            iob_reverse,
            iob_prio_enc,
        ]


if __name__ == "__main__":
    iob_ctls.setup_as_top_module()
