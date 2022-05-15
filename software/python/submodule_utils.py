#!/usr/bin/env python3
# Library with useful functions to manage submodules and peripherals

import sys
import subprocess
import os
import re
import math

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

# Parameter: PERIPHERALS string defined in config.mk
# Returns dictionary with amount of instances each peripheral of the SoC to be created 
def get_peripherals(peripherals_str):
    peripherals = peripherals_str.split()

    # Count how many instances to create of each type of peripheral
    instances_amount = {}
    for i in peripherals:
        instances_amount[i]=peripherals.count(i)

    return instances_amount

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
            signal = re.search("^\s*((?:input)|(?:output))(?:\s|(?:\[([^:]+):([^\]]+)\]))*(.*),?", verilog_lines[i])
            if signal is not None:
                # Store signal in dictionary with format: module_signals[signalname] = "input [size:0]"
                if signal.group(2) is None:
                    module_signals[signal.group(4)]=signal.group(1)
                else:
                    #FUTURE IMPROVEMENT: make python parse verilog macros.
                    module_signals[signal.group(4)]="{} [{}:{}]".format(signal.group(1), 
                            signal.group(2) if signal.group(2).isdigit() else
                            ("" if "`" in signal.group(2) else "`") # Set as macro if it was a parameter
                            +signal.group(2).replace("ADDR_W","/*<SwregFilename>*/_ADDR_W"),
                            signal.group(3))
        elif "`IOB_INPUT" in verilog_lines[i]: #If it is a known verilog macro
            signal = re.search("^\s*`IOB_INPUT\(\s*(\w+)\s*,\s*([^\s]+)\s*\),?", verilog_lines[i])
            if signal is not None:
                # Store signal in dictionary with format: module_signals[signalname] = "input [size:0]"
                module_signals[signal.group(1)]="input [{}:0]".format(
                        int(signal.group(2))-1 if signal.group(2).isdigit() else 
                        (("" if "`" in signal.group(2) else "`") # Set as macro if it was a parameter
                        +signal.group(2)+"-1").replace("ADDR_W","/*<SwregFilename>*/_ADDR_W")) # Replace keyword "ADDR_W" by "/*<SwregFilename>*/_ADDR_W"
        elif "`IOB_OUTPUT" in verilog_lines[i]: #If it is a known verilog macro
            signal = re.search("^\s*`IOB_OUTPUT\(\s*(\w+)\s*,\s*([^\s]+)\s*\),?", verilog_lines[i])
            if signal is not None:
                # Store signal in dictionary with format: module_signals[signalname] = "output [size:0]"
                module_signals[signal.group(1)]="output [{}:0]".format(
                        int(signal.group(2))-1 if signal.group(2).isdigit() else 
                        (("" if "`" in signal.group(2) else "`")
                        +signal.group(2)+"-1").replace("ADDR_W","/*<SwregFilename>*/_ADDR_W")) # Replace keyword "ADDR_W" by "/*<SwregFilename>*/_ADDR_W"
        elif '`include "gen_if.vh"' in verilog_lines[i]: #If it is a known verilog include
            module_signals["clk"]="input "
            module_signals["rst"]="input "
        elif '`include "iob_s_if.vh"' in verilog_lines[i]: #If it is a known verilog include
            module_signals["valid"]="input "
            module_signals["address"]="input [/*<SwregFilename>*/_ADDR_W:0] "
            module_signals["wdata"]="input [DATA_W:0] "
            module_signals["wstrb"]="input [DATA_W/8:0] "
            module_signals["rdata"]="output [DATA_W:0] "
            module_signals["ready"]="output "
        else:
            print("Unknow macro/signal declaration '{}' in module '{}'".format(verilog_lines[i],verilog_lines[module_start-1]))
            exit(-1)
    return module_signals

# Given a dictionary of signals, returns a dictionary with only pio signals.
# It removes reserved signals, such as: clk, rst, valid, address, wdata, wstrb, rdata or ready
def get_pio_signals(peripheral_signals):
    pio_signals = peripheral_signals.copy()
    for signal in ["clk","rst","arst","valid","address","wdata","wstrb","rdata","ready"]:
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

# Return dictionary with signals for each peripheral given in the input list 
# Also need to provide a dictionary with directory location of each peripheral given
def get_peripherals_signals(list_of_peripherals, submodule_directories):
    # Get signals of each peripheral
    peripheral_signals = {}
    for i in list_of_peripherals:
        peripheral_signals[i] = {}
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
        
        module_file.close()
    #print(peripheral_signals) #DEBUG
    return peripheral_signals

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
    instances_amount = get_peripherals(peripherals_str)
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            print(corename+str(i), end=" ")

def print_peripherals(peripherals_str):
    instances_amount = get_peripherals(peripherals_str)
    for i in instances_amount:
        print(i, end=" ")

def print_nslaves(peripherals_str):
    instances_amount = get_peripherals(peripherals_str)
    i=0
    # Calculate total amount of instances
    for corename in instances_amount:
        i=i+instances_amount[corename]
    print(i, end="")

def print_nslaves_w(peripherals_str):
    instances_amount = get_peripherals(peripherals_str)
    i=0
    # Calculate total amount of instances
    for corename in instances_amount:
        i=i+instances_amount[corename]
    print(math.ceil(math.log(i,2)))

#Creates list of defines of peripheral instances with sequential numbers
def print_peripheral_defines(defmacro, peripherals_str):
    instances_amount = get_peripherals(peripherals_str)
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
