import os
import re

import iob_colors
from iob_soc_peripherals import (
    get_pio_signals,
    get_peripherals_ports_params_top,
    get_peripheral_port_mapping,
    get_reserved_signals,
    get_reserved_signal_connection,
)
from if_gen import get_port_name
from iob_split import iob_split
import io_gen


# Automatically include <corename>_swreg_def.vh verilog headers after IOB_PRAGMA_PHEADERS comment
def insert_header_files(dest_dir, name, peripherals_list):
    fd_out = open(f"{dest_dir}/{name}_periphs_swreg_def.vs", "w")
    # Get each type of peripheral used
    included_peripherals = []
    for instance in peripherals_list:
        if instance.module.name not in included_peripherals:
            included_peripherals.append(instance.module.name)
            # Only insert swreg file if module has regiters
            if hasattr(instance.module, "csrs") and instance.module.csrs:
                top = instance.module.name
                fd_out.write(f'`include "{top}_swreg_def.vh"\n')
    fd_out.close()


# Creates the Verilog Snippet (.vs) files required by {top}.v
# build_dir: build directory
# top: top name of the system
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# peripheral_portmap: list of tuples each of them a port map
# internal_wires: Optional argument. List of extra wires to create inside module
def create_systemv(
    build_dir, top, peripherals_list, peripheral_portmap, internal_wires=None
):
    num_extmem_connections = 1  # By default, one connection for iob-soc's cache
    latest_extmem_bus_size = -1
    peripherals_with_trap = []  # List of peripherals with trap output

    out_dir = os.path.join(build_dir, "hardware/src")

    insert_header_files(out_dir, top, peripherals_list)

    # Get port list, parameter list and top module name for each type of peripheral used
    port_list, params_list, top_list = get_peripherals_ports_params_top(
        peripherals_list
    )

    # Insert internal module wires (if any)
    periphs_wires_str = ""
    if internal_wires:
        # Insert internal wires
        for wire in internal_wires:
            periphs_wires_str += f"    wire [{wire['n_bits']}-1:0] {wire['name']};\n"

    periphs_inst_str = ""
    # Insert IOs and Instances for this type of peripheral
    for instance in peripherals_list:
        # Peripheral pbus split io wire declaration
        periphs_inst_str += f'\t\n`include "iob_soc_{instance.name}_iob_wire.vs"\n\n'

        # Create peripheral instance Verilog Snippet
        periphs_inst_str += "\n"
        # Insert peripheral comment
        periphs_inst_str += "   // {}\n".format(instance.name)
        periphs_inst_str += "\n"
        # Insert peripheral type
        periphs_inst_str += "   {}\n".format(top_list[instance.module.name])
        # Insert peripheral parameters (if any)
        if params_list[instance.module.name]:
            periphs_inst_str += "     #(\n"
            # Insert parameters
            for param in params_list[instance.module.name]:
                periphs_inst_str += "      .{}({}){}\n".format(
                    param["name"], instance.name + "_" + param["name"], ","
                )
            # Remove comma at the end of last parameter
            periphs_inst_str = periphs_inst_str[::-1].replace(",", "", 1)[::-1]
            periphs_inst_str += "   )\n"
        # Insert peripheral instance name
        periphs_inst_str += "   {} (\n".format(instance.name)
        # Insert io signals
        # print(f"Debug: {instance.name} {instance.io} {port_list[instance.module.name]}\n")  # DEBUG
        ## Group peripheral ports with the same condition to be used
        grouped_signals = []
        for signal in get_pio_signals(port_list[instance.module.name]):
            if "if_defined" in signal.keys():
                if_defined_key = f"{top.upper()}_{signal['if_defined']}"
            else:
                if_defined_key = ""

            if not grouped_signals or grouped_signals[-1][0] != if_defined_key:
                grouped_signals.append((if_defined_key, []))

            grouped_signals[-1][1].append(signal)

        ## Iterate over the grouped signals and generate the code
        for if_defined_key, signals_in_group in grouped_signals:
            if if_defined_key != "":
                periphs_inst_str += f"`ifdef {if_defined_key}\n"

            for signal in signals_in_group:
                _, port_name = get_port_name("", signal["direction"], signal)
                periphs_inst_str += f"      .{port_name}({get_peripheral_port_mapping(peripheral_portmap, instance, signal['if_name'], signal['name'])}),\n"

            if if_defined_key != "":
                periphs_inst_str += "`endif\n"

        # Insert reserved signals
        for signal in get_reserved_signals(port_list[instance.module.name]):
            # Check if should append this peripheral to the list of peripherals with extmem interfaces
            # Note: This implementation assumes that the axi_awid_o will be the first signal of the ext_mem interface
            if signal["name"] == "axi_awid_o":
                # Get extmem bus size of this peripheral
                latest_extmem_bus_size = get_extmem_bus_size(signal["n_bits"])
                num_extmem_connections += latest_extmem_bus_size

            if "if_defined" in signal.keys():
                periphs_inst_str += f"`ifdef {top.upper()}_{signal['if_defined']}\n"
            periphs_inst_str += "      " + (
                get_reserved_signal_connection(
                    signal["name"],
                    top.upper() + "_" + instance.name,
                    top_list[instance.module.name].upper() + "_SWREG",
                )
                + ",\n"
            ).replace(
                "/*<extmem_conn_num>*/",
                str(num_extmem_connections - latest_extmem_bus_size),
            ).replace(
                "/*<bus_size>*/", str(latest_extmem_bus_size)
            )
            if "if_defined" in signal.keys():
                periphs_inst_str += "`endif\n"

            if signal["name"] == "trap_o":
                peripherals_with_trap.append(instance)

        # Remove comma at the end of last signal
        periphs_inst_str = periphs_inst_str[::-1].replace(",", "", 1)[::-1]

        periphs_inst_str += "      );\n"

    # pbus split instance
    periphs_inst_str += "\n\twire iob_pbus_split_rst;\n"
    periphs_inst_str += "\tassign iob_pbus_split_rst = cpu_reset;\n"
    periphs_inst_str += '\t\n`include "iob_pbus_split_inst.vs"\n'

    # Create internal wires to connect the peripherals trap signals
    periphs_wires_str += "\n    // Internal wires for trap signals\n"
    periphs_wires_str += "    wire cpu_trap_o;\n"
    trap_or_str = "    assign trap_o = cpu_trap_o"
    for peripheral in peripherals_with_trap:
        periphs_wires_str += f"    wire {top.upper()}_{peripheral.name}_trap_o;\n"
        trap_or_str += f"| {top.upper()}_{peripheral.name}_trap_o"
    trap_or_str += ";\n"

    # Logic OR of trap signals
    periphs_wires_str += trap_or_str

    fd_wires = open(f"{out_dir}/{top}_pwires.vs", "w")
    fd_wires.write(periphs_wires_str)
    fd_wires.close()

    fd_periphs = open(f"{out_dir}/{top}_periphs_inst.vs", "w")
    fd_periphs.write(periphs_inst_str)
    fd_periphs.close()


