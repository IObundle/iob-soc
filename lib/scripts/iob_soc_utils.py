import sys
import os

from iob_soc_peripherals import (
    create_periphs_tmp,
    iob_soc_peripheral_setup,
    reserved_signals,
)

from iob_soc_create_system import create_systemv, get_extmem_bus_size
from iob_soc_create_wrapper_files import create_wrapper_files
from submodule_utils import (
    add_prefix_to_parameters_in_port,
    eval_param_expression_from_config,
    if_gen_interface,
)

import iob_colors
import shutil
import fnmatch
import if_gen
import copy_srcs
from verilog_gen import inplace_change


def find_dict_in_list(list_obj, name):
    """Find an dictionary with a given name in a list of dictionaries"""
    for i in list_obj:
        if i["name"] == name:
            return i
    raise Exception(
        f"{iob_colors.FAIL}Could not find element with name: {name}{iob_colors.ENDC}"
    )


def iob_soc_sw_setup(python_module, exclude_files=[]):
    peripherals_list = python_module.peripherals
    confs = python_module.confs
    build_dir = python_module.build_dir
    name = python_module.name

    # Build periphs_tmp.h
    if peripherals_list:
        create_periphs_tmp(
            python_module.name,
            next(i["val"] for i in confs if i["name"] == "ADDR_W"),
            peripherals_list,
            f"{build_dir}/software/{name}_periphs.h",
        )


def iob_soc_wrapper_setup(python_module, exclude_files=[]):
    confs = python_module.confs
    build_dir = python_module.build_dir
    name = python_module.name
    num_extmem_connections = python_module.num_extmem_connections
    # Try to build wrapper files
    # if not fnmatch.filter(exclude_files,'iob_soc_sim_wrapper.v'):
    create_wrapper_files(
        build_dir, name, python_module.ios, confs, num_extmem_connections
    )

    # Note:
    # The settings below are only used with `USE_EXTMEM=1`.
    # Currently they are always being set up (even with USE_EXTMEM=0) to allow
    # the users to manually add USE_EXTMEM=1 in the build_dir.
    # As we no longer support build-time defines, we may need to change this in the future.

    python_module._setup_submodules(
        [
            # Create extmem wrapper files
            {
                "file_prefix": "ddr4_",
                "interface": "axi",
                "type": "master",
                "wire_prefix": "ddr4_",
                "port_prefix": "ddr4_",
            },
            {
                "file_prefix": f"iob_bus_{num_extmem_connections}_",
                "interface": "axi",
                "type": "master",
                "wire_prefix": "",
                "port_prefix": "",
                "bus_size": num_extmem_connections,
            },
            {
                "file_prefix": f"iob_bus_0_{num_extmem_connections}_",
                "interface": "axi",
                "type": "master",
                "wire_prefix": "",
                "port_prefix": "",
                "bus_start": 0,
                "bus_size": num_extmem_connections,
            },
            {
                "file_prefix": "iob_memory_",
                "interface": "axi",
                "type": "slave",
                "wire_prefix": "memory_",
                "port_prefix": "",
            },
        ]
    )


def iob_soc_doc_setup(python_module, exclude_files=[]):
    # Copy .odg figures without processing
    shutil.copytree(
        os.path.join(os.path.dirname(__file__), "..", "document/"),
        os.path.join(python_module.build_dir, "document/"),
        dirs_exist_ok=True,
        ignore=lambda directory, contents: [
            f for f in contents if os.path.splitext(f)[1] not in [".odg", ""]
        ],
    )


def iob_soc_hw_setup(python_module, exclude_files=[]):
    peripherals_list = python_module.peripherals
    build_dir = python_module.build_dir
    name = python_module.name

    # Try to build <system_name>.v if template <system_name>.v is available and iob_soc.v not in exclude list
    # Note, it checks for iob_soc.v in exclude files, instead of <system_name>.v to be consistent with the copy_common_files() function.
    # [If a user does not want to build <system_name>.v from the template, then he also does not want to copy the template from the iob-soc]
    if not fnmatch.filter(exclude_files, "iob_soc.v"):
        create_systemv(
            build_dir,
            name,
            peripherals_list,
            internal_wires=python_module.internal_wires,
        )


