import sys

from iob_core import iob_core


class axis2axi(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            signals=[],
        )
        self.create_port(
            name="rst",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Synchronous reset interface",
            ports=[
                {
                    "name": "rst",
                    "direction": "input",
                    "width": 1,
                    "descr": "Synchronous reset input",
                },
            ],
        )
        self.create_port(
            name="config_in",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="AXI Stream input configuration interface",
            ports=[
                {
                    "name": "config_in_addr",
                    "direction": "input",
                    "width": "AXI_ADDR_W",
                    "descr": "",
                },
                {
                    "name": "config_in_valid",
                    "direction": "input",
                    "width": 1,
                    "descr": "",
                },
                {
                    "name": "config_in_ready",
                    "direction": "output",
                    "width": 1,
                    "descr": "",
                },
            ],
        )
        self.create_port(
            name="config_out",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="AXI Stream output configuration interface",
            ports=[
                {
                    "name": "config_out_addr",
                    "direction": "input",
                    "width": "AXI_ADDR_W",
                    "descr": "",
                },
                {
                    "name": "config_out_length",
                    "direction": "input",
                    "width": "AXI_ADDR_W",
                    "descr": "",
                },
                {
                    "name": "config_out_valid",
                    "direction": "input",
                    "width": 1,
                    "descr": "",
                },
                {
                    "name": "config_out_ready",
                    "direction": "output",
                    "width": 1,
                    "descr": "",
                },
            ],
        )
        self.create_port(
            name="axis_in",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="AXI Stream input interface",
            ports=[
                {
                    "name": "axis_in_data",
                    "direction": "input",
                    "width": "AXI_DATA_W",
                    "descr": "",
                },
                {
                    "name": "axis_in_valid",
                    "direction": "input",
                    "width": 1,
                    "descr": "",
                },
                {
                    "name": "axis_in_ready",
                    "direction": "output",
                    "width": 1,
                    "descr": "",
                },
            ],
        )
        self.create_port(
            name="axis_out",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="AXI Stream output interface",
            ports=[
                {
                    "name": "axis_out_data",
                    "direction": "output",
                    "width": "AXI_DATA_W",
                    "descr": "",
                },
                {
                    "name": "axis_out_valid",
                    "direction": "output",
                    "width": 1,
                    "descr": "",
                },
                {
                    "name": "axis_out_ready",
                    "direction": "input",
                    "width": 1,
                    "descr": "",
                },
            ],
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
        # Not real ports of axis2axi
        # self.create_port(
        #    name="axi_write",
        #    type="master",
        #    file_prefix="",
        #    wire_prefix="",
        #    port_prefix="",
        #    signals=[],
        #    widths={
        #        "ID_W": "AXI_ID_W",
        #        "ADDR_W": "AXI_ADDR_W",
        #        "DATA_W": "AXI_DATA_W",
        #        "LEN_W": "AXI_LEN_W",
        #    },
        #    descr="AXI write interface",
        # )
        # self.create_port(
        #    name="axi_read",
        #    type="master",
        #    file_prefix="",
        #    wire_prefix="",
        #    port_prefix="",
        #    signals=[],
        #    widths={
        #        "ID_W": "AXI_ID_W",
        #        "ADDR_W": "AXI_ADDR_W",
        #        "DATA_W": "AXI_DATA_W",
        #        "LEN_W": "AXI_LEN_W",
        #    },
        #    descr="AXI read interface",
        # )
        self.create_port(
            name="extmem",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="External memory interface",
            ports=[
                #  Write port
                {
                    "name": "ext_mem_w_en",
                    "direction": "output",
                    "width": 1,
                    "descr": "Memory write enable",
                },
                {
                    "name": "ext_mem_w_addr",
                    "direction": "output",
                    "width": "BUFFER_W",
                    "descr": "Memory write address",
                },
                {
                    "name": "ext_mem_w_data",
                    "direction": "output",
                    "width": "AXI_DATA_W",
                    "descr": "Memory write data",
                },
                #  Read port
                {
                    "name": "ext_mem_r_en",
                    "direction": "output",
                    "width": 1,
                    "descr": "Memory read enable",
                },
                {
                    "name": "ext_mem_r_addr",
                    "direction": "output",
                    "width": "BUFFER_W",
                    "descr": "Memory read address",
                },
                {
                    "name": "ext_mem_r_data",
                    "direction": "input",
                    "width": "AXI_DATA_W",
                    "descr": "Memory read data",
                },
            ],
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

        # For simulation
        self.create_instance(
            "axi_ram",
            "axi_ram_inst",
        )
        self.create_instance(
            "iob_ram_t2p",
            "iob_ram_t2p_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        axis2axi.clean_build_dir()
    elif "print" in sys.argv:
        axis2axi.print_build_dir()
    else:
        axis2axi()
