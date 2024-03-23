from typing import List

from iob_base import iob_base
from iob_conf import create_conf
from iob_port import create_port
from iob_wire import create_wire, get_wire_signal
from iob_reg import create_reg


class iob_module(iob_base):
    """Class to describe a (Verilog) module"""

    def __init__(self, *args, **kwargs):
        # List of module macros and Verilog (false-)parameters
        self.set_default_value("confs", [])
        self.set_default_value("ports", [])
        self.set_default_value("wires", [])
        self.set_default_value("regs", [])
        # List of instances of other cores inside this core
        self.set_default_value("blocks", [])
        # List of core Verilog snippets
        self.set_default_value("snippets", [])

    def create_conf(self, *args, **kwargs):
        create_conf(self, *args, **kwargs)

    def create_port(self, *args, **kwargs):
        create_port(self, *args, **kwargs)

    def create_wire(self, *args, **kwargs):
        create_wire(self, *args, **kwargs)

    def get_wire_signal(self, *args, **kwargs):
        get_wire_signal(self, *args, **kwargs)

    def create_reg(self, *args, **kwargs):
        create_reg(self, *args, **kwargs)

    def create_instance(self, core_name: str, *args, **kwargs):
        """Import core and create an instance of it inside this module
        param core_name: Name of the core
        """
        exec(f"from {core_name} import {core_name}")
        instance = vars()[core_name](*args, **kwargs)
        self.blocks.append(instance)

    def create_snippet(self, snippet_outputs: List[str], snippet_code: str):
        """Create a Verilog snippet to insert in this core.
        param snippet_outputs: List of output ports of this snippet.
                               Used internally to calculate global wires of
                               the project.
        param snippet_code: Verilog code of the snippet.
        """
        # TODO: Store outputs and use them for global wires list
        self.snippets.append(snippet_code)
