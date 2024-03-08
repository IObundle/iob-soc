#!/usr/bin/env python3

# this script generates interfaces for Verilog modules and testbenches to add a
# new standard interface, add the name to the interface_names list, and an
# interface dictionary as below run this script with the -h option for help

import re

if_names = [
    "clk_en_rst",
    "clk_rst",
    "iob",
    "axil_read",
    "axil_write",
    "axil",
    "axi_read",
    "axi_write",
    "axi",
    "apb",
    "axis",
    "rom_sp",
    "rom_tdp",
    "ram_sp",
    "ram_tdp",
    "ram_2p",
]

if_types = [
    "m_port",
    "s_port",
    "m_portmap",
    "s_portmap",
    "m_m_portmap",
    "s_s_portmap",
    "wire",
    "m_tb_wire",
    "s_tb_wire",
]


def parse_widths(func):
    """Decorator to temporarily change values of global variables based on `widths` dicitonary."""

    def inner(widths={}):
        vars_backup = {}
        # Backup global variables
        for k, v in widths.items():
            assert k in globals(), f"Width variable '{k}' does not exist!"
            vars_backup[k] = globals()[k]
            globals()[k] = v
        # Call the function
        return_obj = func()
        # Restore global variables
        for k in widths:
            globals()[k] = vars_backup[k]
        return return_obj

    return inner


def try_math_eval(expr):
    """Try to evaluate math expressions, otherwise return the input."""
    try:
        return int(eval(expr, {"__builtins__": None}, {}))
    except TypeError:
        return expr


DATA_W = 32
DATA_SECTION_W = 8
ADDR_W = 32

#
# below are functions that return interface ports for each interface type
# the port direction is relative to the master module (driver)
#


@parse_widths
def get_iob_ports():
    return [
        {
            "name": "iob_valid",
            "direction": "output",
            "width": 1,
            "descr": "Request address is valid.",
        },
        {
            "name": "iob_addr",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address.",
        },
        {
            "name": "iob_wdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "Write data.",
        },
        {
            "name": "iob_wstrb",
            "direction": "output",
            "width": try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            "descr": "Write strobe.",
        },
        {
            "name": "iob_rvalid",
            "direction": "input",
            "width": 1,
            "descr": "Read data valid.",
        },
        {
            "name": "iob_rdata",
            "direction": "input",
            "width": DATA_W,
            "descr": "Read data.",
        },
        {
            "name": "iob_ready",
            "direction": "input",
            "width": 1,
            "descr": "Interface ready.",
        },
    ]


@parse_widths
def get_clk_rst_ports():
    return [
        {
            "name": "clk",
            "direction": "output",
            "width": 1,
            "descr": "Clock",
        },
        {
            "name": "arst",
            "direction": "output",
            "width": 1,
            "descr": "Asynchronous active-high reset",
        },
    ]


@parse_widths
def get_clk_en_rst_ports():
    clk_rst_ports = get_clk_rst_ports()
    return [
        clk_rst_ports[0],
        {
            "name": "cke",
            "direction": "output",
            "width": 1,
            "descr": "Enable",
        },
        clk_rst_ports[1],
    ]


def get_mem_ports(suffix):
    return [
        {
            "name": "clk" + "_" + suffix,
            "direction": "output",
            "width": 1,
            "descr": f"Clock port {suffix}",
        },
        {
            "name": "en" + "_" + suffix,
            "direction": "output",
            "width": 1,
            "descr": f"Enable port {suffix}",
        },
        {
            "name": "addr" + "_" + suffix,
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address port {suffix}",
        },
    ]


def get_mem_read_ports(suffix):
    mem_ports = get_mem_ports(suffix)
    mem_read_ports = mem_ports + [
        {
            "name": "rdata" + "_" + suffix,
            "direction": "input",
            "width": DATA_W,
            "descr": "Data port {suffix}",
        },
    ]
    return mem_read_ports


