#!/usr/bin/env python3
#
#    wire_gen.py: build Verilog module wires
#

import if_gen
import os


def generate_wires(core):
    out_dir = core.build_dir + "/hardware/src"

    f_wires = open(f"{out_dir}/{core.name}_wires.vs", "w+")

    for wire in core.wires:
        # Open ifdef if conditional interface
        if wire.if_defined:
            f_wires.write(f"`ifdef {core.name.upper()}_{wire.if_defined}\n")

        if wire.file_prefix:
            file_prefix = wire.file_prefix
        else:
            file_prefix = wire.wire_prefix

        if_gen.gen_wires(
            wire.name,
            file_prefix,
            "",
            wire.wire_prefix,
            wire.signals,
            wire.mult,
            wire.widths,
        )

        # append vs_file to wires.vs
        vs_file = open(f"{file_prefix}{wire.name}_wire.vs", "r")
        f_wires.writelines(["    " + s for s in vs_file.readlines()])

        # move all .vs files from current directory to out_dir
        for file in os.listdir("."):
            if file.endswith(".vs"):
                os.rename(file, f"{out_dir}/{file}")

        # Close ifdef if conditional interface
        if wire.if_defined:
            f_wires.write("`endif\n")

    f_wires.close()
