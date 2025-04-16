#!/usr/bin/env python3
import os
import re

import iob_colors
from latex import write_table


def params_vh(params, top_module, out_dir):
    for parameter in params:
        if parameter["type"] in ["P", "F"]:
            break
    else:
        return

    file2create = open(f"{out_dir}/{top_module}_params.vs", "w")
    core_prefix = f"{top_module}_".upper()
    for parameter in params:
        # If parameter has 'doc_only' attribute set to True, skip it
        if "doc_only" in parameter.keys() and parameter["doc_only"]:
            continue
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
        # If parameter has 'doc_only' attribute set to True, skip it
        if "doc_only" in parameter.keys() and parameter["doc_only"]:
            continue
        if parameter["type"] in ["P", "F"]:
            p_name = parameter["name"].upper()
            file2create.write(f"\n  .{p_name}({p_name}),")

    file2create = open(f"{out_dir}/{top_module}_inst_params.vs", "rb+")
    file2create.seek(-1, os.SEEK_END)
    file2create.write(b"\n")
    file2create.close()


def conf_vh(macros, top_module, out_dir):
    file2create = open(f"{out_dir}/{top_module}_conf.vh", "w")
    core_prefix = f"{top_module}_".upper()
    fname = f"{core_prefix}CONF"
    # These ifndefs cause issues when this file is included in multiple files and it contains other ifdefs inside this block.
    # For example, assume this file is included in another one that does not have `MACRO1` defined. Now assume that inside this block there is an `ifdef MACRO1` block.
    # Since `MACRO1` is not defined in the file that is including this, the `ifdef MACRO1` wont be executed.
    # Now assume this file is included in another file that has `MACRO1` defined. Now, this block
    # wont execute because of the `ifndef` added here, therefore the `ifdef MACRO1` block will also not execute when it should have.
    # file2create.write(f"`ifndef VH_{fname}_VH\n")
    # file2create.write(f"`define VH_{fname}_VH\n\n")

    # First, order the macros by type, P first, M second, F last
    sorted_macros = []
    for macro in macros:
        if macro["type"] == "P":
            sorted_macros.append(macro)
    for macro in macros:
        if macro["type"] == "M":
            sorted_macros.append(macro)
    for macro in macros:
        if macro["type"] == "F":
            sorted_macros.append(macro)

    prev_type = ""
    # Now, write the macros to the file
    for macro in sorted_macros:
        macro_type = macro["type"]
        # If the type of the macro is different from the previous one, add a comment
        if macro_type != prev_type:
            if macro_type == "P":
                file2create.write(f"// Core Configuration Parameters Default Values\n")
            elif macro_type == "M":
                file2create.write(f"// Core Constants. DO NOT CHANGE\n")
            elif macro_type == "F":
                file2create.write(f"// Core Derived Parameters. DO NOT CHANGE\n")

        # If macro has 'doc_only' attribute set to True, skip it
        if "doc_only" in macro.keys() and macro["doc_only"]:
            continue
        if "if_defined" in macro.keys():
            file2create.write(f"`ifdef {macro['if_defined']}\n")

        # Only insert macro if its is not a bool define, and if so only insert it if it is true
        if type(macro["val"]) != bool:
            m_name = macro["name"].upper()
            m_default_val = macro["val"]
            file2create.write(f"`define {core_prefix}{m_name} {m_default_val}\n")
        elif macro["val"]:
            m_name = macro["name"].upper()
            file2create.write(f"`define {core_prefix}{m_name} 1\n")
        if "if_defined" in macro.keys():
            file2create.write("`endif\n")

        prev_type = macro_type
    # file2create.write(f"\n`endif // VH_{fname}_VH\n")


