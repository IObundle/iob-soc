import os

from iob_module import iob_module

from iob_counter_ld import iob_counter_ld


class iob_modcnt(iob_module):
    name = "iob_modcnt"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_modcnt,
                iob_counter_ld,
            ]
        )
