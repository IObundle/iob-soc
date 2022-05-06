#!/usr/bin/env python3
#Creates system.v based on system_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *

reserved_signals_template = """\
      .clk(clk),
      .rst(reset),
      .valid(slaves_req[`valid(`/*<InstanceName>*/)]),
      .address(slaves_req[`address(`/*<InstanceName>*/,`/*<SwregFilename>*/_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`/*<InstanceName>*/)]),
      .wstrb(slaves_req[`wstrb(`/*<InstanceName>*/)]),
      .rdata(slaves_resp[`rdata(`/*<InstanceName>*/)]),
      .ready(slaves_resp[`ready(`/*<InstanceName>*/)])
"""

def create_systemv(directories_str, sut_peripherals_str):
    # Get peripherals, directories and signals
    sut_instances_amount = get_sut_peripherals(sut_peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals = get_peripherals_signals(sut_instances_amount, submodule_directories)

    # Read template file
    template_file = open(root_dir+"/hardware/src/system_core.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    for corename in sut_instances_amount:
        swreg_filename = ""
        # Insert header files
        path = root_dir+"/"+submodule_directories[corename]+"/hardware/include"
        start_index = find_idx(template_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
            if file.endswith("swreg.vh"):
                template_contents.insert(start_index, '`include "{}"\n'.format(file.replace("swreg","swreg_def")))
                #Store swreg filename
                swreg_filename = os.path.splitext(file)[0]

        # Insert IOs and Instances for this type of peripheral
        for i in range(sut_instances_amount[corename]):
            pio_signals = get_pio_signals(peripheral_signals[corename])
            # Insert system IOs for peripheral
            start_index = find_idx(template_contents, "PIO")
            for signal in pio_signals:
                template_contents.insert(start_index, '    {} {}_{},\n'.format(peripheral_signals[corename][signal].replace("/*<SwregFilename>*/",swreg_filename),corename+str(i),signal))
            # Insert peripheral instance
            start_index = find_idx(template_contents, "endmodule")-1
            template_contents.insert(start_index, "      );\n")
            # Insert reserved signals #TODO: only insert signals present in IO
            for signal in reversed(reserved_signals_template.splitlines(True)):
                template_contents.insert(start_index, 
                        re.sub("\/\*<InstanceName>\*\/",corename+str(i),
                        re.sub("\/\*<SwregFilename>\*\/",swreg_filename, 
                            signal)))
            # Insert io signals
            for signal in pio_signals:
                template_contents.insert(start_index, '      .{}({}_{}),\n'.format(signal,corename+str(i),signal))
            template_contents.insert(start_index, "     (\n")
            template_contents.insert(start_index, "   {} {}\n".format(swreg_filename[:-6], corename+str(i)))
            template_contents.insert(start_index, "\n")
            template_contents.insert(start_index, "   // {}\n".format(corename+str(i)))
            template_contents.insert(start_index, "\n")

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
