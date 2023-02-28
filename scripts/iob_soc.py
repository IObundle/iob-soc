#!/usr/bin/env python3
import sys
import os

sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')

import periphs_tmp
import createSystem
import createTestbench
import createTopSystem
from submodule_utils import iob_soc_peripheral_setup, set_default_submodule_dirs
from setup import setup

# peripheral_ios: Optional argument. Selects if should append peripheral IOs to 'ios' list
# internal_wires: Optional argument. List of extra wires for creste_systemv to create inside this core/system module
def setup_iob_soc( python_module, peripheral_ios=True, internal_wires=None):
    confs = python_module.confs
    build_dir = python_module.build_dir
    submodules = python_module.submodules
    name = python_module.name
    ios = python_module.ios

    #
    # IOb-SoC related functions
    #

    set_default_submodule_dirs(python_module)

    peripherals_list = iob_soc_peripheral_setup(python_module, append_peripheral_ios=peripheral_ios)

    # Setup from LIB
    setup(python_module)
    
    # Build periphs_tmp.h
    if peripherals_list: periphs_tmp.create_periphs_tmp(next(i['val'] for i in confs if i['name'] == 'P'),
                                   peripherals_list, f"{build_dir}/software/{name}_periphs.h")

    # Try to build iob_soc.v if template is available
    createSystem.create_systemv(python_module.setup_dir, submodules['dirs'], name, peripherals_list, os.path.join(build_dir,f'hardware/src/{name}.v'), internal_wires=internal_wires)
    # Try to build simulation system_tb.v if template is available
    createTestbench.create_system_testbench(python_module.setup_dir, submodules['dirs'], name, peripherals_list, os.path.join(build_dir,f'hardware/simulation/src/{name}_tb.v'))
    # Try to build simulation system_top.v if template is available
    createTopSystem.create_top_system(python_module.setup_dir, submodules['dirs'], name, peripherals_list, ios, confs, os.path.join(build_dir,f'hardware/simulation/src/{name}_top.v'))



