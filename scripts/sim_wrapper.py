#!/usr/bin/env python3

import sys, os

sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')

from submodule_utils import *
import createSystem

#Creates the Verilog Snippet (.vs) files required by {name}_sim_wrapper.v
# template_file: path to template file
# submodule_dirs: dictionary with directory of each submodule. Format: {"PERIPHERALCORENAME1":"PATH_TO_DIRECTORY", "PERIPHERALCORENAME2":"PATH_TO_DIRECTORY2"}
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# ios: ios dictionary of system
# confs: confs dictionary of system
# out_file: path to output file
def create_sim_wrapper(build_dir, name, ios, confs):
    out_dir = os.path.join(build_dir,f'hardware/simulation/src/')

    # Insert wires and connect them to system 
    for table in ios:
        # If table has 'doc_only' attribute set to True, skip it
        if "doc_only" in table.keys() and table["doc_only"]:
            continue

        pio_signals = get_pio_signals(table['ports'])

        # Insert system IOs for peripheral
        pwires_str = ""
        if pio_signals and 'if_defined' in table.keys(): pwires_str += f"`ifdef {table['if_defined']}\n"
        for signal in pio_signals:
            pwires_str += '   wire [{}-1:0] {}_{};\n'.format(add_prefix_to_parameters_in_string(signal['n_bits'],confs,"`"+name.upper()+"_"),
                                                                             table['name'],
                                                                             signal['name'])
        if pio_signals and 'if_defined' in table.keys(): pwires_str += "`endif\n"

        # Connect wires to soc port
        pportmaps_str = ""
        if pio_signals and 'if_defined' in table.keys(): pportmaps_str += f"`ifdef {table['if_defined']}\n"
        for signal in pio_signals:
            pportmaps_str += '               .{signal}({signal}),\n'.format(signal=table['name']+"_"+signal['name'])
        if pio_signals and 'if_defined' in table.keys(): pportmaps_str += "`endif\n"

    fd_pportmaps = open(f"{out_dir}/{name}_pportmaps.vs", "w")
    fd_pportmaps.write(pportmaps_str)
    fd_pportmaps.close()
    
    fd_periphs = open(f"{out_dir}/{name}_sim_pwires.vs", "w")
    fd_periphs.write(pwires_str)
    fd_periphs.close()
