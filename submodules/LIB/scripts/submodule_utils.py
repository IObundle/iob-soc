#!/usr/bin/env python3
# Library with useful functions to manage submodules and peripherals

import sys
import subprocess
import os
import re
import math
import importlib
import if_gen
import iob_colors
import copy

# List of reserved signals
# These signals are known by the python scripts and are always auto-connected using the matching Verilog the string.
# These signals can not be portmapped! They will always have the fixed connection specified here.
reserved_signals = {
    "clk_i": ".clk_i(clk_i)",
    "cke_i": ".cke_i(cke_i)",
    "en_i": ".en_i(en_i)",
    "arst_i": ".arst_i(arst_i)",
    "iob_valid_i": ".iob_valid_i(slaves_req[`VALID(`/*<InstanceName>*/)])",
    "iob_addr_i": ".iob_addr_i(slaves_req[`ADDRESS(`/*<InstanceName>*/,`/*<SwregFilename>*/_ADDR_W)])",
    "iob_wdata_i": ".iob_wdata_i(slaves_req[`WDATA(`/*<InstanceName>*/)])",
    "iob_wstrb_i": ".iob_wstrb_i(slaves_req[`WSTRB(`/*<InstanceName>*/)])",
    "iob_rdata_o": ".iob_rdata_o(slaves_resp[`RDATA(`/*<InstanceName>*/)])",
    "iob_ready_o": ".iob_ready_o(slaves_resp[`READY(`/*<InstanceName>*/)])",
    "iob_rvalid_o": ".iob_rvalid_o(slaves_resp[`RVALID(`/*<InstanceName>*/)])",
    "trap_o": ".trap_o(/*<InstanceName>*/_trap_o)",
    "axi_awid_o": ".axi_awid_o          (axi_awid_o             [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_awaddr_o": ".axi_awaddr_o      (axi_awaddr_o           [/*<extmem_conn_num>*/*AXI_ADDR_W     +:/*<bus_size>*/*AXI_ADDR_W])",
    "axi_awlen_o": ".axi_awlen_o        (axi_awlen_o            [/*<extmem_conn_num>*/*AXI_LEN_W      +:/*<bus_size>*/*AXI_LEN_W])",
    "axi_awsize_o": ".axi_awsize_o      (axi_awsize_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_awburst_o": ".axi_awburst_o    (axi_awburst_o          [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_awlock_o": ".axi_awlock_o      (axi_awlock_o           [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_awcache_o": ".axi_awcache_o    (axi_awcache_o          [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_awprot_o": ".axi_awprot_o      (axi_awprot_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_awqos_o": ".axi_awqos_o        (axi_awqos_o            [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_awvalid_o": ".axi_awvalid_o    (axi_awvalid_o          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_awready_i": ".axi_awready_i    (axi_awready_i          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_wdata_o": ".axi_wdata_o        (axi_wdata_o            [/*<extmem_conn_num>*/*AXI_DATA_W     +:/*<bus_size>*/*AXI_DATA_W])",
    "axi_wstrb_o": ".axi_wstrb_o        (axi_wstrb_o            [/*<extmem_conn_num>*/*(AXI_DATA_W/8) +:/*<bus_size>*/*(AXI_DATA_W/8)])",
    "axi_wlast_o": ".axi_wlast_o        (axi_wlast_o            [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_wvalid_o": ".axi_wvalid_o      (axi_wvalid_o           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_wready_i": ".axi_wready_i      (axi_wready_i           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_bid_i": ".axi_bid_i            (axi_bid_i              [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_bresp_i": ".axi_bresp_i        (axi_bresp_i            [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_bvalid_i": ".axi_bvalid_i      (axi_bvalid_i           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_bready_o": ".axi_bready_o      (axi_bready_o           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_arid_o": ".axi_arid_o          (axi_arid_o             [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_araddr_o": ".axi_araddr_o      (axi_araddr_o           [/*<extmem_conn_num>*/*AXI_ADDR_W     +:/*<bus_size>*/*AXI_ADDR_W])",
    "axi_arlen_o": ".axi_arlen_o        (axi_arlen_o            [/*<extmem_conn_num>*/*AXI_LEN_W      +:/*<bus_size>*/*AXI_LEN_W])",
    "axi_arsize_o": ".axi_arsize_o      (axi_arsize_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_arburst_o": ".axi_arburst_o    (axi_arburst_o          [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_arlock_o": ".axi_arlock_o      (axi_arlock_o           [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_arcache_o": ".axi_arcache_o    (axi_arcache_o          [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_arprot_o": ".axi_arprot_o      (axi_arprot_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_arqos_o": ".axi_arqos_o        (axi_arqos_o            [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_arvalid_o": ".axi_arvalid_o    (axi_arvalid_o          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_arready_i": ".axi_arready_i    (axi_arready_i          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_rid_i": ".axi_rid_i            (axi_rid_i              [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_rdata_i": ".axi_rdata_i        (axi_rdata_i            [/*<extmem_conn_num>*/*AXI_DATA_W     +:/*<bus_size>*/*AXI_DATA_W])",
    "axi_rresp_i": ".axi_rresp_i        (axi_rresp_i            [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_rlast_i": ".axi_rlast_i        (axi_rlast_i            [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_rvalid_i": ".axi_rvalid_i      (axi_rvalid_i           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_rready_o": ".axi_rready_o      (axi_rready_o           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
}


