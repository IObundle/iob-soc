import sys

from iob_core import iob_core


class iob_fifo_async(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_port(
            name="write",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Write interface",
            ports=[
                {
                    "name": "w_clk",
                    "direction": "input",
                    "width": 1,
                    "descr": "Write clock",
                },
                {
                    "name": "w_cke",
                    "direction": "input",
                    "width": 1,
                    "descr": "Write clock enable",
                },
                {
                    "name": "w_arst",
                    "direction": "input",
                    "width": 1,
                    "descr": "Write async reset",
                },
                {
                    "name": "w_rst",
                    "direction": "input",
                    "width": 1,
                    "descr": "Write sync reset",
                },
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
                {
                    "name": "w_empty",
                    "direction": "output",
                    "width": 1,
                    "descr": "Write empty signal",
                },
                {
                    "name": "w_level",
                    "direction": "output",
                    "width": "ADDR_W+1",
                    "descr": "Write fifo level",
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
                    "name": "r_clk",
                    "direction": "input",
                    "width": 1,
                    "descr": "Read clock",
                },
                {
                    "name": "r_cke",
                    "direction": "input",
                    "width": 1,
                    "descr": "Read clock enable",
                },
                {
                    "name": "r_arst",
                    "direction": "input",
                    "width": 1,
                    "descr": "Read async reset",
                },
                {
                    "name": "r_rst",
                    "direction": "input",
                    "width": 1,
                    "descr": "Read sync reset",
                },
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
                    "name": "r_full",
                    "direction": "output",
                    "width": 1,
                    "descr": "Read full signal",
                },
                {
                    "name": "r_empty",
                    "direction": "output",
                    "width": 1,
                    "descr": "Read empty signal",
                },
                {
                    "name": "r_level",
                    "direction": "output",
                    "width": "ADDR_W+1",
                    "descr": "Read fifo level",
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
                #  Write port
                {
                    "name": "ext_mem_w_clk",
                    "direction": "output",
                    "width": 1,
                    "descr": "Memory clock",
                },
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
                    "name": "ext_mem_r_clk",
                    "direction": "output",
                    "width": 1,
                    "descr": "Memory clock",
                },
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

        self.create_instance(
            "iob_gray_counter",
            "iob_gray_counter_inst",
        )

        self.create_instance(
            "iob_gray2bin",
            "iob_gray2bin_inst",
        )

        self.create_instance(
            "iob_sync",
            "iob_sync_inst",
        )

        self.create_instance(
            "iob_asym_converter",
            "iob_asym_converter_inst",
        )

        # For simulation
        self.create_instance(
            "iob_ram_t2p",
            "iob_ram_t2p_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_fifo_async.clean_build_dir()
    elif "print" in sys.argv:
        iob_fifo_async.print_build_dir()
    else:
        iob_fifo_async()
