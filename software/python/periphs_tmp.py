#!/usr/bin/env python3
#Creates periphs_tmp.h

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *

# Arguments:
#   P: $P variable in config.mk
#   peripheral_instances_amount: list with amount of instances of each peripheral (returned by get_peripherals())
def create_periphs_tmp(P, peripheral_instances_amount, filename):

    template_contents = []
    for corename in peripheral_instances_amount:
        for i in range(peripheral_instances_amount[corename]):
            template_contents.insert(0,"#define {}_BASE (1<<{}) |({}<<({}-N_SLAVES_W))\n".format(corename+str(i),P,corename+str(i),P))

    periphs_tmp_file = open(filename, "w")
    periphs_tmp_file.writelines(template_contents)
    periphs_tmp_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<3:
        print("Needs two arguments.\nUsage: {} <address_selection_bits_of_peripherals (config.mk variable $P)> <peripherals>".format(sys.argv[0]))
        exit(-1)
    create_periphs_tmp(sys.argv[1], get_peripherals(sys.argv[2])[0], "periphs_tmp.h") 
