#!/usr/bin/env python3

import sys, os

sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')

from submodule_utils import *
import createSystem

#Creates testbench based on {top}_tb.vt template 
# template_file: path to template file
# submodule_dirs: dictionary with directory of each submodule. Format: {"PERIPHERALCORENAME1":"PATH_TO_DIRECTORY", "PERIPHERALCORENAME2":"PATH_TO_DIRECTORY2"}
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# out_file: path to output file
def create_system_testbench(template_file, submodule_dirs, top, peripherals_list, out_file):
    # Only create testbench if template is available
    if not os.path.isfile(template_file): return
    # Don't override output file
    if os.path.isfile(out_file): return

    # Read template file
    with open(template_file, "r") as file:
        template_contents = file.readlines() 

    # Insert header files
    createSystem.insert_header_files(template_contents, peripherals_list, submodule_dirs)

    # Write system_tb.v
    output_file = open(out_file, "w")
    output_file.writelines(template_contents)
    output_file.close()
