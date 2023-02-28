#!/usr/bin/env python3

import sys, os

sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')

from submodule_utils import *
import createSystem

#Creates testbench based on {top}_tb.vt template 
# setup_dir: root directory of the repository
# submodule_dirs: dictionary with directory of each submodule. Format: {"PERIPHERALCORENAME1":"PATH_TO_DIRECTORY", "PERIPHERALCORENAME2":"PATH_TO_DIRECTORY2"}
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# out_file: path to output file
def create_system_testbench(setup_dir, submodule_dirs, top, peripherals_list, out_file):
    # Only create testbench if template is available
    if not os.path.isfile(setup_dir+f"/hardware/simulation/src/{top}_tb.vt"): return

    # Read template file
    template_file = open(setup_dir+f"/hardware/simulation/src/{top}_tb.vt", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Insert header files
    createSystem.insert_header_files(template_contents, peripherals_list, submodule_dirs)

    # Write system_tb.v
    output_file = open(out_file, "w")
    output_file.writelines(template_contents)
    output_file.close()