def get_mem_write_ports(suffix):
    mem_ports = get_mem_ports(suffix)
    mem_write_ports = mem_ports + [
        {
            "name": "wdata" + "_" + suffix,
            "direction": "output",
            "width": DATA_W,
            "descr": "Data port {suffix}",
        },
        {
            "name": "wstrb" + "_" + suffix,
            "direction": "output",
            "width": try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            "descr": "Write strobe port {suffix}",
        },
    ]
    return mem_write_ports


def remove_duplicates(ports):
    seen_dicts = []
    result = []
    for d in ports:
        tuple_d = tuple(d.items())
        if tuple_d not in seen_dicts:
            seen_dicts.append(tuple_d)
            result.append(d)
    return result


@parse_widths
def get_rom_sp_ports():
    ports = get_mem_read_ports("") + get_mem_write_ports("")
    return remove_duplicates(ports)


@parse_widths
def get_rom_tdp_ports():
    ports = get_mem_read_ports("a") + get_mem_read_ports("b")
    return remove_duplicates(ports)


@parse_widths
def get_ram_sp_ports():
    ports = get_mem_read_ports("") + get_mem_write_ports("")
    return remove_duplicates(ports)


@parse_widths
def get_ram_tdp_ports():
    ports = (
        get_mem_read_ports("a")
        + get_mem_read_ports("b")
        + get_mem_write_ports("a")
        + get_mem_write_ports("b")
    )
    return remove_duplicates(ports)


@parse_widths
def get_ram_2p_ports():
    ports = get_mem_read_ports("b") + get_mem_write_ports("a")
    return remove_duplicates(ports)


#
# AXI4
#
ID_W = 1
SIZE_W = 3
BURST_W = 2
LOCK_W = 2
CACHE_W = 4
PROT_W = 3
QOS_W = 4
RESP_W = 2
LEN_W = 8


@parse_widths
def get_axil_write_ports():
    return [
        {
            "name": "axil_awaddr",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address write channel address.",
        },
        {
            "name": "axil_awprot",
            "direction": "output",
            "width": PROT_W,
            "descr": "Address write channel protection type. Set to 000 if master output; ignored if slave input.",
        },
        {
            "name": "axil_awvalid",
            "direction": "output",
            "width": 1,
            "descr": "Address write channel valid.",
        },
        {
            "name": "axil_awready",
            "direction": "input",
            "width": 1,
            "descr": "Address write channel ready.",
        },
        {
            "name": "axil_wdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "Write channel data.",
        },
        {
            "name": "axil_wstrb",
            "direction": "output",
            "width": try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            "descr": "Write channel write strobe.",
        },
        {
            "name": "axil_wvalid",
            "direction": "output",
            "width": 1,
            "descr": "Write channel valid.",
        },
        {
            "name": "axil_wready",
            "direction": "input",
            "width": 1,
            "descr": "Write channel ready.",
        },
        {
            "name": "axil_bresp",
            "direction": "input",
            "width": RESP_W,
            "descr": "Write response channel response.",
        },
        {
            "name": "axil_bvalid",
            "direction": "input",
            "width": 1,
            "descr": "Write response channel valid.",
        },
        {
            "name": "axil_bready",
            "direction": "output",
            "width": 1,
            "descr": "Write response channel ready.",
        },
    ]


@parse_widths
def get_axil_read_ports():
    return [
        {
            "name": "axil_araddr",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address read channel address.",
        },
        {
            "name": "axil_arprot",
            "direction": "output",
            "width": PROT_W,
            "descr": "Address read channel protection type. Set to 000 if master output; ignored if slave input.",
        },
        {
            "name": "axil_arvalid",
            "direction": "output",
            "width": 1,
            "descr": "Address read channel valid.",
        },
        {
            "name": "axil_arready",
            "direction": "input",
            "width": 1,
            "descr": "Address read channel ready.",
        },
        {
            "name": "axil_rdata",
            "direction": "input",
            "width": DATA_W,
            "descr": "Read channel data.",
        },
        {
            "name": "axil_rresp",
            "direction": "input",
            "width": RESP_W,
            "descr": "Read channel response.",
        },
        {
            "name": "axil_rvalid",
            "direction": "input",
            "width": 1,
            "descr": "Read channel valid.",
        },
        {
            "name": "axil_rready",
            "direction": "output",
            "width": 1,
            "descr": "Read channel ready.",
        },
    ]


