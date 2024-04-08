import os

from iob_base import find_obj_in_list

from iob_soc_peripherals import (
    create_periphs_tmp,
    iob_soc_peripheral_setup,
)

from iob_soc_create_system import (
    create_systemv,
    get_extmem_bus_size,
    create_pbus_split_submodule,
)
from iob_soc_create_wrapper_files import create_wrapper_files

import fnmatch
import if_gen
import copy_srcs
import verilog_gen


def iob_soc_sw_setup(python_module, exclude_files=[]):
    """Create automatic software sources, like 'periphs_tmp.h'"""
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

    # Create extmem wrapper files
    gen_ifaces = [
        {
            "file_prefix": "ddr4_",
            "name": "axi",
            "type": "master",
            "wire_prefix": "ddr4_",
            "port_prefix": "ddr4_",
            "param_prefix": "ddr4_",
            "ports": [],
            "descr": "External memory interface",
        },
        {
            "file_prefix": f"iob_bus_{num_extmem_connections}_",
            "name": "axi",
            "type": "master",
            "wire_prefix": "",
            "port_prefix": "",
            "bus_size": num_extmem_connections,
            "ports": [],
            "descr": f"iob_bus_{num_extmem_connections} interface",
        },
        {
            "file_prefix": f"iob_bus_0_{num_extmem_connections}_",
            "name": "axi",
            "type": "master",
            "wire_prefix": "",
            "port_prefix": "",
            "bus_start": 0,
            "bus_size": num_extmem_connections,
            "ports": [],
            "descr": f"iob_bus_0_{num_extmem_connections} interface",
        },
        {
            "file_prefix": "iob_memory_",
            "name": "axi",
            "type": "slave",
            "wire_prefix": "memory_",
            "port_prefix": "",
            "ports": [],
            "descr": "iob_memory interface",
        },
    ]
    generate_ifaces(gen_ifaces, python_module.build_dir)


def generate_ifaces(ifaces, build_dir):
    for iface in ifaces:
        if_gen.gen_if(
            iface["name"],
            iface["file_prefix"],
            iface["port_prefix"],
            iface["wire_prefix"],
            iface["ports"],
            iface["param_prefix"] if "param_prefix" in iface.keys() else "",
            iface["mult"] if "mult" in iface.keys() else 1,
            iface["widths"] if "widths" in iface.keys() else {},
        )
    # move all .vs files from current directory to out_dir
    for file in os.listdir("."):
        if file.endswith(".vs"):
            os.rename(file, f"{build_dir}/hardware/src/{file}")


def iob_soc_hw_setup(python_module, exclude_files=[]):
    """Create automatic hardware sources, like 'iob_soc.v'
    NOTE: This may not be needed when the py2hw process generates the iob_soc.v completely
    """
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
            python_module.peripheral_portmap,
            internal_wires=python_module.internal_wires,
        )
        pbus_ios = create_pbus_split_submodule(python_module)
        # generate pbus split ios for replacement in _periphs_inst.vs
        generate_ifaces(pbus_ios, python_module.build_dir)


def update_ios_with_extmem_connections(python_module):
    """Fill 'mult' argument of 'axi' port automatically based on number of peripherals that need to connect to the external memory interconnect"""
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
    find_obj_in_list(python_module.ios, "axi")[
        "mult"
    ] = python_module.num_extmem_connections


######################################


# Run specialized iob-soc setup sequence
def pre_setup_iob_soc(core):
    """Update IOb-SoC core attributes automatically.
    These updated attributes will be used by the setup process.
    """
    name = core.name
    confs = core.confs

    # Replace original IOb-SoC name in values of confs with new name
    for conf in confs:
        if type(conf.val) is str:
            conf.val = conf.val.replace("iob_soc", name).replace(
                "IOB_SOC", name.upper()
            )

    # Setup peripherals
    # iob_soc_peripheral_setup(core)
    # update_ios_with_extmem_connections(core)

    # Ignore snippets that should not be replaced by the normal setup process
    # These snippets will only be generated and replaced by iob-soc after the setup process
    core.ignore_snippets += [
        f"{name}_periphs_swreg_def.vs",
        f"{name}_pwires.vs",
        f"{name}_periphs_inst.vs",
        f"{name}_wrapper_pwires.vs",
        f"{name}_pportmaps.vs",
        f"{name}_interconnect.vs",
        "iob_memory_axi_s_portmap.vs",
        f"{name}_cyclonev_interconnect_s_portmap.vs",
        f"{name}_ku040_rstn.vs",
        "ddr4_axi_wire.vs",
        f"{name}_ku040_interconnect_s_portmap.vs",
    ]


def post_setup_iob_soc(python_module):
    confs = python_module.confs
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir
    name = python_module.name
    num_extmem_connections = python_module.num_extmem_connections

    # Remove `[0+:1]` part select in AXI connections of ext_mem0 in iob_soc.v template
    # NOTE: This will not be needed when the py2hw process generates the iob_soc.v completely
    if num_extmem_connections == 1:
        verilog_gen.inplace_change(
            os.path.join(
                python_module.build_dir, "hardware/src", python_module.name + ".v"
            ),
            "[0+:1]",
            "",
        )

    # Run iob-soc specialized setup sequence
    iob_soc_sw_setup(python_module)
    iob_soc_hw_setup(python_module)

    ### Only run lines below if this system is the top module ###
    if not python_module.is_top_module:
        return

    iob_soc_wrapper_setup(python_module)

    verilog_gen.replace_includes(python_module.setup_dir, python_module.build_dir, [])

    # Check if was setup with INIT_MEM and USE_EXTMEM (check if macro exists)
    extmem_macro = bool(find_obj_in_list(confs, "USE_EXTMEM"))
    initmem_macro = bool(find_obj_in_list(confs, "INIT_MEM"))
    ethernet_macro = bool(find_obj_in_list(confs, "USE_ETHERNET"))

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

    scripts_dir = ""
    # Find the scripts directory in the setup_dir which has all the scripts in the list above
    for root, dirs, files in os.walk(setup_dir):
        if all(script in files for script in scripts):
            scripts_dir = root
            break
    # Copy scripts to build directory
    copy_srcs.copy_files(f"{scripts_dir}", f"{build_dir}/scripts", scripts)

    # Copy  console_ethernet.py
    if ethernet_macro:
        copy_srcs.copy_files(
            scripts_dir,
            f"{build_dir}/scripts",
            ["console_ethernet.py"],
            "*.py",
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
