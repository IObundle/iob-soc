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

    for corename in instances_amount:
        top_module_name = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk");

        # Insert header files
        path = root_dir+"/"+submodule_directories[corename]+"/hardware/include"
        if os.path.isdir(path):
            start_index = find_idx(template_contents, "PHEADER")
            for file in os.listdir(path):
                if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                    template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
        # Add topmodule_swreg_def.vh if mkregs.conf exists
        if os.path.isfile(root_dir+"/"+submodule_directories[corename]+"/mkregs.conf"):
            template_contents.insert(start_index, '`include "{}"\n'.format(top_module_name+"_swreg_def.vh"))

    # Write system_tb.v
    systemtb_file = open("system_tb.v", "w")
    systemtb_file.writelines(template_contents)
    systemtb_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<4:
        print("Usage: {} <root_dir> <directories_defined_in_config.mk> <peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir
    create_system_testbench(sys.argv[2], sys.argv[3]) 
