import os

from iob_module import iob_module

from iob_add2 import iob_add2


class iob_add(iob_module):
    name = "iob_add"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_add2,
            ]
        )
