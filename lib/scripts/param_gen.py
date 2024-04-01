#!/usr/bin/env python3
import os


def has_params(confs):
    """Check if given 'confs' list has any parameters"""
    for conf in confs:
        if conf.type in ["P", "F"]:
            return True
    return False


def params_vs(params, top_module, out_dir):
    if not has_params(params):
        return

    lines = []
    core_prefix = f"{top_module}_".upper()
    for parameter in params:
        if parameter.type in ["P", "F"]:
            p_name = parameter.name.upper()
            lines.append(f"    parameter {p_name} = `{core_prefix}{p_name},\n")
    lines[-1] = lines[-1].replace(",\n", "\n")
    file2create = open(f"{out_dir}/{top_module}_params.vs", "w")
    file2create.writelines(lines)
    file2create.close()

    lines = []
    for parameter in params:
        if parameter.type in ["P", "F"]:
            p_name = parameter.name.upper()
            lines.append(f"        .{p_name}({p_name}),\n")
    lines[-1] = lines[-1].replace(",\n", "\n")
    file2create = open(f"{out_dir}/{top_module}_inst_params.vs", "w")
    file2create.writelines(lines)
    file2create.close()


def generate_params(core):
    params_vs(core.confs, core.instance_name, core.build_dir + "/hardware/src")
