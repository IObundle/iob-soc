#!/usr/bin/env python3
#Creates system_tb.v based on system_core_tb.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *

def create_system_testbench(directories_str, peripherals_str):
    # Get peripherals, directories and signals
    instances_amount, _ = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)

    # Read template file
    template_file = open(root_dir+"/hardware/simulation/verilog_tb/system_core_tb.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Insert header files
    for corename in instances_amount:
        path = root_dir+"/"+submodule_directories[corename]+"/hardware/include"
        if os.path.isdir(path):
            start_index = find_idx(template_contents, "PHEADER")
            for file in os.listdir(path):
                if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                    template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
                if file.endswith("swreg.vh"):
                    template_contents.insert(start_index, '`include "{}"\n'.format(file.replace("swreg","swreg_def")))

    # Write system.v
    systemv_file = open("system_tb.v", "w")
    systemv_file.writelines(template_contents)
    systemv_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<4:
        print("Usage: {} <root_dir> <directories_defined_in_config.mk> <peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir
    create_system_testbench(sys.argv[2], sys.argv[3]) 
