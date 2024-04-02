from iob_base import iob_base
from iob_conf import create_conf
from iob_port import create_port
from iob_wire import create_wire, get_wire_signal
from iob_csr import create_csr
from iob_snippet import create_snippet


class iob_module(iob_base):
    """Class to describe a (Verilog) module"""

    global_top_module = None  # Datatype is 'iob_module'

    def __init__(self, *args, **kwargs):
        self.set_default_attribute("name", self.__class__.__name__, str)
        # List of module macros and Verilog (false-)parameters
        self.set_default_attribute("confs", [], list)
        self.set_default_attribute("ports", [], list)
        self.set_default_attribute("wires", [], list)
        # List of core Control/Status Registers
        self.set_default_attribute("csrs", [], list)
        # List of core Verilog snippets
        self.set_default_attribute("snippets", [], list)
        # List of instances of other cores inside this core
        self.set_default_attribute("blocks", [], list)

    def create_conf(self, *args, **kwargs):
        create_conf(self, *args, **kwargs)

    def create_port(self, *args, **kwargs):
        create_port(self, *args, **kwargs)

    def create_wire(self, *args, **kwargs):
        create_wire(self, *args, **kwargs)

    def get_wire_signal(self, *args, **kwargs):
        get_wire_signal(self, *args, **kwargs)

    def create_csr(self, *args, **kwargs):
        create_csr(self, *args, **kwargs)

    def create_snippet(self, *args, **kwargs):
        create_snippet(self, *args, **kwargs)

    def create_instance(self, core_name: str, instance_name: str, *args, **kwargs):
        """Import core and create an instance of it inside this module
        param core_name: Name of the core
        param instance_name: Verilog instance name
        """
        # Ensure 'blocks' list exists
        self.set_default_attribute("blocks", [])
        # Ensure global top module is set
        self.update_global_top_module()

        exec(f"from {core_name} import {core_name}")
        instance = vars()[core_name](
            *args, instance_name=instance_name, instantiator=self, **kwargs
        )
        self.blocks.append(instance)

    def update_global_top_module(self):
        """Update global top module if it has not been set before.
        The first module to call this method is the global top module.
        """
        if __class__.global_top_module is None:
            __class__.global_top_module = self
