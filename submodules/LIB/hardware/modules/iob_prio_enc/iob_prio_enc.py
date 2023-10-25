import os

from iob_module import iob_module

from iob_reverse import iob_reverse


class iob_prio_enc(iob_module):
    name = "iob_prio_enc"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_reverse,
            ]
        )
