import os

from iob_module import iob_module


class iob_reg(iob_module):
    name = "iob_reg"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "clk_en_rst_s_port"},
            ]
        )

    @classmethod
    def _setup_confs(cls):
        _confs = [
            {
                "name": "RST_POL",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Reset polarity is high.",
            },
        ]

