#!/usr/bin/env python3
#Creates periphs_tmp.h for tester

import sys, os

# Add folder to path that contains python scripts to be imported
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import periphs_tmp 
from periphs_tmp import *

sys.path.append(os.path.join(os.path.dirname(__file__), '../../hardware/tester'))
import tester_utils
from tester_utils import get_tester_peripherals


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)>2:
        root_dir=sys.argv[2]
        periphs_tmp.root_dir = root_dir
        tester_utils.root_dir = root_dir
        create_periphs_tmp(sys.argv[1], get_tester_peripherals(), "tester_periphs_tmp.h") 
    else:
        print("Needs two arguments.\nUsage: {} <address_selection_bits_of_peripherals (config.mk variable $P)> <root_dir>".format(sys.argv[0]))
