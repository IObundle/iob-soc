#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
from setup import setup, setup_submodule
from submodule_utils import get_n_periphs, get_n_periphs_w, get_periphs_id_as_macros
from ios import get_peripheral_ios
from blocks import get_peripheral_blocks

top = 'iob_soc'
version = 'V0.70'

confs = \
[
    # SoC macros
    {'name':'PERIPHERALS',   'type':'M', 'val':'UART', 'min':'NA', 'max':'NA', 'descr':"List with corename of peripherals to be attached to peripheral bus"},
    {'name':'DATA_W',        'type':'M', 'val':'32', 'min':'1', 'max':'32', 'descr':"Data bus width"},
    {'name':'ADDR_W',        'type':'M', 'val':'32', 'min':'1', 'max':'32', 'descr':"Address bus width"},
    {'name':'FIRM_ADDR_W',   'type':'M', 'val':'15', 'min':'1', 'max':'32', 'descr':"Firmware address width"},
    {'name':'SRAM_ADDR_W',   'type':'M', 'val':'15', 'min':'1', 'max':'32', 'descr':"SRAM address width"},
    {'name':'BOOTROM_ADDR_W','type':'M', 'val':'12', 'min':'1', 'max':'32', 'descr':"Boot ROM address width"},
    {'name':'USE_MUL_DIV',   'type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Enable MUL and DIV CPU instrunctions"},
    {'name':'USE_COMPRESSED','type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Use compressed CPU instructions"},
    {'name':'E',             'type':'M', 'val':'31', 'min':'1', 'max':'32', 'descr':"Address selection bit for external memory"},
    {'name':'P',             'type':'M', 'val':'30', 'min':'1', 'max':'32', 'descr':"Address selection bit for peripherals"},
    {'name':'B',             'type':'M', 'val':'29', 'min':'1', 'max':'32', 'descr':"Address selection bit for boot ROM"},
    {'name':'INIT_MEM',      'type':'M', 'val':'1', 'min':'0', 'max':'1', 'descr':"Enable memory initialization"},
    {'name':'RUN_EXTMEM',    'type':'M', 'val':'0', 'min':'0', 'max':'1', 'descr':"Run firmware from external memory"},
    {'name':'DCACHE_ADDR_W', 'type':'M', 'val':'24', 'min':'1', 'max':'32', 'descr':"DCACHE address width"},
    {'name':'DDR_DATA_W',    'type':'M', 'val':'32', 'min':'1', 'max':'32', 'descr':"DDR data bus width"},
    {'name':'DDR_ADDR_W','type':'M', 'val':'24', 'min':'1', 'max':'32', 'descr':"DDR address bus width in simulation"},
    #TODO: Need to find a way to use value below when running on fpga
    {'name':'DDR_ADDR_W_HW', 'type':'M', 'val':'30', 'min':'1', 'max':'32', 'descr':"DDR address bus width"},
    #TODO: Need to find a way to use value below when running on fpga
    {'name':'BAUD_HW',       'type':'M', 'val':'115200', 'min':'1', 'max':'NA', 'descr':"UART baud rate"},
    {'name':'BAUD',      'type':'M', 'val':'5000000', 'min':'1', 'max':'NA', 'descr':"UART baud rate for simulation"},
    {'name':'FREQ',          'type':'M', 'val':'100000000', 'min':'1', 'max':'NA', 'descr':"System clock frequency"},
    {'name':'AXI_ID_W',      'type':'M', 'val':'0', 'min':'1', 'max':'32', 'descr':"AXI ID bus width"},
    {'name':'AXI_ADDR_W',    'type':'M', 'val':'`IOB_SOC_ADDR_W', 'min':'1', 'max':'32', 'descr':"AXI address bus width"},
    {'name':'AXI_DATA_W',    'type':'M', 'val':'`IOB_SOC_DATA_W', 'min':'1', 'max':'32', 'descr':"AXI data bus width"},
    # SoC parameters
    {'name':'ADDR_W',        'type':'P', 'val':'`IOB_SOC_ADDR_W', 'min':'1', 'max':'32', 'descr':"Address bus width"},
    {'name':'DATA_W',        'type':'P', 'val':'`IOB_SOC_DATA_W', 'min':'1', 'max':'32', 'descr':"Data bus width"},
    {'name':'BOOTROM_ADDR_W','type':'P', 'val':'`IOB_SOC_BOOTROM_ADDR_W', 'min':'1', 'max':'32', 'descr':"Boot ROM address width"},
    {'name':'SRAM_ADDR_W',   'type':'P', 'val':'`IOB_SOC_SRAM_ADDR_W', 'min':'1', 'max':'32', 'descr':"SRAM address width"},
    {'name':'AXI_ID_W',      'type':'P', 'val':'`IOB_SOC_AXI_ID_W', 'min':'1', 'max':'32', 'descr':"AXI ID bus width"},
    {'name':'AXI_ADDR_W',    'type':'P', 'val':'`IOB_SOC_AXI_ADDR_W', 'min':'1', 'max':'32', 'descr':"AXI address bus width"},
    {'name':'AXI_DATA_W',    'type':'P', 'val':'`IOB_SOC_AXI_DATA_W', 'min':'1', 'max':'32', 'descr':"AXI data bus width"},
]
# Append macros with ID of each peripheral
confs.extend(get_periphs_id_as_macros(next(i['val'] for i in confs if i['name'] == 'PERIPHERALS')))
# Append macro with number of peripherals
confs.append({'name':'N_SLAVES',   'type':'M', 'val':get_n_periphs(next(i['val'] for i in confs if i['name'] == 'PERIPHERALS')), 'min':'NA', 'max':'NA', 'descr':"Number of peripherals"})
# Append macro with width of peripheral bus
confs.append({'name':'N_SLAVES_W', 'type':'M', 'val':get_n_periphs_w(next(i['val'] for i in confs if i['name'] == 'PERIPHERALS')), 'min':'NA', 'max':'NA', 'descr':"Peripheral bus width"})


# regs = []

ios = \
[
    {'name': 'general', 'descr':'General interface signals', 'ports': [
        {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"rst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, synchronous and active high"},
        {'name':"trap_o", 'type':"O", 'n_bits':'1', 'descr':"CPU trap signal"}
    ]},
    {'name': 'axi_m_port', 'descr':'AXI master interface', 'ports': [
    ]}
]
# Append peripherals IO 
ios.extend(get_peripheral_ios(next(i['val'] for i in confs if i['name'] == 'PERIPHERALS'),os.path.dirname(__file__)))


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
    ]}
]
# Append peripherals instances
blocks.append({'name':'peripherals', 'descr':'Peripheral modules', 'blocks':
        get_peripheral_blocks(next(i['val'] for i in confs if i['name'] == 'PERIPHERALS'),os.path.dirname(__file__))})

if __name__ == "__main__":
    # Setup submodules
    setup_submodule(f"../{top+'_'+version}","submodules/UART")
    setup_submodule(f"../{top+'_'+version}","submodules/CACHE")
    # Setup this system
    setup(top, version, confs, ios, None, blocks)
