import os

#
# from iob_base import find_obj_in_list
#
from iob_soc_peripherals import create_periphs_tmp, set_peripheral_macros


#
from iob_soc_create_system import insert_header_files


# import fnmatch
# import if_gen
# import copy_srcs
# import verilog_gen
#
#
def iob_soc_sw_setup(attributes, peripherals, ADDR_W):
    create_periphs_tmp(
        attributes["name"],
        ADDR_W,
        peripherals,
        f"{attributes['build_dir']}/software/{attributes['name']}_periphs.h",
    )


#
#
# def iob_soc_wrapper_setup(python_module, exclude_files=[]):
#     confs = python_module.confs
#     build_dir = python_module.build_dir
#     name = python_module.name
#     num_extmem_connections = python_module.num_extmem_connections
#
#     # Note:
#     # The settings below are only used with `USE_EXTMEM=1`.
#     # Currently they are always being set up (even with USE_EXTMEM=0) to allow
#     # the users to manually add USE_EXTMEM=1 in the build_dir.
#     # As we no longer support build-time defines, we may need to change this in the future.
#
#     # Create extmem wrapper files
#     gen_ifaces = [
#         {
#             "file_prefix": "ddr4_",
#             "name": "axi",
#             "type": "master",
#             "wire_prefix": "ddr4_",
#             "port_prefix": "ddr4_",
#             "param_prefix": "ddr4_",
#             "ports": [],
#             "descr": "External memory interface",
#         },
#         {
#             "file_prefix": f"iob_bus_{num_extmem_connections}_",
#             "name": "axi",
#             "type": "master",
#             "wire_prefix": "",
#             "port_prefix": "",
#             "bus_size": num_extmem_connections,
#             "ports": [],
#             "descr": f"iob_bus_{num_extmem_connections} interface",
#         },
#         {
#             "file_prefix": f"iob_bus_0_{num_extmem_connections}_",
#             "name": "axi",
#             "type": "master",
#             "wire_prefix": "",
#             "port_prefix": "",
#             "bus_start": 0,
#             "bus_size": num_extmem_connections,
#             "ports": [],
#             "descr": f"iob_bus_0_{num_extmem_connections} interface",
#         },
#         {
#             "file_prefix": "iob_memory_",
#             "name": "axi",
#             "type": "slave",
#             "wire_prefix": "memory_",
#             "port_prefix": "",
#             "ports": [],
#             "descr": "iob_memory interface",
#         },
#     ]
#     generate_ifaces(gen_ifaces, python_module.build_dir)
#
#
# def generate_ifaces(ifaces, build_dir):
#     for iface in ifaces:
#         if_gen.gen_if(
#             iface["name"],
#             iface["file_prefix"],
#             iface["port_prefix"],
#             iface["wire_prefix"],
#             iface["ports"],
#             iface["param_prefix"] if "param_prefix" in iface.keys() else "",
#             iface["mult"] if "mult" in iface.keys() else 1,
#             iface["widths"] if "widths" in iface.keys() else {},
#         )
#     # move all .vs files from current directory to out_dir
#     for file in os.listdir("."):
#         if file.endswith(".vs"):
#             os.rename(file, f"{build_dir}/hardware/src/{file}")
#
#
# def iob_soc_hw_setup(python_module, exclude_files=[]):
#     """Create automatic hardware sources, like 'iob_soc.v'
#     NOTE: This may not be needed when the py2hw process generates the iob_soc.v completely
#     """
#     peripherals_list = python_module.peripherals
#     build_dir = python_module.build_dir
#     name = python_module.name
#
#     # Try to build <system_name>.v if template <system_name>.v is available and iob_soc.v not in exclude list
#     # Note, it checks for iob_soc.v in exclude files, instead of <system_name>.v to be consistent with the copy_common_files() function.
#     # [If a user does not want to build <system_name>.v from the template, then he also does not want to copy the template from the iob-soc]
#     if not fnmatch.filter(exclude_files, "iob_soc.v"):
#         create_systemv(
#             build_dir,
#             name,
#             peripherals_list,
#             python_module.peripheral_portmap,
#             internal_wires=python_module.internal_wires,
#         )
#         pbus_ios = create_pbus_split_submodule(python_module)
#         # generate pbus split ios for replacement in _periphs_inst.vs
#         generate_ifaces(pbus_ios, python_module.build_dir)
#
#
# def update_ios_with_extmem_connections(python_module):
#     """Fill 'mult' argument of 'axi' port automatically based on number of peripherals that need to connect to the external memory interconnect"""
#     peripherals_list = python_module.peripherals
#
#     num_extmem_connections = 1  # By default, one connection for iob-soc's cache
#     # Count numer of external memory connections
#     for peripheral in peripherals_list:
#         for interface in peripheral.module.ios:
#             # Check if interface is a standard axi_m_port (for extmem connection)
#             if interface["name"] == "axi_m_port":
#                 num_extmem_connections += 1
#                 continue
#             # Check if interface does not have the standard axi_m_port name,
#             # but does contains its standard signals. For example, it may be a
#             # bus of axi_m_ports, therefore may have a different name.
#             for port in interface["ports"]:
#                 if port["name"] == "axi_awid_o":
#                     num_extmem_connections += get_extmem_bus_size(port["width"])
#                     # Break the inner loop...
#                     break
#             else:
#                 # Continue if the inner loop wasn't broken.
#                 continue
#             # Inner loop was broken, break the outer.
#             break
#
#     python_module.num_extmem_connections = num_extmem_connections
#
#     # Update size of "axi" interface for external memory
#     find_obj_in_list(python_module.ios, "axi")[
#         "mult"
#     ] = python_module.num_extmem_connections
#
#
######################################


