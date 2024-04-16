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

from submodule_utils import *

# List of reserved signals
# These signals are known by the python scripts and are always auto-connected using the matching Verilog the string.
# These signals can not be portmapped! They will always have the fixed connection specified here.
reserved_signals = {
    "clk": ".clk_i(clk_i)",
    "cke": ".cke_i(cke_i)",
    "en": ".en_i(en_i)",
    "arst": ".arst_i(arst_i)",
    "iob_valid": ".iob_valid_i(/*<InstanceName>*/_iob_valid)",
    "iob_addr": ".iob_addr_i(/*<InstanceName>*/_iob_addr[`/*<SwregFilename>*/_ADDR_W-1:0])",
    "iob_wdata": ".iob_wdata_i(/*<InstanceName>*/_iob_wdata)",
    "iob_wstrb": ".iob_wstrb_i(/*<InstanceName>*/_iob_wstrb)",
    "iob_rdata": ".iob_rdata_o(/*<InstanceName>*/_iob_rdata)",
    "iob_ready": ".iob_ready_o(/*<InstanceName>*/_iob_ready)",
    "iob_rvalid": ".iob_rvalid_o(/*<InstanceName>*/_iob_rvalid)",
    "trap": ".trap_o(/*<InstanceName>*/_trap_o)",
    "axi_awid": ".axi_awid_o          (axi_awid_o             [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_awaddr": ".axi_awaddr_o      (axi_awaddr_o           [/*<extmem_conn_num>*/*AXI_ADDR_W     +:/*<bus_size>*/*AXI_ADDR_W])",
    "axi_awlen": ".axi_awlen_o        (axi_awlen_o            [/*<extmem_conn_num>*/*AXI_LEN_W      +:/*<bus_size>*/*AXI_LEN_W])",
    "axi_awsize": ".axi_awsize_o      (axi_awsize_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_awburst": ".axi_awburst_o    (axi_awburst_o          [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_awlock": ".axi_awlock_o      (axi_awlock_o           [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_awcache": ".axi_awcache_o    (axi_awcache_o          [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_awprot": ".axi_awprot_o      (axi_awprot_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_awqos": ".axi_awqos_o        (axi_awqos_o            [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_awvalid": ".axi_awvalid_o    (axi_awvalid_o          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_awready": ".axi_awready_i    (axi_awready_i          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_wdata": ".axi_wdata_o        (axi_wdata_o            [/*<extmem_conn_num>*/*AXI_DATA_W     +:/*<bus_size>*/*AXI_DATA_W])",
    "axi_wstrb": ".axi_wstrb_o        (axi_wstrb_o            [/*<extmem_conn_num>*/*(AXI_DATA_W/8) +:/*<bus_size>*/*(AXI_DATA_W/8)])",
    "axi_wlast": ".axi_wlast_o        (axi_wlast_o            [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_wvalid": ".axi_wvalid_o      (axi_wvalid_o           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_wready": ".axi_wready_i      (axi_wready_i           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_bid": ".axi_bid_i            (axi_bid_i              [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_bresp": ".axi_bresp_i        (axi_bresp_i            [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_bvalid": ".axi_bvalid_i      (axi_bvalid_i           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_bready": ".axi_bready_o      (axi_bready_o           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_arid": ".axi_arid_o          (axi_arid_o             [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_araddr": ".axi_araddr_o      (axi_araddr_o           [/*<extmem_conn_num>*/*AXI_ADDR_W     +:/*<bus_size>*/*AXI_ADDR_W])",
    "axi_arlen": ".axi_arlen_o        (axi_arlen_o            [/*<extmem_conn_num>*/*AXI_LEN_W      +:/*<bus_size>*/*AXI_LEN_W])",
    "axi_arsize": ".axi_arsize_o      (axi_arsize_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_arburst": ".axi_arburst_o    (axi_arburst_o          [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_arlock": ".axi_arlock_o      (axi_arlock_o           [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_arcache": ".axi_arcache_o    (axi_arcache_o          [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_arprot": ".axi_arprot_o      (axi_arprot_o           [/*<extmem_conn_num>*/*3              +:/*<bus_size>*/*3])",
    "axi_arqos": ".axi_arqos_o        (axi_arqos_o            [/*<extmem_conn_num>*/*4              +:/*<bus_size>*/*4])",
    "axi_arvalid": ".axi_arvalid_o    (axi_arvalid_o          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_arready": ".axi_arready_i    (axi_arready_i          [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_rid": ".axi_rid_i            (axi_rid_i              [/*<extmem_conn_num>*/*AXI_ID_W       +:/*<bus_size>*/*AXI_ID_W])",
    "axi_rdata": ".axi_rdata_i        (axi_rdata_i            [/*<extmem_conn_num>*/*AXI_DATA_W     +:/*<bus_size>*/*AXI_DATA_W])",
    "axi_rresp": ".axi_rresp_i        (axi_rresp_i            [/*<extmem_conn_num>*/*2              +:/*<bus_size>*/*2])",
    "axi_rlast": ".axi_rlast_i        (axi_rlast_i            [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_rvalid": ".axi_rvalid_i      (axi_rvalid_i           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
    "axi_rready": ".axi_rready_o      (axi_rready_o           [/*<extmem_conn_num>*/*1              +:/*<bus_size>*/*1])",
}


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


