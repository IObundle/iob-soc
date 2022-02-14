#!/usr/bin/env python3
# Library with useful functions to manage submodules and peripherals

import sys
import subprocess
import os
import re

# Returns dictionary with a directory for every submodule in submodules folder
def get_submodule_directories():
    # Get directories for each submodule
    submodule_directories = {}
    for file in os.listdir(root_dir+"/submodules"):
        if os.path.isdir(root_dir+"/submodules/"+file):
            corename = subprocess.run(['make', '--no-print-directory', '-C', root_dir+'/submodules/'+file, 'corename'], stdout=subprocess.PIPE).stdout.decode('utf-8').replace('\n','')
            submodule_directories[corename] = file
    #print(submodule_directories) #DEBUG

    return submodule_directories

# Returns dictionary with amount of instances each peripheral of the SUT to be created 
def get_sut_peripherals():
    # Get peripherals list of config.mk
    sut_peripherals = subprocess.run(['make', '--no-print-directory', '-C', root_dir+'/hardware/tester', 'sut-peripherals', 'SUT_DIR=../..'], stdout=subprocess.PIPE)
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
        pio_file = open(root_dir+"/submodules/"+submodule_directories[i]+"/hardware/include/pio.v", "r") 
        pio_contents = pio_file.readlines() 
        for j in pio_contents:
            signal = re.search("^\s*((?:(?:input)|(?:output))(?:\s|(?:\[.*\]))*)(.*),", j)
            if signal is not None:
                # Store input or output and array size of pio.v 
                peripheral_signals[i][signal.group(2)]=signal.group(1)

                ## Find matching signal of inst.v # This is currently not used!
                #with open(root_dir+"/submodules/"+submodule_directories[i]+"/hardware/include/inst.v", "r" ) as f:
                #    matching_signal = re.search("\.([^\s]+)\s+\({}\),".format(signal.group(2).replace("/","\/").replace("*","\*")),f.read(),re.MULTILINE).group(1)
                ## Place an array that contains:
                ##   input or output and array size of pio.v 
                ##   matching signal in inst.v 
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

def print_defines():
    sut_instances_amount = get_sut_peripherals()
    j=0
    for corename in sut_instances_amount:
        for i in range(sut_instances_amount[corename]):
            print(corename+str(i)+"="+str(j), end=" ")
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
           print_defines()
        else:
            print("Unknown argument.\nUsage: {} <command> <root_dir>\n Commands: TODO".format(sys.argv[0]))
    else:
        print("Needs two arguments.\nUsage: {} <command> <root_dir>".format(sys.argv[0]))
