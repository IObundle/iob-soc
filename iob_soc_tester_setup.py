#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
import setup
from mk_configuration import update_define

sys.path.insert(0, os.path.dirname(__file__)+'/scripts')
from tester import setup_tester, update_tester_conf

sys.path.insert(0, os.path.dirname(__file__)+'/submodules/IOBSOC/scripts')
import iob_soc

name='iob_soc_tester'
version='V0.50'
flows='pc-emul emb sim fpga'
if setup.is_top_module(sys.modules[__name__]):
    setup_dir=os.path.dirname(__file__)
    build_dir=f"../{name}_{version}"
submodules = {
    'hw_setup': {
        'headers' : [ 'iob_wire', 'axi_wire', 'axi_m_m_portmap', 'axi_m_port', 'axi_m_m_portmap', 'axi_m_portmap'],
        'modules': [ 'PICORV32', 'CACHE', 'UART', 'iob_merge', 'iob_split', 'iob_rom_sp.v', 'iob_ram_dp_be.v', 'iob_ram_dp_be_xil.v', 'iob_pulse_gen.v', 'iob_counter.v', 'iob_ram_2p_asym.v', 'iob_reg.v', 'iob_reg_re.v', 'iob_ram_sp_be.v', 'iob_ram_dp.v', 'iob_reset_sync']
    },
    'sim_setup': {
        'headers' : [ 'axi_s_portmap', 'iob_tasks.vh'  ],
        'modules': [ 'axi_ram.v' ]
    },
    'sw_setup': {
        'headers': [  ],
        'modules': [ 'CACHE', 'UART', 'iob_str'  ]
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
    # macros
    {'name':'USE_MUL_DIV',   'type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Enable MUL and DIV CPU instructions"},
    {'name':'USE_COMPRESSED','type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Use compressed CPU instructions"},
    {'name':'E',             'type':'M', 'val':'31', 'min':'1', 'max':'32', 'descr':"Address selection bit for external memory"},
    {'name':'P',             'type':'M', 'val':'30', 'min':'1', 'max':'32', 'descr':"Address selection bit for peripherals"},
    {'name':'B',             'type':'M', 'val':'29', 'min':'1', 'max':'32', 'descr':"Address selection bit for boot ROM"},

    # parameters
    {'name':'BOOTROM_ADDR_W','type':'P', 'val':'12', 'min':'1', 'max':'32', 'descr':"Boot ROM address width"},
    {'name':'SRAM_ADDR_W',   'type':'P', 'val':'15', 'min':'1', 'max':'32', 'descr':"SRAM address width"},

    #mandatory parameters (do not change them!)
    {'name':'ADDR_W',        'type':'P', 'val':'32', 'min':'1', 'max':'32', 'descr':"Address bus width"},
    {'name':'DATA_W',        'type':'P', 'val':'32', 'min':'1', 'max':'32', 'descr':"Data bus width"},
    {'name':'AXI_ID_W',      'type':'P', 'val':'0', 'min':'1', 'max':'32', 'descr':"AXI ID bus width"},
    {'name':'AXI_ADDR_W',    'type':'P', 'val':'`MEM_ADDR_W', 'min':'1', 'max':'32', 'descr':"AXI address bus width"},
    {'name':'AXI_DATA_W',    'type':'P', 'val':'`IOB_SOC_TESTER_DATA_W', 'min':'1', 'max':'32', 'descr':"AXI data bus width"},
    {'name':'AXI_LEN_W',     'type':'P', 'val':'4', 'min':'1', 'max':'4', 'descr':"AXI burst length width"},
]

regs = [] 

ios = \
[
    {'name': 'general', 'descr':'General interface signals', 'ports': [
        {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"arst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, synchronous and active high"},
        {'name':"trap_o", 'type':"O", 'n_bits':'2', 'descr':"CPU trap signal (One for tester and one optionally for SUT)"}
    ]},
    {'name': 'axi_m_custom_port', 'descr':'Bus of AXI master interfaces. One for Tester, one optionally from SUT', 'if_defined':'USE_EXTMEM', 'ports': [
        {'name':'axi_awid_o', 'type':'O', 'n_bits':'2*AXI_ID_W', 'descr':'Address write channel ID'},
        {'name':'axi_awaddr_o', 'type':'O', 'n_bits':'2*AXI_ADDR_W', 'descr':'Address write channel address'},
        {'name':'axi_awlen_o', 'type':'O', 'n_bits':'2*8', 'descr':'Address write channel burst length'},
        {'name':'axi_awsize_o', 'type':'O', 'n_bits':'2*3', 'descr':'Address write channel burst size. This signal indicates the size of each transfer in the burst'},
        {'name':'axi_awburst_o', 'type':'O', 'n_bits':'2*2', 'descr':'Address write channel burst type'},
        {'name':'axi_awlock_o', 'type':'O', 'n_bits':'2*2', 'descr':'Address write channel lock type'},
        {'name':'axi_awcache_o', 'type':'O', 'n_bits':'2*4', 'descr':'Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'},
        {'name':'axi_awprot_o', 'type':'O', 'n_bits':'2*3', 'descr':'Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'},
        {'name':'axi_awqos_o', 'type':'O', 'n_bits':'2*4', 'descr':'Address write channel quality of service'},
        {'name':'axi_awvalid_o', 'type':'O', 'n_bits':'2*1', 'descr':'Address write channel valid'},
        {'name':'axi_awready_i', 'type':'I', 'n_bits':'2*1', 'descr':'Address write channel ready'},
        {'name':'axi_wdata_o', 'type':'O', 'n_bits':'2*AXI_DATA_W', 'descr':'Write channel data'},
        {'name':'axi_wstrb_o', 'type':'O', 'n_bits':'2*(AXI_DATA_W/8)', 'descr':'Write channel write strobe'},
        {'name':'axi_wlast_o', 'type':'O', 'n_bits':'2*1', 'descr':'Write channel last word flag'},
        {'name':'axi_wvalid_o', 'type':'O', 'n_bits':'2*1', 'descr':'Write channel valid'},
        {'name':'axi_wready_i', 'type':'I', 'n_bits':'2*1', 'descr':'Write channel ready'},
        {'name':'axi_bid_i', 'type':'I', 'n_bits':'2*AXI_ID_W', 'descr':'Write response channel ID'},
        {'name':'axi_bresp_i', 'type':'I', 'n_bits':'2*2', 'descr':'Write response channel response'},
        {'name':'axi_bvalid_i', 'type':'I', 'n_bits':'2*1', 'descr':'Write response channel valid'},
        {'name':'axi_bready_o', 'type':'O', 'n_bits':'2*1', 'descr':'Write response channel ready'},
        {'name':'axi_arid_o', 'type':'O', 'n_bits':'2*AXI_ID_W', 'descr':'Address read channel ID'},
        {'name':'axi_araddr_o', 'type':'O', 'n_bits':'2*AXI_ADDR_W', 'descr':'Address read channel address'},
        {'name':'axi_arlen_o', 'type':'O', 'n_bits':'2*8', 'descr':'Address read channel burst length'},
        {'name':'axi_arsize_o', 'type':'O', 'n_bits':'2*3', 'descr':'Address read channel burst size. This signal indicates the size of each transfer in the burst'},
        {'name':'axi_arburst_o', 'type':'O', 'n_bits':'2*2', 'descr':'Address read channel burst type'},
        {'name':'axi_arlock_o', 'type':'O', 'n_bits':'2*2', 'descr':'Address read channel lock type'},
        {'name':'axi_arcache_o', 'type':'O', 'n_bits':'2*4', 'descr':'Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'},
        {'name':'axi_arprot_o', 'type':'O', 'n_bits':'2*3', 'descr':'Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'},
        {'name':'axi_arqos_o', 'type':'O', 'n_bits':'2*4', 'descr':'Address read channel quality of service'},
        {'name':'axi_arvalid_o', 'type':'O', 'n_bits':'2*1', 'descr':'Address read channel valid'},
        {'name':'axi_arready_i', 'type':'I', 'n_bits':'2*1', 'descr':'Address read channel ready'},
        {'name':'axi_rid_i', 'type':'I', 'n_bits':'2*AXI_ID_W', 'descr':'Read channel ID'},
        {'name':'axi_rdata_i', 'type':'I', 'n_bits':'2*AXI_DATA_W', 'descr':'Read channel data'},
        {'name':'axi_rresp_i', 'type':'I', 'n_bits':'2*2', 'descr':'Read channel response'},
        {'name':'axi_rlast_i', 'type':'I', 'n_bits':'2*1', 'descr':'Read channel last word'},
        {'name':'axi_rvalid_i', 'type':'I', 'n_bits':'2*1', 'descr':'Read channel valid'},
        {'name':'axi_rready_o', 'type':'O', 'n_bits':'2*1', 'descr':'Read channel ready'},
    ]},
]

# ----------- Example Tester module configuration -----------
# 'module_parameters' dictionary will be overriden if it is called by another core/system by defining the following hardware module:
#     'hw_modules': [ ('TESTER',module_parameters) ]
if 'module_parameters' not in vars():
    module_parameters = {
        # Allows overriding entries in 'confs' dictionary of the 'blocks' dictionary in iob_soc_tester.py
        'extra_peripherals': 
        [
#           {'name':'UART0', 'type':'UART', 'descr':'Default UART interface', 'params':{}}, # It is possible to override default tester peripherals with new parameters
        ],

        # Allows for manual configuration of directory paths for peripherals added in 'extra_peripherals' list
        'extra_peripherals_dirs':
        {
#           UART:'./submodules/UART'
        },

        # Map IO connections of Tester peripherals with UUT's IO and the top system.
        'peripheral_portmap':
        [
            ({'corename':'UART0', 'if_name':'rs232', 'port':'', 'bits':[]},{'corename':'self', 'if_name':'UART', 'port':'', 'bits':[]}), #Map UART0 of tester to external interface
        ],

        # Allows overriding entries in 'confs' dictionary of iob_soc_tester.py
        'confs':
        [
            # Override default values of Tester params
            #{'name':'BOOTROM_ADDR_W','type':'P', 'val':'13', 'min':'1', 'max':'32', 'descr':"Boot ROM address width"},
            #{'name':'SRAM_ADDR_W',   'type':'P', 'val':'16', 'min':'1', 'max':'32', 'descr':"SRAM address width"},
        ],

        # Name of the System Under Test (SUT) firmmware. Used by tester to initialize external memory in simulation.
        #'sut_fw_name':name+'_firmware'
    }

# Update tester configuration based on module_parameters
update_tester_conf(sys.modules[__name__])

# Add IOb-SoC modules. These will copy and generate common files from the IOb-SoC repository.
# Don't add module to 'hw_setup'. This will be added by the setup_tester function.
iob_soc.add_iob_soc_modules(sys.modules[__name__])

def custom_setup():
    # Add the following arguments:
    # "INIT_MEM": if should setup with init_mem or not
    # "USE_EXTMEM": if should setup with extmem or not
    for arg in sys.argv[1:]:
        if arg == "INIT_MEM":
            update_define(confs, "INIT_MEM",True)
        if arg == "USE_EXTMEM":
            update_define(confs, "USE_EXTMEM",True)
    
    for conf in confs:
        if (conf['name'] == 'USE_EXTMEM') and conf['val']:
            submodules['hw_setup']['headers'].append({ 'file_prefix':'ddr4_', 'interface':'axi_wire', 'wire_prefix':'ddr4_', 'port_prefix':'ddr4_' })
            submodules['hw_setup']['modules'].append('axi_interconnect')
            submodules['hw_setup']['headers'] += [
                     { 'file_prefix':'iob_bus_0_2_', 'interface':'axi_m_portmap', 'wire_prefix':'', 'port_prefix':'', 'bus_start':0, 'bus_size':2 },
                     { 'file_prefix':'iob_bus_2_3_', 'interface':'axi_s_portmap', 'wire_prefix':'', 'port_prefix':'', 'bus_start':2, 'bus_size':1 },
                     # Can't use portmaps below, because it creates axi_awlock and axi_arlock with 2 bits instead of 1 (these are used for axi_interconnect)
                     #{ 'file_prefix':'iob_bus_0_2_s_', 'interface':'axi_portmap', 'wire_prefix':'', 'port_prefix':'s_', 'bus_start':0, 'bus_size':2 },
                     #{ 'file_prefix':'iob_bus_2_3_m_', 'interface':'axi_portmap', 'wire_prefix':'', 'port_prefix':'m_', 'bus_start':2, 'bus_size':1 },
                     { 'file_prefix':'iob_bus_3_', 'interface':'axi_wire', 'wire_prefix':'', 'port_prefix':'', 'bus_size':3 },
                     { 'file_prefix':'iob_bus_2_', 'interface':'axi_wire', 'wire_prefix':'', 'port_prefix':'', 'bus_size':2 },
                    ]

# Main function to setup this system and its components
def main():
    custom_setup()
    # Setup this system
    setup_tester(sys.modules[__name__])

if __name__ == "__main__":
    main()
