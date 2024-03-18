from dataclasses import dataclass, field
from typing import Dict, List

from iob_module import iob_module

from iob_reg_r import iob_reg_r
from iob_mux import iob_mux
from iob_demux import iob_demux
from iob_prio_enc import iob_prio_enc

import io_gen


@dataclass
class iob_merge2(iob_module):
    version = "V0.10"
    name_prefix: str = ""
    data_w: str = "DATA_W"
    addr_w: str = "ADDR_W"
    split_ptr: str = "ADDR_W-2"
    input_ios: List = field(default_factory=list)
    output_io: Dict = field(default_factory=dict)
    build_dir: str = "."

    def __post_init__(self) -> None:
        self.submodule_list = [
            iob_reg_r(),
            iob_mux(),
            iob_demux(),
            iob_prio_enc(),
        ]
        self.num_merges: int = len(self.input_ios)
        self.name: str = f"iob_{self.name_prefix}_merge2"
        self.confs = [
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
            },
        ]
        self.ios: List = [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and async reset",
                "ports": [],
                "connect_to_port": True,
            },
            {
                "name": "rst",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": f"{self.name}_",
                "descr": "Sync reset",
                "ports": [
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": "1",
                        "descr": "Sync reset",
                    },
                ],
            },
        ]
        for input_io in self.input_ios:
            copy_input_io = input_io.copy()
            copy_input_io["is_io"] = True
            self.ios.append(copy_input_io)
        self.output_io = self.output_io.copy()
        self.output_io["is_io"] = True
        self.ios.append(self.output_io)

    def gen_vlog_header(self, f):
        f.write("`timescale 1ns / 1ps\n\n")
        f.write(f'`include "{self.name}_conf.vh"\n\n')
        f.write(f"module {self.name} #(\n")
        f.write(f'\t`include "{self.name}_params.vs"\n')
        f.write(") (\n")
        f.write(f'\t`include "{self.name}_io.vs"\n')
        f.write(");\n\n")
        f.write(f"\tlocalparam NBITS = {(self.num_merges-1).bit_length()};\n")
        f.write("\twire [NBITS-1:0] sel, sel_reg;\n\n")

    def gen_vlog_aux_signals(self, f):
        f.write("\tiob_prio_enc #(\n")
        f.write(f"\t  .W ({self.num_merges}),\n")
        f.write('\t  .MODE("HIGH")\n')
        f.write("\t) sel_enc0 (\n")
        f.write("\t  .unencoded_i(mux_valid_din),\n")
        f.write("\t  .encoded_o(sel)\n")
        f.write("\t);\n\n")
        f.write("\tiob_reg_r #(\n")
        f.write("\t  .DATA_W (NBITS),\n")
        f.write("\t  .RST_VAL(0)\n")
        f.write("\t) sel_reg0 (\n")
        f.write('\t  `include "clk_en_rst_s_s_portmap.vs"\n')
        f.write("\t  .rst_i(rst_i),\n")
        f.write("\t  .data_i(sel),\n")
        f.write("\t  .data_o(sel_reg)\n")
        f.write("\t);\n\n")

    def gen_vlog_demux(self, f, data_w, signal, sel="sel"):
        f.write(f"\t//{signal}\n")
        demux_data_o = f"demux_{signal}_dout"
        demux_data_i = f'{self.output_io["port_prefix"]}iob_{signal}_i'
        f.write(f"\twire[{self.num_merges}*{data_w}-1:0] {demux_data_o};\n")
        idx = 0
        for input in self.input_ios:
            output_wire = f'{input["port_prefix"]}iob_{signal}_o'
            f.write(
                f"\tassign {output_wire} = {demux_data_o}[{idx}*{data_w}+:{data_w}];\n"
            )
            idx += 1
        f.write("\n\tiob_demux #(\n")
        f.write(f"\t  .DATA_W ({data_w}),\n")
        f.write(f"\t  .N ({self.num_merges})\n")
        f.write(f"\t) iob_demux_{signal} (\n")
        f.write(f"\t  .sel_i({sel}),\n")
        f.write(f"\t  .data_i({demux_data_i}),\n")
        f.write(f"\t  .data_o({demux_data_o})\n")
        f.write("\t);\n\n")

    def gen_vlog_mux(self, f, data_w, signal):
        f.write(f"\t//{signal}\n")
        mux_data_i = f"mux_{signal}_din"
        mux_data_o = f'{self.output_io["port_prefix"]}iob_{signal}_o'
        f.write(f"\twire [{self.num_merges}*{data_w}-1:0] {mux_data_i};\n")
        f.write(f"\tassign {mux_data_i} = {{\n")
        first_wire = True
        # reverse: most significant to least significant signal
        for input in reversed(self.input_ios):
            input_wire = f'{input["port_prefix"]}iob_{signal}_i'
            if not first_wire:
                f.write(",\n")
            f.write(f"\t\t{input_wire}")
            first_wire = False
        f.write("\n\t};\n")
        f.write("\n\tiob_mux #(\n")
        f.write(f"\t  .DATA_W ({data_w}),\n")
        f.write(f"\t  .N ({self.num_merges})\n")
        f.write(f"\t) iob_mux_{signal} (\n")
        f.write("\t  .sel_i(sel),\n")
        f.write(f"\t  .data_i({mux_data_i}),\n")
        f.write(f"\t  .data_o({mux_data_o})\n")
        f.write("\t);\n\n")

    def gen_verilog_module(self, top_dir="."):
        file_name = f"{top_dir}/hardware/src/{self.name}.v"
        with open(file_name, "w") as f:
            self.gen_vlog_header(f)
            self.gen_vlog_mux(f, 1, "valid")
            self.gen_vlog_mux(f, "ADDR_W", "addr")
            self.gen_vlog_mux(f, "DATA_W", "wdata")
            self.gen_vlog_mux(f, "DATA_W/8", "wstrb")
            self.gen_vlog_demux(f, "DATA_W", "rdata", sel="sel_reg")
            self.gen_vlog_demux(f, 1, "rvalid", sel="sel_reg")
            self.gen_vlog_demux(f, 1, "ready")
            self.gen_vlog_aux_signals(f)
            f.write("endmodule")

    def gen_verilog_instance(self, top_dir="."):
        file_name = f"{top_dir}/hardware/src/{self.name}_inst.vs"
        with open(file_name, "w") as f:
            f.write(f"\n\t{self.name} #(\n")
            f.write(f"\t\t.ADDR_W({self.addr_w}),\n")
            f.write(f"\t\t.DATA_W({self.data_w})\n")
            f.write(f"\t) {self.name} (\n")
            f.write(f'\t`include "{self.name}_io_portmap.vs"\n')
            f.write("\t);\n\n")

    def _setup(self, *args, **kwargs):
        try:
            top_dir = args[2]
        except IndexError:
            top_dir = "."
        self.gen_verilog_module(top_dir)
        self.gen_verilog_instance(top_dir)
        super()._setup(*args, **kwargs)


if __name__ == "__main__":
    test_merge = iob_merge2(
        name_prefix="test",
        data_w="32",
        addr_w="32",
        split_ptr="32 - 2",
        input_ios=[
            {
                "name": "iob",
                "type": "slave",
                "file_prefix": "merge_in_ram_w_",
                "port_prefix": "ram_w_",
                "wire_prefix": "ram_w_",
                "param_prefix": "",
                "descr": "merge input ram_w",
                "ports": [],
                "widths": {
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
            {
                "name": "iob",
                "type": "slave",
                "file_prefix": "merge_in_ram_r_",
                "port_prefix": "ram_r_",
                "wire_prefix": "ram_r_",
                "param_prefix": "",
                "descr": "merge input ram_r",
                "ports": [],
                "widths": {
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
        ],
        output_io={
            "name": "iob",
            "type": "master",
            "file_prefix": "merge_out_ram_i_",
            "port_prefix": "ram_i_",
            "wire_prefix": "ram_i_",
            "param_prefix": "",
            "descr": "merge output ram_i",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        },
    )
    test_merge.gen_verilog_module(top_dir=".")
    test_merge.gen_verilog_instance(top_dir=".")
    io_gen.generate_ports(test_merge)