# Run specialized iob-soc setup sequence
def pre_setup_iob_soc(attributes_dict, peripherals, params):
    """Update IOb-SoC core attributes automatically.
    These updated attributes will be used by the setup process.
    """
    name = attributes_dict["name"]
    confs = attributes_dict["confs"]
    build_dir = attributes_dict["build_dir"]

    # Replace original IOb-SoC name in values of confs with new name
    for conf in confs:
        if type(conf["val"]) is str:
            conf["val"] = (
                conf["val"].replace("iob_soc", name).replace("IOB_SOC", name.upper())
            )

    # Setup peripherals
    set_peripheral_macros(confs, peripherals)
    out_dir = os.path.join(f"{build_dir}/hardware/src")
    os.makedirs(out_dir, exist_ok=True)
    insert_header_files(out_dir, name, peripherals)
    # iob_soc_peripheral_setup(attributes_dict)
    # update_ios_with_extmem_connections(attributes_dict)

    # Ignore snippets that should not be replaced by the normal setup process
    # These snippets will only be generated and replaced by iob-soc after the setup process
    # TODO: Remove this when wrappers are fully py2hwsw generated
    attributes_dict["ignore_snippets"] = [
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

    #
    # Create auto_sw_build.mk
    #
    os.makedirs(f"{build_dir}/software", exist_ok=True)
    with open(f"{build_dir}/software/auto_sw_build.mk", "w") as file:
        file.write("#This file was auto generated by iob_soc_utils.py\n")
        if params["init_mem"]:
            # Append init_ddr_contents.hex target to sw_build.mk
            file.write("\n#Auto-generated target to create init_ddr_contents.hex\n")
            file.write("HEX+=init_ddr_contents.hex\n")
            file.write("# init file for internal mem with firmware of both systems\n")
            file.write(f"init_ddr_contents.hex: {name}_firmware.hex\n")

            # TODO: Remove SUT stuff from iob-soc (only used for Tester)
            # sut_firmware_name = (
            #    python_module.sut_fw_name.replace(".c", ".hex")
            #    if "sut_fw_name" in python_module.__dict__.keys()
            #    else "-"
            # )
            sut_firmware_name = "-"
            file.write(
                f"	../../scripts/hex_join.py $^ {sut_firmware_name} {params['mem_addr_w']} > $@\n"
            )
        if params["use_ethernet"]:
            # Set custom ethernet CONSOLE_CMD
            file.write(
                'CONSOLE_CMD ?=rm -f soc2cnsl cnsl2soc; $(IOB_CONSOLE_PYTHON_ENV) $(PYTHON_DIR)/console_ethernet.py -L -c $(PYTHON_DIR)/console.py -m "$(RMAC_ADDR)" -i "$(ETH_IF)"\n',
            )
            file.write(
                """\
    UTARGETS+=iob_eth_rmac.h
    EMUL_HDR+=iob_eth_rmac.h
    iob_eth_rmac.h:
        echo "#define ETH_RMAC_ADDR 0x$(RMAC_ADDR)" > $@\n
""",
            )

    #
    # Create auto_fpga_build.mk
    #
    os.makedirs(f"{build_dir}/hardware/fpga", exist_ok=True)
    with open(f"{build_dir}/hardware/fpga/auto_fpga_build.mk", "w") as file:
        file.write("#This file was auto generated by iob_soc_utils.py\n")

        # Set N_INTERCONNECT_SLAVES variable
        # TODO: Count axi interfaces automatically for peripherals with DMA
        file.write("N_INTERCONNECT_SLAVES:=1\n")
        # Set USE_EXTMEM variable
        file.write(f"USE_EXTMEM:={int(params['use_extmem'])}\n")
        # Set INIT_MEM variable
        file.write(f"INIT_MEM:={int(params['init_mem'])}\n")
        if params["use_ethernet"]:
            # Set custom ethernet CONSOLE_CMD
            file.write(
                'CONSOLE_CMD=$(IOB_CONSOLE_PYTHON_ENV) $(PYTHON_DIR)/console_ethernet.py -s /dev/usb-uart -c $(PYTHON_DIR)/console.py -m "$(RMAC_ADDR)" -i "$(ETH_IF)"\n',
            )

        if params["init_mem"]:
            # Append init_ddr_contents.hex target to sw_build.mk
            file.write("\n#Auto-generated target to create init_ddr_contents.hex\n")
            file.write("RUN_DEPS+=init_ddr_contents.hex\n")
            file.write("BUILD_DEPS+=init_ddr_contents.hex\n")
            file.write("# init file for internal mem with firmware of both systems\n")
            file.write(f"init_ddr_contents.hex: {name}_firmware.hex\n")

            # TODO: Remove SUT stuff from iob-soc (only used for Tester)
            # sut_firmware_name = (
            #    python_module.sut_fw_name.replace(".c", ".hex")
            #    if "sut_fw_name" in python_module.__dict__.keys()
            #    else "-"
            # )
            sut_firmware_name = "-"
            file.write(
                f"	../../scripts/hex_join.py $^ {sut_firmware_name} {params['mem_addr_w']} > $@\n"
            )

    #
    # Create auto_sim_build.mk
    #
    os.makedirs(f"{build_dir}/hardware/simulation", exist_ok=True)
    with open(f"{build_dir}/hardware/simulation/auto_sim_build.mk", "w") as file:
        file.write("#This file was auto generated by iob_soc_utils.py\n")
        if params["use_ethernet"]:
            file.write("USE_ETHERNET=1\n")
            # Set custom ethernet CONSOLE_CMD
            file.write(
                'ETH2FILE_SCRIPT="$(PYTHON_DIR)/eth2file.py"\n'
                'CONSOLE_CMD=$(IOB_CONSOLE_PYTHON_ENV) $(PYTHON_DIR)/console_ethernet.py -L -c $(PYTHON_DIR)/console.py -e $(ETH2FILE_SCRIPT) -m "$(RMAC_ADDR)" -i "$(ETH_IF)" -t 60\n',
            )

    #
    # Create auto_iob_soc_firmware.lds
    #
    os.makedirs(f"{build_dir}/software", exist_ok=True)
    with open(f"{build_dir}/software/auto_iob_soc_firmware.lds", "w") as file:
        file.write("/* This file was auto generated by iob_soc_utils.py */\n")
        file.write(f". = {params['fw_addr']};\n")


# def post_setup_iob_soc(python_module):
#     confs = python_module.confs
#     build_dir = python_module.build_dir
#     setup_dir = python_module.setup_dir
#     name = python_module.name
#     num_extmem_connections = python_module.num_extmem_connections
#
#     # Run iob-soc specialized setup sequence
#     iob_soc_sw_setup(python_module)
#     iob_soc_hw_setup(python_module)
#
#     ### Only run lines below if this system is the top module ###
#     if not python_module.is_top_module:
#         return
#
#     iob_soc_wrapper_setup(python_module)
#
#     verilog_gen.replace_includes(python_module.setup_dir, python_module.build_dir, [])
#
#     # Check if was setup with INIT_MEM and USE_EXTMEM (check if macro exists)
#     extmem_macro = bool(find_obj_in_list(confs, "USE_EXTMEM"))
#     initmem_macro = bool(find_obj_in_list(confs, "INIT_MEM"))
#     ethernet_macro = bool(find_obj_in_list(confs, "USE_ETHERNET"))
#
#     scripts = [
#         "console.py",
#         "board_client.py",
#         "makehex.py",
#         "hex_split.py",
#         "hex_join.py",
#     ]
#
#     scripts_dir = ""
#     # Find the scripts directory in the setup_dir which has all the scripts in the list above
#     for root, dirs, files in os.walk(setup_dir):
#         if all(script in files for script in scripts):
#             scripts_dir = root
#             break
#     # Copy scripts to build directory
#     copy_srcs.copy_files(f"{scripts_dir}", f"{build_dir}/scripts", scripts)
#
#     # Copy  console_ethernet.py
#     if ethernet_macro:
#         copy_srcs.copy_files(
#             scripts_dir,
#             f"{build_dir}/scripts",
#             ["console_ethernet.py"],
#             "*.py",
#         )
#
#     mem_add_w_parameter = next((i for i in confs if i["name"] == "MEM_ADDR_W"), False)
