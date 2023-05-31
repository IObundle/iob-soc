#!/usr/bin/env python3

import sys
import os

from iob_soc_create_system import insert_header_files

#Creates testbench based on {top}_tb.vt template 
# template_file: path to template file
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# out_file: path to output file
def create_system_testbench(template_file, top, peripherals_list, out_file):
    # Only create testbench if template is available
    if not os.path.isfile(template_file): return
    # Don't override output file
    if os.path.isfile(out_file): return

    # Read template file
    with open(template_file, "r") as file:
        template_contents = file.readlines() 

    # Insert header files
    insert_header_files(template_contents, peripherals_list)

    # Write system_tb.v
    output_file = open(out_file, "w")
    output_file.writelines(template_contents)
    output_file.close()
