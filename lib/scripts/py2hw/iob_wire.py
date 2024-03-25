from dataclasses import dataclass
from typing import List, Dict

import iob_base
import if_gen


@dataclass
class iob_wire:
    """Class to represent a wire in an iob module"""

    name: str = None

    """ 'if_gen' related arguments """
    # Type of interface: 'master', 'slave' or '' (for neither)
    type: str = "master"
    wire_prefix: str = ""
    mult: str = ""
    widths: Dict[str, str] = None

    """ Other wire arguments """
    descr: str = "Default description"
    # Only set the wire if this Verilog macro is defined
    if_defined: str = None
    # List of signals belonging to this wire
    # (each signal is similar to a Verilog wire)
    signals: List = None
    # Reference to a global signal connected to this one
    global_wire = None

    def __post_init__(self):
        if not self.name:
            raise ValueError("Wire name is not set")

        if self.name in if_gen.if_names:
            # TODO: Use if_gen to generate wire
            return

        # Create wire manually
        # TODO


def create_wire(core, *args, **kwargs):
    """Creates a new wire object and adds it to the core's wire list
    param core: core object
    """
    # Ensure 'wires' list exists
    core.set_default_attribute("wires", [])
    wire = iob_wire(*args, **kwargs)
    core.wires.append(wire)


def get_wire_signal(core, wire_name: str, signal_name: str):
    """Return a signal reference from a given wire.
    param core: core object
    param wire_name: name of wire in the core's local wire list
    param signal_name: name of signal in the wire's signal list
    """

    for wire in core.wire_list:
        if wire.name == wire_name:
            return wire
