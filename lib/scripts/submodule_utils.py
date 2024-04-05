import os
import sys
import re
import math
import if_gen


# given a mathematical string with parameters, replace every parameter by its numeric value and tries to evaluate the string.
# param_expression: string defining a math expression that may contain parameters
# params_dict: dictionary of parameters, where the key is the parameter name and the value is its value
def eval_param_expression(param_expression, params_dict):
    if type(param_expression) is int:
        return param_expression
    else:
        original_expression = param_expression
        # Split string to separate parameters/macros from the rest
        split_expression = re.split(r"([^\w_])", param_expression)
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
                    split_expression = re.split(r"([^\w_])", "".join(split_expression))
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
        params_dict[param.name] = param.__dict__[param_attribute]

    return eval_param_expression(param_expression, params_dict)


# Replaces a verilog parameter in a string with its value.
# The value is determined based on default value and the instance parameters given (that may override the default)
# Arguments:
#   string_with_parameter: string with parameter that will be replaced. Example: "SIZE_PARAMETER+2"
#   params_list: list of dictionaries, each of them describes a parameter and contains its default value
#   instance_parameters: dictionary of parameters for this peripheral instance that may override default value
#                        The keys are the parameters names, the values are the parameters values
# Returns:
#   String with parameter replaced. Example: "input [32:0]"
def replaceByParameterValue(string_with_parameter, params_list, instance_parameters):
    param_to_replace = None
    # Find parameter name
    for parameter in params_list:
        if parameter["name"] in string_with_parameter:
            param_to_replace = parameter
            break

    # Return unmodified string if there is no parameter in string
    if not param_to_replace:
        return string_with_parameter

    # If parameter should be overriden
    if param_to_replace["name"] in instance_parameters:
        # Replace parameter in string with value from instance parameter to override
        return string_with_parameter.replace(
            param_to_replace["name"], instance_parameters[param_to_replace["name"]]
        )
    else:
        # Replace parameter in string with default value
        return string_with_parameter.replace(
            param_to_replace["name"], param_to_replace["val"]
        )


# Given a string and a list of possible suffixes, check if string given has a suffix from the list
# Returns a turple:
#        -(prefix, suffix): 'prefix' is the full_string with the suffix removed. 'suffix' is the string from the list that is a suffix of the full_string.
#        -(None, None): if no suffix is found
def find_suffix_from_list(full_string, list_of_suffix_strings):
    return next(
        (
            (full_string[: -len(i)], i)
            for i in list_of_suffix_strings
            if full_string.endswith(i)
        ),
        (None, None),
    )


# Get path to build directory of directory
# Parameter: directory: path to core directory
# Returns: string with path to build directory
def get_build_lib(directory):
    # pattern: <any_string>_V[number].[number]
    # example: iob_CORE_V1.23
    build_dir_pattern = re.compile("(.*?)_V[0-9]+.[0-9]+")

    dir_entries = os.scandir(directory)
    for d in dir_entries:
        if d.is_dir() and build_dir_pattern.match(d.name):
            return d.path
    return ""


def clog2(val):
    return math.ceil(math.log2(val))


# A virtual file object with a port list. It has a write() method to extract information from if_gen.py signals.
# Can be used to create virtual file objects with a write() method that parses the if_gen.py port string.
class if_gen_hack_list:
    def __init__(self):
        self.port_list = []

    def write(self, port_string):
        # Parse written string
        port = re.search(
            r"^\s*((?:input)|(?:output))\s+\[([^:]+)-1:0\]\s+([^,]+),.*$",
            port_string,
        )
        # Append port to port dictionary
        self.port_list.append(
            {
                "name": port.group(3),
                "direction": port.group(1),
                "width": port.group(2),
                "descr": next(
                    signal["description"]
                    for signal in if_gen.iob
                    + if_gen.clk_en_rst
                    + if_gen.axi_write
                    + if_gen.axi_read
                    + if_gen.amba
                    if signal["name"] in port.group(3)
                ),
            }
        )


def if_gen_interface(interface_name, port_prefix, bus_size=1):
    if_gen.create_signal_table(interface_name)
    # Create a virtual file object
    virtual_file_obj = if_gen_hack_list()
    # Tell if_gen to write ports in virtual file object
    if_gen.write_vs_contents(
        interface_name, port_prefix, "", virtual_file_obj, bus_size=bus_size
    )
    # Extract port list from virtual file object
    return virtual_file_obj.port_list


