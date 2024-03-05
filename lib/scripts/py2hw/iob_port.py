from dataclasses import dataclass
from typing import Dict, List
from iob_wire import iob_wire


@dataclass
class iob_port:
    """ Describes an IO port. """
    direction: str
    description: str = "Default description"

    def __post_init__(self):
        if not self.direction:
            raise Exception("Port direction is required")
        elif self.direction not in ["input", "output", "inout"]:
            raise Exception("Error: Direction must be 'input', 'output', or 'inout'.")

    def connect(self, value):
        """Connect a wire to the port"""
        if not isinstance(value, (iob_wire, iob_port)):
            raise ValueError(f"Error: Port {self.name} can only be connected to a wire or port.")
        if value.width != self.width:
            print(f"Error: Port {self.name} width ({self.width}) does not match wire {value.name} width ({value.width}).")
            exit(1)
        self.value = value

    def set_value(self, value):
        self.wire().set_value(value)

    def get_value(self):
        return self.wire().get_value()

    def wire(self):
        """Return the wire connected to the port"""
        return self.value
        
    def print_port(self, comma=True):
        if comma:
            print(f"      {self.direction} [{self.width}-1:0] {self.name},")
        else:
            print(f"      {self.direction} [{self.width}-1:0] {self.name}")

        
    def print_port_assign(self, comma=True):
        if not isinstance(self.value, (iob_wire, iob_port)):
            print(f"Error: Port {self.name} is not connected.")
            exit(1)
        if comma:
            print(f"      .{self.name}({self.value.name}),")
        else:
            print(f"      .{self.name}({self.value.name})")


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
