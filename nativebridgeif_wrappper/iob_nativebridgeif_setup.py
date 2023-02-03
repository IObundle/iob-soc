#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
import setup
from submodule_utils import import_setup

meta = \
{
'name':'iob_nativebridgeif',
'flows':'sim',
'setup_dir':os.path.dirname(__file__)}
meta['submodules'] = {}

regfileif_core_module=import_setup(f"{meta['setup_dir']}/..")
# Copy some meta fields from the regfileif core
meta['version']=regfileif_core_module.meta['version']
meta['flows']=regfileif_core_module.meta['flows']
meta['build_dir']=f"../{meta['name']+'_'+meta['version']}"

confs = regfileif_core_module.confs

ios = \
[
    {'name': 'iob_s_port', 'descr':'Slave CPU native interface', 'ports': [
    ]},
    {'name': 'iob_m_port', 'descr':'Master CPU native interface', 'ports': [
    ]},
]

regs = \
[
    {'name': 'dummy', 'descr':'Dummy registers to run register setup functions', 'regs': [
        {'name':"DUMMY", 'type':"R", 'n_bits':1, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':False, 'descr':"Dummy Register"},
    ]}
]

blocks = []

# Main function to setup this core and its components
def main():
    setup.setup(sys.modules[__name__])

    # Remove swreg_gen and swreg_inst files
    os.remove(f"{meta['build_dir']}/hardware/src/{meta['name']}_swreg_inst.vh")
    os.remove(f"{meta['build_dir']}/hardware/src/{meta['name']}_swreg_gen.v")

    # Modify iob_nativebridgeif_swreg_def.vh
    with open(f"{meta['build_dir']}/hardware/src/{meta['name']}_swreg_def.vh", 'w') as file:
        file.write('`include "iob_regfileif_swreg_def.vh"\n')
        file.write("`define IOB_NATIVEBRIDGEIF_SWREG_ADDR_W `IOB_REGFILEIF_SWREG_ADDR_W\n")

if __name__ == "__main__":
    main()
