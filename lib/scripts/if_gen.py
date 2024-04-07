#!/usr/bin/env python3

# this script generates interfaces for Verilog modules and testbenches to add a
# new standard interface, add the name to the interface_names list, and an
# interface dictionary as below run this script with the -h option for help

import re
from copy import deepcopy
from iob_signal import iob_signal, iob_signal_reference

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
    "rs232",
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
    """Decorator to temporarily change values of global variables based on `widths` dictionary."""

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
        iob_signal(
            name="iob_valid",
            direction="output",
            width=1,
            descr="Request address is valid.",
        ),
        iob_signal(
            name="iob_addr",
            direction="output",
            width=ADDR_W,
            descr="Address.",
        ),
        iob_signal(
            name="iob_wdata",
            direction="output",
            width=DATA_W,
            descr="Write data.",
        ),
        iob_signal(
            name="iob_wstrb",
            direction="output",
            width=try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            descr="Write strobe.",
        ),
        iob_signal(
            name="iob_rvalid",
            direction="input",
            width=1,
            descr="Read data valid.",
        ),
        iob_signal(
            name="iob_rdata",
            direction="input",
            width=DATA_W,
            descr="Read data.",
        ),
        iob_signal(
            name="iob_ready",
            direction="input",
            width=1,
            descr="Interface ready.",
        ),
    ]


@parse_widths
def get_clk_rst_ports():
    return [
        iob_signal(
            name="clk",
            direction="output",
            width=1,
            descr="Clock",
        ),
        iob_signal(
            name="arst",
            direction="output",
            width=1,
            descr="Asynchronous active-high reset",
        ),
    ]


@parse_widths
def get_clk_en_rst_ports():
    clk_rst_ports = get_clk_rst_ports()
    return [
        clk_rst_ports[0],
        iob_signal(
            name="cke",
            direction="output",
            width=1,
            descr="Enable",
        ),
        clk_rst_ports[1],
    ]


def get_mem_ports(suffix):
    return [
        iob_signal(
            name="clk" + "_" + suffix,
            direction="output",
            width=1,
            descr=f"Clock port {suffix}",
        ),
        iob_signal(
            name="en" + "_" + suffix,
            direction="output",
            width=1,
            descr=f"Enable port {suffix}",
        ),
        iob_signal(
            name="addr" + "_" + suffix,
            direction="output",
            width=ADDR_W,
            descr="Address port {suffix}",
        ),
    ]


def get_mem_read_ports(suffix):
    mem_ports = get_mem_ports(suffix)
    mem_read_ports = mem_ports + [
        iob_signal(
            name="rdata" + "_" + suffix,
            direction="input",
            width=DATA_W,
            descr="Data port {suffix}",
        ),
    ]
    return mem_read_ports


def get_mem_write_ports(suffix):
    mem_ports = get_mem_ports(suffix)
    mem_write_ports = mem_ports + [
        iob_signal(
            name="wdata" + "_" + suffix,
            direction="output",
            width=DATA_W,
            descr="Data port {suffix}",
        ),
        iob_signal(
            name="wstrb" + "_" + suffix,
            direction="output",
            width=try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            descr="Write strobe port {suffix}",
        ),
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
        iob_signal(
            name="axil_awaddr",
            direction="output",
            width=ADDR_W,
            descr="Address write channel address.",
        ),
        iob_signal(
            name="axil_awprot",
            direction="output",
            width=PROT_W,
            descr="Address write channel protection type. Set to 000 if master output; ignored if slave input.",
        ),
        iob_signal(
            name="axil_awvalid",
            direction="output",
            width=1,
            descr="Address write channel valid.",
        ),
        iob_signal(
            name="axil_awready",
            direction="input",
            width=1,
            descr="Address write channel ready.",
        ),
        iob_signal(
            name="axil_wdata",
            direction="output",
            width=DATA_W,
            descr="Write channel data.",
        ),
        iob_signal(
            name="axil_wstrb",
            direction="output",
            width=try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            descr="Write channel write strobe.",
        ),
        iob_signal(
            name="axil_wvalid",
            direction="output",
            width=1,
            descr="Write channel valid.",
        ),
        iob_signal(
            name="axil_wready",
            direction="input",
            width=1,
            descr="Write channel ready.",
        ),
        iob_signal(
            name="axil_bresp",
            direction="input",
            width=RESP_W,
            descr="Write response channel response.",
        ),
        iob_signal(
            name="axil_bvalid",
            direction="input",
            width=1,
            descr="Write response channel valid.",
        ),
        iob_signal(
            name="axil_bready",
            direction="output",
            width=1,
            descr="Write response channel ready.",
        ),
    ]


