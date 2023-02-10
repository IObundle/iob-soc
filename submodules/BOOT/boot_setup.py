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
        'headers' : [ 'iob_s_port' ],
        'modules': [ 'iob_reg.v', 'iob_reg_e.v', 'iob_pulse_gen.v', 'iob_rom_sp.v' ]
    },
}

confs = \
[
    # Macros

    # Parameters
    {'name':'DATA_W',      'type':'P', 'val':'32', 'min':'NA', 'max':'NA', 'descr':"Data bus width"},
    {'name':'ADDR_W',      'type':'P', 'val':'`BOOT_SWREG_ADDR_W', 'min':'NA', 'max':'NA', 'descr':"Address bus width"},
    {'name':'HEXFILE', 'type':'P', 'val':'0', 'min':'NA', 'max':'NA', 'descr':""},
    {'name':'BOOTROM_ADDR_W', 'type':'P', 'val':'BOOTROM_ADDR_W', 'min':'NA', 'max':'NA', 'descr':""},
    {'name':'SRAM_ADDR_W', 'type':'P', 'val':'SRAM_ADDR_W', 'min':'NA', 'max':'NA', 'descr':""}
]

ios = \
[
    {'name': 'iob_s_port', 'descr':'CPU native interface', 'ports': [
    ]},
    {'name': 'sram_w_if', 'descr':'SRAM write interface', 'ports': [
        {'name':"sram_w_avalid_o" , 'type':"O", 'n_bits':'1', 'descr':"SRAM write valid."},
        {'name':"sram_w_addr_o" , 'type':"O", 'n_bits':'SRAM_ADDR_W', 'descr':"SRAM write address."},
        {'name':"sram_w_data_o" , 'type':"O", 'n_bits':'DATA_W', 'descr':"SRAM write data."},
        {'name':"sram_w_strb_o" , 'type':"O", 'n_bits':'DATA_W/8', 'descr':"SRAM write strobe."}
    ]},
    {'name': 'general', 'descr':'GENERAL INTERFACE SIGNALS', 'ports': [
        {'name':"cpu_rst_o" , 'type':"O", 'n_bits':'1', 'descr':"CPU sync reset."},
        {'name':"boot_o" , 'type':"O", 'n_bits':'1', 'descr':"System boot indicator."},
        {'name':"clk_i" , 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"arst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, asynchronous and active high"},
        {'name':"cke_i" , 'type':"I", 'n_bits':'1', 'descr':"System reset, asynchronous and active high"}
    ]},
]

regs = \
[
    {'name': 'boot', 'descr':'Boot controlregister.', 'regs': [
        {'name':"BOOT_CTR_W", 'type':"W", 'n_bits':2, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':False, 'descr':"Boot control register (write)."},
        {'name':"BOOT_CTR_R", 'type':"R", 'n_bits':2, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':False, 'descr':"Boot control register (read)."}
    ]}
]

blocks = []

# Main function to setup this core and its components
def main():
    setup.setup(sys.modules[__name__])

if __name__ == "__main__":
    main()
