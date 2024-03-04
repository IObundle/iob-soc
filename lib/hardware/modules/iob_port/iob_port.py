from dataclasses import dataclass
from typing import Dict, List


# Class that describes a Verilog instance of a module
@dataclass
class iob_port:
    """ Describes an IO port. """
    name: str  # Name of the port
    direction: str  # Direction of the port #TODO: would be nice if instead of 'str' we only accepted 'input', 'output', or 'inout'
    width: int = 1  # Width of the port
    description: str = "Default description"  # Description of the Verilog instance

    def __post_init__(self):
        if not self.name:
            raise Exception("Port name is required")
        if not self.direction:
            raise Exception("Port direction is required")


@dataclass
class iob_interface:
    """ Describes a group of ports.
    If list of ports is empty, try to generate them automatically based on interface name and attributes.
    """
    name: str  # Name of the interface
    type: str = "master"  # 'master' or 'slave'
    wire_prefix: str
    port_prefix: str
    mult: str
    widths: Dict[str, str]
    description: str = "Default description"
    if_defined: str  # Only create this interface if macro given here is defined
    ports: List[iob_port]  # List of iob_ports for this interface

    def __post_init__(self):
        if not self.name:
            raise Exception("Interface name is required")