# Import the <corename>_setup.py from the given core directory/file
def import_setup(module_location, **kwargs):
    # Check if module_location is a directory
    if os.path.isdir(module_location):
        # Find <corename>_setup.py file
        for x in os.listdir(module_location):
            if x.endswith("_setup.py"):
                filename = x
                module_location = module_location + "/" + x
                break
        if "filename" not in vars():
            raise FileNotFoundError(
                f"Could not find a *_setup.py file in {module_location}"
            )
    else:
        if not os.path.isfile(module_location):
            raise FileNotFoundError(f"Could not find {module_location}")
        filename = module_location.split("/")[-1]
    # Import <corename>_setup.py
    module_name = filename.split(".")[0]
    spec = importlib.util.spec_from_file_location(module_name, module_location)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    # Define objects given in the module
    for key, value in kwargs.items():
        vars(module)[key] = value
    spec.loader.exec_module(module)

    return module


# Return short port type string based on given types: "input", "output" and "inout"
# Maps "I", "O" and "IO" to "input", "output" and "inout", respectively.
def get_short_port_type(port_type):
    if port_type == "input":
        return "I"
    elif port_type == "output":
        return "O"
    else:
        return "IO"


# Adds and fills 'dirs' dictionary inside 'submodules' dicionary of given core/system _setup.py python module
#       To implement this, we can either: crate a global dictionary with all submodules; or we can do a BFS search for submodules every time we call this function, starting from the root current working directory.
def set_default_submodule_dirs(python_module):
    # Make sure 'dirs' dictionary exists
    if "dirs" not in python_module.submodules:
        python_module.submodules["dirs"] = {}

    if os.path.isdir(f"{python_module.setup_dir}/submodules"):
        # Add default path for every submodule without a path
        for submodule in os.listdir(f"{python_module.setup_dir}/submodules"):
            if submodule not in python_module.submodules["dirs"]:
                python_module.submodules["dirs"].update(
                    {submodule: f"{python_module.setup_dir}/submodules/{submodule}"}
                )

    # Make sure 'LIB' path exists
    if "LIB" not in python_module.submodules["dirs"]:
        python_module.submodules["dirs"]["LIB"] = "submodules/LIB"


# Get peripheral related macros
# confs: confs dictionary to be filled with peripheral macros
# peripherals_list: list of peripherals
def get_peripheral_macros(confs, peripherals_list):
    # Append macros with ID of each peripheral
    confs.extend(get_periphs_id_as_macros(peripherals_list))
    # Append macro with number of peripherals
    # Only append macro if it does not exist (to allow subclasses set their own number)
    if not list([i for i in confs if i["name"] == "N_SLAVES"]):
        confs.append(
            {
                "name": "N_SLAVES",
                "type": "M",
                "val": get_n_periphs(peripherals_list),
                "min": "NA",
                "max": "NA",
                "descr": "Number of peripherals",
            }
        )
    if not list([i for i in confs if i["name"] == "N_SLAVES_W"]):
        # Append macro with width of peripheral bus
        confs.append(
            {
                "name": "N_SLAVES_W",
                "type": "M",
                "val": get_n_periphs_w(peripherals_list),
                "min": "NA",
                "max": "NA",
                "descr": "Peripheral bus width",
            }
        )


