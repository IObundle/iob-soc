#!/usr/bin/env python3
#
#    tester.py: tester related functions
#
import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
sys.path.insert(0, os.path.dirname(__file__)+'/../submodules/IOBSOC/scripts')

from submodule_utils import import_setup, get_table_ports, add_prefix_to_parameters_in_port, eval_param_expression_from_config, set_default_submodule_dirs
from ios import get_interface_mapping
import setup 
import iob_soc 
import build_srcs
import iob_colors
import sim_wrapper


# Setup a Tester 
# module_parameters is a dictionary that contains the following elements:
#    - extra_peripherals: list of peripherals to append to the 'peripherals' table in the 'blocks' list of the Tester
#    - extra_peripheral_dirs: dictionary with directories of each extra peripheral
#    - peripheral_portmap: Dictionary where each key-value pair is a Mapping between two signals. Example
#                     { {'corename':'UART1', 'if_name':'rs232', 'port':'', 'bits':[]}:{'corename':'UUT', 'if_name':'UART0', 'port':'', 'bits':[]} }
#    - confs: Optional dictionary with extra macros/parameters or with overrides for existing ones
def setup_tester( python_module ):
    module_parameters = python_module.module_parameters
    confs = python_module.confs
    #ios = python_module.ios
    #submodules = python_module.submodules
    #name = python_module.name

    # Add IOb-SoC hw module.
    #iob_soc.add_iob_soc_modules(python_module, peripheral_ios=False, internal_wires=peripheral_wires, filter_modules=['hw_setup'])

    ## Recreate iob_soc_tester_sim_wrapper.v, as it may have been generated during sim_setup, however at that time, the ios had not been updated by this function.
    #if os.path.isfile(os.path.join(python_module.build_dir,f'hardware/simulation/src/{name}_sim_wrapper.v')):
    #    os.remove(os.path.join(python_module.build_dir,f'hardware/simulation/src/{name}_sim_wrapper.v'))
    #    sim_wrapper.create_sim_wrapper(os.path.join(python_module.setup_dir,f'hardware/simulation/src/{name}_sim_wrapper.vt'), submodules['dirs'], name, tester_peripherals_list, ios, confs, os.path.join(python_module.build_dir,f'hardware/simulation/src/{name}_sim_wrapper.v'))

    # Call setup function for the tester
    setup.setup(python_module)

    #Check if setup with INIT_MEM and USE_EXTMEM (check if macro exists)
    extmem_macro = next((i for i in confs if i['name']=='USE_EXTMEM'), False)
    initmem_macro = next((i for i in confs if i['name']=='INIT_MEM'), False)
    if extmem_macro and extmem_macro['val'] and \
       initmem_macro and initmem_macro['val']:
        # Append init_ddr_contents.hex target to sw_build.mk
        with open(f"{python_module.build_dir}/software/sw_build.mk", 'a') as file:
            file.write("\n#Auto-generated target to create init_ddr_contents.hex\n")
            file.write("HEX+=init_ddr_contents.hex\n")
            file.write("# init file for external mem with firmware of both systems\n")
            file.write("init_ddr_contents.hex: iob_soc_tester_firmware.hex\n")

            sut_firmware_name = module_parameters['sut_fw_name'].replace('.c','')+'.hex' if 'sut_fw_name' in module_parameters.keys() else '-'
            file.write(f"	../../scripts/joinHexFiles.py {sut_firmware_name} $^ $(shell cat ../../software/bsp.h | sed -n 's/.*MEM_ADDR_W \([^ ]*\).*/\\1/p') > $@\n")
        # Copy joinHexFiles.py from LIB
        build_srcs.copy_files( "submodules/LIB", f"{python_module.build_dir}/scripts", [ "joinHexFiles.py" ], '*.py' )
