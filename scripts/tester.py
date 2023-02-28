#!/usr/bin/env python3
#
#    tester.py: tester related functions
#
import os, sys
sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')
sys.path.insert(0, os.path.dirname(__file__)+'/../submodules/IOBSOC/scripts')

from submodule_utils import import_setup, get_table_ports, add_prefix_to_parameters_in_port, eval_param_expression_from_config, iob_soc_peripheral_setup, set_default_submodule_dirs
from ios import get_interface_mapping
from iob_soc import setup_iob_soc
import build_srcs
import iob_colors

# Add tester modules to the list of hw, sim, sw and fpga modules of the current core/system
# python_module: python module of the current system
# tester_options: dictionary with tester options
def add_tester_modules(python_module, tester_options):
    # Make sure lists exist
    for i in ['hw_setup','sim_setup','fpga_setup','sw_setup']:
        if i not in python_module.submodules: python_module.submodules[i] = { 'headers' : [], 'modules': [] }

    # Add tester to lists
    for i in ['hw_setup','sim_setup','fpga_setup','sw_setup']:
        python_module.submodules[i]['modules'].append(('TESTER',tester_options))

    # Add tester flows to the UUT flows
    # This is required if the UUT is creating the build directory because it handles the flows enabled in config_build.mk
    python_module.flows += ' emb sim fpga'

#Given the io dictionary of ports, the port name (and size, and optional bit list) and a wire, it will map the selected bits of the port to the given wire.
#io_dict: dictionary where keys represent port names, values are the mappings
#port_name: name of the port to map
#port_size: size the port (if port_bits are not specified, this value is not used)
#port_bits: list of bits of the port that are being mapped to the wire. If list is empty it will map all the bits.
#           The order of bits in this list is important. The bits of the wire will always be filled in incremental order and will match the corresponding bit of the port given on this list following the list order. Example: The list [5,3] will map the port bit 5 to wire bit 0 and port bit 3 to wire bit 1.
#wire_name: name of the wire to connect the bits of the port to.
def map_IO_to_wire(io_dict, port_name, port_size, port_bits, wire_name):
    if not port_bits:
        assert port_name not in io_dict, f"{iob_colors.FAIL}Peripheral port {port_name} has already been previously mapped!{iob_colors.ENDC}"
        # Did not specify bits, connect all the entire port (all the bits)
        io_dict[port_name] = wire_name
    else:
        # Initialize array with port_size, all bits with 'None' value (not mapped)
        if port_name not in io_dict: io_dict[port_name] = [None for n in range(int(port_size))]
        # Map the selected bits to the corresponding wire bits
        # Each element in the bit list of this port will be a tuple containign the name of the wire to connect to and the bit of that wire.
        for wire_bit, bit in enumerate(port_bits):
            assert not io_dict[port_name][bit], f"{iob_colors.FAIL}Peripheral port {port_name} bit {bit} has already been previously mapped!{iob_colors.ENDC}"
            io_dict[port_name][bit] = (wire_name, wire_bit)

# Update tester configuration based on module_parameters
# python_module: Tester python module
def update_tester_conf( python_module ):
    blocks = python_module.blocks
    module_parameters = python_module.module_parameters
    confs = python_module.confs
    submodules = python_module.submodules

    #Add extra 'headers', 'modules' to corresponding lists if they exist (hw_setup, sw_setup, ...)
    if 'extra_submodules' in module_parameters.keys(): 
        for setup_type in ['hw_setup','sw_setup','sim_setup','fpga_setup']:
            if setup_type in module_parameters['extra_submodules'].keys():
                # Ensure tester has lists for that setup_type
                if setup_type not in submodules.keys():
                    submodules[setup_type] = {'headers':[],'modules':[]}
                submodules[setup_type]['headers']+=module_parameters['extra_submodules'][setup_type]['headers']
                submodules[setup_type]['modules']+=module_parameters['extra_submodules'][setup_type]['modules']

    #Override Tester confs if any are given in the 'confs' dictionary of the 'module_parameters' dictionary
    if 'confs' in module_parameters.keys(): 
        for entry in module_parameters['confs']:
            #If entry exists in confs, then update it
            for idx, entry2 in enumerate(confs):
                if entry['name'] == entry2['name']:
                    confs[idx]=entry
                    break
            else:
                #Did not find entry, so append it
                confs.append(entry)

    #Create default submodule directories
    set_default_submodule_dirs(python_module)
    #Update submodule directories of Tester with new peripherals directories
    submodules['dirs'].update(module_parameters['extra_peripherals_dirs'])

    #Add extra peripherals to tester list (by updating original list)
    tester_peripherals_list=next(i['blocks'] for i in blocks if i['name'] == 'peripherals')
    for peripheral in module_parameters['extra_peripherals']:
        # Allow extra peripherals with the same name to override default peripherals
        for default_peripheral in tester_peripherals_list:
            if peripheral['name'] == default_peripheral['name']:
                default_peripheral = peripheral
                break # Skip appending peripheral
        else: #this is a new peripheral since it did not update a default (existing) peripheral
            tester_peripherals_list.append(peripheral)


