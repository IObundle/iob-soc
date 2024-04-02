from iob_core import iob_core


class iob_fp_fpu(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_instance(
            "iob_fp_add",
            "iob_fp_add_inst",
        )

        self.create_instance(
            "iob_fp_mul",
            "iob_fp_mul_inst",
        )

        self.create_instance(
            "iob_fp_div",
            "iob_fp_div_inst",
        )

        self.create_instance(
            "iob_fp_sqrt",
            "iob_fp_sqrt_inst",
        )

        self.create_instance(
            "iob_fp_minmax",
            "iob_fp_minmax_inst",
        )

        self.create_instance(
            "iob_fp_cmp",
            "iob_fp_cmp_inst",
        )

        self.create_instance(
            "iob_fp_int2float",
            "iob_fp_int2float_inst",
        )

        self.create_instance(
            "iob_fp_uint2float",
            "iob_fp_uint2float_inst",
        )

        self.create_instance(
            "iob_fp_float2int",
            "iob_fp_float2int_inst",
        )

        self.create_instance(
            "iob_fp_float2uint",
            "iob_fp_float2uint_inst",
        )

        super().__init__(*args, **kwargs)
