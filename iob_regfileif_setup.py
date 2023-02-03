#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
import setup
import mkregs

meta = \
{
'name':'iob_regfileif',
'version':'V0.10',
'flows':'sim',
'setup_dir':os.path.dirname(__file__)}
meta['build_dir']=f"../{meta['name']+'_'+meta['version']}"
meta['submodules'] = {
    'hw_setup': {
        'headers' : [ 'iob_s_port', 'iob_s_portmap' ],
        'modules': [ 'iob_reg.v', 'iob_reg_e.v' ]
    },
}

confs = \
[
    # Macros

    # Parameters
    {'name':'DATA_W',      'type':'P', 'val':'32', 'min':'NA', 'max':'32', 'descr':"Data bus width"},
    {'name':'ADDR_W',      'type':'P', 'val':'`IOB_REGFILEIF_SWREG_ADDR_W', 'min':'NA', 'max':'32', 'descr':"Address bus width"},
]

ios = \
[
    {'name': 'iob_s_port', 'descr':'CPU native interface', 'ports': [
    ]},
    {'name': 'external_iob_s_port', 'descr':'External CPU native interface', 'ports': [
    ]},
    {'name': 'general', 'descr':'General interface signals', 'ports': [
        {'name':"clk_i" , 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"arst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, asynchronous and active high"},
        {'name':"cke_i", 'type':"I", 'n_bits':'1', 'descr':"System clock enable signal."},
    ]},
]

regs=[]

blocks = []

# Main function to setup this core and its components
def main():
    global regs
    # Ensure user has configured registers for this peripheral
    assert 'regs' in module_parameters, "Error: REGFILEIF 'regs' dictionary not found."
    regs+=module_parameters['regs']

    setup.setup(sys.modules[__name__])

    #### Invert registers type to create drivers for Secondary system
    for table in regs: 
        for reg in table['regs']:
            if reg['type'] == 'W': reg['type']='R'
            else: reg['type']='W'

    #### Create an instance of the mkregs class inside the mkregs module
    mkregs_obj = mkregs.mkregs()
    mkregs_obj.config = confs
    # Get register table
    reg_table = mkregs_obj.get_reg_table(regs, False)
    # Create inverted register hardware
    mkregs_obj.write_hwheader(reg_table, meta['build_dir']+'/hardware/src', f"{meta['name']}_inverted")
    mkregs_obj.write_hwcode(reg_table, meta['build_dir']+'/hardware/src', f"{meta['name']}_inverted")

    #### Modify `*_swreg_inst.vh` file to prevent overriding definitions of the `*_inverted_swreg_inst.vh` file
    with open(f"{meta['build_dir']}/hardware/src/{meta['name']}_swreg_inst.vh", "r") as file:
        lines = file.readlines()
    # Modify lines
    for idx, line in enumerate(lines):
        # Remove wires, as they have already been declared in the `*_inverted_swreg_inst.vh` file
        if line.startswith("`IOB_WIRE"): lines[idx] = ""
        # Replace name of swreg_0 instance
        if line.startswith(") swreg_0 ("): lines[idx] = ") swreg_1 (\n"
        # Rename `iob_ready_ and iob_rvalid` ports as this mapping was already used in the `*_inverted_swreg_inst.vh` file
        if '.iob_ready_nxt_o' in line: lines[idx] = ".iob_ready_nxt_o(iob_ready_nxt2),\n"
        if '.iob_rvalid_nxt_o' in line: lines[idx] = ".iob_rvalid_nxt_o(iob_rvalid_nxt2),\n"
        # Remove `iob_s_portmap.vh` as this mapping was already used in the `*_inverted_swreg_inst.vh` file
        if '`include "iob_s_portmap.vh"' in line: 
            lines[idx] = ""
            #Insert correct portmap. The normal (non inverted) registers are connected to the external interface that connects to the primary system.
            lines.insert(idx,".iob_avalid_i(external_iob_avalid_i), //Request valid.\n")
            lines.insert(idx,".iob_addr_i(external_iob_addr_i), //Address.\n")
            lines.insert(idx,".iob_wdata_i(external_iob_wdata_i), //Write data.\n")
            lines.insert(idx,".iob_wstrb_i(external_iob_wstrb_i), //Write strobe.\n")
            lines.insert(idx,".iob_rvalid_o(external_iob_rvalid_o), //Read data valid.\n")
            lines.insert(idx,".iob_rdata_o(external_iob_rdata_o), //Read data.\n")
            lines.insert(idx,".iob_ready_o(external_iob_ready_o), //Interface ready.\n")
    # Insert 2 wires for iob_ready_nxt and iob_rvalid_nxt ports
    lines.insert(0,"`IOB_WIRE(iob_ready_nxt2, 1)\n")
    lines.insert(0,"`IOB_WIRE(iob_rvalid_nxt2, 1)\n")
    # Write modified lines to file
    with open(f"{meta['build_dir']}/hardware/src/{meta['name']}_swreg_inst.vh", "w") as file:
        file.writelines(lines)

    #### Modify "iob_regfileif_inverted_swreg_def" to include `IOB_REGFILEIF_SWREG_ADDR_W`
    with open(f"{meta['build_dir']}/hardware/src/{meta['name']}_inverted_swreg_def.vh", "r") as file: lines = file.readlines()
    for idx, line in enumerate(lines):
        if line.startswith("`define IOB_REGFILEIF_INVERTED_SWREG_ADDR_W"):
            lines.insert(idx,line.replace("_INVERTED",""))
            break
    with open(f"{meta['build_dir']}/hardware/src/{meta['name']}_inverted_swreg_def.vh", "w") as file: file.writelines(lines)

    #### Create params, inst_params and conf files for inverted hardware. (Use symlinks to save disk space and highlight they are equal)
    os.symlink(f"{meta['name']}_conf.vh", f"{meta['build_dir']}/hardware/src/{meta['name']}_inverted_conf.vh")
    os.symlink(f"{meta['name']}_params.vh", f"{meta['build_dir']}/hardware/src/{meta['name']}_inverted_params.vh")
    os.symlink(f"{meta['name']}_inst_params.vh", f"{meta['build_dir']}/hardware/src/{meta['name']}_inverted_inst_params.vh")

    #### Create inverted register software
    mkregs_obj.write_swheader(reg_table, meta['build_dir']+'/software/esrc', f"{meta['name']}_inverted")
    mkregs_obj.write_swcode(reg_table, meta['build_dir']+'/software/esrc', f"{meta['name']}_inverted")

if __name__ == "__main__":
    main()
