#!/usr/bin/env python3
# Library with useful functions to manage submodules and peripherals

import sys
import subprocess
import os
import re

# Returns dictionary with every directory defined in <root_dir>/config.mk
def get_directories():
    # Get directories for each submodule
    directories = {}
    dirs_str = subprocess.run(['make', '--no-print-directory', '-C', root_dir, 'directories'], stdout=subprocess.PIPE).stdout.decode('utf-8').splitlines()
    for line in dirs_str:
        var_name, path  = line.split("=", 1)
        directories[var_name] = path
    return directories

# Convert keys from format "CORENAME_DIR" to "CORENAME"
# (Removes "_DIR" sufix from every key in the directories dictionary)
def get_submodule_directories():
    directories = get_directories()
    keys = list(directories.keys())
    for key in keys:
        directories[key.replace("_DIR","")] = directories.pop(key)
    return directories

# Returns dictionary with amount of instances each peripheral of the SUT to be created 
def get_sut_peripherals():
    # Get peripherals list of config.mk
    sut_peripherals = subprocess.run(['make', '--no-print-directory', '-C', root_dir, 'sut-peripherals', 'ROOT_DIR=../..'], stdout=subprocess.PIPE)
    sut_peripherals = sut_peripherals.stdout.decode('ascii').split()

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
        pio_file = open(root_dir+"/"+submodule_directories[i]+"/hardware/include/pio.vh", "r")
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
def print_instances():
    sut_instances_amount = get_sut_peripherals()
    for corename in sut_instances_amount:
        for i in range(sut_instances_amount[corename]):
            print(corename+str(i), end=" ")

def print_peripherals():
    sut_instances_amount = get_sut_peripherals()
    for i in sut_instances_amount:
        print(i, end=" ")

def print_nslaves():
    sut_instances_amount = get_sut_peripherals()
    i=0
    # Calculate total amount of instances
    for corename in sut_instances_amount:
        i=i+sut_instances_amount[corename]
    print(i, end="")

#Creates list of defines of sut instances with sequential numbers
def print_sut_peripheral_defines(defmacro):
    sut_instances_amount = get_sut_peripherals()
    j=0
    for corename in sut_instances_amount:
        for i in range(sut_instances_amount[corename]):
            print(defmacro+corename+str(i)+"="+str(j), end=" ")
            j = j + 1

if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)>2:
        root_dir=sys.argv[2]
        if sys.argv[1] == "get_peripherals":
           print_peripherals() 
        elif sys.argv[1] == "get_instances":
           print_instances()
        elif sys.argv[1] == "get_n_slaves":
           print_nslaves()
        elif sys.argv[1] == "get_defines":
            if len(sys.argv)>3:
               print_sut_peripheral_defines(sys.argv[3])
            else:
                print("Unknown argument.\nUsage: {} print_defines <root_dir> <defmacro>\n".format(sys.argv[0]))
        else:
            print("Unknown argument.\nUsage: {} <command> <root_dir>\n".format(sys.argv[0]))
    else:
        print("Needs two arguments.\nUsage: {} <command> <root_dir>".format(sys.argv[0]))
