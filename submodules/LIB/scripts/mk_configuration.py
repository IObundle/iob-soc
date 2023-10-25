#!/usr/bin/env python3
import os
import re

import iob_colors
from latex import write_table


def params_vh(params, top_module, out_dir):
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
    for macro in macros:
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
    # file2create.write(f"\n`endif // VH_{fname}_VH\n")


def conf_h(macros, top_module, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    file2create = open(f"{out_dir}/{top_module}_conf.h", "w")
    core_prefix = f"{top_module}_".upper()
    fname = f"{core_prefix}CONF"
    file2create.write(f"#ifndef H_{fname}_H\n")
    file2create.write(f"#define H_{fname}_H\n\n")
    for macro in macros:
        # Only insert macro if its is not a bool define, and if so only insert it if it is true
        if type(macro["val"]) != bool:
            m_name = macro["name"].upper()
            # Replace any Verilog specific syntax by equivalent C syntax
            m_default_val = re.sub("\d+'h", "0x", str(macro["val"]))
            file2create.write(
                f"#define {m_name} {str(m_default_val).replace('`','')}\n"
            )  # Remove Verilog macros ('`')
        elif macro["val"]:
            m_name = macro["name"].upper()
            file2create.write(f"#define {m_name} 1\n")
    file2create.write(f"\n#endif // H_{fname}_H\n")

    file2create.close()


def config_build_mk(python_module):
    file2create = open(f"{python_module.build_dir}/config_build.mk", "w")
    file2create.write(f"NAME={python_module.name}\n")
    file2create.write(f"CSR_IF={python_module.csr_if}\n\n")
    file2create.write(f"VERSION={python_module.version}\n")
    file2create.write(f"BUILD_DIR_NAME={python_module.build_dir.split('/')[-1]}\n")
    file2create.write(f"FLOWS={python_module.flows}\n\n")

    file2create.close()


# This function append a list of flows to the existing config_build.mk file
# Usually called by submodules that have flows not contained in the top core/system
# flows_list:  list of flows of module
# flows_filter: list of flows that should be appended if they exist in flows_list
# build_dir: build directory containing config_build.mk
def append_flows_config_build_mk(flows_list, flows_filter, build_dir):
    flows2append = ""
    for flow in flows_filter:
        if flow in flows_list:
            flows2append += f"{flow} "

    if not flows2append:
        return

    append_str_config_build_mk(f"FLOWS+={flows2append}\n\n", build_dir)


# Append a string to the config_build.mk
def append_str_config_build_mk(str_2_append, build_dir):
    file = open(f"{build_dir}/config_build.mk", "a")
    file.write(str_2_append)
    file.close()


# Generate TeX table of confs
def generate_confs_tex(confs, out_dir):
    tex_table = []
    for conf in confs:
        conf_val = conf["val"] if type(conf["val"]) != bool else "1"
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

    write_table(f"{out_dir}/confs", tex_table)


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


# given a mathematical string with parameters, replace every parameter by its numeric value and tries to evaluate the string.
# param_expression: string defining a math expression that may contain parameters
# params_dict: dictionary of parameters, where the key is the parameter name and the value is its value
def eval_param_expression(param_expression, params_dict):
    if type(param_expression) == int:
        return param_expression
    else:
        original_expression = param_expression
        # Split string to separate parameters/macros from the rest
        split_expression = re.split("([^\w_])", param_expression)
        # Replace each parameter, following the reverse order of parameter list. The reversed order allows replacing parameters recursively (parameters may have values with parameters that came before).
        for param_name, param_value in reversed(params_dict.items()):
            # Replace every instance of this parameter by its value
            for idx, word in enumerate(split_expression):
                if word == param_name:
                    # Replace parameter/macro by its value
                    split_expression[idx] = param_value
                    # Remove '`' char if it was a macro
                    if idx > 0 and split_expression[idx - 1] == "`":
                        split_expression[idx - 1] = ""
                    # resplit the string in case the parameter value contains other parameters
                    split_expression = re.split("([^\w_])", "".join(split_expression))
        # Join back the string
        param_expression = "".join(split_expression)
        # Evaluate $clog2 expressions
        param_expression = param_expression.replace("$clog2", "clog2")
        # Evaluate IOB_MAX and IOB_MIN expressions
        param_expression = param_expression.replace("`IOB_MAX", "max")
        param_expression = param_expression.replace("`IOB_MIN", "min")

        # Try to calculate string as it should only contain numeric values
        try:
            return eval(param_expression)
        except:
            sys.exit(
                f"Error: string '{original_expression}' evaluated to '{param_expression}' is not a numeric expression."
            )


# given a mathematical string with parameters, replace every parameter by its numeric value and tries to evaluate the string. The parameters are taken from the confs dictionary.
# param_expression: string defining a math expression that may contain parameters
# confs: list of dictionaries, each of which describes a parameter and has attributes: 'name', 'val' and 'max'.
# param_attribute: name of the attribute in the paramater that contains the value to replace in string given. Attribute names are: 'val', 'min, or 'max'.
def eval_param_expression_from_config(param_expression, confs, param_attribute):
    # Create parameter dictionary with correct values to be replaced in string
    params_dict = {}
    for param in confs:
        params_dict[param["name"]] = param[param_attribute]

    return eval_param_expression(param_expression, params_dict)
