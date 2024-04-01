from typing import Dict

from iob_base import iob_base
from iob_port import find_port
from iob_wire import find_wire


class iob_instance(iob_base):
    """Class to describe a module's (Verilog) instance"""

    def __init__(
        self,
        *args,
        instance_name: str = None,
        parameters: Dict = {},
        connect: Dict = {},
        instantiator=None,
        **kwargs
    ):
        """Build a (Verilog) instance
        param parameters: Verilog parameter values for this instance
                          Key: Verilog parameter name, Value: Verilog parameter value
        param connect: External wires to connect to ports of this instance
                       Key: Port name, Value: Wire name
        param instantiator: Module that is instantiating this instance
        """
        self.instance_name = instance_name or self.__class__.__name__ + "_inst"
        self.set_default_attribute("description", "Default description")
        # Verilog parameter values
        self.set_default_attribute("parameters", parameters)
        # Only use this instance in Verilog if this Verilog macro is defined
        self.set_default_attribute("if_defined", None, str)

        # Connect instance ports to external wires
        for port_name, wire_name in connect.items():
            port = find_port(self, port_name)
            wire = find_wire(instantiator, wire_name)
            port.connect_external(wire)
