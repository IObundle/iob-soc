import os

from iob_module import iob_module

from iob_fp_add import iob_fp_add
from iob_fp_mul import iob_fp_mul
from iob_fp_div import iob_fp_div
from iob_fp_sqrt import iob_fp_sqrt
from iob_fp_minmax import iob_fp_minmax
from iob_fp_cmp import iob_fp_cmp
from iob_fp_int2float import iob_fp_int2float
from iob_fp_uint2float import iob_fp_uint2float
from iob_fp_float2int import iob_fp_float2int
from iob_fp_float2uint import iob_fp_float2uint


class iob_fp_fpu(iob_module):
    name = "iob_fp_fpu"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_fp_add,
                iob_fp_mul,
                iob_fp_div,
                iob_fp_sqrt,
                iob_fp_minmax,
                iob_fp_cmp,
                iob_fp_int2float,
                iob_fp_uint2float,
                iob_fp_float2int,
                iob_fp_float2uint,
            ]
        )
