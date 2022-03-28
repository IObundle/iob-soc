#!/usr/bin/env python3
#Creates boot.c for tester

import sys, os
import submodule_utils 
from submodule_utils import find_idx

def create_boot():
    # Read template file
    template_file = open(root_dir+"/software/bootloader/boot.c", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    template_contents[find_idx(template_contents, "PROGNAME")-1] = '#define PROGNAME "IOb-Tester-Bootloader"\n'


    # Write boot.c
    boot_file = open("boot.c", "w")
    boot_file.writelines(template_contents)
    boot_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)>1:
        root_dir=sys.argv[1]
        create_boot() 
    else:
        print("Needs one argument.\nUsage: {} <root_dir>".format(sys.argv[0]))