def conf_h(macros, top_module, out_dir):
    if len(macros) == 0:
        return
    os.makedirs(out_dir, exist_ok=True)
    file2create = open(f"{out_dir}/{top_module}_conf.h", "w")
    core_prefix = f"{top_module}_".upper()
    fname = f"{core_prefix}CONF"
    file2create.write(f"#ifndef H_{fname}_H\n")
    file2create.write(f"#define H_{fname}_H\n\n")
    for macro in macros:
        # If macro has 'doc_only' attribute set to True, skip it
        if "doc_only" in macro.keys() and macro["doc_only"]:
            continue
        # Only insert macro if its is not a bool define, and if so only insert it if it is true
        if type(macro["val"]) != bool:
            m_name = macro["name"].upper()
            # Replace any Verilog specific syntax by equivalent C syntax
            m_default_val = re.sub("\\d+'h", "0x", str(macro["val"]))
            m_min_val = re.sub("\\d+'h", "0x", str(macro["min"]))
            m_max_val = re.sub("\\d+'h", "0x", str(macro["max"]))
            file2create.write(
                f"#define {core_prefix}{m_name} {str(m_default_val).replace('`','')}\n"
            )  # Remove Verilog macros ('`')
            file2create.write(
                f"#define {core_prefix}{m_name}_MIN {str(m_min_val).replace('`','')}\n"
            )  # Remove Verilog macros ('`')
            file2create.write(
                f"#define {core_prefix}{m_name}_MAX {str(m_max_val).replace('`','')}\n"
            )  # Remove Verilog macros ('`')
        elif macro["val"]:
            m_name = macro["name"].upper()
            file2create.write(f"#define {core_prefix}{m_name} 1\n")
    file2create.write(f"\n#endif // H_{fname}_H\n")

    file2create.close()


def config_build_mk(python_module):
    file2create = open(f"{python_module.build_dir}/config_build.mk", "w")
    file2create.write(f"NAME={python_module.name}\n")
    file2create.write(f"CSR_IF={python_module.csr_if}\n\n")
    file2create.write(f"BUILD_DIR_NAME={python_module.build_dir.split('/')[-1]}\n")
    file2create.write(f"IS_FPGA={int(python_module.is_system)}\n")

    file2create.close()


# Append a string to the config_build.mk
def append_str_config_build_mk(str_2_append, build_dir):
    file = open(f"{build_dir}/config_build.mk", "a")
    file.write(str_2_append)
    file.close()


# Generate TeX table of confs
def generate_confs_tex(confs, out_dir):
    tex_table = []
    derv_params = []
    for conf in confs:
        conf_val = conf["val"] if type(conf["val"]) != bool else "1"
        # False parameters are not included in the table
        if conf["type"] != "F":
            tex_table.append(
                [
                    conf["name"],
                    conf["type"],
                    conf["min"],
                    conf_val,
                    conf["max"],
                    conf["descr"],
                ]
            )
        else:
            derv_params.append(
                [
                    conf["name"],
                    conf_val,
                    conf["descr"],
                ]
            )

    # Write table with true parameters and macros
    write_table(f"{out_dir}/confs", tex_table)

    # Write list of derived parameters
    file2create = open(f"{out_dir}/derived_params.tex", "w")
    file2create.write("\\begin{description}\n")
    for derv_param in derv_params:
        # replace underscores and $clog2 with \_ and $\log_2
        for i in range(len(derv_param)):
            derv_param[i] = str(derv_param[i]).replace("_", "\\_")
            derv_param[i] = str(derv_param[i]).replace("$clog2", "log2")
        # write the line
        file2create.write(
            f"  \\item[{derv_param[0]}] {derv_param[2]} Value: {derv_param[1]}.\n"
        )
    file2create.write("\\end{description}\n")


# Select if a define from the confs dictionary is set or not
# define_name: name of the macro in confs (its called define because it is unvalued, it is either set or unset)
# should_set: Select if define should be set or not
def update_define(confs, define_name, should_set):
    for macro in confs:
        if macro["name"] == define_name:
            # Found macro. Unset it if not 'should_set'
            if should_set:
                macro["val"] = True
            else:
                macro["val"] = False
            break
    else:
        # Did not find define. Set it if should_set.
        if should_set:
            confs.append(
                {
                    "name": define_name,
                    "type": "M",
                    "val": True,
                    "min": "NA",
                    "max": "NA",
                    "descr": "Define",
                }
            )
