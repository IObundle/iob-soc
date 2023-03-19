#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
import setup
from submodule_utils import import_setup

name='iob_axistream_out'
setup_dir=os.path.dirname(__file__)

# Import axistream_in module to reuse some cofniguration options
axistream_in_module=import_setup(f"{setup_dir}/../axistream_in/")
version=axistream_in_module.version
flows=axistream_in_module.flows

if setup.is_top_module(sys.modules[__name__]):
    build_dir=f"../{name}_{version}"

submodules = axistream_in_module.submodules

confs = axistream_in_module.confs

ios = \
[
    {'name': 'iob_s_port', 'descr':'CPU native interface', 'ports': [
    ]},
    {'name': 'general', 'descr':'GENERAL INTERFACE SIGNALS', 'ports': [
        {'name':"clk_i" , 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"arst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, asynchronous and active high"},
        {'name':"cke_i", 'type':"I", 'n_bits':'1', 'descr':"System clock enable signal."},
    ]},
    {'name': 'axistream', 'descr':'', 'ports': [
        {'name':'tdata_o', 'type':'O', 'n_bits':'TDATA_W', 'descr':'TData output interface'},
        {'name':'tvalid_o', 'type':'O', 'n_bits':'1', 'descr':'TValid output interface'},
        {'name':'tready_i', 'type':'I', 'n_bits':'1', 'descr':'TReady input interface'},
        {'name':'tlast_o', 'type':'O', 'n_bits':'1', 'descr':'TLast output interface'},
    ]}
]

regs = \
[
    {'name': 'axistream', 'descr':'Axistream software accessible registers.', 'regs': [
        {'name':"AXISTREAMOUT_IN", 'type':"R", 'n_bits':32, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':"32 bits: Set next FIFO input (Writing to this register pushes the value into the FIFO)"},
        {'name':"AXISTREAMOUT_FULL", 'type':"R", 'n_bits':1, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':"1 bit: Return if FIFO is full"},
        {'name':"AXISTREAMOUT_WSTRB_NEXT_WORD_LAST", 'type':"R", 'n_bits':5, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':"From 1 to 4 bits: Set which output words of the next input word in AXISTREAMOUT_IN are valid and send TLAST signal along with last valid byte. (If this register has value 0, all 4 bytes will be valid and it will not send a TLAST signal with the last byte [MSB]). When the output word width (TDATA) is 8, 16 or 32 bits, this register has size 4, 2 or 1 bits respectively."},

    ]}
]

blocks = []

# Main function to setup this core and its components
def main():
    setup.setup(sys.modules[__name__])

if __name__ == "__main__":
    main()