@parse_widths
def get_axil_ports():
    return get_axil_read_ports() + get_axil_write_ports()


@parse_widths
def get_axi_write_ports():
    axil_write = get_axil_write_ports()

    for port in axil_write:
        port["name"] = port["name"].replace("axil", "axi")

    return axil_write + [
        {
            "name": "axi_awid",
            "direction": "output",
            "width": ID_W,
            "descr": "Address write channel ID.",
        },
        {
            "name": "axi_awlen",
            "direction": "output",
            "width": LEN_W,
            "descr": "Address write channel burst length.",
        },
        {
            "name": "axi_awsize",
            "direction": "output",
            "width": SIZE_W,
            "descr": "Address write channel burst size. This signal indicates the size of each transfer in the burst.",
        },
        {
            "name": "axi_awburst",
            "direction": "output",
            "width": BURST_W,
            "descr": "Address write channel burst type.",
        },
        {
            "name": "axi_awlock",
            "direction": "output",
            "width": LOCK_W,
            "descr": "Address write channel lock type.",
        },
        {
            "name": "axi_awcache",
            "direction": "output",
            "width": CACHE_W,
            "descr": "Address write channel memory type. Set to 0000 if master output; ignored if slave input.",
        },
        {
            "name": "axi_awqos",
            "direction": "output",
            "width": QOS_W,
            "descr": "Address write channel quality of service.",
        },
        {
            "name": "axi_wlast",
            "direction": "output",
            "width": 1,
            "descr": "Write channel last word flag.",
        },
        {
            "name": "axi_bid",
            "direction": "input",
            "width": ID_W,
            "descr": "Write response channel ID.",
        },
    ]


@parse_widths
def get_axi_read_ports():
    axil_read = get_axil_read_ports()

    for port in axil_read:
        port["name"] = port["name"].replace("axil", "axi")

    return axil_read + [
        {
            "name": "axi_arid",
            "direction": "output",
            "width": ID_W,
            "descr": "Address read channel ID.",
        },
        {
            "name": "axi_arlen",
            "direction": "output",
            "width": LEN_W,
            "descr": "Address read channel burst length.",
        },
        {
            "name": "axi_arsize",
            "direction": "output",
            "width": SIZE_W,
            "descr": "Address read channel burst size. This signal indicates the size of each transfer in the burst.",
        },
        {
            "name": "axi_arburst",
            "direction": "output",
            "width": BURST_W,
            "descr": "Address read channel burst type.",
        },
        {
            "name": "axi_arlock",
            "direction": "output",
            "width": LOCK_W,
            "descr": "Address read channel lock type.",
        },
        {
            "name": "axi_arcache",
            "direction": "output",
            "width": CACHE_W,
            "descr": "Address read channel memory type. Set to 0000 if master output; ignored if slave input.",
        },
        {
            "name": "axi_arqos",
            "direction": "output",
            "width": QOS_W,
            "descr": "Address read channel quality of service.",
        },
        {
            "name": "axi_rid",
            "direction": "input",
            "width": ID_W,
            "descr": "Read channel ID.",
        },
        {
            "name": "axi_rlast",
            "direction": "input",
            "width": 1,
            "descr": "Read channel last word.",
        },
    ]


@parse_widths
def get_axi_ports():
    return get_axi_read_ports() + get_axi_write_ports()


@parse_widths
def get_axis_ports():
    return [
        {
            "name": "axis_tvalid",
            "direction": "output",
            "width": 1,
            "descr": "axis stream valid.",
        },
        {
            "name": "axis_tready",
            "direction": "input",
            "width": 1,
            "descr": "axis stream ready.",
        },
        {
            "name": "axis_tdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "axis stream data.",
        },
        {
            "name": "axis_tlast",
            "direction": "output",
            "width": 1,
            "descr": "axis stream last.",
        },
    ]


