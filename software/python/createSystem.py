#!/usr/bin/env python3
#Creates tester.v based on system_core.v template and on peripheral portmap configuration

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *
from portmap_utils import read_portmap

def create_systemv(directories_str, peripherals_str, portmap_path):
    # Get peripherals, directories and signals
    instances_amount, instances_parameters = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals, peripheral_parameters = get_peripherals_signals(instances_amount,submodule_directories)

    # Read portmap file and get encoded data
    pwires, mapped_signals = read_portmap(instances_amount, peripheral_signals, portmap_path)

    # Read template file
    template_file = open(root_dir+"/hardware/src/system_core.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Array to store if pwires have been inserted
    pwires_inserted = [0] * len(pwires)

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

        # Insert IOs and Instances for this type of peripheral
        for i in range(instances_amount[corename]):
            # Insert peripheral instance (in reverse order of lines)
            start_index = find_idx(template_contents, "endmodule")-1
            template_contents.insert(start_index, "      );\n")
            first_reversed_signal=True
            # Insert reserved signals 
            for signal in reversed(reserved_signals_template.splitlines(True)):
                str_match=re.match("^\s*\.([^\(\s]+)\s*\(",signal)
                # Only insert if this reserved signal (from template) is present in IO of this peripheral
                if (str_match is not None) and str_match.group(1) in peripheral_signals[corename]:
                    template_contents.insert(start_index, 
                            re.sub("\/\*<InstanceName>\*\/","TESTER_"+corename+str(i),
                            re.sub("\/\*<SwregFilename>\*\/",top_module_name+"_swreg",
                            signal)))
                    # Remove comma at the end of last signal
                    if first_reversed_signal == True:
                        template_contents[start_index]=template_contents[start_index][::-1].replace(",","",1)[::-1]
                        first_reversed_signal = False

            # Insert io signals
            for signal in pio_signals:
                # Make sure this signal is mapped
                if mapped_signals[corename][i][signal] < -1:
                    print("Error: signal {} of {}[{}] not mapped!".format(signal,corename,i))
                    exit(-1)
                # Check if mapped between peripherals
                if mapped_signals[corename][i][signal] > -1:
                    # Make sure we have not yet created PWIRE of this signal
                    if pwires_inserted[mapped_signals[corename][i][signal]] == False:
                        # Insert pwire
                        signal_size = replaceByParameterValue(pwires[mapped_signals[corename][i][signal]][1],\
                                      peripheral_parameters[corename],\
                                      instances_parameters[corename][i])
                        template_contents.insert(find_idx(template_contents, "PWIRES"), '    wire {} {};\n'.format(signal_size,pwires[mapped_signals[corename][i][signal]][0]))
                        start_index+=1 #Increment start_index because we inserted a line in this file
                        # Mark this signal as been inserted
                        pwires_inserted[mapped_signals[corename][i][signal]] = True
                    # Insert io
                    template_contents.insert(start_index, '      .{}({}),\n'.format(signal,pwires[mapped_signals[corename][i][signal]][0]))
                else: # Mapped to external interface
                    # Insert PIO
                    signal_size = replaceByParameterValue(peripheral_signals[corename][signal],\
                                  peripheral_parameters[corename],\
                                  instances_parameters[corename][i])
                    template_contents.insert(find_idx(template_contents, "PIO"), '    {} {}_{},\n'.format(signal_size,corename+str(i),signal))
                    start_index+=1 #Increment start_index because we inserted a line in this file
                    # Insert peripheral PORT
                    template_contents.insert(start_index, '      .{}({}_{}),\n'.format(signal,corename+str(i),signal))

            # Insert syntax declaring start of verilog instance with parameters
            template_contents.insert(start_index, "   {} (\n".format(corename+str(i)))
            if len(instances_parameters[corename][i])>0:
                template_contents.insert(start_index, "   )\n")
                first_reversed_signal=True
                # Insert parameters
                for parameter in instances_parameters[corename][i]:
                    template_contents.insert(start_index, '      {}{}\n'.format(parameter,"" if first_reversed_signal else ","))
                    first_reversed_signal=False
                template_contents.insert(start_index, "     #(\n")
            template_contents.insert(start_index, "   {}\n".format(top_module_name))
            template_contents.insert(start_index, "\n")
            template_contents.insert(start_index, "   // {}\n".format(corename+str(i)))
            template_contents.insert(start_index, "\n")

    # Write tester.v
    systemv_file = open("tester.v", "w")
    systemv_file.writelines(template_contents)
    systemv_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)!=5:
        print("Usage: {} <root_dir> <portmap_path> <directories_defined_in_config.mk> <peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir

    create_systemv(sys.argv[3], sys.argv[4], os.path.join(root_dir,sys.argv[2])) 
