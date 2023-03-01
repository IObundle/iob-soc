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
import shutil
from pathlib import Path
import fnmatch

# Creates a function that:
#   - Only copies a file if destination does not exist
#   - Renames any 'iob_soc' string inside de src file and in its name, to the given 'system_name' string argument.
def copy_with_rename(system_name):
    def copy_func(src, dst):
        dst = os.path.join(
                os.path.dirname(dst),
                os.path.basename(dst.replace('iob_soc',system_name).replace('IOB_SOC',system_name.upper()))
                )
        if not os.path.isfile(dst):
            with open(src, 'r') as file:
                lines = file.readlines()
            for idx in range(len(lines)): 
                lines[idx]=lines[idx].replace('iob_soc',system_name).replace('IOB_SOC',system_name.upper())
            with open(dst, 'w') as file:
                file.writelines(lines)

    return copy_func

# Copy files common to all iob-soc based systems from the iob-soc directory
# Files containing 'iob_soc' in the name or inside them will be renamed to the new 'system_name'.
# build_dir: path to the build directory
# system_name: Name of the iob-soc based system that is being built
# exclude_file_list: list of strings, each string representing an ignore pattern for the source files.
#                    For example, using the ignore pattern '*.v' would prevent from copying every Verilog source file.
#                    Note, if the new system name is 'my_system', we would still use the 'iob_soc' system name in the ignore patterns.
#                    For example, if we dont want it to generate the 'my_system_firmware.c' based on the 'iob_soc_firmware.c', then we should add 'iob_soc_firmware.c' to the ignore list.
def copy_common_files(build_dir, system_name, exclude_file_list):
    # Copy hardware
    shutil.copytree(os.path.join(os.path.dirname(__file__),'../hardware'), os.path.join(build_dir,'hardware'), dirs_exist_ok=True, copy_function=copy_with_rename(system_name), ignore=shutil.ignore_patterns(*exclude_file_list))
    # Copy software
    shutil.copytree(os.path.join(os.path.dirname(__file__),'../software'), os.path.join(build_dir,'software'), dirs_exist_ok=True, copy_function=copy_with_rename(system_name), ignore=shutil.ignore_patterns(*exclude_file_list))

# peripheral_ios: Optional argument. Selects if should append peripheral IOs to 'ios' list
# internal_wires: Optional argument. List of extra wires for creste_systemv to create inside this core/system module
# exclude_files: Optional argument. List of files to exclude when copying from the iob-soc directory
#                                   This list accepts ignore patterns, for example with '*.v' it will not copy any verilog sources from the iob-soc directory.
#                                   The ignore file names should have the name of the source file (of the iob-soc directory) and not the resulting file name after copy (the resulting file name may have the name of the system instead of 'iob-soc').
#                                   If the verilog template '*.vt' files are ignored, it will also prevent this function from generating the verilog files based on those templates.
def setup_iob_soc( python_module, peripheral_ios=True, internal_wires=None, exclude_files=[]):
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

    # Copy files common to all iob-soc based systems
    #   Renames every 'iob_soc' string to 'system_name'.
    #   Does not override existing files in build directory.
    #   Ignores source files in the 'excluded_files' list
    copy_common_files(build_dir, name, exclude_files)

    # Try to build <system_name>.v if template <system_name>.vt is available and iob_soc.vt not in exclude list
    # Note, it checks for iob_soc.vt in exclude files, instead of <system_name>.vt, to be consistent with the copy_common_files() function.
    #[If a user does not want to build <system_name>.v from the template, then he also does not want to copy the template from the iob-soc]
    if not fnmatch.filter(exclude_files,'iob_soc.vt'):
        createSystem.create_systemv(os.path.join(build_dir,f'hardware/src/{name}.vt'), submodules['dirs'], name, peripherals_list, os.path.join(build_dir,f'hardware/src/{name}.v'), internal_wires=internal_wires)
    # Try to build simulation <system_name>_tb.v if template <system_name>_tb.vt is available and iob_soc_tb.vt not in exclude list
    if not fnmatch.filter(exclude_files,'iob_soc_tb.vt'):
        createTestbench.create_system_testbench(os.path.join(build_dir,f'hardware/simulation/src/{name}_tb.vt'), submodules['dirs'], name, peripherals_list, os.path.join(build_dir,f'hardware/simulation/src/{name}_tb.v'))
    # Try to build simulation <system_name>_top.v if template <system_name>_top.vt is available and iob_soc_top.vt not in exclude list
    if not fnmatch.filter(exclude_files,'iob_soc_top.vt'):
        createTopSystem.create_top_system(os.path.join(build_dir,f'hardware/simulation/src/{name}_top.vt'), submodules['dirs'], name, peripherals_list, ios, confs, os.path.join(build_dir,f'hardware/simulation/src/{name}_top.v'))

    # Delete verilog templates from build dir
    for p in Path(build_dir).rglob("*.vt"):
        p.unlink()
