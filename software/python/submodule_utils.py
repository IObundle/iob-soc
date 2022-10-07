#!/usr/bin/env python3
# Library with useful functions to manage submodules and peripherals

import sys
import subprocess
import os
import re
import math

# Signals in this template will only be inserted if they exist in the peripheral IO
reserved_signals_template = """\
      .clk(clk),
      .rst(rst),
      .reset(rst),
      .arst(rst),
      .valid(slaves_req[`valid(`/*<InstanceName>*/)]),
      .address(slaves_req[`address(`/*<InstanceName>*/,`/*<SwregFilename>*/_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`/*<InstanceName>*/)]),
      .wstrb(slaves_req[`wstrb(`/*<InstanceName>*/)]),
      .rdata(slaves_resp[`rdata(`/*<InstanceName>*/)]),
      .ready(slaves_resp[`ready(`/*<InstanceName>*/)]),
      .trap(trap[0]),
      .m_axi_awid    (m_axi_awid[AXI_ID_W-1:0]),
      .m_axi_awaddr  (m_axi_awaddr[AXI_ADDR_W-1:0]),
      .m_axi_awlen   (m_axi_awlen[7:0]),
      .m_axi_awsize  (m_axi_awsize[2:0]),
      .m_axi_awburst (m_axi_awburst[1:0]),
      .m_axi_awlock  (m_axi_awlock[1:0]),
      .m_axi_awcache (m_axi_awcache[3:0]),
      .m_axi_awprot  (m_axi_awprot[2:0]),
      .m_axi_awqos   (m_axi_awqos[3:0]),
      .m_axi_awvalid (m_axi_awvalid[0:0]),
      .m_axi_awready (m_axi_awready[0:0]),
      .m_axi_wdata   (m_axi_wdata[`DATA_W-1:0]),
      .m_axi_wstrb   (m_axi_wstrb[`DATA_W/8-1:0]),
      .m_axi_wlast   (m_axi_wlast[0:0]),
      .m_axi_wvalid  (m_axi_wvalid[0:0]),
      .m_axi_wready  (m_axi_wready[0:0]),
      .m_axi_bid     (m_axi_bid[AXI_ID_W-1:0]),
      .m_axi_bresp   (m_axi_bresp[1:0]),
      .m_axi_bvalid  (m_axi_bvalid[0:0]),
      .m_axi_bready  (m_axi_bready[0:0]),
      .m_axi_arid    (m_axi_arid[AXI_ID_W-1:0]),
      .m_axi_araddr  (m_axi_araddr[AXI_ADDR_W-1:0]),
      .m_axi_arlen   (m_axi_arlen[7:0]),
      .m_axi_arsize  (m_axi_arsize[2:0]),
      .m_axi_arburst (m_axi_arburst[1:0]),
      .m_axi_arlock  (m_axi_arlock[1:0]),
      .m_axi_arcache (m_axi_arcache[3:0]),
      .m_axi_arprot  (m_axi_arprot[2:0]),
      .m_axi_arqos   (m_axi_arqos[3:0]),
      .m_axi_arvalid (m_axi_arvalid[0:0]),
      .m_axi_arready (m_axi_arready[0:0]),
      .m_axi_rid     (m_axi_rid[AXI_ID_W-1:0]),
      .m_axi_rdata   (m_axi_rdata[`DATA_W-1:0]),
      .m_axi_rresp   (m_axi_rresp[1:0]),
      .m_axi_rlast   (m_axi_rlast[0:0]),
      .m_axi_rvalid  (m_axi_rvalid[0:0]),
      .m_axi_rready  (m_axi_rready[0:0]),
"""


# Parameter: string with directories separated by ';'
# Returns dictionary with every directory defined in <root_dir>/config.mk
def get_directories(directories_str):
    # Get directories for each submodule
    directories = {}
    list_dirs_str = directories_str.split(';')
    list_dirs_str.pop(-1)
    for line in list_dirs_str:
        var_name, path  = line.strip().split("=", 1)
        directories[var_name] = path
    return directories

# Convert keys from format "CORENAME_DIR" to "CORENAME"
# (Removes "_DIR" sufix from every key in the directories dictionary)
def get_submodule_directories(directories_str):
    directories = get_directories(directories_str)
    keys = list(directories.keys())
    for key in keys:
        directories[key.replace("_DIR","")] = directories.pop(key)
    return directories

