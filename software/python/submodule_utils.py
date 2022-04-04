#!/usr/bin/env python3
# Library with useful functions to manage submodules and peripherals

import sys
import subprocess
import os
import re

# Parameter: string with directories separated by '\n'
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
# Returns dictionary with amount of instances each peripheral of the SUT to be created 
def get_sut_peripherals(sut_peripherals_str):
    sut_peripherals = sut_peripherals_str.split()

    # Count how many instances to create of each type of peripheral
    sut_instances_amount = {}
    for i in sut_peripherals:
        sut_instances_amount[i]=sut_peripherals.count(i)
    #print(sut_instances_amount) #DEBUG

    return sut_instances_amount

# Return dictionary with signals for each peripheral given in the input list 
# Also need to provide a dictionary with directory location of each peripheral given
# list_of_peripherals input can be {**sut_instances_amount, **tester_instances_amount} to get all peripherals from tester and SUT
def get_peripherals_signals(list_of_peripherals, submodule_directories):
    # Get signals of each peripheral
    peripheral_signals = {}
    for i in list_of_peripherals:
        peripheral_signals[i] = {}
        pio_path = root_dir+"/"+submodule_directories[i]+"/hardware/include/pio.vh"
        #Skip iteration if peripheral does not have pio
        if not os.path.isfile(pio_path):
            continue
        pio_file = open(pio_path, "r")
        pio_contents = pio_file.readlines() 
        for j in pio_contents:
            signal = re.search("^\s*((?:(?:input)|(?:output))(?:\s|(?:\[.*\]))*)(.*),", j)
            if signal is not None:
                # Store input or output and array size of pio.vh
                peripheral_signals[i][signal.group(2)]=signal.group(1)

                ## Find matching signal of inst.vh # This is currently not used!
                #with open(root_dir+"/"+submodule_directories[i]+"/hardware/include/inst.vh", "r" ) as f:
                #    matching_signal = re.search("\.([^\s]+)\s+\({}\),".format(signal.group(2).replace("/","\/").replace("*","\*")),f.read(),re.MULTILINE).group(1)
                ## Place an array that contains:
                ##   input or output and array size of pio.vh
                ##   matching signal in inst.vh
                #peripheral_signals[i][signal.group(2)]=[signal.group(1),matching_signal]
        pio_file.close()
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
def print_instances(sut_peripherals_str):
    sut_instances_amount = get_sut_peripherals(sut_peripherals_str)
    for corename in sut_instances_amount:
        for i in range(sut_instances_amount[corename]):
            print(corename+str(i), end=" ")

def print_peripherals(sut_peripherals_str):
    sut_instances_amount = get_sut_peripherals(sut_peripherals_str)
    for i in sut_instances_amount:
        print(i, end=" ")

def print_nslaves(sut_peripherals_str):
    sut_instances_amount = get_sut_peripherals(sut_peripherals_str)
    i=0
    # Calculate total amount of instances
    for corename in sut_instances_amount:
        i=i+sut_instances_amount[corename]
    print(i, end="")

#Creates list of defines of sut instances with sequential numbers
def print_sut_peripheral_defines(defmacro, sut_peripherals_str):
    sut_instances_amount = get_sut_peripherals(sut_peripherals_str)
    j=0
    for corename in sut_instances_amount:
        for i in range(sut_instances_amount[corename]):
            print(defmacro+corename+str(i)+"="+str(j), end=" ")
            j = j + 1

if __name__ == "__main__":
    # Parse arguments
    if sys.argv[1] == "get_peripherals":
        if len(sys.argv)<3:
            print("Usage: {} get_peripherals <sut_peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_peripherals(sys.argv[2])
    elif sys.argv[1] == "get_instances":
        if len(sys.argv)<3:
            print("Usage: {} get_instances <sut_peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_instances(sys.argv[2])
    elif sys.argv[1] == "get_n_slaves":
        if len(sys.argv)<3:
            print("Usage: {} get_n_slaves <sut_peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_nslaves(sys.argv[2])
    elif sys.argv[1] == "get_defines":
        if len(sys.argv)<3:
            print("Usage: {} get_defines <sut_peripherals> <optional:defmacro>\n".format(sys.argv[0]))
            exit(-1)
        if len(sys.argv)<4:
            print_sut_peripheral_defines("",sys.argv[2])
        else:
            print_sut_peripheral_defines(sys.argv[3],sys.argv[2])
    else:
        print("Unknown command.\nUsage: {} <command> <parameters>\n Commands: get_peripherals get_instances get_n_slaves get_defines print_sut_peripheral_defines".format(sys.argv[0]))
        exit(-1)
