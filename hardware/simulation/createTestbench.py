#!/usr/bin/env python3
#Creates system_tb.v based on system_tb_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
sys.path.append(os.path.join(os.path.dirname(__file__), '../../software'))
import submodule_utils 
from submodule_utils import *

def create_system_tb():
    # Get peripherals, directories and signals
    sut_instances_amount = get_sut_peripherals()
    submodule_directories = get_submodule_directories()
    peripheral_signals = get_peripherals_signals(sut_instances_amount, submodule_directories)

    # Read template file
    template_file = open(root_dir+"/hardware/testbench/system_core_tb.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Insert header files
    for corename in sut_instances_amount:
        path = root_dir+"/submodules/"+submodule_directories[corename]+"/hardware/include"
        start_index = find_idx(template_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh"):
                template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))

    # Insert wires and connect them to uut 
    for corename in sut_instances_amount:
        # Insert for every instance
        for i in range(sut_instances_amount[corename]):
            # Insert system IOs for peripheral
            start_index = find_idx(template_contents, "PWIRES")
            for signal in peripheral_signals[corename]:
                template_contents.insert(start_index, '   {}  {};\n'.format(re.sub("(?:(?:input)|(?:output))\s+","wire",peripheral_signals[corename][signal]),re.sub("\/\*<InstanceName>\*\/",corename+str(i),signal)))
            # Connect wires to sut port
            start_index = find_idx(template_contents, "PORTS")
            for signal in peripheral_signals[corename]:
                template_contents.insert(start_index, '               .{signal}({signal}),\n'.format(signal=re.sub("\/\*<InstanceName>\*\/",corename+str(i),signal)))

    # Write system.v
    systemv_file = open("system_tb.v", "w")
    systemv_file.writelines(template_contents)
    systemv_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)>1:
        root_dir=sys.argv[1]
        submodule_utils.root_dir = root_dir
        create_system_tb() 
    else:
        print("Needs one argument.\nUsage: {} <root_dir>".format(sys.argv[0]))
