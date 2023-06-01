#!/usr/bin/env python3
import sys
import os

from iob_soc_create_periphs_tmp import create_periphs_tmp
from iob_soc_create_system import create_systemv
from iob_soc_create_testbench import create_system_testbench
from iob_soc_create_sim_wrapper import create_sim_wrapper
from submodule_utils import import_setup, get_table_ports, add_prefix_to_parameters_in_port, eval_param_expression_from_config, iob_soc_peripheral_setup, set_default_submodule_dirs, reserved_signals
from ios import get_interface_mapping
import setup
import iob_colors
import shutil
from pathlib import Path
import fnmatch
import if_gen
import verilog_tools
import build_srcs

# Creates a function that:
#   - Renames any 'iob_soc' string inside de src file and in its name, to the given 'system_name' string argument.
def copy_with_rename(system_name):
    def copy_func(src, dst):
        dst = os.path.join(
                os.path.dirname(dst),
                os.path.basename(dst.replace('iob_soc',system_name).replace('IOB_SOC',system_name.upper()))
                )
        #print(f"### DEBUG: {src} {dst}")
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


######################################
# Specialized IOb-SoC setup functions.
######################################

def iob_soc_sw_setup(python_module, exclude_files=[]):
    peripherals_list = python_module.peripherals
    confs = python_module.confs
    build_dir = python_module.build_dir
    name = python_module.name

    # Build periphs_tmp.h
    if peripherals_list: create_periphs_tmp(next(i['val'] for i in confs if i['name'] == 'P'),
                                   peripherals_list, f"{build_dir}/software/{name}_periphs.h")

    # Copy files common to all iob-soc based systems
    copy_common_files(build_dir, name, "software", exclude_files)

def iob_soc_sim_setup(python_module, exclude_files=[]):
    peripherals_list = python_module.peripherals
    confs = python_module.confs
    build_dir = python_module.build_dir
    name = python_module.name
    #print(f"DEBUG {name} sim func()", file=sys.stderr)
    copy_common_files(build_dir, name, "hardware/simulation", exclude_files)
    # Try to build simulation <system_name>_tb.v if template <system_name>_tb.vt is available and iob_soc_tb.vt not in exclude list
    if not fnmatch.filter(exclude_files,'iob_soc_tb.vt'):
        create_system_testbench(os.path.join(build_dir,f'hardware/simulation/src/{name}_tb.vt'), name, peripherals_list, os.path.join(build_dir,f'hardware/simulation/src/{name}_tb.v'))
    # Try to build simulation <system_name>_sim_wrapper.v if template <system_name>_sim_wrapper.vt is available and iob_soc_sim_wrapper.vt not in exclude list
    if not fnmatch.filter(exclude_files,'iob_soc_sim_wrapper.vt'):
        create_sim_wrapper(os.path.join(build_dir,f'hardware/simulation/src/{name}_sim_wrapper.vt'), name, peripherals_list, python_module.ios, confs, os.path.join(build_dir,f'hardware/simulation/src/{name}_sim_wrapper.v'))

def iob_soc_fpga_setup(python_module, exclude_files=[]):
    copy_common_files(python_module.build_dir, python_module.name, "hardware/fpga", exclude_files)

def iob_soc_doc_setup(python_module, exclude_files=[]):
    # Copy and rename files, except figures (we don't want to process figures)
    copy_common_files(python_module.build_dir, python_module.name, "document/", ['*.odg']+exclude_files)
    # Copy .odg figures without processing
    shutil.copytree(os.path.join(os.path.dirname(__file__),'..', "document/"),
            os.path.join(python_module.build_dir,"document/"), dirs_exist_ok=True,
            ignore=lambda directory, contents: [f for f in contents if os.path.splitext(f)[1] not in ['.odg', '']])

def iob_soc_hw_setup(python_module, exclude_files=[]):
    peripherals_list = python_module.peripherals
    build_dir = python_module.build_dir
    name = python_module.name

    copy_common_files(build_dir, name, "hardware/src", exclude_files)
    # Try to build <system_name>.v if template <system_name>.vt is available and iob_soc.vt not in exclude list
    # Note, it checks for iob_soc.vt in exclude files, instead of <system_name>.vt, to be consistent with the copy_common_files() function.
    #[If a user does not want to build <system_name>.v from the template, then he also does not want to copy the template from the iob-soc]
    if not fnmatch.filter(exclude_files,'iob_soc.vt'):
        create_systemv(os.path.join(build_dir,f'hardware/src/{name}.vt'), name, peripherals_list, os.path.join(build_dir,f'hardware/src/{name}.v'), internal_wires=python_module.internal_wires)

    # Delete verilog templates from build dir
    for p in Path(build_dir).rglob("*.vt"):
        p.unlink()