# Replaces a verilog parameter in a string with its value.
# The value is determined based on default value and ordered parameters given (that may override the default)
# Arguments: 
#   string_with_parameter: string with parameter that will be replaced. Example: "input [SIZE_PARAMETER:0]"
#   parameters_default_values: dictionary of parameters where key is parameter name 
#                              and value is default value of this parameter. 
#                              Example: {"SIZE_PARAMETER":16, "ANOTHER_PARAMETER":0}
#   ordered_parameter_values: list of ordered parameter values that override default ones.
#                              Example: ["32", "5"]
# Returns: 
#   String with parameter replaced. Example: "input [32:0]"
def replaceByParameterValue(string_with_parameter, parameters_default_values, ordered_parameter_values):
    parameter_idx=0
    parameter_name=""

    #Find parameter name
    for parameter in parameters_default_values:
        #Check if parameter is in string, and is not followed by any other letters that could be considered part of the parameter
        result = re.search(f"[^a-zA-Z_`]{parameter}[^a-zA-Z_]", string_with_parameter)
        if result is not None:
            parameter_name=parameter
            break
        parameter_idx+=1

    #Return unmodified string if there is no parameter in string
    if not parameter_name:
        return string_with_parameter;

    #If parameter should be overriden
    if(len(ordered_parameter_values)>parameter_idx):
        #Replace parameter in string with value from parameter override
        return string_with_parameter.replace(parameter_name,ordered_parameter_values[parameter_idx])
    else:
        #Replace parameter in string with default value 
        return string_with_parameter.replace(parameter_name,parameters_default_values[parameter_name])

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
        i = i.split("[") # Split corename and parameters
        # Initialize corename in dictionary 
        if i[0] not in instances_amount:
            instances_amount[i[0]]=0
            instances_parameters[i[0]]=[]
        # Insert parameters of this instance (if there are any)
        if len(i) > 1:
            i[1] = i[1].strip("]") # Delete final "]" from parameter list
            instances_parameters[i[0]].append(i[1].split(","))
        else:
            instances_parameters[i[0]].append([])
        # Increment amount of instances
        instances_amount[i[0]]+=1

    #print(instances_amount, file = sys.stderr) #Debug
    #print(instances_parameters, file = sys.stderr) #Debug
    return instances_amount, instances_parameters

