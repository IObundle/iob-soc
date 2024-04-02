import sys

from iob_core import iob_core


class axis2axi(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            signals=[],
        )
        self.create_port(
            name="axi",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="AXI master interface",
            signals=[],
            widths={
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
            },
        )
        self.create_port(
            name="axi_write",
            type="master",
            file_prefix="",
            wire_prefix="",
            port_prefix="",
            signals=[],
            widths={
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
            descr="AXI write interface",
        )
        self.create_port(
            name="axi_read",
            type="master",
            file_prefix="",
            wire_prefix="",
            port_prefix="",
            signals=[],
            widths={
                "ID_W": "AXI_ID_W",
                "ADDR_W": "AXI_ADDR_W",
                "DATA_W": "AXI_DATA_W",
                "LEN_W": "AXI_LEN_W",
            },
            descr="AXI read interface",
        )

        self.create_instance(
            "iob_fifo_sync",
            "iob_fifo_sync_inst",
        )

        self.create_instance(
            "iob_counter",
            "iob_counter_inst",
        )

        self.create_instance(
            "iob_reg_r",
            "iob_reg_r_inst",
        )

        self.create_instance(
            "iob_reg_re",
            "iob_reg_re_inst",
        )

        #self.create_instance(
        #    "axi_ram",
        #    "axi_ram_inst",
        #)

        #self.create_instance(
        #    "iob_ram_t2p",
        #    "iob_ram_t2p_inst",
        #)

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        axis2axi.clean_build_dir()
    elif "print" in sys.argv:
        axis2axi.print_build_dir()
    else:
        axis2axi()
