# Class that describes a Verilog instance of a module
class iob_verilog_instance:
    def __init__(
        self,
        name="instance_0",
        description="default description",
        module=None,
        parameters={},
    ):
        self.name = name  # Name of the Verilog instance
        self.description = description  # Description of the Verilog instance
        self.module = module  # Python module object that describes the Verilog module being instantiated
        self.parameters = (
            parameters  # Dictionary of Verilog parameters to pass to this instance
        )
