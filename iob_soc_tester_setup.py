#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
from setup import setup

meta = \
{
'name':'iob_soc_tester',
'version':'V0.50',
'flows':'pc-emul emb sim doc fpga',
'setup_dir':os.path.dirname(__file__)}
meta['build_dir']=f"../{meta['name']+'_'+meta['version']}"
meta['submodules'] = {
    'hw_setup': {
        'v_headers' : [ 'axi_m_m_portmap', 'axi_m_port' ],
        'hw_modules': [ 'PICORV32', 'CACHE', 'UART', 'iob_merge.v', 'iob_split.v', 'iob_rom_sp.v', 'iob_ram_dp_be.v', 'iob_pulse_gen.v', 'iob_reg_are.v', 'iob_counter.v', 'iob_ram_2p_asym.v' ]
    },
    'sim_setup': {
        'v_headers' : [  ],
        'hw_modules': [ 'axi_ram.v' ]
    },
    'sw_setup': {
        'sw_headers': [  ],
        'sw_modules': [  ]
    },
}

blocks = \
[
    {'name':'cpu', 'descr':'CPU module', 'blocks': [
        {'name':'cpu', 'descr':'PicoRV32 CPU'},
    ]},
    {'name':'bus_split', 'descr':'Split modules for buses', 'blocks': [
        {'name':'ibus_split', 'descr':'Split CPU instruction bus into internal and external memory buses'},
        {'name':'dbus_split', 'descr':'Split CPU data bus into internal and external memory buses'},
        {'name':'int_dbus_split', 'descr':'Split internal data bus into internal memory and peripheral buses'},
        {'name':'pbus_split', 'descr':'Split peripheral bus into a bus for each peripheral'},
    ]},
    {'name':'memories', 'descr':'Memory modules', 'blocks': [
        {'name':'int_mem0', 'descr':'Internal SRAM memory'},
        {'name':'ext_mem0', 'descr':'External DDR memory'},
    ]},
    {'name':'peripherals', 'descr':'peripheral modules', 'blocks': [
        {'name':'UART0', 'type':'UART', 'descr':'Default UART interface', 'params':{}},
    ]},
]

