#!/usr/bin/env python3
import sys
import os

sys.path.insert(0, os.getcwd()+'/submodules/LIB/scripts')

import periphs_tmp
import createSystem
import createTestbench
import sim_wrapper
from submodule_utils import import_setup, get_table_ports, add_prefix_to_parameters_in_port, eval_param_expression_from_config, iob_soc_peripheral_setup, set_default_submodule_dirs, get_peripherals_list, reserved_signals
from ios import get_interface_mapping
from setup import setup
import iob_colors
import shutil
from pathlib import Path
import fnmatch
import if_gen

# Creates a function that:
#   - Only copies a file if destination does not exist
#   - Renames any 'iob_soc' string inside de src file and in its name, to the given 'system_name' string argument.
def copy_with_rename(system_name):
    def copy_func(src, dst):
        dst = os.path.join(
                os.path.dirname(dst),
                os.path.basename(dst.replace('iob_soc',system_name).replace('IOB_SOC',system_name.upper()))
                )
        #print(f"### DEBUG: {src} {dst}")
        if not os.path.isfile(dst):
            with open(src, 'r') as file:
                lines = file.readlines()
            for idx in range(len(lines)): 
                lines[idx]=lines[idx].replace('iob_soc',system_name).replace('IOB_SOC',system_name.upper())
            with open(dst, 'w') as file:
                file.writelines(lines)

    return copy_func

# Copy files common to all iob-soc based systems from the iob-soc directory
# Files containing 'iob_soc' in the name or inside them will be renamed to the new 'system_name'.
# build_dir: path to the build directory
# system_name: Name of the iob-soc based system that is being built
# directory: path to the directory being copied in relation to the root directory.
# exclude_file_list: list of strings, each string representing an ignore pattern for the source files.
#                    For example, using the ignore pattern '*.v' would prevent from copying every Verilog source file.
#                    Note, if the new system name is 'my_system', we would still use the 'iob_soc' system name in the ignore patterns.
#                    For example, if we dont want it to generate the 'my_system_firmware.c' based on the 'iob_soc_firmware.c', then we should add 'iob_soc_firmware.c' to the ignore list.
def copy_common_files(build_dir, system_name, directory, exclude_file_list):
    # Copy hardware
    shutil.copytree(os.path.join(os.path.dirname(__file__),'..', directory), os.path.join(build_dir,directory), dirs_exist_ok=True, copy_function=copy_with_rename(system_name), ignore=shutil.ignore_patterns(*exclude_file_list))



