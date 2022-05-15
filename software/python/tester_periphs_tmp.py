#!/usr/bin/env python3
#Creates periphs_tmp.h for tester

import sys, os

# Add folder to path that contains python scripts to be imported
import periphs_tmp 
from periphs_tmp import *

import tester_utils
from submodule_utils import get_peripherals


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<3:
        print("Needs two arguments.\nUsage: {} <address_selection_bits_of_peripherals (config.mk variable $P)> <tester_peripherals_list>".format(sys.argv[0]))
        exit(-1)
    create_periphs_tmp(sys.argv[1], get_peripherals(sys.argv[2]), "tester_periphs_tmp.h") 
