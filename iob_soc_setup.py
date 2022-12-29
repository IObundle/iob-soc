#!/usr/bin/env python3

import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
from setup import setup, setup_submodule
from submodule_utils import get_n_periphs, get_n_periphs_w, get_periphs_id_as_macros
from ios import get_peripheral_ios
from blocks import get_peripheral_blocks

import periphs_tmp
import createSystem
import createTestbench
import createTopSystem

meta = \
{
'name':'iob_soc',
'version':'V0.70',
'flows':'pc-emul emb sim doc fpga',
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
# Get peripherals list from 'peripherals' table in blocks list
peripherals_list=next(i['blocks'] for i in blocks if i['name'] == 'peripherals')

dirs = {
'setup':os.path.dirname(__file__),
'build':f"../{meta['name']+'_'+meta['version']}",
}
submodule_dirs = {
'PICORV32':f"{dirs['setup']}/submodules/PICORV32",
'CACHE':f"{dirs['setup']}/submodules/CACHE",
'UART':f"{dirs['setup']}/submodules/UART",
'LIB':f"{dirs['setup']}/submodules/LIB",
}

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
    {'name':'AXI_ADDR_W',    'type':'P', 'val':'`IOB_SOC_DCACHE_ADDR_W', 'min':'1', 'max':'32', 'descr':"AXI address bus width"},
    {'name':'AXI_DATA_W',    'type':'P', 'val':'`IOB_SOC_DATA_W', 'min':'1', 'max':'32', 'descr':"AXI data bus width"},
    {'name':'AXI_LEN_W',     'type':'P', 'val':'4', 'min':'1', 'max':'4', 'descr':"AXI burst length width"},
]
# Append macros with ID of each peripheral
confs.extend(get_periphs_id_as_macros(peripherals_list))
# Append macro with number of peripherals
confs.append({'name':'N_SLAVES', 'type':'M', 'val':get_n_periphs(peripherals_list), 'min':'NA', 'max':'NA', 'descr':"Number of peripherals"})
# Append macro with width of peripheral bus
confs.append({'name':'N_SLAVES_W', 'type':'M', 'val':get_n_periphs_w(peripherals_list), 'min':'NA', 'max':'NA', 'descr':"Peripheral bus width"})


# regs = []

ios = \
[
    {'name': 'general', 'descr':'General interface signals', 'ports': [
        {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"System clock input"},
        {'name':"rst_i", 'type':"I", 'n_bits':'1', 'descr':"System reset, synchronous and active high"},
        {'name':"trap_o", 'type':"O", 'n_bits':'1', 'descr':"CPU trap signal"}
    ]},
]
# Append peripherals IO 
ios.extend(get_peripheral_ios(peripherals_list, submodule_dirs,os.path.dirname(__file__)))

lib_srcs = {
    'hw_setup': {
        'v_headers' : [ 'axi_m_m_portmap', 'axi_m_port' ],
        'hw_modules': [ 'iob_merge.v', 'iob_split.v', 'iob_rom_sp.v', 'iob_ram_dp_be.v', 'iob_pulse_gen.v', 'iob_reg_are.v', 'iob_counter.v', 'iob_ram_2p_asym.v' ]
    },
    'sim_setup': {
        'v_headers' : [  ],
        'hw_modules': [ 'axi_ram.v' ]
    },
    'fpga_setup': {
        'v_headers': [  ],
        'hw_modules': [  ]
    },
    'sw_setup': {
        'sw_headers': [  ],
        'sw_modules': [  ]
    },
}

# Main function to setup this system and its components
# Gen_tex and gen_makefile are created by default. However, when this system is a submodule of another, we don't want these files of this system.
# dirs_override: allows overriding some directories. This is useful when a top system wants to override the default build directory of this system.
def main(dirs_override={}, gen_tex=True, gen_makefile=True):
    #Override dirs
    dirs.update(dirs_override)
    # Setup this system
    setup(meta, confs, ios, None, blocks, lib_srcs, dirs=dirs, gen_tex=gen_tex, gen_makefile=gen_makefile)
    # Setup submodules
    setup_submodule(dirs['build'],submodule_dirs["PICORV32"])
    setup_submodule(dirs['build'],submodule_dirs["CACHE"])
    setup_submodule(dirs['build'],submodule_dirs["UART"])
    # periphs_tmp.h
    periphs_tmp.create_periphs_tmp(next(i['val'] for i in confs if i['name'] == 'P'),
                                   peripherals_list, f"{dirs['build']}/software/periphs.h")
    # iob_soc.v
    createSystem.create_systemv(os.path.dirname(__file__), submodule_dirs, meta['name'], peripherals_list, os.path.join(dirs['build'],'hardware/src/iob_soc.v'))
    # system_tb.v
    createTestbench.create_system_testbench(os.path.dirname(__file__), submodule_dirs, peripherals_list, os.path.join(dirs['build'],'hardware/simulation/src/system_tb.v'))
    # system_top.v
    createTopSystem.create_top_system(os.path.dirname(__file__), submodule_dirs, peripherals_list, os.path.join(dirs['build'],'hardware/simulation/src/system_top.v'))

if __name__ == "__main__":
    main()
