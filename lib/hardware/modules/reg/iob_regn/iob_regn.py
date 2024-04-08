from iob_core import iob_core


class iob_regn(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_conf(
            name="DATA_W",
            type="P",
            val="1",
            min="NA",
            max="NA",
            descr="Data bus width",
        )
        self.create_conf(
            name="RST_VAL",
            type="P",
            val="{DATA_W{1'b0}}",
            min="NA",
            max="NA",
            descr="Reset value.",
        )
        self.create_conf(
            name="RST_POL",
            type="M",
            val="1",
            min="0",
            max="1",
            descr="Reset polarity.",
        )

        super().__init__(*args, **kwargs)