# This function should be called fromt the *_setup.py module of the iob-soc based system being constructed.
# This function adds function to the 'modules' lists that will generate and copy common iob-soc files from this repository.
# python_module: *_setup.py module of the iob-soc based system being setup.
# filter_modules: Optional argument. List with the specific iob-soc modules that should be setup. Default is all modules.
# exclude_files: Optional argument. List of files to exclude when copying from the iob-soc directory
#                                   This list accepts ignore patterns, for example with '*.v' it will not copy any verilog sources from the iob-soc directory.
#                                   The ignore file names should have the name of the source file (of the iob-soc directory) and not the resulting file name after copy (the resulting file name may have the name of the system instead of 'iob-soc').
#                                   If the verilog template '*.vt' files are ignored, it will also prevent this function from generating the verilog files based on those templates.
def add_iob_soc_modules( python_module, filter_modules=['hw_setup','sim_setup','fpga_setup','sw_setup'], exclude_files=[]):
    confs = python_module.confs
    build_dir = python_module.build_dir
    submodules = python_module.submodules
    name = python_module.name
    ios = python_module.ios

    set_default_submodule_dirs(python_module)

    # Only run iob-soc setup once (this function may execute multiple times)
    if 'ran_iob_soc_setup' not in vars(python_module):
        peripherals_list = iob_soc_peripheral_setup(python_module)
        python_module.internal_wires = peripheral_portmap(python_module, peripherals_list)
        python_module.ran_iob_soc_setup = True
    else:
        # Get peripherals list from 'peripherals' table in blocks list
        peripherals_list = get_peripherals_list(python_module.blocks)

    ################# Setup functions that will run right after setup of build dir #################
    # These functions will be inserted in the begining of the respective 'modules' list.
    # They will, therefore, run before copying files from any of the other submodules,
    # but after copying the module's files.

    def iob_soc_sw_setup():
        #print(f"DEBUG {name} sw func()", file=sys.stderr)
        # Build periphs_tmp.h
        if peripherals_list: periphs_tmp.create_periphs_tmp(next(i['val'] for i in confs if i['name'] == 'P'),
                                       peripherals_list, f"{build_dir}/software/{name}_periphs.h")
        # Copy files common to all iob-soc based systems
        copy_common_files(build_dir, name, "software", exclude_files)

    def iob_soc_sim_setup():
        #print(f"DEBUG {name} sim func()", file=sys.stderr)
        copy_common_files(build_dir, name, "hardware/simulation", exclude_files)
        # Try to build simulation <system_name>_tb.v if template <system_name>_tb.vt is available and iob_soc_tb.vt not in exclude list
        if not fnmatch.filter(exclude_files,'iob_soc_tb.vt'):
            createTestbench.create_system_testbench(os.path.join(build_dir,f'hardware/simulation/src/{name}_tb.vt'), submodules['dirs'], name, peripherals_list, os.path.join(build_dir,f'hardware/simulation/src/{name}_tb.v'))
        # Try to build simulation <system_name>_sim_wrapper.v if template <system_name>_sim_wrapper.vt is available and iob_soc_sim_wrapper.vt not in exclude list
        if not fnmatch.filter(exclude_files,'iob_soc_sim_wrapper.vt'):
            sim_wrapper.create_sim_wrapper(os.path.join(build_dir,f'hardware/simulation/src/{name}_sim_wrapper.vt'), submodules['dirs'], name, peripherals_list, ios, confs, os.path.join(build_dir,f'hardware/simulation/src/{name}_sim_wrapper.v'))

    def iob_soc_fpga_setup():
        copy_common_files(build_dir, name, "hardware/fpga", exclude_files)

    def iob_soc_hw_setup():
        #print(f"DEBUG {name} hw func()", file=sys.stderr)

        copy_common_files(build_dir, name, "hardware/src", exclude_files)
        # Try to build <system_name>.v if template <system_name>.vt is available and iob_soc.vt not in exclude list
        # Note, it checks for iob_soc.vt in exclude files, instead of <system_name>.vt, to be consistent with the copy_common_files() function.
        #[If a user does not want to build <system_name>.v from the template, then he also does not want to copy the template from the iob-soc]
        if not fnmatch.filter(exclude_files,'iob_soc.vt'):
            createSystem.create_systemv(os.path.join(build_dir,f'hardware/src/{name}.vt'), submodules['dirs'], name, peripherals_list, os.path.join(build_dir,f'hardware/src/{name}.v'), internal_wires=python_module.internal_wires)

        # Delete verilog templates from build dir
        for p in Path(build_dir).rglob("*.vt"):
            p.unlink()
    ################################################################################################

    # Make sure lists exist
    for i in ['hw_setup','sim_setup','fpga_setup','sw_setup']:
        if i not in submodules: submodules[i] = { 'headers' : [], 'modules': [] }

    # Add iob-soc functions to begining of 'modules' lists.
    for i, func in [('hw_setup',iob_soc_hw_setup),('sim_setup',iob_soc_sim_setup),\
                   ('fpga_setup',iob_soc_fpga_setup),('sw_setup',iob_soc_sw_setup)]:
        # Only add module if it was not added before and only if it is filtered
        if (not 'imported_iob_soc_'+i in vars(python_module) or not vars(python_module)['imported_iob_soc_'+i]) and\
        i in filter_modules:
            submodules[i]['modules'].insert(0,func)
            # Store that we have already added this iob_soc module in this system's python module
            vars(python_module)['imported_iob_soc_'+i] = True
            #print(f"DEBUG {name} {func}", file=sys.stderr)
            #print(f"##########DEBUG {name} {i} {submodules[i]['modules']}", file=sys.stderr)


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
            assert bit < len(io_dict[port_name]), f"{iob_colors.FAIL}Peripheral port {port_name} does not have bit {bit}!{iob_colors.ENDC}"
            assert not io_dict[port_name][bit], f"{iob_colors.FAIL}Peripheral port {port_name} bit {bit} has already been previously mapped!{iob_colors.ENDC}"
            io_dict[port_name][bit] = (wire_name, wire_bit)

