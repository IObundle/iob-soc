#!/usr/bin/env python3
#Creates system.v based on system_core.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *


# Automatically include *swreg_def.vh verilog headers in system.v
def insert_header_files(template_contents, root_dir):
    # get path to build_lib
    build_path = get_build_lib(root_dir)
    header_path = f"{build_path}/hw/vsrc/"
    vsrc_files = os.listdir(header_path)
    header_index = find_idx(template_contents, "PHEADER")

    # include swreg_def.vh files
    for file in vsrc_files:
        if file.endswith("swreg_def.vh"):
            template_contents.insert(header_index, f'`include "{file}"\n')


def create_systemv(root_dir, directories_str, peripherals_str):
    # Get peripherals, directories and signals
    instances_amount, instances_parameters = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals, peripheral_parameters = get_peripherals_signals(instances_amount,submodule_directories)
    print(f'peripheral_signals: {peripheral_signals}')
    print(f'peripheral_parameters: {peripheral_parameters}')

    # Read template file
    template_file = open(root_dir+"/hardware/src/system.vt", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    insert_header_files(template_contents, root_dir)

    for corename in instances_amount:
        top_module_name = get_top_module_from_dir(f'{root_dir}/{submodule_directories[corename]}')

        pio_signals = get_pio_signals(peripheral_signals[corename])

        # Insert IOs and Instances for this type of peripheral
        for i in range(instances_amount[corename]):
            # Insert system IOs for peripheral
            start_index = find_idx(template_contents, "PIO")
            for signal in pio_signals:
                signal_size = replaceByParameterValue(peripheral_signals[corename][signal],\
                              peripheral_parameters[corename],\
                              instances_parameters[corename][i])
                template_contents.insert(start_index, '    {} {}_{},\n'.format(signal_size,corename+str(i),signal))
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
                            re.sub("\/\*<InstanceName>\*\/",corename+str(i),
                            re.sub("\/\*<SwregFilename>\*\/",top_module_name+"_swreg",
                            signal)))
                    # Remove comma at the end of last signal
                    if first_reversed_signal == True:
                        template_contents[start_index]=template_contents[start_index][::-1].replace(",","",1)[::-1]
                        first_reversed_signal = False

            # Insert io signals
            for signal in pio_signals:
                template_contents.insert(start_index, '      .{}({}_{}),\n'.format(signal,corename+str(i),signal))
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

    # Write system.v
    systemv_file = open("system.v", "w")
    systemv_file.writelines(template_contents)
    systemv_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<4:
        print("Usage: {} <root_dir> <directories_defined_in_info.mk> <peripherals>\n".format(sys.argv[0]))
        exit(-1)
    root_dir=sys.argv[1]
    submodule_utils.root_dir = root_dir

    create_systemv(root_dir, sys.argv[2], sys.argv[3]) 
