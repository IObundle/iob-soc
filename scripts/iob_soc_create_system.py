#!/usr/bin/env python3
import os
import re

import iob_colors
from submodule_utils import (
    get_pio_signals,
    get_peripherals_ports_params_top,
    get_reserved_signals,
    get_reserved_signal_connection,
)
from ios import get_peripheral_port_mapping


# Automatically include <corename>_swreg_def.vh verilog headers after IOB_PRAGMA_PHEADERS comment
def insert_header_files(dest_dir, name, peripherals_list):
    fd_out = open(f"{dest_dir}/{name}_periphs_swreg_def.vs", "w")
    # Get each type of peripheral used
    included_peripherals = []
    for instance in peripherals_list:
        if instance.__class__.name not in included_peripherals:
            included_peripherals.append(instance.__class__.name)
            # Only insert swreg file if module has regiters
            if hasattr(instance, "regs") and instance.regs:
                top = instance.__class__.name
                fd_out.write(f'`include "{top}_swreg_def.vh"\n')
    fd_out.close()


# Creates the Verilog Snippet (.vs) files required by {top}.v
# build_dir: build directory
# top: top name of the system
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# internal_wires: Optional argument. List of extra wires to create inside module
def create_systemv(build_dir, top, peripherals_list, internal_wires=None):
    num_extmem_connections = 1  # By default, one connection for iob-soc's cache
    latest_extmem_bus_size = -1
    peripherals_with_trap = []  # List of peripherals with trap output

    out_dir = os.path.join(build_dir, f"hardware/src/")

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
        # Create peripheral instance Verilog Snippet
        periphs_inst_str += "\n"
        # Insert peripheral comment
        periphs_inst_str += "   // {}\n".format(instance.name)
        periphs_inst_str += "\n"
        # Insert peripheral type
        periphs_inst_str += "   {}\n".format(top_list[instance.__class__.name])
        # Insert peripheral parameters (if any)
        if params_list[instance.__class__.name]:
            periphs_inst_str += "     #(\n"
            # Insert parameters
            for param in params_list[instance.__class__.name]:
                periphs_inst_str += "      .{}({}){}\n".format(
                    param["name"], instance.name + "_" + param["name"], ","
                )
            # Remove comma at the end of last parameter
            periphs_inst_str = periphs_inst_str[::-1].replace(",", "", 1)[::-1]
            periphs_inst_str += "   )\n"
        # Insert peripheral instance name
        periphs_inst_str += "   {} (\n".format(instance.name)
        # Insert io signals
        # print(f"Debug: {instance.name} {instance.io} {port_list[instance.__class__.name]}\n")  # DEBUG
        ## Group peripheral ports with the same condition to be used
        grouped_signals = []
        for signal in get_pio_signals(port_list[instance.__class__.name]):
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
                periphs_inst_str += f"      .{signal['name']}({get_peripheral_port_mapping(instance, signal['if_name'], signal['name'])}),\n"

            if if_defined_key != "":
                periphs_inst_str += "`endif\n"

        # Insert reserved signals
        for signal in get_reserved_signals(port_list[instance.__class__.name]):
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
                    top_list[instance.__class__.name].upper() + "_SWREG",
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
