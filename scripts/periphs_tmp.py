#!/usr/bin/env python3
#Creates periphs_tmp.h

import sys, os

# Add folder to path that contains python scripts to be imported
from submodule_utils import *

# Arguments:
#   periph_addr_select_bit: Adress selection bit (P variable)
#   peripherals_list: list with amount of instances of each peripheral (returned by get_peripherals())
def create_periphs_tmp(periph_addr_select_bit, peripherals_list, out_file):
    # Don't override output file
    if os.path.isfile(out_file): return

    template_contents = []
    for instance in peripherals_list:
        template_contents.extend("#define {}_BASE (1<<{}) |({}<<({}-N_SLAVES_W))\n".format(instance['name'],periph_addr_select_bit,instance['name'],periph_addr_select_bit))

    # Write system.v
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    periphs_tmp_file = open(out_file, "w")
    periphs_tmp_file.writelines(template_contents)
    periphs_tmp_file.close()