confs = \
[
    # SoC defines
    {'name':'INIT_MEM',      'type':'D', 'val':'1', 'min':'0', 'max':'1', 'descr':"Enable memory initialization"},
    {'name':'RUN_EXTMEM',    'type':'D', 'val':'0', 'min':'0', 'max':'1', 'descr':"Run firmware from external memory"}, #This is the new USE_DDR

    # SoC macros
    {'name':'USE_MUL_DIV',   'type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Enable MUL and DIV CPU instrunctions"},
    {'name':'USE_COMPRESSED','type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Use compressed CPU instructions"},
    {'name':'E',             'type':'M', 'val':'31', 'min':'1', 'max':'32', 'descr':"Address selection bit for external memory"},
    {'name':'P',             'type':'M', 'val':'30', 'min':'1', 'max':'32', 'descr':"Address selection bit for peripherals"},
    {'name':'B',             'type':'M', 'val':'29', 'min':'1', 'max':'32', 'descr':"Address selection bit for boot ROM"},
    {'name':'DCACHE_ADDR_W', 'type':'M', 'val':'24', 'min':'1', 'max':'32', 'descr':"DCACHE address width"},
    {'name':'DDR_DATA_W',    'type':'M', 'val':'32', 'min':'1', 'max':'32', 'descr':"DDR data bus width"},
    {'name':'DDR_ADDR_W',    'type':'M', 'val':'24', 'min':'1', 'max':'32', 'descr':"DDR address bus width in simulation"},
    #TODO: Need to find a way to use value below when running on fpga
    {'name':'DDR_ADDR_W_HW', 'type':'M', 'val':'30', 'min':'1', 'max':'32', 'descr':"DDR address bus width"},
    #TODO: Need to find a way to use value below when running on fpga
    {'name':'BAUD_HW',       'type':'M', 'val':'115200', 'min':'1', 'max':'NA', 'descr':"UART baud rate"},
    {'name':'BAUD',          'type':'M', 'val':'5000000', 'min':'1', 'max':'NA', 'descr':"UART baud rate for simulation"},
    {'name':'FREQ',          'type':'M', 'val':'100000000', 'min':'1', 'max':'NA', 'descr':"System clock frequency"},

    # SoC parameters
    {'name':'ADDR_W',        'type':'P', 'val':'32', 'min':'1', 'max':'32', 'descr':"Address bus width"},
    {'name':'DATA_W',        'type':'P', 'val':'32', 'min':'1', 'max':'32', 'descr':"Data bus width"},
    {'name':'BOOTROM_ADDR_W','type':'P', 'val':'12', 'min':'1', 'max':'32', 'descr':"Boot ROM address width"},
    {'name':'SRAM_ADDR_W',   'type':'P', 'val':'15', 'min':'1', 'max':'32', 'descr':"SRAM address width"},
    {'name':'AXI_ID_W',      'type':'P', 'val':'0', 'min':'1', 'max':'32', 'descr':"AXI ID bus width"},
    {'name':'AXI_ADDR_W',    'type':'P', 'val':'`IOB_SOC_TESTER_DCACHE_ADDR_W', 'min':'1', 'max':'32', 'descr':"AXI address bus width"},
    {'name':'AXI_DATA_W',    'type':'P', 'val':'`IOB_SOC_TESTER_DATA_W', 'min':'1', 'max':'32', 'descr':"AXI data bus width"},
    {'name':'AXI_LEN_W',     'type':'P', 'val':'4', 'min':'1', 'max':'4', 'descr':"AXI burst length width"},
]

regs = [] 

ios = \
[
    {'name': 'general', 'descr':'General interface signals', 'ports': [
        {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"rst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, synchronous and active high"},
        {'name':"trap_o", 'type':"O", 'n_bits':'2', 'descr':"CPU trap signal"}
    ]},
#    {'name': 'axi_m_port', 'descr':'AXI master interface', 'ports': [
#    ]}

#`ifdef TESTER_USE_DDR
# //AXI MASTER INTERFACE
# `IOB_OUTPUT(m_axi_awid, 2*AXI_ID_W), //Address write channel ID
# `IOB_OUTPUT(m_axi_awaddr, 2*AXI_ADDR_W), //Address write channel address
# `IOB_OUTPUT(m_axi_awlen, 2*8), //Address write channel burst length
# `IOB_OUTPUT(m_axi_awsize, 2*3), //Address write channel burst size. This signal indicates the size of each transfer in the burst
# `IOB_OUTPUT(m_axi_awburst, 2*2), //Address write channel burst type
# `IOB_OUTPUT(m_axi_awlock, 2*2), //Address write channel lock type
# `IOB_OUTPUT(m_axi_awcache, 2*4), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
# `IOB_OUTPUT(m_axi_awprot, 2*3), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
# `IOB_OUTPUT(m_axi_awqos, 2*4), //Address write channel quality of service
# `IOB_OUTPUT(m_axi_awvalid, 2*1), //Address write channel valid
# `IOB_INPUT(m_axi_awready, 2*1), //Address write channel ready
# `IOB_OUTPUT(m_axi_wdata, 2*AXI_DATA_W), //Write channel data
# `IOB_OUTPUT(m_axi_wstrb, 2*(AXI_DATA_W/8)), //Write channel write strobe
# `IOB_OUTPUT(m_axi_wlast, 2*1), //Write channel last word flag
# `IOB_OUTPUT(m_axi_wvalid, 2*1), //Write channel valid
# `IOB_INPUT(m_axi_wready, 2*1), //Write channel ready
# `IOB_INPUT(m_axi_bid, 2*AXI_ID_W), //Write response channel ID
# `IOB_INPUT(m_axi_bresp, 2*2), //Write response channel response
# `IOB_INPUT(m_axi_bvalid, 2*1), //Write response channel valid
# `IOB_OUTPUT(m_axi_bready, 2*1), //Write response channel ready
# `IOB_OUTPUT(m_axi_arid, 2*AXI_ID_W), //Address read channel ID
# `IOB_OUTPUT(m_axi_araddr, 2*AXI_ADDR_W), //Address read channel address
# `IOB_OUTPUT(m_axi_arlen, 2*8), //Address read channel burst length
# `IOB_OUTPUT(m_axi_arsize, 2*3), //Address read channel burst size. This signal indicates the size of each transfer in the burst
# `IOB_OUTPUT(m_axi_arburst, 2*2), //Address read channel burst type
# `IOB_OUTPUT(m_axi_arlock, 2*2), //Address read channel lock type
# `IOB_OUTPUT(m_axi_arcache, 2*4), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
# `IOB_OUTPUT(m_axi_arprot, 2*3), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
# `IOB_OUTPUT(m_axi_arqos, 2*4), //Address read channel quality of service
# `IOB_OUTPUT(m_axi_arvalid, 2*1), //Address read channel valid
# `IOB_INPUT(m_axi_arready, 2*1), //Address read channel ready
# `IOB_INPUT(m_axi_rid, 2*AXI_ID_W), //Read channel ID
# `IOB_INPUT(m_axi_rdata, 2*AXI_DATA_W), //Read channel data
# `IOB_INPUT(m_axi_rresp, 2*2), //Read channel response
# `IOB_INPUT(m_axi_rlast, 2*1), //Read channel last word
# `IOB_INPUT(m_axi_rvalid, 2*1), //Read channel valid
# `IOB_OUTPUT(m_axi_rready, 2*1), //Read channel ready
#`endif //  `ifdef USE_DDR

]

#TODO: Modify setup function to NOT fill ios with peripherals IOs, as this will be handled by the portmap functions

#TODO: Ensure the createSystem and other functions create the iob_soc_tester.v output file

# Main function to setup this system and its components
def main():
    # Setup this system
    setup(meta, confs, ios, regs, blocks, ios_prefix=True )

if __name__ == "__main__":
    main()
