#!/usr/bin/env python3
#Creates system.v based on system_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *

def create_systemv(directories_str, sut_peripherals_str):
    # Get peripherals, directories and signals
    sut_instances_amount = get_sut_peripherals(sut_peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals = get_peripherals_signals(sut_instances_amount, submodule_directories)

    # Read template file
    template_file = open(root_dir+"/hardware/src/system_core.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Insert header files
    for corename in sut_instances_amount:
        path = root_dir+"/"+submodule_directories[corename]+"/hardware/include"
        start_index = find_idx(template_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
            if file.endswith("swreg.vh"):
                template_contents.insert(start_index, '`include "{}"\n'.format(file.replace("swreg","swreg_def")))

    # Insert IOs and Instances for peripheral
    for corename in sut_instances_amount:
        # Read inst.vh file
        instv_file = open(root_dir+"/"+submodule_directories[corename]+"/hardware/include/inst.vh", "r")
        instv_contents = instv_file.readlines() 
        # Insert for every instance
        for i in range(sut_instances_amount[corename]):
            # Insert system IOs for peripheral
            start_index = find_idx(template_contents, "PIO")
            for signal in peripheral_signals[corename]:
                template_contents.insert(start_index, '    {} {},\n'.format(peripheral_signals[corename][signal],re.sub("\/\*<InstanceName>\*\/",corename+str(i),signal)))
            # Insert peripheral instance
            start_index = find_idx(template_contents, "endmodule")-1
            for j in reversed(instv_contents):
                template_contents.insert(start_index, re.sub("\/\*<InstanceName>\*\/",corename+str(i),j))
        instv_file.close()

    # Write system.v
    systemv_file = open("system.v", "w")
    systemv_file.writelines(template_contents)
    systemv_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<4:
        print("Usage: {} <root_dir> <directories_defined_in_config.mk> <sut_peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir

    create_systemv(sys.argv[2], sys.argv[3]) 
