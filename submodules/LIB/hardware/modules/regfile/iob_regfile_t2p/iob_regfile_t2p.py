import os

from iob_module import iob_module

from iob_sync import iob_sync


class iob_regfile_t2p(iob_module):
    name = "iob_regfile_t2p"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_sync,
            ]
        )
