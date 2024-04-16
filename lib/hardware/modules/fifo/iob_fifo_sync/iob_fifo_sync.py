import sys

from iob_core import iob_core


class iob_fifo_sync(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            ports=[],
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
            name="write",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Write interface",
            ports=[
                {
                    "name": "w_en",
                    "direction": "input",
                    "width": 1,
                    "descr": "Write enable",
                },
                {
                    "name": "w_data",
                    "direction": "input",
                    "width": "W_DATA_W",
                    "descr": "Write data",
                },
                {
                    "name": "w_full",
                    "direction": "output",
                    "width": 1,
                    "descr": "Write full signal",
                },
            ],
        )
        self.create_port(
            name="read",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Read interface",
            ports=[
                {
                    "name": "r_en",
                    "direction": "input",
                    "width": 1,
                    "descr": "Read enable",
                },
                {
                    "name": "r_data",
                    "direction": "output",
                    "width": "R_DATA_W",
                    "descr": "Read data",
                },
                {
                    "name": "r_empty",
                    "direction": "output",
                    "width": 1,
                    "descr": "Read empty signal",
                },
            ],
        )
        self.create_port(
            name="extmem",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="External memory interface",
            ports=[
                {
                    "name": "ext_mem_clk",
                    "direction": "output",
                    "width": 1,
                    "descr": "Memory clock",
                },
                #  Write port
                {
                    "name": "ext_mem_w_en",
                    "direction": "output",
                    "width": "R",
                    "descr": "Memory write enable",
                },
                {
                    "name": "ext_mem_w_addr",
                    "direction": "output",
                    "width": "MINADDR_W",
                    "descr": "Memory write address",
                },
                {
                    "name": "ext_mem_w_data",
                    "direction": "output",
                    "width": "MAXDATA_W",
                    "descr": "Memory write data",
                },
                #  Read port
                {
                    "name": "ext_mem_r_en",
                    "direction": "output",
                    "width": "R",
                    "descr": "Memory read enable",
                },
                {
                    "name": "ext_mem_r_addr",
                    "direction": "output",
                    "width": "MINADDR_W",
                    "descr": "Memory read address",
                },
                {
                    "name": "ext_mem_r_data",
                    "direction": "input",
                    "width": "MAXDATA_W",
                    "descr": "Memory read data",
                },
            ],
        )
        self.create_port(
            name="fifo",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="FIFO interface",
            ports=[
                {
                    "name": "level",
                    "direction": "output",
                    "width": "ADDR_W+1",
                    "descr": "FIFO level",
                },
            ],
        )

        self.create_instance(
            "iob_reg_r",
            "iob_reg_r_inst",
        )

        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )

        self.create_instance(
            "iob_counter",
            "iob_counter_inst",
        )

        self.create_instance(
            "iob_asym_converter",
            "iob_asym_converter_inst",
        )

        # For simulation
        self.create_instance(
            "iob_ram_2p",
            "iob_ram_2p_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_fifo_sync.clean_build_dir()
    elif "print" in sys.argv:
        iob_fifo_sync.print_build_dir()
    else:
        iob_fifo_sync()