# Function to handle portmap connections between: peripherals, internal, and external system interfaces.
def peripheral_portmap(python_module, peripherals_list):
    ios = python_module.ios
    submodules = python_module.submodules

    # Generate an empty list if peripheral_portmap does not exist
    if not 'peripheral_portmap' in vars(python_module):
        python_module.peripheral_portmap = []

    peripheral_portmap = python_module.peripheral_portmap

    # Add default portmap for peripherals not configured in peripheral_portmap
    for peripheral in peripherals_list:
        if peripheral['name'] not in [i[0]['corename'] for i in peripheral_portmap or []]+[i[1]['corename'] for i in peripheral_portmap or []]:
            # Import module of one of the given core types (to access its IO)
            module = import_setup(submodules['dirs'][peripheral['type']])
            # Map all ports of all interfaces
            for interface in module.ios:
                if interface['ports']:
                    for port in interface['ports']:
                        if port['name'] not in reserved_signals:
                            # Map port to the external system interface
                            peripheral_portmap.append(({'corename':peripheral['name'], 'if_name':interface['name'], 'port':port['name'], 'bits':[]}, {'corename':'external', 'if_name':peripheral['name'], 'port':'', 'bits':[]}))
                else: 
                    if interface['name'] not in if_gen.interfaces:
                        # Map entire interface to the external system interface
                        peripheral_portmap.append(({'corename':peripheral['name'], 'if_name':interface['name'], 'port':'', 'bits':[]}, {'corename':'external', 'if_name':peripheral['name'], 'port':'', 'bits':[]}))

    # Add 'IO" attribute to every peripheral
    for peripheral in peripherals_list:
        peripheral['IO']={}

    # List of peripheral interconnection wires
    peripheral_wires = []

    #Handle peripheral portmap
    for map_idx, mapping in enumerate(peripheral_portmap):
        # List to store both items in this mamping
        mapping_items = [None, None]
        assert mapping[0]['corename'] and mapping[1]['corename'], f"{iob_colors.FAIL}Mapping 'corename' can not be empty on portmap index {map_idx}!{iob_colors.ENDC}"
        # The 'external' keyword in corename is reserved to map signals to the external interface (causes it to create a system port)
        # Get system block of peripheral in mapping[0]
        if mapping[0]['corename']!='external': mapping_items[0]=next(i for i in peripherals_list if i['name'] == mapping[0]['corename'])

        # Get system block of peripheral in mapping[1]
        if mapping[1]['corename']!='external': mapping_items[1]=next(i for i in peripherals_list if i['name'] == mapping[1]['corename'])

        #Make sure we are not mapping two external interfaces
        assert mapping_items != [None, None], f"{iob_colors.FAIL}{map_idx} Cannot map between two external interfaces!{iob_colors.ENDC}"

        # Store index if any of the entries is the external interface
        # Store -1 if we are not mapping to external interface
        mapping_external_interface = mapping_items.index(None) if None in mapping_items else -1

        # Create interface for this portmap if it is connected to external interface
        if mapping_external_interface>-1:
            # List of system IOs from ports of this mapping
            mapping_ios=[]
            # Add peripherals table to ios of system
            assert mapping[0]['if_name'] if mapping_external_interface==0 else mapping[1]['if_name'], f"{iob_colors.FAIL}Portmap index {map_idx} needs an interface name for the 'external' corename!{iob_colors.ENDC}"
            ios.append({'name': mapping[0]['if_name'] if mapping_external_interface==0 else mapping[1]['if_name'], 'descr':f"IOs for peripherals based on portmap index {map_idx}", 'ports': mapping_ios, 'ios_table_prefix':True})

        # Import module of one of the given core types (to access its IO)
        module = import_setup(submodules['dirs'][mapping_items[0]['type']])

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
                    peripheral_wires.append({'name':wire_name, 'n_bits':add_prefix_to_parameters_in_port(port,module.confs,mapping[0]['corename']+"_")['n_bits']})
                else:
                    #Mapped to external interface
                    #Add system IO for this port
                    mapping_ios.append(add_prefix_to_parameters_in_port(port,module.confs,mapping[0]['corename']+"_"))
                    #Wire name generated the same way as ios inserted in verilog 
                    if mapping_external_interface==0:
                        wire_name = f"{mapping[0]['if_name']+'_'}{port['name']}"
                    else:
                        wire_name = f"{mapping[1]['if_name']+'_'}{port['name']}"

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
                # Insert wire of the ports into the peripherals_wires list of the system

            if mapping_external_interface<0:
                # Not mapped to external interface
                # Create wire name based on mapping
                wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{mapping[0]['port']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{mapping[1]['port']}"
                peripheral_wires.append({'name':wire_name, 'n_bits':add_prefix_to_parameters_in_port(port,module.confs,mapping[0]['corename']+"_")['n_bits']})
            else:
                #Mapped to external interface
                #Add system IO for this port
                mapping_ios.append(add_prefix_to_parameters_in_port({'name':port['name'], 'type':port['type'], 'n_bits':n_bits, 'descr':port['descr']},
                                                                           module.confs,mapping[0]['corename']+"_"))
                #Wire name generated the same way as ios inserted in verilog 
                if mapping_external_interface==0:
                    wire_name = f"{mapping[0]['if_name']+'_'}{port['name']}"
                else:
                    wire_name = f"{mapping[1]['if_name']+'_'}{port['name']}"

            #Insert mapping between IO and wire for mapping[0] (if its not external interface)
            if mapping_external_interface!=0: map_IO_to_wire(mapping_items[0]['IO'], mapping[0]['port'], eval_param_expression_from_config(port['n_bits'],module.confs,'max'), mapping[0]['bits'], wire_name)

            #Insert mapping between IO and wire for mapping[1] (if its not external interface)
            if mapping_external_interface!=1: map_IO_to_wire(mapping_items[1]['IO'], mapping[1]['port'], eval_param_expression_from_config(port2['n_bits'],module2.confs,'max'), mapping[1]['bits'], wire_name)

    return peripheral_wires