@parse_widths
def get_axil_read_ports():
    return [
        iob_signal(
            name="axil_araddr",
            direction="output",
            width=ADDR_W,
            descr="Address read channel address.",
        ),
        iob_signal(
            name="axil_arprot",
            direction="output",
            width=PROT_W,
            descr="Address read channel protection type. Set to 000 if master output; ignored if slave input.",
        ),
        iob_signal(
            name="axil_arvalid",
            direction="output",
            width=1,
            descr="Address read channel valid.",
        ),
        iob_signal(
            name="axil_arready",
            direction="input",
            width=1,
            descr="Address read channel ready.",
        ),
        iob_signal(
            name="axil_rdata",
            direction="input",
            width=DATA_W,
            descr="Read channel data.",
        ),
        iob_signal(
            name="axil_rresp",
            direction="input",
            width=RESP_W,
            descr="Read channel response.",
        ),
        iob_signal(
            name="axil_rvalid",
            direction="input",
            width=1,
            descr="Read channel valid.",
        ),
        iob_signal(
            name="axil_rready",
            direction="output",
            width=1,
            descr="Read channel ready.",
        ),
    ]


@parse_widths
def get_axil_ports():
    return get_axil_read_ports() + get_axil_write_ports()


@parse_widths
def get_axi_write_ports():
    axil_write = get_axil_write_ports()

    for port in axil_write:
        port.name = port.name.replace("axil", "axi")

    return axil_write + [
        iob_signal(
            name="axi_awid",
            direction="output",
            width=ID_W,
            descr="Address write channel ID.",
        ),
        iob_signal(
            name="axi_awlen",
            direction="output",
            width=LEN_W,
            descr="Address write channel burst length.",
        ),
        iob_signal(
            name="axi_awsize",
            direction="output",
            width=SIZE_W,
            descr="Address write channel burst size. This signal indicates the size of each transfer in the burst.",
        ),
        iob_signal(
            name="axi_awburst",
            direction="output",
            width=BURST_W,
            descr="Address write channel burst type.",
        ),
        iob_signal(
            name="axi_awlock",
            direction="output",
            width=LOCK_W,
            descr="Address write channel lock type.",
        ),
        iob_signal(
            name="axi_awcache",
            direction="output",
            width=CACHE_W,
            descr="Address write channel memory type. Set to 0000 if master output; ignored if slave input.",
        ),
        iob_signal(
            name="axi_awqos",
            direction="output",
            width=QOS_W,
            descr="Address write channel quality of service.",
        ),
        iob_signal(
            name="axi_wlast",
            direction="output",
            width=1,
            descr="Write channel last word flag.",
        ),
        iob_signal(
            name="axi_bid",
            direction="input",
            width=ID_W,
            descr="Write response channel ID.",
        ),
    ]


@parse_widths
def get_axi_read_ports():
    axil_read = get_axil_read_ports()

    for port in axil_read:
        port.name = port.name.replace("axil", "axi")

    return axil_read + [
        iob_signal(
            name="axi_arid",
            direction="output",
            width=ID_W,
            descr="Address read channel ID.",
        ),
        iob_signal(
            name="axi_arlen",
            direction="output",
            width=LEN_W,
            descr="Address read channel burst length.",
        ),
        iob_signal(
            name="axi_arsize",
            direction="output",
            width=SIZE_W,
            descr="Address read channel burst size. This signal indicates the size of each transfer in the burst.",
        ),
        iob_signal(
            name="axi_arburst",
            direction="output",
            width=BURST_W,
            descr="Address read channel burst type.",
        ),
        iob_signal(
            name="axi_arlock",
            direction="output",
            width=LOCK_W,
            descr="Address read channel lock type.",
        ),
        iob_signal(
            name="axi_arcache",
            direction="output",
            width=CACHE_W,
            descr="Address read channel memory type. Set to 0000 if master output; ignored if slave input.",
        ),
        iob_signal(
            name="axi_arqos",
            direction="output",
            width=QOS_W,
            descr="Address read channel quality of service.",
        ),
        iob_signal(
            name="axi_rid",
            direction="input",
            width=ID_W,
            descr="Read channel ID.",
        ),
        iob_signal(
            name="axi_rlast",
            direction="input",
            width=1,
            descr="Read channel last word.",
        ),
    ]


@parse_widths
def get_axi_ports():
    return get_axi_read_ports() + get_axi_write_ports()


