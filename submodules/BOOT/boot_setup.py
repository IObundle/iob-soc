#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
import setup

name='boot'
version='V0.10'
flows='sim emb'
setup_dir=os.path.dirname(__file__)
build_dir=f"../{name}_{version}"
submodules = {
    'hw_setup': {
        'headers' : [ 'iob_s_port', 'iob_s_s_portmap' ],
        'modules': [ 'iob_reg.v', 'iob_reg_e.v', 'iob_pulse_gen.v', 'iob_rom_dp.v' ]
    },
}

confs = \
[
    # Macros

    # Parameters
    {'name':'DATA_W',      'type':'P', 'val':'32', 'min':'32', 'max':'32', 'descr':"Data bus width"},
    {'name':'ADDR_W',      'type':'P', 'val':'`BOOT_SWREG_ADDR_W', 'min':'NA', 'max':'NA', 'descr':"Address bus width"},
    {'name':'HEXFILE', 'type':'P', 'val':'0', 'min':'NA', 'max':'NA', 'descr':""},
    {'name':'BOOTROM_ADDR_W', 'type':'P', 'val':'12', 'min':'12', 'max':'12', 'descr':""},
    {'name':'SRAM_ADDR_W', 'type':'P', 'val':'15', 'min':'15', 'max':'15', 'descr':""}
]

ios = \
[
    {'name': 'iob_s_port', 'descr':'IOb control interface for CPU', 'ports': [
    ]},
    {'name': 'ibus', 'descr':'Instruction bus', 'ports': [
        {'name':"ibus_avalid_1" , 'type':"O", 'n_bits':'1', 'descr':"Address is valid."},
        {'name':"ibus_addr_i" , 'type':"O", 'n_bits':'256', 'descr':"Address."},
        {'name':"ibus_rdata_o" , 'type':"O", 'n_bits':'DATA_W', 'descr':"SRAM write data."},
        {'name':"ibus_rvalid_o" , 'type':"O", 'n_bits':'DATA_W/8', 'descr':"SRAM write strobe."},
        {'name':"ibus_ready_o" , 'type':"O", 'n_bits':'DATA_W/8', 'descr':"SRAM write strobe."}
    ]},
    {'name': 'general', 'descr':'GENERAL INTERFACE SIGNALS', 'ports': [
        {'name':"cpu_rst_o" , 'type':"O", 'n_bits':'1', 'descr':"CPU sync reset."},
        {'name':"preboot_o" , 'type':"O", 'n_bits':'1', 'descr':"System preboot indicator."},
        {'name':"boot_o" , 'type':"O", 'n_bits':'1', 'descr':"System boot indicator."},
        {'name':"clk_i" , 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"arst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, asynchronous and active high"},
        {'name':"cke_i" , 'type':"I", 'n_bits':'1', 'descr':"System reset, asynchronous and active high"}
    ]},
]

regs = \
[
    {'name': 'boot', 'descr':'Boot controlregister.', 'regs': [
        {'name':'ROM', 'type':'R', 'n_bits':'DATA_W', 'rst_val':0, 'addr':0x40000000, 'log2n_items':'12', 'autologic':False, 'descr':"Bootloader ROM."},
        {'name':'CTR', 'type':'W', 'n_bits':3, 'rst_val':0, 'addr':(0x40000000+2**12), 'log2n_items':0, 'autologic':False, 'descr':"Boot control register (write). The register has the following fields: 0: preboot enable, 1: boot enable, 2: CPU reset"},
    ]}
]

blocks = []

# Main function to setup this core and its components
def main():
    setup.setup(sys.modules[__name__])
if __name__ == "__main__":
    main()