# Generate list of dictionaries with interfaces for each peripheral instance
# Each dictionary is follows the format of a dictionary table in the
# 'ios' list of the <corename>_setup.py
# Example dictionary of a peripheral instance with one port:
#    {'name': 'instance_name', 'descr':'instance description', 'ports': [
#        {'name':"clk_i", 'type':"I", 'width':'1', 'descr':"Peripheral clock input"}
#    ]}
def get_peripheral_ios(peripherals_list):
    port_list = {}
    # Get port list for each type of peripheral used
    for instance in peripherals_list:
        # Make sure we have a hw_module for this peripheral type
        # assert check_module_in_modules_list(instance['type'],submodules["hw_setup"]["modules"]), f"{iob_colors.FAIL}peripheral {instance['type']} configured but no corresponding hardware module found!{iob_colors.ENDC}"
        # Only insert ports of this peripheral type if we have not done so before
        if instance.module.name not in port_list:
            # Extract only PIO signals from the peripheral (no reserved/known signals)
            port_list[instance.module.name] = get_pio_signals(
                get_module_io(instance.module.ios, instance.module.confs, instance.name)
            )

    ios_list = []
    # Append ports of each instance
    for instance in peripherals_list:
        ios_list.append(
            {
                "name": instance.name,
                "descr": f"{instance.name} interface signals",
                "ports": port_list[instance.module.name],
                "ios_table_prefix": True,
            }
        )
    return ios_list


# This function is used to setup peripheral related configuration in the python module of iob-soc systems
# python_module: Module of the iob-soc system being setup
# def iob_soc_peripheral_setup(python_module):
#     """ Fill IOb-SoC macros related to peripherals automatically (like N_SLAVES, N_SLAVES_W, etc)"""
#     # Get peripherals list from 'peripherals' table in blocks list
#     peripherals_list = python_module.peripherals
#
#     if peripherals_list:
#         # Get port list, parameter list and top module name for each type of peripheral used
#         _, params_list, _ = get_peripherals_ports_params_top(peripherals_list)
#         # Insert peripheral instance parameters in system parameters
#         # This causes the system to have a parameter for each parameter of each peripheral instance
#         for instance in peripherals_list:
#             for parameter in params_list[instance.module.name]:
#                 parameter_to_append = parameter.copy()
#                 # Override parameter value if user specified a 'parameters' dictionary with an override value for this parameter.
#                 if parameter["name"] in instance.parameters:
#                     parameter_to_append["val"] = instance.parameters[parameter["name"]]
#                 # Add instance name prefix to the name of the parameter. This makes this parameter unique to this instance
#                 parameter_to_append[
#                     "name"
#                 ] = f"{instance.name}_{parameter_to_append['name']}"
#                 python_module.confs.append(parameter_to_append)
#
#         # Get peripheral related macros
#         get_peripheral_macros(python_module.confs, peripherals_list)


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