def update_ios_with_extmem_connections(python_module):
    ios = python_module.ios
    peripherals_list = python_module.peripherals

    num_extmem_connections = 1  # By default, one connection for iob-soc's cache
    # Count numer of external memory connections
    for peripheral in peripherals_list:
        for interface in peripheral.module.ios:
            # Check if interface is a standard axi_m_port (for extmem connection)
            if interface["name"] == "axi_m_port":
                num_extmem_connections += 1
                continue
            # Check if interface does not have the standard axi_m_port name,
            # but does contains its standard signals. For example, it may be a
            # bus of axi_m_ports, therefore may have a different name.
            for port in interface["ports"]:
                if port["name"] == "axi_awid_o":
                    num_extmem_connections += get_extmem_bus_size(port["width"])
                    # Break the inner loop...
                    break
            else:
                # Continue if the inner loop wasn't broken.
                continue
            # Inner loop was broken, break the outer.
            break

    python_module.num_extmem_connections = num_extmem_connections

    # Update size of "axi" interface for external memory
    find_dict_in_list(python_module.ios, "axi")[
        "mult"
    ] = python_module.num_extmem_connections


######################################


# Run specialized iob-soc setup sequence
def pre_setup_iob_soc(python_module):
    confs = python_module.confs
    name = python_module.name

    # Replace IOb-SoC name in values of confs
    for conf in confs:
        if type(conf["val"]) == str:
            conf["val"] = (
                conf["val"].replace("iob_soc", name).replace("IOB_SOC", name.upper())
            )

    # Setup peripherals
    iob_soc_peripheral_setup(python_module)
    python_module.internal_wires = peripheral_portmap(python_module)
    update_ios_with_extmem_connections(python_module)