######################################

# Run specialized iob-soc setup sequence
def setup_iob_soc(python_module):
    confs = python_module.confs
    build_dir = python_module.build_dir
    name = python_module.name

    # Replace IOb-SoC name in values of confs
    for conf in confs:
        if type(conf['val']) == str:
            conf['val'] = conf['val'].replace('iob_soc',name).replace('IOB_SOC',name.upper())

    set_default_submodule_dirs(python_module)

    # Setup peripherals
    iob_soc_peripheral_setup(python_module)
    python_module.internal_wires = peripheral_portmap(python_module)

    # Call setup function for iob_soc
    setup.setup(python_module, disable_file_copy=True)

    # Run iob-soc specialized setup sequence
    iob_soc_sim_setup(python_module)
    iob_soc_fpga_setup(python_module)
    iob_soc_sw_setup(python_module)
    iob_soc_hw_setup(python_module)
    iob_soc_doc_setup(python_module)

    if setup.is_top_module(python_module):
        verilog_tools.replace_includes([build_dir + "/hardware"])

    # Check if was setup with INIT_MEM and USE_EXTMEM (check if macro exists)
    extmem_macro = next((i for i in confs if i['name']=='USE_EXTMEM'), False)
    initmem_macro = next((i for i in confs if i['name']=='INIT_MEM'), False)
    mem_add_w_parameter = next((i for i in confs if i['name']=='MEM_ADDR_W'), False)
    if extmem_macro and extmem_macro['val'] and \
       initmem_macro and initmem_macro['val']:
        # Append init_ddr_contents.hex target to sw_build.mk
        with open(f"{build_dir}/software/sw_build.mk", 'a') as file:
            file.write("\n#Auto-generated target to create init_ddr_contents.hex\n")
            file.write("HEX+=init_ddr_contents.hex\n")
            file.write("# init file for external mem with firmware of both systems\n")
            file.write(f"init_ddr_contents.hex: {name}_firmware.hex\n")

            sut_firmware_name = python_module.sut_fw_name.replace('.c','.hex') if 'sut_fw_name' in python_module.__dict__.keys() else '-'
            file.write(f"	../../scripts/joinHexFiles.py {sut_firmware_name} $^ {mem_add_w_parameter['val']} > $@\n")
        # Copy joinHexFiles.py from LIB
        build_srcs.copy_files( "submodules/LIB", f"{build_dir}/scripts", [ "joinHexFiles.py" ], '*.py' )





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
def peripheral_portmap(python_module):
    peripherals_list = python_module.peripherals
    ios = python_module.ios

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

        # The 'external' keyword in corename is reserved to map signals to the external interface, causing it to create a system IO port
        # The 'internal' keyword in corename is reserved to map signals to the internal interface, causing it to create an internal system wire

        # Get system block of peripheral in mapping[0]
        if mapping[0]['corename'] not in ['external','internal']:
            assert any(i for i in peripherals_list if i['name'] == mapping[0]['corename']), f"{iob_colors.FAIL}{map_idx} Peripheral instance named '{mapping[0]['corename']}' not found!{iob_colors.ENDC}"
            mapping_items[0]=next(i for i in peripherals_list if i['name'] == mapping[0]['corename'])

        # Get system block of peripheral in mapping[1]
        if mapping[1]['corename'] not in ['external','internal']:
            assert any(i for i in peripherals_list if i['name'] == mapping[1]['corename']), f"{iob_colors.FAIL}{map_idx} Peripheral instance named '{mapping[1]['corename']}' not found!{iob_colors.ENDC}"
            mapping_items[1]=next(i for i in peripherals_list if i['name'] == mapping[1]['corename'])

        #Make sure we are not mapping two external or internal interfaces
        assert mapping_items != [None, None], f"{iob_colors.FAIL}{map_idx} Cannot map between two internal/external interfaces!{iob_colors.ENDC}"

        # By default, store -1 if we are not mapping to external/internal interface
        mapping_external_interface = -1
        mapping_internal_interface = -1

        # Store index if any of the entries is the external/internal interface
        if None in mapping_items:
            if mapping[mapping_items.index(None)]['corename'] == 'external':
                mapping_external_interface = mapping_items.index(None)
            else:
                mapping_internal_interface = mapping_items.index(None)

        # Create interface for this portmap if it is connected to external interface
        if mapping_external_interface>-1:
            # List of system IOs from ports of this mapping
            mapping_ios=[]
            # Add peripherals table to ios of system
            assert mapping[0]['if_name'] if mapping_external_interface==0 else mapping[1]['if_name'], f"{iob_colors.FAIL}Portmap index {map_idx} needs an interface name for the 'external' corename!{iob_colors.ENDC}"
            ios.append({'name': mapping[0]['if_name'] if mapping_external_interface==0 else mapping[1]['if_name'], 'descr':f"IOs for peripherals based on portmap index {map_idx}", 'ports': mapping_ios, 'ios_table_prefix':True})

        # Import module of one of the given core types (to access its IO)
        module = import_setup(submodules['dirs'][mapping_items[0]['type']])
        #print(f"DEBUG: {module.name} {module.ios}", file=sys.stderr)

        #Get ports of configured interface
        interface_table = next((i for i in module.ios if i['name'] == mapping[0]['if_name']), None) 
        assert interface_table, f"{iob_colors.FAIL}Interface {mapping[0]['if_name']} of {mapping[0]['corename']} not found!{iob_colors.ENDC}"
        interface_ports=get_table_ports(interface_table)

        #If mapping_items[1] is not internal/external interface
        if mapping_internal_interface!=1 and mapping_external_interface!=1: 
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
                if mapping_internal_interface<0 and mapping_external_interface<0:
                    # Not mapped to internal/external interface
                    # Create peripheral wire name based on mapping.
                    wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{port['name']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{if_mapping[port['name']]}"
                    peripheral_wires.append({'name':wire_name, 'n_bits':add_prefix_to_parameters_in_port(port,module.confs,mapping[0]['corename']+"_")['n_bits']})
                elif mapping_internal_interface>-1:
                    #Mapped to internal interface
                    #Wire name generated the same way as ios inserted in verilog 
                    if mapping_internal_interface==0:
                        wire_name = f"{mapping[0]['if_name']+'_'}{port['name']}"
                    else:
                        wire_name = f"{mapping[1]['if_name']+'_'}{port['name']}"
                    #Add internal system wire for this port
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

                #Insert mapping between IO and wire for mapping[0] (if its not internal/external interface)
                if mapping_internal_interface!=0 and mapping_external_interface!=0:
                    map_IO_to_wire(mapping_items[0]['IO'], port['name'], 0, [], wire_name)

                #Insert mapping between IO and wire for mapping[1] (if its not internal/external interface)
                if mapping_internal_interface!=1 and mapping_external_interface!=1:
                    map_IO_to_wire(mapping_items[1]['IO'], if_mapping[port['name']], 0, [], wire_name)

        else:
            # Mapping configuration specified a port, therefore only insert singal for that port

            port = next((i for i in interface_ports if i['name'] == mapping[0]['port']),None)
            assert port, f"{iob_colors.FAIL}Port {mapping[0]['port']} of {mapping[0]['if_name']} for {mapping[0]['corename']} not found!{iob_colors.ENDC}"

            if mapping_internal_interface!=1 and mapping_external_interface!=1: 
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

            if mapping_internal_interface<0 and mapping_external_interface<0:
                # Not mapped to external interface
                # Create wire name based on mapping
                wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{mapping[0]['port']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{mapping[1]['port']}"
                peripheral_wires.append({'name':wire_name, 'n_bits':add_prefix_to_parameters_in_port(port,module.confs,mapping[0]['corename']+"_")['n_bits']})
            elif mapping_internal_interface>-1:
                #Mapped to internal interface
                #Wire name generated the same way as ios inserted in verilog 
                if mapping_internal_interface==0:
                    wire_name = f"{mapping[0]['if_name']+'_'}{port['name']}"
                else:
                    wire_name = f"{mapping[1]['if_name']+'_'}{port['name']}"
                #Add internal system wire for this port
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

            #Insert mapping between IO and wire for mapping[0] (if its not internal/external interface)
            if mapping_internal_interface!=0 and mapping_external_interface!=0:
                map_IO_to_wire(mapping_items[0]['IO'], mapping[0]['port'], eval_param_expression_from_config(port['n_bits'],module.confs,'max'), mapping[0]['bits'], wire_name)

            #Insert mapping between IO and wire for mapping[1] (if its not internal/external interface)
            if mapping_internal_interface!=1 and mapping_external_interface!=1:
                map_IO_to_wire(mapping_items[1]['IO'], mapping[1]['port'], eval_param_expression_from_config(port2['n_bits'],module2.confs,'max'), mapping[1]['bits'], wire_name)

    # Merge interfaces with the same name into a single interface
    interface_names = []
    for interface in ios:
        if interface['name'] not in interface_names:
            interface_names.append(interface['name'])
    new_ios = []
    for interface_name in interface_names:
        first_interface_instance = None
        for interface in ios:
            if interface['name'] == interface_name:
                if not first_interface_instance:
                    first_interface_instance = interface
                    new_ios.append(interface)
                else:
                    first_interface_instance['ports']+=interface['ports']
    python_module.ios=new_ios
    #print(f"### Debug python_module.ios: {python_module.ios}", file=sys.stderr)

    return peripheral_wires


