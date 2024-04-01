from typing import Dict

from iob_base import iob_base, find_obj_in_list, fail_with_msg


class iob_instance(iob_base):
    """Class to describe a module's (Verilog) instance"""

    def __init__(
        self,
        *args,
        instance_name: str = None,
        parameters: Dict = {},
        connect: Dict = {},
        instantiator=None,
        **kwargs,
    ):
        """Build a (Verilog) instance
        param parameters: Verilog parameter values for this instance
                          Key: Verilog parameter name, Value: Verilog parameter value
        param connect: External wires to connect to ports of this instance
                       Key: Port name, Value: Wire name
        param instantiator: Module that is instantiating this instance
        """
        self.set_default_attribute(
            "instance_name", instance_name or self.__class__.__name__ + "_inst", str
        )
        self.set_default_attribute("description", "Default description", str)
        # Verilog parameter values
        self.set_default_attribute("parameters", parameters, Dict)
        # Only use this instance in Verilog if this Verilog macro is defined
        self.set_default_attribute("if_defined", None, str)

        # Connect instance ports to external wires
        for port_name, wire_name in connect.items():
            port = find_obj_in_list(self.ports, port_name)
            if not port:
                fail_with_msg(
                    f"Port '{port_name}' not found in instance '{self.instance_name}' of module '{instantiator.name}'!"
                )
            wire = find_obj_in_list(instantiator.wires, wire_name) or find_obj_in_list(
                instantiator.ports, wire_name
            )
            if not wire:
                fail_with_msg(
                    f"Wire/port '{wire_name}' not found in module '{instantiator.name}'!"
                )
            port.connect_external(wire)