# Check if a module of certain type is in given modules list.
def check_module_in_modules_list(module_type, modules_list):
    for item in modules_list:
        if type(item) == str:
            if item == module_type:
                return True
        elif type(item) == tuple:
            if item[0] == module_type:
                return True
    return False


# Generate list of dictionaries with interfaces for each peripheral instance
# Each dictionary is follows the format of a dictionary table in the
# 'ios' list of the <corename>_setup.py
# Example dictionary of a peripheral instance with one port:
#    {'name': 'instance_name', 'descr':'instance description', 'ports': [
#        {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"}
#    ]}
def get_peripheral_ios(peripherals_list):
    port_list = {}
    # Get port list for each type of peripheral used
    for instance in peripherals_list:
        # Make sure we have a hw_module for this peripheral type
        # assert check_module_in_modules_list(instance['type'],submodules["hw_setup"]["modules"]), f"{iob_colors.FAIL}peripheral {instance['type']} configured but no corresponding hardware module found!{iob_colors.ENDC}"
        # Only insert ports of this peripheral type if we have not done so before
        if instance.__class__.name not in port_list:
            # Extract only PIO signals from the peripheral (no reserved/known signals)
            port_list[instance.__class__.name] = get_pio_signals(
                get_module_io(instance.ios, instance.confs, instance.name)
            )

    ios_list = []
    # Append ports of each instance
    for instance in peripherals_list:
        ios_list.append(
            {
                "name": instance.name,
                "descr": f"{instance.name} interface signals",
                "ports": port_list[instance.__class__.name],
                "ios_table_prefix": True,
            }
        )
    return ios_list


# This function is used to setup peripheral related configuration in the python module of iob-soc systems
# python_module: Module of the iob-soc system being setup
def iob_soc_peripheral_setup(python_module):
    # Get peripherals list from 'peripherals' table in blocks list
    peripherals_list = python_module.peripherals

    if peripherals_list:
        # Get port list, parameter list and top module name for each type of peripheral used
        _, params_list, _ = get_peripherals_ports_params_top(peripherals_list)
        # Insert peripheral instance parameters in system parameters
        # This causes the system to have a parameter for each parameter of each peripheral instance
        for instance in peripherals_list:
            for parameter in params_list[instance.__class__.name]:
                parameter_to_append = parameter.copy()
                # Override parameter value if user specified a 'parameters' dictionary with an override value for this parameter.
                if parameter["name"] in instance.parameters:
                    parameter_to_append["val"] = instance.parameters[parameter["name"]]
                # Add instance name prefix to the name of the parameter. This makes this parameter unique to this instance
                parameter_to_append[
                    "name"
                ] = f"{instance.name}_{parameter_to_append['name']}"
                python_module.confs.append(parameter_to_append)

        # Get peripheral related macros
        get_peripheral_macros(python_module.confs, peripherals_list)


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


# Return submodule_dirs dictionary from iob_*_setup.py in given directory
def get_submodule_directories(root_dir):
    module = import_setup(root_dir)
    return module.submodule_dirs


def clog2(val):
    return math.ceil(math.log2(val))


# given a mathematical string with parameters, replace every parameter by its numeric value and tries to evaluate the string.
# param_expression: string defining a math expression that may contain parameters
# params_dict: dictionary of parameters, where the key is the parameter name and the value is its value
def eval_param_expression(param_expression, params_dict):
    if type(param_expression) == int:
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
        params_dict[param["name"]] = param[param_attribute]

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


# Parameter: PERIPHERALS string defined in config.mk
# Returns dictionary with amount of instances for each peripheral
# Also returns dictionary with verilog parameters for each of those instance
# instances_amount example: {'corename': numberOfInstances, 'anothercorename': numberOfInstances}
# instances_parameters example: {'corename': [['instance1parameter1','instance1parameter2'],['instance2parameter1','instance2parameter2']]}
def get_peripherals(peripherals_str):
    peripherals = peripherals_str.split()

    instances_amount = {}
    instances_parameters = {}
    # Count how many instances to create of each type of peripheral
    for i in peripherals:
        i = i.split("[")  # Split corename and parameters
        # Initialize corename in dictionary
        if i[0] not in instances_amount:
            instances_amount[i[0]] = 0
            instances_parameters[i[0]] = []
        # Insert parameters of this instance (if there are any)
        if len(i) > 1:
            i[1] = i[1].strip("]")  # Delete final "]" from parameter list
            instances_parameters[i[0]].append(i[1].split(","))
        else:
            instances_parameters[i[0]].append([])
        # Increment amount of instances
        instances_amount[i[0]] += 1

    # print(instances_amount, file = sys.stderr) #Debug
    # print(instances_parameters, file = sys.stderr) #Debug
    return instances_amount, instances_parameters


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
                "type": get_short_port_type(port.group(1)),
                "n_bits": port.group(2),
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