# Given ios object for the module, extract the list of ports.
# It essencially removes de tables of each interface in 'ios'.
# Returns a list of dictionaries that describe each port. (The list contains ports from all tables in ios)
# Also add certain table attributes to each signal of that table.
# Example return list:
# [ {'name':"clk_i", 'type':"I", 'width':'1', 'descr':"Peripheral clock input"},
#  {'name':"rst_i", 'type':"I", 'width':'1', 'descr':"Peripheral reset input"} ]
#
# The `confs` and `corename` are optional parameters that should be provided togheter. If they are set, this function will add the `corename` as a prefix to any parameters in the port widths that are also present in the `confs` dictionary.
def get_module_io(ios, confs=None, corename=None):
    module_signals = []
    for table in ios:
        # If table has 'doc_only' attribute set to True, skip it
        if "doc_only" in table.keys() and table["doc_only"]:
            continue

        if table["ports"]:
            table_signals = table["ports"]
        elif table["name"] in if_gen.if_names:
            # Interface has no ports and is a if_gen interface, so generate it.
            table_signals = eval(f"if_gen.get_{table['name']}_ports()")
            if "mult" in table and table["mult"] > 1:
                for port in table_signals:
                    port["width"] = port["width"] * table["mult"]
        else:
            print(
                f"{iob_colors.WARNING}Unknown interface '{table['name']}'.{iob_colors.ENDC}"
            )

        # Add signal attributes
        for signal in table_signals:
            # Add ifdef attribute to every signal if table also has it
            if "if_defined" in table.keys():
                signal["if_defined"] = table["if_defined"]
            # Save the name without prefix in an attribute
            signal["name_without_prefix"] = signal["name"]
            # Save the interface name in an attribute
            signal["if_name"] = table["name"]
            # Add prefix to signal name if ios_table_prefix is set
            if "ios_table_prefix" in table.keys() and table["ios_table_prefix"]:
                signal["name"] = (
                    table["name"] + "_" + signal["name"]
                )  # Add prefix to the signal name

            # Add corename prefix to parameters in port width, if `confs` and `corename` are given
            if confs and corename:
                signal["width"] = add_prefix_to_parameters_in_port(
                    signal, confs, corename + "_"
                )["width"]
        module_signals.extend(table_signals)
    return module_signals


# string: string with parameter
# confs: confs list of dictionaries. Each dictionary describes a parameter (macros will be filtered if they exist)
# prefix: String to add as a prefix to any parameter found in the string
def add_prefix_to_parameters_in_string(string, confs, prefix):
    for parameter in confs:
        if parameter["type"] in ["P", "F"]:
            string = re.sub(
                f"((?:^.*[^a-zA-Z_])|^){parameter['name']}((?:[^a-zA-Z_].*$)|$)",
                f"\\g<1>{prefix}{parameter['name']}\\g<2>",
                str(string),
            )
    return string


# port: dictionary describing a port (IO). Example: {'name':"clk_i", 'type':"I", 'width':'1', 'descr':"Peripheral clock input"}
# confs: confs list of dictionaries. Each dictionary describes a parameter (macros will be filtered if they exist)
# prefix: String to add as a prefix to any parameter found in the port width
def add_prefix_to_parameters_in_port(port, confs, prefix):
    local_port = port.copy()
    local_port["width"] = add_prefix_to_parameters_in_string(
        local_port["width"], confs, prefix
    )
    return local_port


# Given lines read from the verilog file with a module declaration
# this function returns the parameters of that module.
# The return value is a dictionary, where the key is the
# parameter name and the value is the default value assigned to the parameter.
def get_module_parameters(verilog_lines):
    module_start = 0
    # Find module declaration
    for line in verilog_lines:
        module_start += 1
        if "module " in line:
            break  # Found module declaration

    parameter_list_start = module_start
    # Find module parameter list start
    for i in range(module_start, len(verilog_lines)):
        parameter_list_start += 1
        if verilog_lines[i].replace(" ", "").startswith("#("):
            break  # Found parameter list start

    module_parameters = {}
    # Get parameters of this module
    for i in range(parameter_list_start, len(verilog_lines)):
        # Ignore comments and empty lines
        if not verilog_lines[i].strip() or verilog_lines[i].lstrip().startswith("//"):
            continue
        if ")" in verilog_lines[i]:
            break  # Found end of parameter list

        # Parse parameter
        parameter = re.search(
            r"^\s*parameter\s+([^=\s]+)\s*=\s*([^\s,]+),?", verilog_lines[i]
        )
        if parameter is not None:
            # Store parameter in dictionary with format: module_parameters[parametername] = "default value"
            module_parameters[parameter.group(1)] = parameter.group(2)

    return module_parameters
