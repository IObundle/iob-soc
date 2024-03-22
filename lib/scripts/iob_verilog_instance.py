from dataclasses import dataclass
from typing import Dict

from iob_module import iob_module


# Class that describes a Verilog instance of a module
# TODO DELETE THIS
@dataclass
class iob_verilog_instance:
    name: str = "instance_0"  # Name of the Verilog instance
    description: str = "Default description"  # Description of the Verilog instance
    module: iob_module  # Python module object that describes the Verilog module being instantiated
    parameters: Dict[
        str, str
    ]  # Dictionary of Verilog parameters to pass to this instance

    def __post_init__(self):
        if not self.module:
            raise Exception("Module to instantiate must be defined")
        if not self.parameters:
            self.parameters = {}