def post_setup_iob_soc(python_module):
    confs = python_module.confs
    build_dir = python_module.build_dir
    name = python_module.name
    num_extmem_connections = python_module.num_extmem_connections

    # Remove `[0+:1]` part select in AXI connections of ext_mem0 in iob_soc.v template
    if num_extmem_connections == 1:
        inplace_change(
            os.path.join(
                python_module.build_dir, "hardware/src", python_module.name + ".v"
            ),
            "[0+:1]",
            "",
        )

    # Run iob-soc specialized setup sequence
    iob_soc_sw_setup(python_module)
    iob_soc_hw_setup(python_module)
    # iob_soc_doc_setup(python_module)

    ### Only run lines below if this system is the top module ###
    if not python_module.is_top_module:
        return

    # FIXME: This function depends on the 'is_top_module' attribute. And since this attribute is only set during `_setup()`, we cant call this function in the `pre_setup_iob_soc()` function.
    #        We also cant call this function here, because it generates and uses verilog snippets, however, the snippets were already replaced by the `_setup()` function.
    #        How can we fix this in branch 'if_gen2'?
    iob_soc_wrapper_setup(python_module)

    # Check if was setup with INIT_MEM and USE_EXTMEM (check if macro exists)
    extmem_macro = bool(
        next((i["val"] for i in confs if i["name"] == "USE_EXTMEM"), False)
    )
    initmem_macro = bool(
        next((i["val"] for i in confs if i["name"] == "INIT_MEM"), False)
    )
    ethernet_macro = bool(
        next((i["val"] for i in confs if i["name"] == "USE_ETHERNET"), False)
    )

    # Set variables in fpga_build.mk
    with open(python_module.build_dir + "/hardware/fpga/fpga_build.mk", "r") as file:
        contents = file.readlines()
    contents.insert(0, "\n")
    # Set N_INTERCONNECT_SLAVES variable
    contents.insert(0, f"N_INTERCONNECT_SLAVES:={num_extmem_connections}\n")
    # Set USE_EXTMEM variable
    contents.insert(0, f"USE_EXTMEM:={int(extmem_macro)}\n")
    # Set INIT_MEM variable
    contents.insert(0, f"INIT_MEM:={int(initmem_macro)}\n")
    if ethernet_macro:
        # Set custom ethernet CONSOLE_CMD
        contents.insert(
            0,
            'CONSOLE_CMD=$(IOB_CONSOLE_PYTHON_ENV) $(PYTHON_DIR)/console_ethernet.py -s /dev/usb-uart -c $(PYTHON_DIR)/console.py -m "$(RMAC_ADDR)"\n',
        )
    contents.insert(0, "#Lines below were auto generated by iob_soc_utils.py\n")
    with open(python_module.build_dir + "/hardware/fpga/fpga_build.mk", "w") as file:
        file.writelines(contents)

    # Set variables in sw_build.mk
    if ethernet_macro:
        with open(python_module.build_dir + "/software/sw_build.mk", "r") as file:
            contents = file.readlines()
        contents.insert(0, "\n")
        # Set custom ethernet CONSOLE_CMD
        contents.insert(
            0,
            'CONSOLE_CMD ?=rm -f soc2cnsl cnsl2soc; $(IOB_CONSOLE_PYTHON_ENV) $(PYTHON_DIR)/console_ethernet.py -L -c $(PYTHON_DIR)/console.py -m "$(RMAC_ADDR)"\n',
        )
        contents.insert(
            0,
            """
#Lines below were auto generated by iob_soc_utils.py
UTARGETS+=iob_eth_rmac.h
EMUL_HDR+=iob_eth_rmac.h
iob_eth_rmac.h:
	echo "#define ETH_RMAC_ADDR 0x$(RMAC_ADDR)" > $@\n
""",
        )
        with open(python_module.build_dir + "/software/sw_build.mk", "w") as file:
            file.writelines(contents)

    scripts = [
        "console.py",
        "board_client.py",
        "makehex.py",
        "hex_split.py",
        "hex_join.py",
    ]

    # Copy scripts to build directory
    copy_srcs.copy_files("./scripts", f"{build_dir}/scripts", scripts)

    # Copy  console_ethernet.py
    if ethernet_macro:
        copy_srcs.copy_files(
            "./scripts", f"{build_dir}/scripts", ["console_ethernet.py"], "*.py"
        )

    mem_add_w_parameter = next((i for i in confs if i["name"] == "MEM_ADDR_W"), False)
    if extmem_macro and initmem_macro:
        # Append init_ddr_contents.hex target to sw_build.mk
        with open(f"{build_dir}/software/sw_build.mk", "a") as file:
            file.write("\n#Auto-generated target to create init_ddr_contents.hex\n")
            file.write("HEX+=init_ddr_contents.hex\n")
            file.write("# init file for external mem with firmware of both systems\n")
            file.write(f"init_ddr_contents.hex: {name}_firmware.hex\n")

            sut_firmware_name = (
                python_module.sut_fw_name.replace(".c", ".hex")
                if "sut_fw_name" in python_module.__dict__.keys()
                else "-"
            )
            file.write(
                f"	../../scripts/hex_join.py $^ {sut_firmware_name} {mem_add_w_parameter['val']} > $@\n"
            )
        # Copy joinHexFiles.py from LIB


# Given the io dictionary of ports, the port name (and size, and optional bit list) and a wire, it will map the selected bits of the port to the given wire.
# io_dict: dictionary where keys represent port names, values are the mappings
# port_name: name of the port to map
# port_size: size the port (if port_bits are not specified, this value is not used)
# port_bits: list of bits of the port that are being mapped to the wire. If list is empty it will map all the bits.
#           The order of bits in this list is important. The bits of the wire will always be filled in incremental order and will match the corresponding bit of the port given on this list following the list order. Example: The list [5,3] will map the port bit 5 to wire bit 0 and port bit 3 to wire bit 1.
# wire_name: name of the wire to connect the bits of the port to.
def map_IO_to_wire(io_dict, port_name, port_size, port_bits, wire_name):
    if not port_bits:
        assert (
            port_name not in io_dict
        ), f"{iob_colors.FAIL}Peripheral port {port_name} has already been previously mapped!{iob_colors.ENDC}"
        # Did not specify bits, connect all the entire port (all the bits)
        io_dict[port_name] = wire_name
    else:
        # Initialize array with port_size, all bits with 'None' value (not mapped)
        if port_name not in io_dict:
            io_dict[port_name] = [None for n in range(int(port_size))]
        # Map the selected bits to the corresponding wire bits
        # Each element in the bit list of this port will be a tuple containign the name of the wire to connect to and the bit of that wire.
        for wire_bit, bit in enumerate(port_bits):
            assert bit < len(
                io_dict[port_name]
            ), f"{iob_colors.FAIL}Peripheral port {port_name} does not have bit {bit}!{iob_colors.ENDC}"
            assert not io_dict[port_name][
                bit
            ], f"{iob_colors.FAIL}Peripheral port {port_name} bit {bit} has already been previously mapped!{iob_colors.ENDC}"
            io_dict[port_name][bit] = (wire_name, wire_bit)


