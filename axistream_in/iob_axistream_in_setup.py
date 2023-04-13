#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
import setup

name='iob_axistream_in'
version='V0.10'
flows='emb'
if setup.is_top_module(sys.modules[__name__]):
    setup_dir=os.path.dirname(__file__)
    build_dir=f"../{name}_{version}"
submodules = {
    'hw_setup': {
        'headers' : [ 'iob_s_port', 'iob_s_portmap' ],
        'modules': [ 'iob_reg.v', 'iob_reg_e.v', 'iob_ram_2p_be.v' ]
    },
}

confs = \
[
    # Macros

    # Parameters
    {'name':'DATA_W',      'type':'P', 'val':'32', 'min':'NA', 'max':'32', 'descr':"Data bus width"},
    {'name':'ADDR_W',      'type':'P', 'val':'`IOB_AXISTREAM_IN_SWREG_ADDR_W', 'min':'NA', 'max':'NA', 'descr':"Address bus width"},
    {'name':'TDATA_W',      'type':'P', 'val':'8', 'min':'NA', 'max':'DATA_W', 'descr':"Width of tdata interface (can be up to DATA_W)"},
    {'name':'FIFO_DEPTH_LOG2',      'type':'P', 'val':'4', 'min':'NA', 'max':'16', 'descr':"Depth of FIFO"},
]

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
        {'name':'tdata_i', 'type':'I', 'n_bits':'TDATA_W', 'descr':'TData input interface'},
        {'name':'tvalid_i', 'type':'I', 'n_bits':'1', 'descr':'TValid input interface'},
        {'name':'tready_o', 'type':'O', 'n_bits':'1', 'descr':'TReady output interface'},
        {'name':'tlast_i', 'type':'I', 'n_bits':'1', 'descr':'TLast input interface'},
    ]}
]

regs = \
[
    {'name': 'axistream', 'descr':'Axistream software accessible registers.', 'regs': [
        {'name':"OUT", 'type':"R", 'n_bits':32, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':False, 'descr':"32 bits: Get next FIFO output (Reading from this register makes it pop the next value from FIFO)"},
        {'name':"EMPTY", 'type':"R", 'n_bits':1, 'rst_val':0, 'addr':4, 'log2n_items':0, 'autologic':False, 'descr':"1 bit: Return if FIFO is empty (May be empty due to waiting for more data or because it received a TLAST signal)"},
        {'name':"LAST", 'type':"R", 'n_bits':5, 'rst_val':0, 'addr':8, 'log2n_items':0, 'autologic':False, 'descr':"1+4 bits: [Bit 4] Signals if FIFO is empty due to receiving a TLAST signal; [Bit 3-0] Tells which bytes (from latest value of AXISTREAMIN_OUT) are valid (similar to WSTRB signal of AXI Stream). (Reading from this register makes it reset and starts filling FIFO with next frame)"},
        {'name':"SOFTRESET", 'type':"W", 'n_bits':1, 'rst_val':0, 'addr':12, 'log2n_items':0, 'autologic':True, 'descr':"Soft reset."},
        {'name':"ENABLE", 'type':"W", 'n_bits':1, 'rst_val':1, 'addr':13, 'log2n_items':0, 'autologic':True, 'descr':"Enable peripheral."},

    ]}
]

blocks = []

# Main function to setup this core and its components
def main():
    setup.setup(sys.modules[__name__])

if __name__ == "__main__":
    main()