# Setup a Tester 
# module_parameters is a dictionary that contains the following elements:
#    - extra_peripherals: list of peripherals to append to the 'peripherals' table in the 'blocks' list of the Tester
#    - extra_peripheral_dirs: dictionary with directories of each extra peripheral
#    - peripheral_portmap: Dictionary where each key-value pair is a Mapping between two signals. Example
#                     { {'corename':'UART1', 'if_name':'rs232', 'port':'', 'bits':[]}:{'corename':'UUT', 'if_name':'UART0', 'port':'', 'bits':[]} }
#    - confs: Optional dictionary with extra macros/parameters or with overrides for existing ones
def setup_tester( python_module ):
    blocks = python_module.blocks
    ios = python_module.ios
    module_parameters = python_module.module_parameters
    confs = python_module.confs
    submodules = python_module.submodules

    tester_peripherals_list=next(i['blocks'] for i in blocks if i['name'] == 'peripherals')

    # Add 'IO" attribute to every peripheral of tester
    for peripheral in tester_peripherals_list:
        peripheral['IO']={}

    # List of peripheral interconnection wires
    peripheral_wires = []

    #Handle peripheral portmap
    for map_idx, mapping in enumerate(module_parameters['peripheral_portmap']):
        # List to store both items in this mamping
        mapping_items = [None, None]
        # Get tester block of peripheral in mapping[0]
        if mapping[0]['corename']: mapping_items[0]=next(i for i in tester_peripherals_list if i['name'] == mapping[0]['corename'])

        # Get tester block of peripheral in mapping[1]
        if mapping[1]['corename']: mapping_items[1]=next(i for i in tester_peripherals_list if i['name'] == mapping[1]['corename'])

        #Make sure we are not mapping two external interfaces
        assert mapping_items != [None, None], f"{iob_colors.FAIL}{map_idx} Cannot map between two external interfaces!{iob_colors.ENDC}"

        # Store index if any of the entries is the external interface
        # Store -1 if we are not mapping to external interface
        mapping_external_interface = mapping_items.index(None) if None in mapping_items else -1

        # List of tester IOs from ports of this mapping
        tester_mapping_ios=[]
        # Add peripherals table to ios of tester
        ios.append({'name': f"portmap_{map_idx}", 'descr':f"IOs for peripherals based on portmap index {map_idx}", 'ports': tester_mapping_ios, 'ios_table_prefix':True})

        # Import module of one of the given core types (to access its IO)
        module = import_setup(submodules['dirs'][mapping_items[0]['type']])
        set_default_submodule_dirs(module)
        iob_soc_peripheral_setup(module)

        #Get ports of configured interface
        interface_table = next((i for i in module.ios if i['name'] == mapping[0]['if_name']), None) 
        assert interface_table, f"{iob_colors.FAIL}Interface {mapping[0]['if_name']} of {mapping[0]['corename']} not found!{iob_colors.ENDC}"
        interface_ports=get_table_ports(interface_table)

        #If mapping_items[1] is not external interface
        if mapping_external_interface!=1: 
            # Import module of one of the given core types (to access its IO)
            module2 = import_setup(submodules['dirs'][mapping_items[1]['type']])
            #Get ports of configured interface
            interface_table = next((i for i in module2.ios if i['name'] == mapping[1]['if_name']), None) 
            assert interface_table, f"{iob_colors.FAIL}Interface {mapping[1]['if_name']} of {mapping[1]['corename']} not found!{iob_colors.ENDC}"
            interface_ports2=get_table_ports(interface_table)

        # Check if should insert one port or every port in the interface
        if not mapping[0]['port']:
            # Mapping configuration did not specify a port, therefore insert all signals from interface and auto-connect them
            #NOTE: currently mapping[1]['if_name'] is always assumed to be equal to mapping[0]['if_name']

            # Get mapping for this interface
            if_mapping = get_interface_mapping(mapping[0]['if_name'])

            # For every port: create wires and connect IO
            for port in interface_ports:
                if mapping_external_interface<0:
                    # Not mapped to external interface
                    # Create peripheral wire name based on mapping.
                    wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{port['name']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{if_mapping[port['name']]}"
                    peripheral_wires.append({'name':wire_name, 'n_bits':port['n_bits']})
                else:
                    #Mapped to external interface
                    #Add tester IO for this port
                    tester_mapping_ios.append(add_prefix_to_parameters_in_port(port,module.confs,mapping[0]['corename']+"_"))
                    #Wire name generated the same way as ios inserted in verilog
                    wire_name = f"portmap_{map_idx}_{port['name']}"

                #Insert mapping between IO and wire for mapping[0] (if its not external interface)
                if mapping_external_interface!=0: map_IO_to_wire(mapping_items[0]['IO'], port['name'], 0, [], wire_name)

                #Insert mapping between IO and wire for mapping[1] (if its not external interface)
                if mapping_external_interface!=1: map_IO_to_wire(mapping_items[1]['IO'], if_mapping[port['name']], 0, [], wire_name)

        else:
            # Mapping configuration specified a port, therefore only insert singal for that port

            port = next((i for i in interface_ports if i['name'] == mapping[0]['port']),None)
            assert port, f"{iob_colors.FAIL}Port {mapping[0]['port']} of {mapping[0]['if_name']} for {mapping[0]['corename']} not found!{iob_colors.ENDC}"
            if mapping_external_interface!=1: 
                port2 = next((i for i in interface_ports2 if i['name'] == mapping[1]['port']), None)
                assert port2, f"{iob_colors.FAIL}Port {mapping[1]['port']} of {mapping[1]['if_name']} for {mapping[1]['corename']} not found!{iob_colors.ENDC}"
            #Get number of bits for this wire. If 'bits' was not specified, use the same size as the port of the peripheral
            if not mapping[0]['bits']:
                # Mapping did not specify bits, use the same size as the port (will map all bits of the port)
                n_bits = port['n_bits']
            else:
                # Mapping specified bits, the width will be the total amount of bits specified
                n_bits = len(mapping[0]['bits'])
                # Insert wire of the ports into the peripherals_wires list of the tester

            if mapping_external_interface<0:
                # Not mapped to external interface
                # Create wire name based on mapping
                wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{mapping[0]['port']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{mapping[1]['port']}"
                peripheral_wires.append({'name':wire_name, 'n_bits':n_bits})
            else:
                #Mapped to external interface
                #Add tester IO for this port
                tester_mapping_ios.append(add_prefix_to_parameters_in_port({'name':port['name'], 'type':port['type'], 'n_bits':n_bits, 'descr':port['descr']},
                                                                           module.confs,mapping[0]['corename']+"_"))
                #Wire name generated the same way as ios inserted in verilog
                wire_name = f"portmap_{map_idx}_{port['name']}"

            #Insert mapping between IO and wire for mapping[0] (if its not external interface)
            if mapping_external_interface!=0: map_IO_to_wire(mapping_items[0]['IO'], mapping[0]['port'], eval_param_expression_from_config(port['n_bits'],module.confs,'max'), mapping[0]['bits'], wire_name)

            #Insert mapping between IO and wire for mapping[1] (if its not external interface)
            if mapping_external_interface!=1: map_IO_to_wire(mapping_items[1]['IO'], mapping[1]['port'], eval_param_expression_from_config(port2['n_bits'],module2.confs,'max'), mapping[1]['bits'], wire_name)

    # Call setup function for the tester
    setup_iob_soc(python_module, peripheral_ios=False, internal_wires=peripheral_wires)

    #Check if setup with INIT_MEM and USE_EXTMEM (check if macro exists)
    extmem_macro = next((i for i in confs if i['name']=='USE_EXTMEM'), False)
    initmem_macro = next((i for i in confs if i['name']=='INIT_MEM'), False)
    if extmem_macro and extmem_macro['val'] and \
       initmem_macro and initmem_macro['val']:
        # Append init_ddr_contents.hex target to sw_build.mk
        with open(f"{python_module.build_dir}/software/sw_build.mk", 'a') as file:
            file.write("\n#Auto-generated target to create init_ddr_contents.hex\n")
            file.write("HEX+=init_ddr_contents.hex\n")
            file.write("# init file for external mem with firmware of both systems\n")
            file.write("init_ddr_contents.hex: iob_soc_tester_firmware.hex\n")

            sut_firmware_name = module_parameters['sut_fw_name'].replace('.c','')+'.hex' if 'sut_fw_name' in module_parameters.keys() else '-'
            file.write(f"	../../scripts/joinHexFiles.py {sut_firmware_name} $^ $(shell cat ../../build_defines.txt | sed -n 's/.*DDR_ADDR_W=\([^ ]*\).*/\\1/p') > $@\n")
        # Copy joinHexFiles.py from LIB
        build_srcs.copy_files( "submodules/LIB", f"{python_module.build_dir}/scripts", [ "joinHexFiles.py" ], '*.py' )