# Function to handle portmap connections between: peripherals, internal, and external system interfaces.
def peripheral_portmap(python_module):
    peripherals_list = python_module.peripherals
    ios = python_module.ios
    peripheral_portmap = python_module.peripheral_portmap

    # Add default portmap for peripherals not configured in peripheral_portmap
    for peripheral in peripherals_list:
        if peripheral.name not in [
            i[0]["corename"] for i in peripheral_portmap or []
        ] + [i[1]["corename"] for i in peripheral_portmap or []]:
            # Map all ports of all interfaces
            for interface in peripheral.module.ios:
                # If table has 'doc_only' attribute set to True, skip it
                if "doc_only" in interface.keys() and interface["doc_only"]:
                    continue

                if interface["ports"]:
                    for port in interface["ports"]:
                        if port["name"] not in reserved_signals:
                            # Map port to the external system interface
                            peripheral_portmap.append(
                                (
                                    {
                                        "corename": peripheral.name,
                                        "if_name": interface["name"],
                                        "port": port["name"],
                                        "bits": [],
                                    },
                                    {
                                        "corename": "external",
                                        "if_name": peripheral.name,
                                        "port": "",
                                        "bits": [],
                                    },
                                )
                            )
                else:
                    # Auto-map if_gen interfaces, except for the ones that have reserved signals.
                    if interface["name"] in if_gen.if_names and interface[
                        "name"
                    ] not in [
                        "iob",
                        "axi",
                        "clk_en_rst",
                        "clk_rst",
                    ]:
                        # Map entire interface to the external system interface
                        peripheral_portmap.append(
                            (
                                {
                                    "corename": peripheral.name,
                                    "if_name": interface["name"],
                                    "port": "",
                                    "bits": [],
                                },
                                {
                                    "corename": "external",
                                    "if_name": peripheral.name,
                                    "port": "",
                                    "bits": [],
                                },
                            )
                        )

    # Add 'IO" attribute to every peripheral
    for peripheral in peripherals_list:
        peripheral.io = {}

    # List of peripheral interconnection wires
    peripheral_wires = []

    # Handle peripheral portmap
    for map_idx, mapping in enumerate(peripheral_portmap):
        # List to store both items in this mamping
        mapping_items = [None, None]
        assert (
            mapping[0]["corename"] and mapping[1]["corename"]
        ), f"{iob_colors.FAIL}Mapping 'corename' can not be empty on portmap index {map_idx}!{iob_colors.ENDC}"

        # The 'external' keyword in corename is reserved to map signals to the external interface, causing it to create a system IO port
        # The 'internal' keyword in corename is reserved to map signals to the internal interface, causing it to create an internal system wire

        # Get system block of peripheral in mapping[0]
        if mapping[0]["corename"] not in ["external", "internal"]:
            assert any(
                i for i in peripherals_list if i.name == mapping[0]["corename"]
            ), f"{iob_colors.FAIL}{map_idx} Peripheral instance named '{mapping[0]['corename']}' not found!{iob_colors.ENDC}"
            mapping_items[0] = next(
                i for i in peripherals_list if i.name == mapping[0]["corename"]
            )

        # Get system block of peripheral in mapping[1]
        if mapping[1]["corename"] not in ["external", "internal"]:
            assert any(
                i for i in peripherals_list if i.name == mapping[1]["corename"]
            ), f"{iob_colors.FAIL}{map_idx} Peripheral instance named '{mapping[1]['corename']}' not found!{iob_colors.ENDC}"
            mapping_items[1] = next(
                i for i in peripherals_list if i.name == mapping[1]["corename"]
            )

        # Make sure we are not mapping two external or internal interfaces
        assert mapping_items != [
            None,
            None,
        ], f"{iob_colors.FAIL}{map_idx} Cannot map between two internal/external interfaces!{iob_colors.ENDC}"

        # By default, store -1 if we are not mapping to external/internal interface
        mapping_external_interface = -1
        mapping_internal_interface = -1

        # Store index if any of the entries is the external/internal interface
        if None in mapping_items:
            if mapping[mapping_items.index(None)]["corename"] == "external":
                mapping_external_interface = mapping_items.index(None)
            else:
                mapping_internal_interface = mapping_items.index(None)

        # Create interface for this portmap if it is connected to external interface
        if mapping_external_interface > -1:
            # List of system IOs from ports of this mapping
            mapping_ios = []
            # Add peripherals table to ios of system
            assert mapping[mapping_external_interface][
                "if_name"
            ], f"{iob_colors.FAIL}Portmap index {map_idx} needs an interface name for the 'external' corename!{iob_colors.ENDC}"

            print(mapping[mapping_external_interface]["if_name"])
            ios.append(
                {
                    "name": mapping[mapping_external_interface]["if_name"],
                    "type": "master",
                    "descr": f"IOs for peripherals based on portmap index {map_idx}",
                    "port_prefix": "",
                    "wire_prefix": "",
                    "ports": mapping_ios,
                    # Only set `ios_table_prefix` if user has not specified a value in the portmap entry
                    # "ios_table_prefix": True
                    # if "ios_table_prefix" not in mapping[mapping_external_interface]
                    # else mapping[mapping_external_interface]["ios_table_prefix"],
                }
            )

        # Get ports of configured interface
        interface_table = next(
            (
                i
                for i in mapping_items[0].module.ios
                if i["name"] == mapping[0]["if_name"]
            ),
            None,
        )
        assert (
            interface_table
        ), f"{iob_colors.FAIL}Interface {mapping[0]['if_name']} of {mapping[0]['corename']} not found!{iob_colors.ENDC}"
        interface_ports = interface_table["ports"]

        # If mapping_items[1] is not internal/external interface
        if mapping_internal_interface != 1 and mapping_external_interface != 1:
            # Get ports of configured interface
            interface_table = next(
                (
                    i
                    for i in mapping_items[1].module.ios
                    if i["name"] == mapping[1]["if_name"]
                ),
                None,
            )
            assert (
                interface_table
            ), f"{iob_colors.FAIL}Interface {mapping[1]['if_name']} of {mapping[1]['corename']} not found!{iob_colors.ENDC}"
            interface_ports2 = interface_table["ports"]

        # Check if should insert one port or every port in the interface
        if not mapping[0]["port"]:
            # Mapping configuration did not specify a port, therefore insert all signals from interface and auto-connect them
            # NOTE: currently mapping[1]['if_name'] is always assumed to be equal to mapping[0]['if_name']

            # Get mapping for this interface
            # if_mapping = get_interface_mapping(mapping[0]["if_name"])

            # For every port: create wires and connect IO
            for port in interface_ports:
                if mapping_internal_interface < 0 and mapping_external_interface < 0:
                    # Not mapped to internal/external interface
                    # Create peripheral wire name based on mapping.
                    wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{port['name']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{if_mapping[port['name']]}"
                    peripheral_wires.append(
                        {
                            "name": wire_name,
                            "width": add_prefix_to_parameters_in_port(
                                port,
                                mapping_items[0].module.confs,
                                mapping[0]["corename"] + "_",
                            )["width"],
                        }
                    )
                elif mapping_internal_interface > -1:
                    # Mapped to internal interface
                    # Wire name generated the same way as ios inserted in verilog
                    if mapping_internal_interface == 0:
                        wire_name = f"{mapping[0]['if_name']+'_'}{port['name']}"
                    else:
                        wire_name = f"{mapping[1]['if_name']+'_'}{port['name']}"
                    # Add internal system wire for this port
                    peripheral_wires.append(
                        {
                            "name": wire_name,
                            "width": add_prefix_to_parameters_in_port(
                                port,
                                mapping_items[0].module.confs,
                                mapping[0]["corename"] + "_",
                            )["width"],
                        }
                    )

                else:
                    # Mapped to external interface
                    # Add system IO for this port
                    mapping_ios.append(
                        add_prefix_to_parameters_in_port(
                            port,
                            mapping_items[0].module.confs,
                            mapping[0]["corename"] + "_",
                        )
                    )
                    # Append if_name as a prefix of signal
                    mapping_ios[-1]["name"] = (
                        mapping[mapping_external_interface]["if_name"]
                        + "_"
                        + port["name"]
                    )
                    # Dont add `if_name` prefix if `iob_table_prefix` is set to False
                    if (
                        "ios_table_prefix" in mapping[mapping_external_interface]
                        and not mapping[mapping_external_interface]["ios_table_prefix"]
                    ):
                        signal_prefix = ""
                    else:
                        signal_prefix = (
                            mapping[mapping_external_interface]["if_name"] + "_"
                        )

                    if (
                        "remove_string_from_port_names"
                        in mapping[mapping_external_interface]
                    ):
                        signal_name = port["name"].replace(
                            mapping[mapping_external_interface][
                                "remove_string_from_port_names"
                            ],
                            "",
                        )
                        # Update port name previsously inserted in mapping_ios
                        mapping_ios[-1]["name"] = signal_name
                    else:
                        signal_name = port["name"]
                    # Wire name generated the same way as ios inserted in verilog
                    wire_name = f"{signal_prefix}{signal_name}"

                # Insert mapping between IO and wire for mapping[0] (if its not internal/external interface)
                if mapping_internal_interface != 0 and mapping_external_interface != 0:
                    map_IO_to_wire(
                        mapping_items[0].io,
                        mapping[0]["if_name"] + "_" + port["name"],
                        0,
                        [],
                        wire_name,
                    )

                # Insert mapping between IO and wire for mapping[1] (if its not internal/external interface)
                if mapping_internal_interface != 1 and mapping_external_interface != 1:
                    map_IO_to_wire(
                        mapping_items[1].io,
                        mapping[1]["if_name"] + "_" + if_mapping[port["name"]],
                        0,
                        [],
                        wire_name,
                    )

        else:
            # Mapping configuration specified a port, therefore only insert singal for that port

            port = next(
                (i for i in interface_ports if i["name"] == mapping[0]["port"]), None
            )
            assert (
                port
            ), f"{iob_colors.FAIL}Port {mapping[0]['port']} of {mapping[0]['if_name']} for {mapping[0]['corename']} not found!{iob_colors.ENDC}"

            if mapping_internal_interface != 1 and mapping_external_interface != 1:
                port2 = next(
                    (i for i in interface_ports2 if i["name"] == mapping[1]["port"]),
                    None,
                )
                assert (
                    port2
                ), f"{iob_colors.FAIL}Port {mapping[1]['port']} of {mapping[1]['if_name']} for {mapping[1]['corename']} not found!{iob_colors.ENDC}"

            # Get number of bits for this wire. If 'bits' was not specified, use the same size as the port of the peripheral
            if not mapping[0]["bits"]:
                # Mapping did not specify bits, use the same size as the port (will map all bits of the port)
                width = port["width"]
            else:
                # Mapping specified bits, the width will be the total amount of bits specified
                width = len(mapping[0]["bits"])
                # Insert wire of the ports into the peripherals_wires list of the system

            if mapping_internal_interface < 0 and mapping_external_interface < 0:
                # Not mapped to external interface
                # Create wire name based on mapping
                wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{mapping[0]['port']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{mapping[1]['port']}"
                peripheral_wires.append(
                    {
                        "name": wire_name,
                        "width": add_prefix_to_parameters_in_port(
                            port,
                            mapping_items[0].module.confs,
                            mapping[0]["corename"] + "_",
                        )["width"],
                    }
                )
            elif mapping_internal_interface > -1:
                # Mapped to internal interface
                # Wire name generated the same way as ios inserted in verilog
                if mapping_internal_interface == 0:
                    wire_name = f"{mapping[0]['if_name']+'_'}{port['name']}"
                else:
                    wire_name = f"{mapping[1]['if_name']+'_'}{port['name']}"
                # Add internal system wire for this port
                peripheral_wires.append(
                    {
                        "name": wire_name,
                        "width": add_prefix_to_parameters_in_port(
                            port,
                            mapping_items[0].module.confs,
                            mapping[0]["corename"] + "_",
                        )["width"],
                    }
                )
            else:
                # Mapped to external interface
                # Add system IO for this port
                mapping_ios.append(
                    add_prefix_to_parameters_in_port(
                        {
                            "name": port["name"],
                            "direction": port["direction"],
                            "width": width,
                            "descr": port["descr"],
                        },
                        mapping_items[0].module.confs,
                        mapping[0]["corename"] + "_",
                    )
                )
                # Append if_name as a prefix of signal
                mapping_ios[-1]["name"] = (
                    mapping[mapping_external_interface]["if_name"] + "_" + port["name"]
                )  # FIXME
                # Dont add `if_name` prefix if `iob_table_prefix` is set to False
                if (
                    "ios_table_prefix" in mapping[mapping_external_interface]
                    and not mapping[mapping_external_interface]["ios_table_prefix"]
                ):
                    signal_prefix = ""
                else:
                    signal_prefix = mapping[mapping_external_interface]["if_name"] + "_"

                if (
                    "remove_string_from_port_names"
                    in mapping[mapping_external_interface]
                ):
                    signal_name = port["name"].replace(
                        mapping[mapping_external_interface][
                            "remove_string_from_port_names"
                        ],
                        "",
                    )
                    # Update port name previsously inserted in mapping_ios
                    mapping_ios[-1]["name"] = signal_name
                else:
                    signal_name = port["name"]
                # Wire name generated the same way as ios inserted in verilog
                wire_name = f"{signal_prefix}{signal_name}"

            # Insert mapping between IO and wire for mapping[0] (if its not internal/external interface)
            if mapping_internal_interface != 0 and mapping_external_interface != 0:
                # print(f"Debug: {mapping_items[0].name} {mapping_items[0].ios} {mapping_items[0].io}\n")  # DEBUG
                map_IO_to_wire(
                    mapping_items[0].io,
                    mapping[0]["if_name"] + "_" + mapping[0]["port"],
                    eval_param_expression_from_config(
                        port["width"], mapping_items[0].module.confs, "max"
                    ),
                    mapping[0]["bits"],
                    wire_name,
                )

            # Insert mapping between IO and wire for mapping[1] (if its not internal/external interface)
            if mapping_internal_interface != 1 and mapping_external_interface != 1:
                map_IO_to_wire(
                    mapping_items[1].io,
                    mapping[1]["if_name"] + "_" + mapping[1]["port"],
                    eval_param_expression_from_config(
                        port2["width"], mapping_items[1].module.confs, "max"
                    ),
                    mapping[1]["bits"],
                    wire_name,
                )

    # Merge interfaces with the same name into a single interface
    interface_names = []
    for interface in ios:
        if interface["name"] not in interface_names:
            interface_names.append(interface["name"])
    new_ios = []
    for interface_name in interface_names:
        first_interface_instance = None
        for interface in ios:
            if interface["name"] == interface_name:
                if not first_interface_instance:
                    first_interface_instance = interface
                    new_ios.append(interface)
                else:
                    first_interface_instance["ports"] += interface["ports"]
    python_module.ios = new_ios
    # print(f"### Debug python_module.ios: {python_module.ios}", file=sys.stderr)

    return peripheral_wires
