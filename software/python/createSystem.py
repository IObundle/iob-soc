#!/usr/bin/env python3
#Creates system.v based on system_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *

# Signals in this template will only be inserted if they exist in the peripheral IO
reserved_signals_template = """\
      .clk(clk),
      .rst(reset),
      .arst(reset),
      .valid(slaves_req[`valid(`/*<InstanceName>*/)]),
      .address(slaves_req[`address(`/*<InstanceName>*/,`/*<SwregFilename>*/_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`/*<InstanceName>*/)]),
      .wstrb(slaves_req[`wstrb(`/*<InstanceName>*/)]),
      .rdata(slaves_resp[`rdata(`/*<InstanceName>*/)]),
      .ready(slaves_resp[`ready(`/*<InstanceName>*/)]),
"""

def create_systemv(directories_str, peripherals_str):
    # Get peripherals, directories and signals
    instances_amount, instances_parameters = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals = get_peripherals_signals(instances_amount, submodule_directories)

    # Read template file
    template_file = open(root_dir+"/hardware/src/system_core.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    for corename in instances_amount:
        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        # Insert header files
        path = root_dir+"/"+submodule_directories[corename]+"/hardware/include"
        start_index = find_idx(template_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
        # Add topmodule_swreg_def.vh if mkregs.conf exists
        if os.path.isfile(root_dir+"/"+submodule_directories[corename]+"/mkregs.conf"):
            template_contents.insert(start_index, '`include "{}"\n'.format(swreg_filename+"_def.vh"))

        # Insert IOs and Instances for this type of peripheral
        for i in range(instances_amount[corename]):
            pio_signals = get_pio_signals(peripheral_signals[corename])
            # Insert system IOs for peripheral
            start_index = find_idx(template_contents, "PIO")
            for signal in pio_signals:
                template_contents.insert(start_index, '    {} {}_{},\n'.format(peripheral_signals[corename][signal].replace("/*<SwregFilename>*/",swreg_filename),corename+str(i),signal))
            # Insert peripheral instance
            start_index = find_idx(template_contents, "endmodule")-1
            template_contents.insert(start_index, "      );\n")
            first_reversed_signal=True
            # Insert reserved signals 
            for signal in reversed(reserved_signals_template.splitlines(True)):
                str_match=re.match("^\s*\.([^\(]+)\(",signal)
                # Only insert if this reserved signal (from template) is present in IO of this peripheral
                if (str_match is not None) and str_match.group(1) in peripheral_signals[corename]:
                    template_contents.insert(start_index, 
                            re.sub("\/\*<InstanceName>\*\/",corename+str(i),
                            re.sub("\/\*<SwregFilename>\*\/",swreg_filename, 
                                signal)))
                    # Remove comma at the end of last signal
                    if first_reversed_signal == True:
                        template_contents[start_index]=template_contents[start_index][::-1].replace(",","",1)[::-1]
                        first_reversed_signal = False
            # Insert io signals
            for signal in pio_signals:
                template_contents.insert(start_index, '      .{}({}_{}),\n'.format(signal,corename+str(i),signal))
            template_contents.insert(start_index, "   {} (\n".format(corename+str(i)))
            if len(instances_parameters[corename][i])>1 or instances_parameters[corename][i][0]:
                template_contents.insert(start_index, "   )\n")
                first_reversed_signal=True
                # Insert parameters
                for parameter in instances_parameters[corename][i]:
                    template_contents.insert(start_index, '      {}{}\n'.format(parameter,"" if first_reversed_signal else ","))
                    first_reversed_signal=False
                template_contents.insert(start_index, "     #(\n")
            template_contents.insert(start_index, "   {}\n".format(swreg_filename[:-6]))
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
        print("Usage: {} <root_dir> <directories_defined_in_config.mk> <peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir

    create_systemv(sys.argv[2], sys.argv[3]) 
