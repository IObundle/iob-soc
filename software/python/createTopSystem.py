#!/usr/bin/env python3
#Creates system_top.v based on system_top_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *
from portmap_utils import read_portmap

def create_top_system(directories_str, peripherals_str, portmap_path):
    # Get peripherals, directories and signals
    instances_amount, instances_parameters = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals, peripheral_parameters = get_peripherals_signals(instances_amount,submodule_directories)

    # Read portmap file and get encoded data
    pwires, mapped_signals = read_portmap(instances_amount, instances_parameters, peripheral_signals, peripheral_parameters, portmap_path)

    # Read template file
    template_file = open(root_dir+"/hardware/simulation/verilog_tb/system_top_core.v", "r")
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

        pio_signals = get_pio_signals(peripheral_signals[corename])

        # Insert wires and connect them to system 
        for i in range(instances_amount[corename]):
            for signal in pio_signals:
                # Check if mapped to external interface
                if mapped_signals[corename][i][signal] == -1:
                    # Insert system IOs for peripheral
                    signal_size = replaceByParameterValue(peripheral_signals[corename][signal],\
                                  peripheral_parameters[corename],\
                                  instances_parameters[corename][i])
                    template_contents.insert(find_idx(template_contents, "PWIRES"), '   {}  {}_{};\n'.format(re.sub("(?:inout|input|output)\s+","wire ", signal_size),corename+str(i),signal))
                    # Connect wires to system port
                    template_contents.insert(find_idx(template_contents, "PORTS"), '               .{signal}({signal}),\n'.format(signal=corename+str(i)+"_"+signal))

    # Write system_top.v
    systemtop_file = open("system_top.v", "w")
    systemtop_file.writelines(template_contents)
    systemtop_file.close()

if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)!=5:
        print("Usage: {} <root_dir> <portmap_path> <directories_defined_in_config.mk> <peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir

    create_top_system(sys.argv[3], sys.argv[4], os.path.join(root_dir,sys.argv[2])) 
