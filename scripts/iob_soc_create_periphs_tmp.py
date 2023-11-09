#!/usr/bin/env python3
# Creates periphs_tmp.h

import sys, os

# Add folder to path that contains python scripts to be imported
from submodule_utils import *


# Arguments:
#   periph_addr_select_bit: Adress selection bit (P variable)
#   peripherals_list: list with amount of instances of each peripheral (returned by get_peripherals())
def create_periphs_tmp(name, addr_w, peripherals_list, out_file):
    # Don't override output file
    if os.path.isfile(out_file):
        return

    template_contents = []
    for instance in peripherals_list:
        template_contents.extend(
            f"#define {instance.name}_BASE ({name.upper()}_{instance.name}<<({addr_w}-1-{name.upper()}_N_SLAVES_W))\n"
        )

    # Write system.v
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    periphs_tmp_file = open(out_file, "w")
    periphs_tmp_file.writelines(template_contents)
    periphs_tmp_file.close()