#
# APB
#


@parse_widths
def get_apb_ports():
    return [
        {
            "name": "apb_addr",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Byte address of the transfer.",
        },
        {
            "name": "apb_sel",
            "direction": "output",
            "width": 1,
            "descr": "Slave select.",
        },
        {
            "name": "apb_enable",
            "direction": "output",
            "width": 1,
            "descr": "Enable. Indicates the number of clock cycles of the transfer.",
        },
        {
            "name": "apb_write",
            "direction": "output",
            "width": 1,
            "descr": "Write. Indicates the direction of the operation.",
        },
        {
            "name": "apb_wdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "Write data.",
        },
        {
            "name": "apb_wstrb",
            "direction": "output",
            "width": try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            "descr": "Write strobe.",
        },
        {
            "name": "apb_rdata",
            "direction": "input",
            "width": DATA_W,
            "descr": "Read data.",
        },
        {
            "name": "apb_ready",
            "direction": "input",
            "width": 1,
            "descr": "Ready. Indicates the end of a transfer.",
        },
    ]


#
# Handle signal direction
#


# reverse module signal direction
def reverse_direction(direction):
    if direction == "input":
        return "output"
    elif direction == "output":
        return "input"
    else:
        print(f"ERROR: reverse_direction: invalid argument {direction}.")
        exit(1)


# testbench signal direction
def get_tbsignal_type(direction):
    if direction == "input":
        return "wire"
    elif direction == "output":
        return "reg"
    else:
        print(f"ERROR: reverse_direction: invalid argument {direction}.")
        exit(1)


# get suffix from direction
def get_suffix(direction):
    if direction == "input":
        return "_i"
    elif direction == "output":
        return "_o"
    elif direction == "inout":
        return "_io"
    else:
        print(f"ERROR: reverse_direction: invalid argument {direction}.")
        exit(1)


# Add a given prefix (in upppercase) to every parameter/macro found in the string
def add_param_prefix(width_str, prefix):
    return re.sub(r"([a-zA-Z_][\w_]*)", prefix.upper() + r"\g<1>", width_str)


#
# Port
#


# Write single port with given direction, bus width, and name to file
def write_port(fout, port_prefix, direction, port):
    name = port_prefix + port["name"] + get_suffix(direction)
    mult = 1
    if "mult" in port:
        mult = port["mult"]
    width = port["width"] * mult
    if width == 1:
        width_str = " "
    else:
        width_str = str("(" + str(mult) + "*" + str(port["width"]) + ")")
        width_str = add_param_prefix(width_str, port_prefix)
        width_str = " [" + width_str + "-1:0] "
    fout.write(direction + width_str + name + "," + "\n")


def write_m_port(fout, port_prefix, param_prefix, port_list):
    for i in range(len(port_list)):
        direction = port_list[i]["direction"]
        write_port(fout, port_prefix, direction, port_list[i])


def write_s_port(fout, port_prefix, param_prefix, port_list):
    for i in range(len(port_list)):
        direction = reverse_direction(port_list[i]["direction"])
        write_port(fout, port_prefix, direction, port_list[i])


#
# Portmap
#


def get_port_name(port_prefix, direction, port):
    suffix = get_suffix(direction)
    port_name = port_prefix + port["name"] + suffix
    return (suffix, port_name)


# Generate portmap string for a single port given direction, but width and name
def get_portmap_string(port_prefix, wire_prefix, direction, port, connect_to_port):
    suffix, port_name = get_port_name(port_prefix, direction, port)
    wire_name = wire_prefix + port["name"]
    if connect_to_port:
        wire_name = wire_name + suffix
    return f".{port_name}({wire_name}),\n"


# Write single port with to file
def write_portmap(fout, port_prefix, wire_prefix, direction, port, connect_to_port):
    portmap_string = get_portmap_string(
        port_prefix,
        wire_prefix,
        direction,
        port,
        connect_to_port,
    )
    fout.write(portmap_string)


