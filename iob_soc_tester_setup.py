#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
from tester import setup_tester

meta = \
{
'name':'iob_soc_tester',
'version':'V0.50',
'flows':'pc-emul emb sim doc fpga',
'setup_dir':os.path.dirname(__file__)}
meta['build_dir']=f"../{meta['name']+'_'+meta['version']}"
meta['submodules'] = {
    'hw_setup': {
        'v_headers' : [ 'iob_wire', 'axi_wire', 'axi_m_m_portmap', 'axi_m_port', 'axi_m_m_portmap', ],
        'hw_modules': [ 'PICORV32', 'CACHE', 'UART', 'iob_merge.v', 'iob_split.v', 'iob_rom_sp.v', 'iob_ram_dp_be.v', 'iob_pulse_gen.v', 'iob_counter.v', 'iob_ram_2p_asym.v', 'iob_reg.v', 'iob_reg_re.v' ]
    },
    'sim_setup': {
        'v_headers' : [ 'axi_wire', 'axi_s_portmap', 'axi_m_portmap' ],
        'hw_modules': [ 'axi_ram.v' ]
    },
    'sw_setup': {
        'sw_headers': [  ],
        'sw_modules': [ 'CACHE', 'UART', ]
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
    {'name':'RUN_EXTMEM',    'type':'D', 'val':'0', 'min':'0', 'max':'1', 'descr':"Run firmware from external memory"}, # USE_DDR was merged with RUN_EXTMEM

    # SoC macros
    {'name':'USE_MUL_DIV',   'type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Enable MUL and DIV CPU instrunctions"},
    {'name':'USE_COMPRESSED','type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Use compressed CPU instructions"},
    {'name':'E',             'type':'M', 'val':'31', 'min':'1', 'max':'32', 'descr':"Address selection bit for external memory"},
    {'name':'P',             'type':'M', 'val':'30', 'min':'1', 'max':'32', 'descr':"Address selection bit for peripherals"},
    {'name':'B',             'type':'M', 'val':'29', 'min':'1', 'max':'32', 'descr':"Address selection bit for boot ROM"},
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
    {'name':'DCACHE_ADDR_W', 'type':'P', 'val':'24', 'min':'1', 'max':'32', 'descr':"DCACHE address width"},
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
    {'name': 'axi_m_port', 'descr':'AXI master interface', 'if_defined':'RUN_EXTMEM', 'ports': [
        {'name':'m_axi_awid', 'type':'O', 'n_bits':'2*AXI_ID_W', 'descr':'Address write channel ID'},
        {'name':'m_axi_awaddr', 'type':'O', 'n_bits':'2*AXI_ADDR_W', 'descr':'Address write channel address'},
        {'name':'m_axi_awlen', 'type':'O', 'n_bits':'2*8', 'descr':'Address write channel burst length'},
        {'name':'m_axi_awsize', 'type':'O', 'n_bits':'2*3', 'descr':'Address write channel burst size. This signal indicates the size of each transfer in the burst'},
        {'name':'m_axi_awburst', 'type':'O', 'n_bits':'2*2', 'descr':'Address write channel burst type'},
        {'name':'m_axi_awlock', 'type':'O', 'n_bits':'2*2', 'descr':'Address write channel lock type'},
        {'name':'m_axi_awcache', 'type':'O', 'n_bits':'2*4', 'descr':'Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'},
        {'name':'m_axi_awprot', 'type':'O', 'n_bits':'2*3', 'descr':'Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'},
        {'name':'m_axi_awqos', 'type':'O', 'n_bits':'2*4', 'descr':'Address write channel quality of service'},
        {'name':'m_axi_awvalid', 'type':'O', 'n_bits':'2*1', 'descr':'Address write channel valid'},
        {'name':'m_axi_awready', 'type':'I', 'n_bits':'2*1', 'descr':'Address write channel ready'},
        {'name':'m_axi_wdata', 'type':'O', 'n_bits':'2*AXI_DATA_W', 'descr':'Write channel data'},
        {'name':'m_axi_wstrb', 'type':'O', 'n_bits':'2*(AXI_DATA_W/8', 'descr':'Write channel write strobe'},
        {'name':'m_axi_wlast', 'type':'O', 'n_bits':'2*1', 'descr':'Write channel last word flag'},
        {'name':'m_axi_wvalid', 'type':'O', 'n_bits':'2*1', 'descr':'Write channel valid'},
        {'name':'m_axi_wready', 'type':'I', 'n_bits':'2*1', 'descr':'Write channel ready'},
        {'name':'m_axi_bid', 'type':'I', 'n_bits':'2*AXI_ID_W', 'descr':'Write response channel ID'},
        {'name':'m_axi_bresp', 'type':'I', 'n_bits':'2*2', 'descr':'Write response channel response'},
        {'name':'m_axi_bvalid', 'type':'I', 'n_bits':'2*1', 'descr':'Write response channel valid'},
        {'name':'m_axi_bready', 'type':'O', 'n_bits':'2*1', 'descr':'Write response channel ready'},
        {'name':'m_axi_arid', 'type':'O', 'n_bits':'2*AXI_ID_W', 'descr':'Address read channel ID'},
        {'name':'m_axi_araddr', 'type':'O', 'n_bits':'2*AXI_ADDR_W', 'descr':'Address read channel address'},
        {'name':'m_axi_arlen', 'type':'O', 'n_bits':'2*8', 'descr':'Address read channel burst length'},
        {'name':'m_axi_arsize', 'type':'O', 'n_bits':'2*3', 'descr':'Address read channel burst size. This signal indicates the size of each transfer in the burst'},
        {'name':'m_axi_arburst', 'type':'O', 'n_bits':'2*2', 'descr':'Address read channel burst type'},
        {'name':'m_axi_arlock', 'type':'O', 'n_bits':'2*2', 'descr':'Address read channel lock type'},
        {'name':'m_axi_arcache', 'type':'O', 'n_bits':'2*4', 'descr':'Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'},
        {'name':'m_axi_arprot', 'type':'O', 'n_bits':'2*3', 'descr':'Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'},
        {'name':'m_axi_arqos', 'type':'O', 'n_bits':'2*4', 'descr':'Address read channel quality of service'},
        {'name':'m_axi_arvalid', 'type':'O', 'n_bits':'2*1', 'descr':'Address read channel valid'},
        {'name':'m_axi_arready', 'type':'I', 'n_bits':'2*1', 'descr':'Address read channel ready'},
        {'name':'m_axi_rid', 'type':'I', 'n_bits':'2*AXI_ID_W', 'descr':'Read channel ID'},
        {'name':'m_axi_rdata', 'type':'I', 'n_bits':'2*AXI_DATA_W', 'descr':'Read channel data'},
        {'name':'m_axi_rresp', 'type':'I', 'n_bits':'2*2', 'descr':'Read channel response'},
        {'name':'m_axi_rlast', 'type':'I', 'n_bits':'2*1', 'descr':'Read channel last word'},
        {'name':'m_axi_rvalid', 'type':'I', 'n_bits':'2*1', 'descr':'Read channel valid'},
        {'name':'m_axi_rready', 'type':'O', 'n_bits':'2*1', 'descr':'Read channel ready'},
    ]},
]

# ----------- Tester module configuration -----------
#module_parameters = {
#    extra_peripherals: 
#    [
#        {'name':'UART0', 'type':'UART', 'descr':'Default UART interface', 'params':{}}, # It is possible to override default tester peripherals with new parameters
#    ],
#
#    extra_peripherals_dirs:{UART:'./submodules/UART'},
#
#    peripheral_portmap:
#    [
#        ({'corename':'UART0', 'if_name':'rs232', 'port':'', 'bits':[]},{'corename':'', 'if_name':'', 'port':'', 'bits':[]}), #Map UART0 of tester to external interface
#    ],
#}

# Main function to setup this system and its components
def main():
    # Setup this system
    setup_tester(meta, confs, ios, regs, blocks, module_parameters)

if __name__ == "__main__":
    main()