@parse_widths
def get_axis_ports():
    return [
        iob_signal(
            name="axis_tvalid",
            direction="output",
            width=1,
            descr="axis stream valid.",
        ),
        iob_signal(
            name="axis_tready",
            direction="input",
            width=1,
            descr="axis stream ready.",
        ),
        iob_signal(
            name="axis_tdata",
            direction="output",
            width=DATA_W,
            descr="axis stream data.",
        ),
        iob_signal(
            name="axis_tlast",
            direction="output",
            width=1,
            descr="axis stream last.",
        ),
    ]


#
# APB
#


@parse_widths
def get_apb_ports():
    return [
        iob_signal(
            name="apb_addr",
            direction="output",
            width=ADDR_W,
            descr="Byte address of the transfer.",
        ),
        iob_signal(
            name="apb_sel",
            direction="output",
            width=1,
            descr="Slave select.",
        ),
        iob_signal(
            name="apb_enable",
            direction="output",
            width=1,
            descr="Enable. Indicates the number of clock cycles of the transfer.",
        ),
        iob_signal(
            name="apb_write",
            direction="output",
            width=1,
            descr="Write. Indicates the direction of the operation.",
        ),
        iob_signal(
            name="apb_wdata",
            direction="output",
            width=DATA_W,
            descr="Write data.",
        ),
        iob_signal(
            name="apb_wstrb",
            direction="output",
            width=try_math_eval(f"{DATA_W}/{DATA_SECTION_W}"),
            descr="Write strobe.",
        ),
        iob_signal(
            name="apb_rdata",
            direction="input",
            width=DATA_W,
            descr="Read data.",
        ),
        iob_signal(
            name="apb_ready",
            direction="input",
            width=1,
            descr="Ready. Indicates the end of a transfer.",
        ),
    ]


#
# RS232
#
N_PINS = 4


@parse_widths
def get_rs232_ports():
    assert N_PINS in [2, 4, 9], "rs232 'N_PINS' must be 2, 4 or 9!"
    ports = []
    if N_PINS == 9:
        ports += [
            iob_signal(
                name="rs232_dcd",
                direction="input",
                width=1,
                descr="Data carrier detect.",
            ),
        ]
    if N_PINS in [2, 4]:
        ports += [
            iob_signal(
                name="rs232_rxd",
                direction="input",
                width=1,
                descr="Receive data.",
            ),
            iob_signal(
                name="rs232_txd",
                direction="output",
                width=1,
                descr="Transmit data.",
            ),
        ]
    if N_PINS == 9:
        ports += [
            iob_signal(
                name="rs232_dtr",
                direction="output",
                width=1,
                descr="Data terminal ready.",
            ),
            iob_signal(
                name="rs232_gnd",
                direction="input",
                width=1,
                descr="Ground.",
            ),
            iob_signal(
                name="rs232_dsr",
                direction="input",
                width=1,
                descr="Data set ready.",
            ),
        ]
    if N_PINS == 4:
        ports += [
            iob_signal(
                name="rs232_rts",
                direction="output",
                width=1,
                descr="Request to send.",
            ),
            iob_signal(
                name="rs232_cts",
                direction="input",
                width=1,
                descr="Clear to send.",
            ),
        ]
    if N_PINS == 9:
        ports += [
            iob_signal(
                name="rs232_ri",
                direction="input",
                width=1,
                descr="Ring indicator.",
            ),
        ]

    return ports


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


def reverse_signals_dir(signals):
    new_signals = deepcopy(signals)
    for signal in new_signals:
        signal.direction = reverse_direction(signal.direction)
    return new_signals


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


# Write single port with given bus width, and name to file
def write_port(fout, port_prefix, param_prefix, port):
    direction = port.direction
    name = port_prefix + port.name + get_suffix(direction)
    width_str = add_param_prefix(str(port.width), param_prefix)
    width_str = " [" + width_str + "-1:0] "
    fout.write(direction + width_str + name + "," + "\n")


def write_m_port(fout, port_prefix, param_prefix, port_list):
    for port in port_list:
        write_port(fout, port_prefix, param_prefix, port)


def write_s_port(fout, port_prefix, param_prefix, port_list):
    write_m_port(fout, port_prefix, param_prefix, port_list)


#
# Portmap
#


def get_port_name(port_prefix, port):
    suffix = get_suffix(port.direction)
    port_name = port_prefix + port.name + suffix
    return (suffix, port_name)


# Generate portmap string for a single port but width and name
def get_portmap_string(port_prefix, wire_prefix, port, connect_to_port):
    suffix, port_name = get_port_name(port_prefix, port)
    wire_name = wire_prefix + port.name
    if connect_to_port:
        wire_name = wire_name + suffix
    return f".{port_name}({wire_name}),\n"


