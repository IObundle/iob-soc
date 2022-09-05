#!/usr/bin/env python3
#Creates system_top.v based on system_top_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *
import createSystem

def create_top_system(root_dir, directories_str, peripherals_str):
    # Get peripherals, directories and signals
    instances_amount, instances_parameters = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals, peripheral_parameters = get_peripherals_signals(instances_amount,submodule_directories)

    # Read template file
    template_file = open(root_dir+"/hardware/simulation/system_top.vt", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    createSystem.insert_header_files(template_contents, root_dir)

    for corename in instances_amount:
        top_module_name = get_top_module_from_dir(f'{root_dir}/{submodule_directories[corename]}')

        pio_signals = get_pio_signals(peripheral_signals[corename])

        # Insert wires and connect them to system 
        for i in range(instances_amount[corename]):
            # Insert system IOs for peripheral
            start_index = find_idx(template_contents, "PWIRES")
            for signal in pio_signals:
                signal_size = replaceByParameterValue(peripheral_signals[corename][signal],\
                              peripheral_parameters[corename],\
                              instances_parameters[corename][i])
                template_contents.insert(start_index, '   {}  {}_{};\n'.format(re.sub("(?:(?:input)|(?:output))\s+","wire ",signal_size),corename+str(i),signal))
            # Connect wires to soc port
            start_index = find_idx(template_contents, "PORTS")
            for signal in pio_signals:
                template_contents.insert(start_index, '               .{signal}({signal}),\n'.format(signal=corename+str(i)+"_"+signal))

    # Write system.v
    systemv_file = open("system_top.v", "w")
    systemv_file.writelines(template_contents)
    systemv_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<4:
        print("Usage: {} <root_dir> <directories_defined_in_info.mk> <peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir
    create_top_system(root_dir, sys.argv[2], sys.argv[3]) 