# Given lines read from the verilog file with a module declaration
# this function returns the inputs and outputs defined in the port list
# of that module. The return value is a dictionary, where the key is the 
# signal name and the value is a string like "input [10:0]"
def get_module_io(verilog_lines):
    module_start = 0
    #Find module declaration
    for line in verilog_lines:
        module_start += 1
        if "module " in line:
            break #Found module declaration

    port_list_start = module_start
    #Find module port list start 
    for i in range(module_start, len(verilog_lines)):
        port_list_start += 1
        if verilog_lines[i].replace(" ", "").startswith("("):
            break #Found port list start

    module_signals = {}
    #Get signals of this module
    for i in range(port_list_start, len(verilog_lines)):
        #Ignore comments and empty lines
        if not verilog_lines[i].strip() or verilog_lines[i].lstrip().startswith("//"):
            continue
        if ");" in verilog_lines[i]:
            break #Found end of port list
        #If this signal is declared in normal verilog format (no macros)
        if any(verilog_lines[i].lstrip().startswith(x) for x in ["input","output"]):
            signal = re.search("^\s*(inout|input|output)(?:\s|(?:\[([^:]+):([^\]]+)\]))*([^,]*),?", verilog_lines[i])
            if signal is not None:
                # Store signal in dictionary with format: module_signals[signalname] = "input [size:0]"
                if signal.group(2) is None:
                    module_signals[signal.group(4)]=signal.group(1)
                else:
                    module_signals[signal.group(4)]="{} [{}:{}]".format(signal.group(1), signal.group(2), signal.group(3))
        elif "`IOB_INPUT" in verilog_lines[i]: #If it is a known verilog macro
            signal = re.search("^\s*`IOB_INPUT\(\s*(\w+)\s*,\s*([^\s]+)\s*\),?", verilog_lines[i])
            if signal is not None:
                # Store signal in dictionary with format: module_signals[signalname] = "input [size:0]"
                module_signals[signal.group(1)]="input [{}:0]".format(
                        int(signal.group(2))-1 if signal.group(2).isdigit() else # Calculate size here if only contains digits
                        signal.group(2)+"-1") # Leave calculation for verilog
        elif "`IOB_OUTPUT" in verilog_lines[i] or "`IOB_OUTPUT_VAR" in verilog_lines[i]: #If it is a known verilog macro
            signal = re.search("^\s*`IOB_OUTPUT(?:_VAR)?\(\s*(\w+)\s*,\s*([^\s]+)\s*\),?", verilog_lines[i])
            if signal is not None:
                # Store signal in dictionary with format: module_signals[signalname] = "output [size:0]"
                module_signals[signal.group(1)]="output [{}:0]".format(
                        int(signal.group(2))-1 if signal.group(2).isdigit() else # Calculate size here if only contains digits
                        signal.group(2)+"-1") # Leave calculation for verilog
        elif "`IOB_INOUT" in verilog_lines[i]: #If it is a known verilog macro
            signal = re.search("^\s*`IOB_INOUT\(\s*(\w+)\s*,\s*([^\s]+)\s*\),?", verilog_lines[i])
            if signal is not None:
                # Store signal in dictionary with format: module_signals[signalname] = "inout [size:0]"
                module_signals[signal.group(1)]="inout [{}:0]".format(
                        int(signal.group(2))-1 if signal.group(2).isdigit() else # Calculate size here if only contains digits
                        signal.group(2)+"-1") # Leave calculation for verilog
        elif '`include "iob_gen_if.vh"' in verilog_lines[i]: #If it is a known verilog include
            module_signals["clk"]="input "
            module_signals["rst"]="input "
        elif '`include "iob_s_if.vh"' in verilog_lines[i]: #If it is a known verilog include
            module_signals["valid"]="input "
            module_signals["address"]="input [ADDR_W:0] "
            module_signals["wdata"]="input [DATA_W:0] "
            module_signals["wstrb"]="input [DATA_W/8:0] "
            module_signals["rdata"]="output [DATA_W:0] "
            module_signals["ready"]="output "
        else:
            print("Unknow macro/signal declaration '{}' in module '{}'".format(verilog_lines[i],verilog_lines[module_start-1]))
            exit(-1)
    return module_signals

# Given lines read from the verilog file with a module declaration
# this function returns the parameters of that module. 
# The return value is a dictionary, where the key is the 
# parameter name and the value is the default value assigned to the parameter.
def get_module_parameters(verilog_lines):
    module_start = 0
    #Find module declaration
    for line in verilog_lines:
        module_start += 1
        if "module " in line:
            break #Found module declaration

    parameter_list_start = module_start
    #Find module parameter list start 
    for i in range(module_start, len(verilog_lines)):
        parameter_list_start += 1
        if verilog_lines[i].replace(" ", "").startswith("#("):
            break #Found parameter list start

    module_parameters = {}
    #Get parameters of this module
    for i in range(parameter_list_start, len(verilog_lines)):
        #Strip comments
        idx = verilog_lines[i].find("//")
        if idx > -1:
            verilog_lines[i] = verilog_lines[i][:idx]
        #Empty lines
        if not verilog_lines[i].strip():
            continue
        if ")" in verilog_lines[i]:
            break #Found end of parameter list

        # Parse parameter
        parameter = re.search("^\s*parameter\s+([^=\s]+)\s*=\s*([^\s,]+),?", verilog_lines[i])
        if parameter is not None:
            # Store parameter in dictionary with format: module_parameters[parametername] = "default value"
                module_parameters[parameter.group(1)]=parameter.group(2)

    return module_parameters

# Given a dictionary of signals, returns a dictionary with only pio signals.
# It removes reserved system signals, such as: clk, rst, valid, address, wdata, wstrb, rdata, ready, ...
def get_pio_signals(peripheral_signals):
    pio_signals = peripheral_signals.copy()
    for signal in ["clk","rst","reset","arst","valid","address","wdata","wstrb","rdata","ready","trap"]\
                  +[i for i in pio_signals if "m_axi_" in i]:
        if signal in pio_signals: pio_signals.pop(signal)
    return pio_signals

# Given a path to a file containing the TOP_MODULE makefile variable declaration, return the value of that variable.
def get_top_module(file_path):
    config_file = open(file_path, "r")
    config_contents = config_file.readlines()
    config_file.close()
    top_module = ""
    for line in config_contents:
        top_module_search = re.search("^\s*TOP_MODULE\s*:?\??=\s*([^\s]+)", line)
        if top_module_search is not None:
            top_module = top_module_search.group(1)
            break;
    return top_module