# Filter out non reserved signals from a given list (not stored in string reserved_signals)
# Example signal_list:
# [ {'name':"clk_i", 'type':"I", 'width':'1', 'descr':"Peripheral clock input"},
#  {'name':"custom_i", 'type':"I", 'width':'1', 'descr':"Peripheral custom input"} ]
# Return of this example:
# [ {'name':"clk_i", 'type':"I", 'width':'1', 'descr':"Peripheral clock input"} ]
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
# [ {'name':"clk_i", 'type':"I", 'width':'1', 'descr':"Peripheral clock input"},
#  {'name':"custom_i", 'type':"I", 'width':'1', 'descr':"Peripheral custom input"} ]
# Return of this example:
# [ {'name':"custom_i", 'type':"I", 'width':'1', 'descr':"Peripheral custom input"} ]
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
        if instance.module.name not in port_list:
            # Append instance IO, parameters, and top name
            port_list[instance.module.name] = get_module_io(instance.module.ios)
            params_list[instance.module.name] = list(
                i for i in instance.module.confs if i["type"] in ["P", "F"]
            )
            top_list[instance.module.name] = instance.module.name
    return port_list, params_list, top_list


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


# Arguments:
#   periph_addr_select_bit: Adress selection bit (P variable)
#   peripherals_list: list with amount of instances of each peripheral (returned by get_peripherals())
def create_periphs_tmp(name, addr_w, peripherals_list, out_file):
    # Don't override output file
    if os.path.isfile(out_file):
        return

    template_contents = []
    for instance in peripherals_list:
        template_contents.extend(
            f"#define {instance.name}_BASE ({name.upper()}_{instance.name}<<({addr_w}-1-{name.upper()}_N_SLAVES_W))\n"
        )

    # Write system.v
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    periphs_tmp_file = open(out_file, "w")
    periphs_tmp_file.writelines(template_contents)
    periphs_tmp_file.close()


# peripheral_instance: dictionary describing a peripheral instance. Must have 'name' and 'IO' attributes.
# port_name: name of the port we are mapping
def get_peripheral_port_mapping(
    peripheral_portmaps, peripheral_instance, if_name, port_name
):
    print(peripheral_instance, if_name, port_name)
    # try to match port map from peripheral_portmap list
    for portmap in peripheral_portmaps:
        if portmap[0]["corename"] == peripheral_instance.name:
            if portmap[0]["if_name"] == if_name and portmap[0]["port"] == port_name:
                return portmap[1]["port"]
    # If IO dictionary (with mapping) does not exist for this peripheral, use default wire name
    if "io" not in peripheral_instance.__dict__:
        return f"{peripheral_instance.name}_{port_name}"

    assert (
        if_name + "_" + port_name in peripheral_instance.io
    ), f"{iob_colors.FAIL}Port '{port_name}' of interface '{if_name}' for peripheral '{peripheral_instance.name}' not mapped!{iob_colors.ENDC}"
    # IO mapping dictionary exists, get verilog string for that mapping
    return get_verilog_mapping(peripheral_instance.io[if_name + "_" + port_name])


# Returns a string that defines a Verilog mapping. This string can be assigend to a verilog wire/port.
def get_verilog_mapping(map_obj):
    # Check if map_obj is mapped to all bits of a signal (it is a string with signal name)
    if type(map_obj) == str:
        return map_obj

    # Signal is mapped to specific bits of single/multiple wire(s)
    verilog_concat_string = ""
    # Create verilog concatenation of bits of same/different wires
    for map_wire_bit in map_obj:
        # Stop concatenation if we find a bit not mapped. (Every bit after it should not be mapped aswell)
        if not map_wire_bit:
            break
        wire, bit = map_wire_bit
        verilog_concat_string = f"{wire}[{bit}],{verilog_concat_string}"

    verilog_concat_string = "{" + verilog_concat_string
    verilog_concat_string = (
        verilog_concat_string[:-1] + "}"
    )  # Replace last comma by a '}'
    return verilog_concat_string