# Given a table from 'ios' dictionary, return its ports list
# If table has a standard interface name (and empty port list) then it generates the port list with if_gen.py
def get_table_ports(table):
    # Check if this table is a standard interface (from if_gen.py)
    # Note: the table['name'] may have a prefix, therefore we separate it before calling if_gen.
    prefix, if_name = find_suffix_from_list(table["name"], if_gen.interfaces)
    if if_name:
        # Interface is standard, generate ports
        return if_gen_interface(if_name, prefix)
    else:
        # Interface is not standard, read ports
        return copy.deepcopy(table["ports"])


# Given ios object for the module, extract the list of ports.
# It essencially removes de tables of each interface in 'ios'.
# Returns a list of dictionaries that describe each port. (The list contains ports from all tables in ios)
# Also add certain table attributes to each signal of that table.
# Example return list:
# [ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"},
#  {'name':"rst_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral reset input"} ]
#
# The `confs` and `corename` are optional parameters that should be provided togheter. If they are set, this function will add the `corename` as a prefix to any parameters in the port widths that are also present in the `confs` dictionary.
def get_module_io(ios, confs=None, corename=None):
    module_signals = []
    for table in ios:
        # If table has 'doc_only' attribute set to True, skip it
        if "doc_only" in table.keys() and table["doc_only"]:
            continue

        table_signals = get_table_ports(table)
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
                signal["n_bits"] = add_prefix_to_parameters_in_port(
                    signal, confs, corename + "_"
                )["n_bits"]
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