# Arguments: - list_of_peripherals: dictionary with corename of each peripheral
#            - submodule_directories: dictionary with directory location of each peripheral given
# Returns: - dictionary with signals from port list in top module of each peripheral
#          - dictionary with parameters in top module of each peripheral
def get_peripherals_signals(list_of_peripherals, submodule_directories):
    peripheral_signals = {}
    peripheral_parameters = {}
    # Get signals of each peripheral
    for i in list_of_peripherals:
        # Find top module verilog file of peripheral
        module_dir = root_dir+"/"+submodule_directories[i]+"/hardware/src"
        module_filename = get_top_module(root_dir+"/"+submodule_directories[i]+"/config.mk")+".v";
        module_path=os.path.join(module_dir,module_filename)
        # Skip iteration if peripheral does not have top module
        if not os.path.isfile(module_path):
            continue
        # Read file
        module_file = open(module_path, "r")
        module_contents = module_file.read().splitlines()
        # Get module inputs and outputs
        peripheral_signals[i] = get_module_io(module_contents)
        peripheral_parameters[i] = get_module_parameters(module_contents)
        
        module_file.close()
    #print(peripheral_signals) #DEBUG
    return peripheral_signals, peripheral_parameters

# Find index of word in array with multiple strings
def find_idx(lines, word):
    for idx, i in enumerate(lines):
        if word in i:
            break
    return idx+1

##########################################################
# Functions to run when this script gets called directly #
##########################################################
def print_instances(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            print(corename+str(i), end=" ")

def print_peripherals(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    for i in instances_amount:
        print(i, end=" ")

def print_nslaves(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    i=0
    # Calculate total amount of instances
    for corename in instances_amount:
        i=i+instances_amount[corename]
    print(i, end="")

def print_nslaves_w(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    i=0
    # Calculate total amount of instances
    for corename in instances_amount:
        i=i+instances_amount[corename]

    if not i:
        print(0)
    else:
        print(math.ceil(math.log(i,2)))

#Print list of peripherals without parameters and duplicates
def remove_duplicates_and_params(peripherals_str):
    peripherals = peripherals_str.split()
    #Remove parameters from peripherals
    for i in range(len(peripherals)):
        peripherals[i] = peripherals[i].split("[")[0]
    #Remove peripheral duplicates
    peripherals = list(set(peripherals))
    #Print list of peripherals
    for p in peripherals:
        print(p, end=" ")

#Creates list of defines of peripheral instances with sequential numbers
def print_peripheral_defines(defmacro, peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    j=0
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            print(defmacro+corename+str(i)+"="+str(j), end=" ")
            j = j + 1

if __name__ == "__main__":
    # Parse arguments
    if sys.argv[1] == "get_peripherals":
        if len(sys.argv)<3:
            print("Usage: {} get_peripherals <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_peripherals(sys.argv[2])
    elif sys.argv[1] == "get_instances":
        if len(sys.argv)<3:
            print("Usage: {} get_instances <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_instances(sys.argv[2])
    elif sys.argv[1] == "get_n_slaves":
        if len(sys.argv)<3:
            print("Usage: {} get_n_slaves <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_nslaves(sys.argv[2])
    elif sys.argv[1] == "get_n_slaves_w":
        if len(sys.argv)<3:
            print("Usage: {} get_n_slaves_w <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_nslaves_w(sys.argv[2])
    elif sys.argv[1] == "remove_duplicates_and_params":
        if len(sys.argv)<3:
            print("Usage: {} remove_duplicates_and_params <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        remove_duplicates_and_params(sys.argv[2])
    elif sys.argv[1] == "get_defines":
        if len(sys.argv)<3:
            print("Usage: {} get_defines <peripherals> <optional:defmacro>\n".format(sys.argv[0]))
            exit(-1)
        if len(sys.argv)<4:
            print_peripheral_defines("",sys.argv[2])
        else:
            print_peripheral_defines(sys.argv[3],sys.argv[2])
    else:
        print("Unknown command.\nUsage: {} <command> <parameters>\n Commands: get_peripherals get_instances get_n_slaves get_n_slaves_w get_defines print_peripheral_defines".format(sys.argv[0]))
        exit(-1)