# Write single port with to file
def write_portmap(fout, port_prefix, wire_prefix, port, connect_to_port):
    portmap_string = get_portmap_string(
        port_prefix,
        wire_prefix,
        port,
        connect_to_port,
    )
    fout.write(portmap_string)


def write_m_portmap(fout, port_prefix, wire_prefix, port_list):
    for port in port_list:
        write_portmap(fout, port_prefix, wire_prefix, port, False)


def write_s_portmap(fout, port_prefix, wire_prefix, port_list):
    write_m_portmap(fout, port_prefix, wire_prefix, port_list)


def write_m_m_portmap(fout, port_prefix, wire_prefix, port_list):
    for port in port_list:
        write_portmap(fout, port_prefix, wire_prefix, port, True)


def write_s_s_portmap(fout, port_prefix, wire_prefix, port_list):
    write_m_m_portmap(fout, port_prefix, wire_prefix, port_list)


#
# Wire
#


# Write wire with given name, bus size, width to file
def write_single_wire(fout, wire_prefix, param_prefix, wire, for_tb):
    if isinstance(wire, iob_signal_reference):
        return
    wire_name = wire_prefix + wire.name
    wtype = "wire"
    if for_tb:
        wire_name = wire_name + get_suffix(reverse_direction(wire.direction))
        wtype = get_tbsignal_type(wire.direction)
    width_str = add_param_prefix(str(wire.width), param_prefix)
    width_str = " [" + width_str + "-1:0] "
    fout.write(wtype + width_str + wire_name + ";\n")


def write_wire(fout, wire_prefix, param_prefix, wires):
    for wire in wires:
        write_single_wire(fout, wire_prefix, param_prefix, wire, False)


def write_tb_wire(fout, wire_prefix, param_prefix, wires):
    for wire in wires:
        write_single_wire(fout, wire_prefix, param_prefix, wire, True)


def write_m_tb_wire(fout, wire_prefix, param_prefix, wires):
    write_tb_wire(fout, wire_prefix, param_prefix, wires)


def write_s_tb_wire(fout, wire_prefix, param_prefix, wires):
    write_m_tb_wire(fout, wire_prefix, param_prefix, wires)


#
# GENERATE INTERFACES
#


def get_signals(name, if_type="", mult=1, widths={}):
    """Get list of signals for given interface
    param if_type: Type of interface.
                   Examples: '' (unspecified), 'master', 'slave', ...
    param mult: Multiplication factor for all signal widths.
    param widths: Dictionary for configuration of specific signal widths.
    """
    eval_str = "get_" + name + "_ports(widths=widths)"
    # print(eval_str)
    signals = eval(eval_str)

    # Set direction according to if_type
    if if_type == "slave":
        signals = reverse_signals_dir(signals)
    # TODO: Code to support other if_types
    # For example, the rs232 has not type.

    if mult > 1:
        for signal in signals:
            signal.width = f"({mult}*{signal.width})"

    return signals


def gen_if(
    name, file_prefix, port_prefix, wire_prefix, param_prefix, mult=1, widths={}
):
    # print(name, file_prefix, port_prefix, wire_prefix, mult)

    # get param prefix
    param_prefix = param_prefix.upper()

    #
    # GENERATE SNIPPETS FOR ALL TYPES OF PORTS AND WIRES
    #
    for if_type in if_types:
        fout = open(file_prefix + name + "_" + if_type + ".vs", "w")

        # get prefixes
        if "portmap" in if_type:
            prefix1 = port_prefix
            prefix2 = wire_prefix
        elif "wire" in if_type:
            prefix1 = wire_prefix
            prefix2 = param_prefix
        else:  # "port"
            prefix1 = port_prefix
            prefix2 = param_prefix

        # get ports
        if if_type.startswith("s"):
            ports = get_signals(name, "slave", mult, widths)
        else:
            ports = get_signals(name, "master", mult, widths)

        eval_str = "write_" + if_type + "(fout, prefix1, prefix2, ports)"
        # print(eval_str, prefix1, prefix2)
        eval(eval_str)
        fout.close()


def gen_wires(name, file_prefix, param_prefix, wire_prefix, signals, mult=1, widths={}):
    # get signals
    if signals == []:
        signals = get_signals(name, mult, widths)

    fout = open(file_prefix + name + "_wire.vs", "w")
    write_wire(fout, wire_prefix, param_prefix, signals)
    fout.close()


#
# Test this Python module
#


if __name__ == "__main__":
    for if_name in if_names:
        gen_if(if_name, "bla_", "di_", "da_", [])