# port: dictionary describing a port (IO). Example: {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"}
# confs: confs list of dictionaries. Each dictionary describes a parameter (macros will be filtered if they exist)
# prefix: String to add as a prefix to any parameter found in the port width
def add_prefix_to_parameters_in_port(port, confs, prefix):
    local_port = port.copy()
    local_port["n_bits"] = add_prefix_to_parameters_in_string(
        local_port["n_bits"], confs, prefix
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


# Filter out non reserved signals from a given list (not stored in string reserved_signals)
# Example signal_list:
# [ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"},
#  {'name':"custom_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral custom input"} ]
# Return of this example:
# [ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"} ]
def get_reserved_signals(signal_list):
    return_list = []
    for signal in signal_list:
        if signal["name"] in reserved_signals:
            return_list.append(signal)
    return return_list


def get_reserved_signal_connection(signal_name, instace_name, swreg_filename):
    signal_connection = reserved_signals[signal_name]
    return re.sub(
        r"\/\*<InstanceName>\*\/",
        instace_name,
        re.sub(r"\/\*<SwregFilename>\*\/", swreg_filename, signal_connection),
    )


# Filter out reserved signals from a given list (stored in string reserved_signals)
# Example signal_list:
# [ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"},
#  {'name':"custom_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral custom input"} ]
# Return of this example:
# [ {'name':"custom_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral custom input"} ]
def get_pio_signals(signal_list):
    return_list = []
    for signal in signal_list:
        if signal["name"] not in reserved_signals:
            return_list.append(signal)
    return return_list


# Get port list, parameter list and top module name for each type of peripheral in a list of instances of peripherals
# port_list, params_list, and top_list are dictionaries where their key is the name of the type of peripheral
# The value of port_list is a list of ports for the given type of peripheral
# The value of params_list is a list of parameters for the given type of peripheral
# The value of top_list is the top name of the given type of peripheral
def get_peripherals_ports_params_top(peripherals_list):
    port_list = {}
    params_list = {}
    top_list = {}
    for instance in peripherals_list:
        if instance.__class__.name not in port_list:
            # Append instance IO, parameters, and top name
            port_list[instance.__class__.name] = get_module_io(instance.ios)
            params_list[instance.__class__.name] = list(
                i for i in instance.confs if i["type"] in ["P", "F"]
            )
            top_list[instance.__class__.name] = instance.__class__.name
    return port_list, params_list, top_list


# Find index of word in array with multiple strings
def find_idx(lines, word):
    for idx, i in enumerate(lines):
        if word in i:
            break
    return idx + 1


# Creates list of defines of peripheral instances with sequential numbers
# Returns list of tuples. One tuple for each peripheral instance with its name and value.
def get_periphs_id(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    peripherals_list = []
    j = 0
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            peripherals_list.append((corename + str(i), str(j)))
            j = j + 1
    return peripherals_list


# Given a list of dictionaries representing each peripheral instance
# Return list of dictionaries representing macros of each peripheral instance with their ID assigned
def get_periphs_id_as_macros(peripherals_list):
    macro_list = []
    for idx, instance in enumerate(peripherals_list, 1):
        macro_list.append(
            {
                "name": instance.name,
                "type": "M",
                "val": str(idx),
                "min": "0",
                "max": "NA",
                "descr": f"ID of {instance.name} peripheral",
            }
        )
    return macro_list


# Return amount of system peripherals
def get_n_periphs(peripherals_list):
    # +1 because the internal memory is not in the peripherals_list. int_mem is implicit peripheral. It is treated as a peripheral by the internal signals. (might change in the future)
    return str(len(peripherals_list) + 1)


# Return bus width required to address all peripherals
def get_n_periphs_w(peripherals_list):
    # +1 because the internal memory is not in the peripherals_list. int_mem is implicit peripheral. It is treated as a peripheral by the internal signals. (might change in the future)
    i = len(peripherals_list) + 1
    if not i:
        return str(0)
    else:
        return str(math.ceil(math.log(i, 2)))


##########################################################
# Functions to run when this script gets called directly #
##########################################################
def print_instances(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            print(corename + str(i), end=" ")


def print_peripherals(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    for i in instances_amount:
        print(i, end=" ")


def print_nslaves(peripherals_str):
    print(get_n_periphs(peripherals_str), end="")


def print_nslaves_w(peripherals_str):
    print(get_n_periphs_w(peripherals_str), end="")


# Print list of peripherals without parameters and duplicates
def remove_duplicates_and_params(peripherals_str):
    peripherals = peripherals_str.split()
    # Remove parameters from peripherals
    for i in range(len(peripherals)):
        peripherals[i] = peripherals[i].split("[")[0]
    # Remove peripheral duplicates
    peripherals = list(set(peripherals))
    # Print list of peripherals
    for p in peripherals:
        print(p, end=" ")


# Print list of peripheral instances with ID assigned
def print_peripheral_defines(defmacro, peripherals_str):
    peripherals_list = get_periphs_id(peripherals_str)
    for instance in peripherals_list:
        print(defmacro + instance[0] + "=" + instance[1], end=" ")


if __name__ == "__main__":
    # Parse arguments
    if sys.argv[1] == "get_peripherals":
        if len(sys.argv) < 3:
            print("Usage: {} get_peripherals <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_peripherals(sys.argv[2])
    elif sys.argv[1] == "get_instances":
        if len(sys.argv) < 3:
            print("Usage: {} get_instances <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_instances(sys.argv[2])
    elif sys.argv[1] == "get_n_periphs":
        if len(sys.argv) < 3:
            print("Usage: {} get_n_periphs <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_nslaves(sys.argv[2])
    elif sys.argv[1] == "get_n_periphs_w":
        if len(sys.argv) < 3:
            print("Usage: {} get_n_periphs_w <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_nslaves_w(sys.argv[2])
    elif sys.argv[1] == "remove_duplicates_and_params":
        if len(sys.argv) < 3:
            print(
                "Usage: {} remove_duplicates_and_params <peripherals>\n".format(
                    sys.argv[0]
                )
            )
            exit(-1)
        remove_duplicates_and_params(sys.argv[2])
    elif sys.argv[1] == "get_periphs_id":
        if len(sys.argv) < 3:
            print(
                "Usage: {} get_periphs_id <peripherals> <optional:defmacro>\n".format(
                    sys.argv[0]
                )
            )
            exit(-1)
        if len(sys.argv) < 4:
            print_peripheral_defines("", sys.argv[2])
        else:
            print_peripheral_defines(sys.argv[3], sys.argv[2])
    else:
        print(
            "Unknown command.\nUsage: {} <command> <parameters>\n Commands: get_peripherals get_instances get_n_periphs get_n_periphs_w get_periphs_id print_peripheral_defines".format(
                sys.argv[0]
            )
        )
        exit(-1)
