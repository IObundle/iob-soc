#!/usr/bin/env python3
#Creates system.v based on system_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *
from tester_utils import read_portmap

# Testing_cut is either 1 or 0, if 0 then the system will be built as if it were a SUT, If 1 then it will be a tester
def create_systemv(directories_str, peripherals_str, portmap_path):
    # Get peripherals, directories and signals
    instances_amount = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals = get_peripherals_signals(instances_amount,submodule_directories)

    # Read portmap file and get encoded data
    pwires, mapped_signals = read_portmap(instances_amount, peripheral_signals, portmap_path)

    #TODO: Adapt below to be only tester

    # Read template file
    template_file = open(root_dir+"/hardware/src/system_core.v", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Array to store if pwires have been inserted
    pwires_inserted = [0] * len(pwires)

    for corename in instances_amount:
        # Insert header files
        path = root_dir+"/"+submodule_directories[corename]+"/hardware/include"
        start_index = find_idx(template_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                template_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
            if file.endswith("swreg.vh"):
                template_contents.insert(start_index, '`include "{}"\n'.format(file.replace("swreg","swreg_def")))

        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        pio_signals = get_pio_signals(peripheral_signals[corename])

        # Insert IOs and Instances for this type of peripheral
        for i in range(instances_amount[corename]):

            # Insert peripheral instance (in reverse order of lines)
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
                # Make sure this signal is mapped
                if mapped_signals[testing_cut][corename][i][signal] < -1:
                    print("Error: signal {} of SUT.{}[{}] not mapped!".format(signal,corename,i))
                    exit(-1)
                # Check if not mapped to external interface and
                # if it is mapped between SUT and SUT (its a signal internal to SUT)
                if mapped_signals[testing_cut][corename][i][signal] > -1 and \
                    1<len(re.findall('(?={})'.format("_Tester_" if testing_cut else "_SUT_"), pwires[mapped_signals[testing_cut][corename][i][signal]][0])):
                    # Make sure we have not yet created PWIRE of this signal
                    if pwires_inserted[mapped_signals[testing_cut][corename][i][signal]] == False:
                        # Insert pwire
                        template_contents.insert(find_idx(template_contents, "PWIRES"), '    wire {} {};\n'.format(pwires[mapped_signals[testing_cut][corename][i][signal]][1].replace("/*<SwregFilename>*/",swreg_filename),pwires[mapped_signals[testing_cut][corename][i][signal]][0]))
                        start_index+=1 #Increment start_index because we inserted a line in this file
                        # Mark this signal as been inserted
                        pwires_inserted[mapped_signals[testing_cut][corename][i][signal]] = True
                    # Insert io
                    template_contents.insert(start_index, '      .{}({}),\n'.format(signal,pwires[mapped_signals[testing_cut][corename][i][signal]][0]))
                else: # Mapped to external interface or to Tester
                    # Insert PIO
                    template_contents.insert(find_idx(template_contents, "PIO"), '    {} {}_{},\n'.format(peripheral_signals[corename][signal].replace("/*<SwregFilename>*/",swreg_filename),corename+str(i),signal))
                    start_index+=1 #Increment start_index because we inserted a line in this file
                    # Insert SUT PORT
                    template_contents.insert(start_index, '      .{}({}_{}),\n'.format(signal,corename+str(i),signal))

            # Insert syntax declaring start of verilog instance
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
    if len(sys.argv)!=5:
        print("Usage: {} <root_dir> <portmap_path> <directories_defined_in_config.mk> <tester_peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir

    create_systemv(sys.argv[3], sys.argv[4], os.path.join(root_dir,sys.argv[2])) 