def write_m_portmap(fout, port_prefix, wire_prefix, port_list):
    for i in range(len(port_list)):
        direction = port_list[i]["direction"]
        write_portmap(fout, port_prefix, wire_prefix, direction, port_list[i], False)


def write_s_portmap(fout, port_prefix, wire_prefix, port_list):
    for i in range(len(port_list)):
        direction = reverse_direction(port_list[i]["direction"])
        write_portmap(fout, port_prefix, wire_prefix, direction, port_list[i], False)


def write_m_m_portmap(fout, port_prefix, wire_prefix, port_list):
    for i in range(len(port_list)):
        direction = port_list[i]["direction"]
        write_portmap(fout, port_prefix, wire_prefix, direction, port_list[i], True)


def write_s_s_portmap(fout, port_prefix, wire_prefix, port_list):
    for i in range(len(port_list)):
        direction = reverse_direction(port_list[i]["direction"])
        write_portmap(fout, port_prefix, wire_prefix, direction, port_list[i], True)


#
# Wire
#


# Write wire with given name, bus size, width to file
def write_single_wire(fout, wire_prefix, param_prefix, wire, for_tb, direction):
    wire_name = wire_prefix + wire["name"]
    wtype = "wire"
    mult = 1
    if "mult" in wire:
        mult = wire["mult"]
    if for_tb:
        if direction == "input":
            wire_name = wire_name + get_suffix(wire["direction"])
            wtype = get_tbsignal_type(reverse_direction(wire["direction"]))
        else:
            wire_name = wire_name + get_suffix(reverse_direction(wire["direction"]))
            wtype = get_tbsignal_type(wire["direction"])
    width_str = add_param_prefix(str(wire["width"]), param_prefix)
    width_str = " [(" + str(mult) + "*" + width_str + ")-1:0] "
    fout.write(wtype + width_str + wire_name + "; //" + "\n")


def write_wire(fout, wire_prefix, param_prefix, wires):
    for i in range(len(wires)):
        write_single_wire(fout, wire_prefix, param_prefix, wires[i], False, "")


def write_tb_wire(fout, wire_prefix, param_prefix, wires, direction):
    for i in range(len(wires)):
        write_single_wire(fout, wire_prefix, param_prefix, wires[i], True, direction)


def write_m_tb_wire(fout, wire_prefix, param_prefix, wires):
    write_tb_wire(fout, wire_prefix, param_prefix, wires, "output")


def write_s_tb_wire(fout, wire_prefix, param_prefix, wires):
    write_tb_wire(fout, wire_prefix, param_prefix, wires, "input")


#
# GENERATE INTERFACES
#


def gen_if(name, file_prefix, port_prefix, wire_prefix, ports, mult=1, widths={}):
    # print(name, file_prefix, port_prefix, wire_prefix, ports, mult)

    # get param prefix
    param_prefix = port_prefix.upper()

    # get ports
    if ports == []:
        eval_str = "get_" + name + "_ports(widths=widths)"
        # print(eval_str)
        ports = eval(eval_str)

        if mult > 1:
            for port in ports:
                port["mult"] = mult

    #
    # GENERATE SNIPPETS FOR ALL TYPES OF PORTS AND WIRES
    #
    # for if_type in range(len(if_types)):
    for i in range(0, 9):
        fout = open(file_prefix + name + "_" + if_types[i] + ".vs", "w")

        # get prefixes
        if "portmap" in if_types[i]:
            prefix1 = port_prefix
            prefix2 = wire_prefix
        elif "wire" in if_types[i]:
            prefix1 = wire_prefix
            prefix2 = param_prefix
        else:  # "port"
            prefix1 = port_prefix
            prefix2 = param_prefix

        eval_str = "write_" + if_types[i] + "(fout, prefix1, prefix2, ports)"
        # print(eval_str, prefix1, prefix2)
        eval(eval_str)
        fout.close()


#
# Test this Python module
#


if __name__ == "__main__":
    # for if_type in range(len(if_names)):
    for i in range(0, 16):
        gen_if(if_names[i], "bla_", "di_", "da_", [])
