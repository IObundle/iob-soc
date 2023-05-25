#!/usr/bin/env python3

import sys, os

sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')

from submodule_utils import *
import createSystem

#Creates simulation wrapper based on {name}_sim_wrapper.vt template 
# template_file: path to template file
# submodule_dirs: dictionary with directory of each submodule. Format: {"PERIPHERALCORENAME1":"PATH_TO_DIRECTORY", "PERIPHERALCORENAME2":"PATH_TO_DIRECTORY2"}
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# ios: ios dictionary of system
# confs: confs dictionary of system
# out_file: path to output file
def create_sim_wrapper(template_file, submodule_dirs, name, peripherals_list, ios, confs, out_file):
    # Only create testbench if template is available
    if not os.path.isfile(template_file): return
    # Don't override output file
    if os.path.isfile(out_file): return

    # Read template file
    with open(template_file, "r") as file:
        template_contents = file.readlines() 

    createSystem.insert_header_files(template_contents, peripherals_list, submodule_dirs)

    # Insert wires and connect them to system 
    for table in ios:
        pio_signals = get_pio_signals(table['ports'])

        # Insert system IOs for peripheral
        start_index = find_idx(template_contents, "IOB_PRAGMA_PWIRES")
        if pio_signals and 'if_defined' in table.keys(): template_contents.insert(start_index, "`endif\n")
        for signal in pio_signals:
            template_contents.insert(start_index, '   wire [{}-1:0] {}_{};\n'.format(add_prefix_to_parameters_in_string(signal['n_bits'],confs,"`"+name.upper()+"_"),
                                                                             table['name'],
                                                                             signal['name']))
        if pio_signals and 'if_defined' in table.keys(): template_contents.insert(start_index, f"`ifdef {table['if_defined']}\n")

        # Connect wires to soc port
        start_index = find_idx(template_contents, "IOB_PRAGMA_PPORTMAPS")
        if pio_signals and 'if_defined' in table.keys(): template_contents.insert(start_index, "`endif\n")
        for signal in pio_signals:
            template_contents.insert(start_index, '               .{signal}({signal}),\n'.format(signal=table['name']+"_"+signal['name']))
        if pio_signals and 'if_defined' in table.keys(): template_contents.insert(start_index, f"`ifdef {table['if_defined']}\n")

    # Delete PRAGMA comments
    start_index = find_idx(template_contents, "IOB_PRAGMA_PWIRES")-1
    template_contents.pop(start_index)
    start_index = find_idx(template_contents, "IOB_PRAGMA_PPORTMAPS")-1
    template_contents.pop(start_index)

    # Write output file
    output_file = open(out_file, "w")
    output_file.writelines(template_contents)
    output_file.close()