# This function will return the size of the axi_m bus based on the width of the axi_awid signal
# axi_awid_width: String representing the width of the axi_awid signal.
def get_extmem_bus_size(axi_awid_width: str):
    # Parse the size of the ext_mem bus, it should be something like "N*AXI_ID_W", where N is the size of the bus
    bus_size = re.findall("^(?:\((\d+)\*)?AXI_ID_W\)?$", axi_awid_width)
    # Make sure parse of with was successful
    assert (
        bus_size != []
    ), f"{iob_colors.FAIL} Could not parse bus size of 'axi_awid' signal with width \"{axi_awid_width}\".{iob_colors.ENDC}"
    # Convert to integer
    return 1 if bus_size[0] == "" else int(bus_size[0])


# peripheral instance io connections
# returns: dict with:
#   - input_io: pbus split input
#   - output_ios: list of pbus split outputs
def get_pbus_ios(python_module):
    pbus_ios = {}
    # int_d_pbus_split_io (pbus split input)
    pbus_ios["input_io"] = {
        "name": "iob",
        "type": "slave",
        "file_prefix": "iob_soc_int_d_pbus_",
        "port_prefix": "int_d_",
        "wire_prefix": "int_d_",
        "param_prefix": "",
        "descr": "iob-soc internal data interface",
        "ports": [],
        "widths": {
            "DATA_W": "DATA_W",
            "ADDR_W": "ADDR_W",
        },
    }
    # add int memory as peripheral 0
    pbus_ios["output_ios"] = [
        {
            "name": "iob",
            "type": "master",
            "file_prefix": "iob_soc_int_mem_d_",
            "port_prefix": "int_mem_d_",
            "wire_prefix": "int_mem_d_",
            "param_prefix": "",
            "descr": "iob-soc internal memory data interface",
            "ports": [],
            "widths": {
                "DATA_W": "DATA_W",
                "ADDR_W": "ADDR_W",
            },
        },
    ]
    for instance in python_module.peripherals:
        instance_io = pbus_split_instance_io(instance, python_module.name)
        pbus_ios["output_ios"].append(instance_io)
    return pbus_ios


def get_pbus_split(python_module):
    pbus_ios = get_pbus_ios(python_module)

    # add pbus split ios to module ios
    # needed for pbus_split module
    python_module.ios.append(pbus_ios["input_io"])
    for instance_io in pbus_ios["output_ios"]:
        python_module.ios.append(instance_io)

    # pbus split submodule
    pbus_split = iob_split(
        name_prefix="pbus",
        data_w="DATA_W",
        addr_w="ADDR_W",
        split_ptr="ADDR_W-2",
        input_io=pbus_ios["input_io"],
        output_ios=pbus_ios["output_ios"],
    )
    return pbus_split


# add pbus split to submodule list
# return list of ios to generate
def create_pbus_split_submodule(python_module):
    pbus_split = get_pbus_split(python_module)
    pbus_split._setup(
        False,
        "hardware",
        python_module.build_dir,
    )

    pbus_ios = [pbus_split.input_io]
    for io in pbus_split.output_ios:
        pbus_ios.append(io)
    return pbus_ios


# Add iob io interface for pbus split
def pbus_split_instance_io(instance, top):
    instance_name = f"{top.upper()}_{instance.name}"
    instance_io = {
        "name": "iob",
        "type": "master",
        "file_prefix": f"iob_soc_{instance.name}_",
        "port_prefix": f"{instance.name}_",
        "wire_prefix": f"{instance_name}_",
        "param_prefix": "",
        "descr": f"iob-soc pbus {instance.name} interface",
        "ports": [],
        "widths": {
            "DATA_W": "DATA_W",
            "ADDR_W": "ADDR_W",
        },
    }
    return instance_io
