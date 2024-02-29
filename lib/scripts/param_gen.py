#!/usr/bin/env python3
import os


def params_vh(params, top_module, out_dir):
    for parameter in params:
        if parameter["type"] in ["P", "F"]:
            break
    else:
        return

    file2create = open(f"{out_dir}/{top_module}_params.vs", "w")
    core_prefix = f"{top_module}_".upper()
    for parameter in params:
        if parameter["type"] in ["P", "F"]:
            p_name = parameter["name"].upper()
            file2create.write(f"\n  parameter {p_name} = `{core_prefix}{p_name},")
    file2create.close()

    file2create = open(f"{out_dir}/{top_module}_params.vs", "rb+")
    file2create.seek(-1, os.SEEK_END)
    file2create.write(b"\n")
    file2create.close()

    file2create = open(f"{out_dir}/{top_module}_inst_params.vs", "w")
    for parameter in params:
        if parameter["type"] in ["P", "F"]:
            p_name = parameter["name"].upper()
            file2create.write(f"\n  .{p_name}({p_name}),")

    file2create = open(f"{out_dir}/{top_module}_inst_params.vs", "rb+")
    file2create.seek(-1, os.SEEK_END)
    file2create.write(b"\n")
    file2create.close()


def generate_params(core):
    params_vh(core.confs, core.name, core.build_dir + "/hardware/src")
