#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
import setup
import mkregs
import shutil
import copy

name='iob_regfileif'
version='V0.10'
flows='sim'
setup_dir=os.path.dirname(__file__)
build_dir=f"../{name}_{version}"
submodules = {
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
    inverted_regs = copy.deepcopy(regs)
    for table in inverted_regs: 
        for reg in table['regs']:
            if reg['type'] == 'W': reg['type']='R'
            else: reg['type']='W'

    #### Create an instance of the mkregs class inside the mkregs module
    mkregs_obj = mkregs.mkregs()
    mkregs_obj.config = confs
    # Get register table
    reg_table = mkregs_obj.get_reg_table(inverted_regs, False)
    # Create inverted register hardware
    mkregs_obj.write_hwheader(reg_table, build_dir+'/hardware/src', f"{name}_inverted")
    mkregs_obj.write_hwcode(reg_table, build_dir+'/hardware/src', f"{name}_inverted")

    #### Modify `*_swreg_inst.vh` file to prevent overriding definitions of the `*_inverted_swreg_inst.vh` file
    with open(f"{build_dir}/hardware/src/{name}_swreg_inst.vh", "r") as file:
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
    with open(f"{build_dir}/hardware/src/{name}_swreg_inst.vh", "w") as file:
        file.writelines(lines)

    #### Modify "iob_regfileif_inverted_swreg_def" to include `IOB_REGFILEIF_SWREG_ADDR_W`
    with open(f"{build_dir}/hardware/src/{name}_inverted_swreg_def.vh", "r") as file: lines = file.readlines()
    for idx, line in enumerate(lines):
        if line.startswith("`define IOB_REGFILEIF_INVERTED_SWREG_ADDR_W"):
            lines.insert(idx,line.replace("_INVERTED",""))
            break
    with open(f"{build_dir}/hardware/src/{name}_inverted_swreg_def.vh", "w") as file: file.writelines(lines)

    #### Create params, inst_params and conf files for inverted hardware. (Use symlinks to save disk space and highlight they are equal)
    if not os.path.isfile(f"{build_dir}/hardware/src/{name}_inverted_conf.vh"): os.symlink(f"{name}_conf.vh", f"{build_dir}/hardware/src/{name}_inverted_conf.vh")
    if not os.path.isfile(f"{build_dir}/hardware/src/{name}_inverted_params.vh"): os.symlink(f"{name}_params.vh", f"{build_dir}/hardware/src/{name}_inverted_params.vh")
    if not os.path.isfile(f"{build_dir}/hardware/src/{name}_inverted_inst_params.vh"): os.symlink(f"{name}_inst_params.vh", f"{build_dir}/hardware/src/{name}_inverted_inst_params.vh")

    #### Create inverted register software
    mkregs_obj.write_swheader(reg_table, build_dir+'/software/esrc', f"{name}_inverted")
    mkregs_obj.write_swheader(reg_table, build_dir+'/software/psrc', f"{name}_inverted")
    mkregs_obj.write_swcode(reg_table, build_dir+'/software/esrc', f"{name}_inverted")

    #### Create pc-emul drivers
    # Copy iob_regfileif_inverted_swreg_emb.c
    shutil.copyfile(f"{build_dir}/software/esrc/{name}_inverted_swreg_emb.c",
                    f"{build_dir}/software/psrc/{name}_inverted_swreg_pc_emul.c")

    # Modify copied iob_regfileif_inverted_swreg_pc_emul.c file
    with open(f"{build_dir}/software/psrc/{name}_inverted_swreg_pc_emul.c", "r") as file: 
        contents = file.readlines()
    for idx, line in enumerate(contents):
        # Always return '1' on read registers
        if 'return' in line: contents[idx] = 'return 1; //Always return "1"\n'
        # Do nothing in write registers
        if 'value));' in line: contents[idx] = '//Not implemented \n'
    with open(f"{build_dir}/software/psrc/{name}_inverted_swreg_pc_emul.c", "w") as file: 
        file.writelines(contents)


if __name__ == "__main__":
    main()
