#!/usr/bin/env python3
#Creates system_top.v based on system_top_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *
from tester_utils import read_portmap

def create_top_system(directories_str, sut_peripherals_str, tester_peripherals_str, portmap_path, testing_cut):
    # Get peripherals, directories and signals
    sut_instances_amount = get_peripherals(sut_peripherals_str)
    tester_instances_amount = get_peripherals(tester_peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals = get_peripherals_signals({**sut_instances_amount, **tester_instances_amount},submodule_directories)

    # Read portmap file and get encoded data
    pwires, mapped_signals = read_portmap(sut_instances_amount, tester_instances_amount, peripheral_signals, portmap_path)

    if testing_cut:
        instances_amount=tester_instances_amount
    else:
        instances_amount=sut_instances_amount

    # Read template file
    template_file = open(root_dir+"/hardware/simulation/verilog_tb/system_top_core.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Insert header files
    for corename in instances_amount:
        path = root_dir+"/"+submodule_directories[corename]+"/hardware/include"
        start_index = find_idx(template_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
            if file.endswith("swreg.vh"):
                template_contents.insert(start_index, '`include "{}"\n'.format(file.replace("swreg","swreg_def")))

        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        # Insert wires and connect them to uut 
        for i in range(instances_amount[corename]):
            pio_signals = get_pio_signals(peripheral_signals[corename])
            for signal in pio_signals:
                # Check if mapped to external interface or
                # if it is mapped between SUT and Tester 
                # (Only insert signal if it is not internal to SUT)
                if mapped_signals[testing_cut][corename][i][signal] == -1 or \
                    2>len(re.findall('(?={})'.format("_Tester_" if testing_cut else "_SUT_"), pwires[mapped_signals[testing_cut][corename][i][signal]][0])):
                    # Insert system IOs for peripheral
                    template_contents.insert(find_idx(template_contents, "PWIRES"), '   {}  {}_{};\n'.format(re.sub("(?:(?:input)|(?:output))\s+","wire ",peripheral_signals[corename][signal].replace("/*<SwregFilename>*/",swreg_filename)),corename+str(i),signal))
                    # Connect wires to sut port
                    template_contents.insert(find_idx(template_contents, "PORTS"), '               .{signal}({signal}),\n'.format(signal=corename+str(i)+"_"+signal))

    # Write system.v
    systemv_file = open("system_top.v", "w")
    systemv_file.writelines(template_contents)
    systemv_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)!=7:
        print("Usage: {} <root_dir> <portmap_path> <directories_defined_in_config.mk> <sut_peripherals> <tester_peripherals> <testing_cut>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir

    create_top_system(sys.argv[3], sys.argv[4], sys.argv[5], os.path.join(root_dir,sys.argv[2]), 1 if (sys.argv[6].lower() not in ['0','false','']) else 0) 
