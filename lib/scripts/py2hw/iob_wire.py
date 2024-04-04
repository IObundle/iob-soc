from dataclasses import dataclass, field
from typing import List, Dict

from iob_base import find_obj_in_list, fail_with_msg


@dataclass
class iob_wire:
    """Class to represent a wire in an iob module"""

    name: str = ""

    """ 'if_gen' related arguments """
    wire_prefix: str = ""
    mult: str | int = 1
    widths: Dict[str, str] = field(default_factory=dict)
    file_prefix: str = ""

    """ Other wire arguments """
    descr: str = "Default description"
    # Only set the wire if this Verilog macro is defined
    if_defined: str = ""
    # List of signals belonging to this wire
    # (each signal is similar to a Verilog wire)
    signals: List = field(default_factory=list)
    # Reference to a global signal connected to this one
    global_wire = None

    def __post_init__(self):
        if not self.name:
            fail_with_msg("Wire name is not set", ValueError)


def create_wire(core, *args, **kwargs):
    """Creates a new wire object and adds it to the core's wire list
    param core: core object
    """
    # Ensure 'wires' list exists
    core.set_default_attribute("wires", [])
    wire = iob_wire(*args, **kwargs)
    core.wires.append(wire)


# It may better for us to use a class instead of dictionaries to represent a 'signal'
# @dataclass
# class iob_signal:
#     pass


@dataclass
class iob_signal_reference:
    """Class that references another signal
    Use to distinguish from a real signal (for generator scripts)
    """

    signal: dict | None = None


def get_wire_signal(core, wire_name: str, signal_name: str):
    """Return a signal reference from a given wire.
    param core: core object
    param wire_name: name of wire in the core's local wire list
    param signal_name: name of signal in the wire's signal list
    """
    wire = find_obj_in_list(core.wires, wire_name) or find_obj_in_list(
        core.ports, wire_name
    )
    if not wire:
        fail_with_msg(f"Could not find wire/port '{wire_name}'!")

    signal = find_obj_in_list(wire.signals, signal_name)
    if not signal:
        fail_with_msg(
            f"Could not find signal '{signal_name}' of wire/port '{wire_name}'!"
        )

    return iob_signal_reference(signal=signal)


def get_real_signal(signal):
    """Given a signal reference, follow the reference (recursively) and return the real signal"""
    while isinstance(signal, iob_signal_reference):
        signal = signal.signal
    return signal
