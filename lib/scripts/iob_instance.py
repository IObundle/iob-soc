from typing import Dict

from iob_base import iob_base


class iob_instance(iob_base):
    """Class to describe a module's (Verilog) instance"""

    def __init__(self, *args, parameters: Dict = {}, **kwargs):
        self.set_default_value("name", self.__class__.__name__)
        self.set_default_value("description", "Default description")
        # Verilog parameter values
        self.set_default_value("parameters", parameters)
