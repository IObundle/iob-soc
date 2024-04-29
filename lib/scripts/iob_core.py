import sys
import os
import shutil
import json
from pathlib import Path

import iob_colors

import copy_srcs

import config_gen
import param_gen
import io_gen
import wire_gen
import reg_gen
import block_gen
import snippet_gen
import doc_gen
import verilog_gen
import ipxact_gen

from iob_module import iob_module
from iob_instance import iob_instance
from iob_base import find_obj_in_list, fail_with_msg, find_file, import_python_module
import sw_tools
import verilog_format
import verilog_lint


class iob_core(iob_module, iob_instance):
    """Generic class to describe how to generate a base IOb IP core"""

    global_wires: list
    # Project settings
    global_build_dir: str = ""
    global_project_root: str = "."
    global_project_vformat: bool = True
    global_project_vlint: bool = True
    # Project wide special target. Used when we don't want to run normal setup (for example, when cleaning).
    global_special_target: str = ""

    def __init__(
        self,
        *args,
        purpose: str = "hardware",
        attributes={},
        connect: dict = {},
        instantiator=None,
        **kwargs,
    ):
        """Build a core (includes module and instance attributes)
        param purpose: Purpose for setup of the core (hardware/simulation/fpga)
        param attributes: py2hwsw dictionary describing the core
            Notes:
                1) Each key/value pair in the dictionary describes an attribute name and
                   corresponding attribute value of the core.
                2) If the dictionary contains a key that does not match any attribute
                   of the core, then an error will be raised.
                3) The values will be processed by the `set_handler` method of the
                   corresponding attribute. This method will convert from the py2hwsw
                   dictionary datatypes into the internal IObundle datatypes.
                   For example, it converts a 'wire' dict into an `iob_wire` object.
                4) If another constructor argument is also given (like the argument
                   'purpose'), and this dictionary also contains a key for the same
                   attribute (like the key 'purpose'), then the value given in the
                   dictionary will override the one from the constructor argument.
        param connect: External wires to connect to ports of this instance
                       Key: Port name, Value: Wire name
        param instantiator: Module that is instantiating this instance
        """
        # Inherit attributes from superclasses
        iob_module.__init__(self, *args, **kwargs)
        iob_instance.__init__(self, *args, **kwargs)
        # Ensure global top module is set
        self.update_global_top_module(attributes)
        # CPU interface for control status registers
        self.set_default_attribute("csr_if", "iob", str)
        self.set_default_attribute("version", "", str)
        self.set_default_attribute("previous_version", self.version, str)
        self.set_default_attribute("setup_dir", "", str)
        self.set_default_attribute("build_dir", "", str)
        # Overlap Read and Write register addresses
        self.set_default_attribute("rw_overlap", False, bool)
        self.set_default_attribute("use_netlist", False, bool)
        self.set_default_attribute(
            "is_top_module", __class__.global_top_module == self, bool
        )
        self.set_default_attribute("is_system", False, bool)
        # List of FPGAs supported by this core
        self.set_default_attribute("board_list", [], list)
        # Where to copy sources of this core
        self.set_default_attribute("purpose", purpose, str)
        # Don't replace snippets mentioned in this list
        self.set_default_attribute("ignore_snippets", [], list)
        # Select if should generate hardware from python
        self.set_default_attribute("generate_hw", True, bool)

        # Read 'attributes' dictionary and set corresponding core attributes
        self.parse_attributes_dict(attributes)

        # Read-only dictionary with relation between the 'purpose' and
        # the corresponding source folder
        self.PURPOSE_DIRS: dict = {
            "hardware": "hardware/src",
            "simulation": "hardware/simulation/src",
            "fpga": "hardware/fpga/src",
        }

        # Connect ports of this instance to external wires (wires of the instantiator)
        self.connect_instance_ports(connect, instantiator)

        # Don't setup this module if using a project wide special target.
        if __class__.global_special_target:
            return

        if not self.is_top_module:
            self.build_dir = __class__.global_build_dir
        self.setup_dir = find_module_setup_dir(self.original_name)[0]
        # print(f"{self.name} {self.build_dir} {self.is_top_module}")  # DEBUG

        self.__create_build_dir()

        # Copy files from LIB to setup various flows
        # (should run before copy of files from module's setup dir)
        if self.is_top_module:
            copy_srcs.flows_setup(self)

        # Copy files from the module's setup dir
        copy_srcs.copy_rename_setup_directory(self)

        # Generate config_build.mk
        if self.is_top_module:
            config_gen.config_build_mk(self)

        # Generate configuration files
        config_gen.generate_confs(self)

        # Generate parameters
        param_gen.generate_params(self)

        # Generate ios
        io_gen.generate_ports(self)

        # Generate wires
        wire_gen.generate_wires(self)

        # Generate csr interface
        csr_gen_obj, reg_table = reg_gen.generate_csr(self)

        # Generate instances
        if self.generate_hw:
            block_gen.generate_blocks(self)

        # Generate snippets
        snippet_gen.generate_snippets(self)

        # Generate main Verilog module
        if self.generate_hw:
            verilog_gen.generate_verilog(self)

        # TODO: Generate a global list of signals
        # This list is useful for a python based simulator
        # 1) Each input of the top generates a global signal
        # 2) Each output of a leaf generates a global signal
        # 3) Each output of a snippet generates a global signal
        #    A snippet is a piece of verilog code manually written (should also receive a list of outputs by the user).
        #    A snippet can also be any method that generates a new signal, like the `concat_bits`, or any other that performs logic in from other signals into a new one.
        # TODO as well: Each module has a local `snippets` list.
        # Note: The 'width' attribute of many module's signals are generaly not needed, because most of them will be connected to global wires (that already contain the width).

        if self.is_top_module:
            # Replace Verilog snippet includes
            self._replace_snippet_includes()
            # Clean duplicate sources in `hardware/src` and its subfolders (like `hardware/simulation/src`)
            self._remove_duplicate_sources()
            # Generate docs
            doc_gen.generate_docs(self, csr_gen_obj, reg_table)
            # Generate ipxact file
            # if self.generate_ipxact: #TODO: When should this be generated?
            #    ipxact_gen.generate_ipxact_xml(self, reg_table, self.build_dir + "/ipxact")
            # Lint and format sources
            self.lint_and_format()

    def update_global_top_module(self, attributes={}):
        """Update the global top module and the global build directory.
        param attributes: Py2hwsw dictionary describing the core
                          Will be used to get the core name and version if available.
        """
        super().update_global_top_module()
        # Ensure top module has a build dir (and associated attributes)
        if __class__.global_top_module == self:
            # Attribute default values
            original_name = self.__class__.__name__
            name = self.original_name
            version = "1.0"
            # Extract values from attributes dict if available
            if "original_name" in attributes:
                original_name = attributes["original_name"]
            if "name" in attributes:
                name = attributes["name"]
            if "version" in attributes:
                version = attributes["version"]
            # Set attributes
            if not hasattr(self, "original_name") or not self.original_name:
                self.original_name = original_name
            if not hasattr(self, "name") or not self.name:
                self.name = name
            if not hasattr(self, "version") or not self.version:
                self.version = version
            if not __class__.global_build_dir:
                __class__.global_build_dir = f"../{self.name}_V{self.version}"
            self.set_default_attribute("build_dir", __class__.global_build_dir)

    def create_instance(self, core_name: str = "", instance_name: str = "", **kwargs):
        """Create an instante of a module, but only if we are not using a
        project wide special target (like clean)
        param core_name: Name of the core
        param instance_name: Verilog instance name
        """
        if __class__.global_special_target:
            return
        assert core_name, fail_with_msg("Missing core_name argument", ValueError)
        # Ensure 'blocks' list exists
        self.set_default_attribute("blocks", [])
        # Ensure global top module is set
        self.update_global_top_module()

        instance = self.get_core_obj(
            core_name, instance_name=instance_name, instantiator=self, **kwargs
        )

        self.blocks.append(instance)

    def connect_instance_ports(self, connect, instantiator):
        """
        param connect: External wires to connect to ports of this instance
                       Key: Port name, Value: Wire name
        param instantiator: Module that is instantiating this instance
        """
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

    def __create_build_dir(self):
        """Create build directory if it doesn't exist"""
        os.makedirs(self.build_dir, exist_ok=True)
        # Create hardware directories
        os.makedirs(f"{self.build_dir}/hardware/src", exist_ok=True)
        os.makedirs(f"{self.build_dir}/hardware/simulation/src", exist_ok=True)
        os.makedirs(f"{self.build_dir}/hardware/fpga/src", exist_ok=True)

        os.makedirs(f"{self.build_dir}/doc", exist_ok=True)
        os.makedirs(f"{self.build_dir}/doc/tsrc", exist_ok=True)

        shutil.copyfile(
            f"{copy_srcs.get_lib_dir()}/build.mk", f"{self.build_dir}/Makefile"
        )

    def _remove_duplicate_sources(self):
        """Remove sources in the build directory from subfolders that exist in `hardware/src`"""
        # Go through all subfolders defined in PURPOSE_DIRS
        for subfolder in self.PURPOSE_DIRS.values():
            # Skip hardware folder
            if subfolder == "hardware/src":
                continue

            # Get common srcs between `hardware/src` and current subfolder
            common_srcs = find_common_deep(
                os.path.join(self.build_dir, "hardware/src"),
                os.path.join(self.build_dir, subfolder),
            )
            # Remove common sources
            for src in common_srcs:
                os.remove(os.path.join(self.build_dir, subfolder, src))
                # print(f'{iob_colors.INFO}Removed duplicate source: {os.path.join(subfolder, src)}{iob_colors.ENDC}')

    def _replace_snippet_includes(self):
        verilog_gen.replace_includes(
            self.setup_dir, self.build_dir, self.ignore_snippets
        )

    def parse_attributes_dict(self, attributes):
        """Parse attributes dictionary given, and build and set the corresponding
        attributes for this core, using the handlers stored in `ATTRIBUTE_PROPERTIES`
        dictionary.
        If there is no handler for an attribute then it will raise an error.
        """
        # For each attribute of the dictionary, check if there is a handler,
        # and use it to set the attribute
        for attr_name, attr_value in attributes.items():
            if attr_name in self.ATTRIBUTE_PROPERTIES:
                self.ATTRIBUTE_PROPERTIES[attr_name].set_handler(attr_value),
            else:
                fail_with_msg(f"Unknown attribute: {attr_name}")

    def lint_and_format(self):
        """Run Linters and Formatters in setup and build directories."""
        # Find Verilog sources and headers from build dir
        verilog_headers = []
        verilog_sources = []
        for path in Path(os.path.join(self.build_dir, "hardware")).rglob("*.vh"):
            # Skip specific Verilog headers
            if path.name.endswith("version.vh") or "test_" in path.name:
                continue
            verilog_headers.append(str(path))
            # print(str(path))
        for path in Path(os.path.join(self.build_dir, "hardware")).rglob("*.v"):
            verilog_sources.append(str(path))
            # print(str(path))

        # Run Verilog linter
        if __class__.global_project_vlint:
            verilog_lint.lint_files(verilog_headers + verilog_sources)

        # Run Verilog formatter
        if __class__.global_project_vformat:
            verilog_format.format_files(
                verilog_headers + verilog_sources,
                os.path.join(os.path.dirname(__file__), "verible-format.rules"),
            )

        # Run Python formatter
        sw_tools.run_tool("black")
        sw_tools.run_tool("black", self.build_dir)

        # Run C formatter
        sw_tools.run_tool("clang")
        sw_tools.run_tool("clang", self.build_dir)

    @classmethod
    def py2hw(cls, core_dict, **kwargs):
        """Generate a core based on the py2hw dictionary interface
        param core_dict: The core dictionary using py2hw dictionary syntax
        param kwargs: Optional additional arguments to pass directly to the core
        """
        return cls(attributes=core_dict, **kwargs)

    @classmethod
    def read_py2hw_json(cls, filepath, **kwargs):
        """Read JSON file with py2hw attributes build a core from it
        param filepath: Path to JSON file using py2hw json syntax
        param kwargs: Optional additional arguments to pass directly to the core
        """
        with open(filepath) as f:
            core_dict = json.load(f)
        return cls.py2hw(core_dict, **kwargs)

    @staticmethod
    def clean_build_dir(core_name):
        """Clean build directory."""
        # Set project wide special target (will prevent normal setup)
        __class__.global_special_target = "clean"
        # Build a new module instance, to obtain its attributes
        module = __class__.get_core_obj(core_name)
        print(
            f"{iob_colors.ENDC}Cleaning build directory: {module.build_dir}{iob_colors.ENDC}"
        )
        # if build_dir exists run make clean in it
        if os.path.exists(module.build_dir):
            os.system(f"make -C {module.build_dir} clean")
        shutil.rmtree(module.build_dir, ignore_errors=True)

    @staticmethod
    def print_build_dir(core_name):
        """Print build directory."""
        # Set project wide special target (will prevent normal setup)
        __class__.global_special_target = "print_build_dir"
        # Build a new module instance, to obtain its attributes
        module = __class__.get_core_obj(core_name)
        print(module.build_dir)

    @staticmethod
    def print_py2hwsw_attributes(core_name):
        """Print the supported py2hw attributes of this core.
        The attributes listed can be used in the 'attributes' dictionary of the
        constructor. This defines the information supported by the py2hw interface.
        """
        # Set project wide special target (will prevent normal setup)
        __class__.global_special_target = "print_attributes"
        # Build a new module instance, to obtain its attributes
        module = __class__.get_core_obj(core_name)
        print(
            f"Attributes supported by the '{module.name}' core's 'py2hwsw' interface:"
        )
        for name in module.ATTRIBUTE_PROPERTIES.keys():
            datatype = module.ATTRIBUTE_PROPERTIES[name].datatype
            descr = module.ATTRIBUTE_PROPERTIES[name].descr
            align_spaces = " " * (20 - len(name))
            align_spaces2 = " " * (18 - len(str(datatype)))
            print(f"- {name}:{align_spaces}{datatype}{align_spaces2}{descr}")

    @staticmethod
    def get_core_obj(core_name, **kwargs):
        """Generate an instance of a core based on given core_name and python parameters
        This method will search for the .py and .json files of the core, and generate a
        python object based on info stored in those files, and info passed via python
        parameters.
        Calling this method may also begin the setup process of the core, depending on
        the value of the `global_special_target` attribute.
        """
        core_dir, file_ext = find_module_setup_dir(core_name)

        if file_ext == ".py":
            import_python_module(
                os.path.join(core_dir, f"{core_name}.py"),
            )
            core_module = sys.modules[core_name]
            # Call `setup(<py_params_dict>)` function of `<core_name>.py` to
            # obtain the core's py2hwsw dictionary.
            # Give it a dictionary with all arguments of this function, since the user
            # may want to use any of them to manipulate the core attributes.
            core_dict = core_module.setup(
                {
                    "core_name": core_name,
                    **kwargs,
                }
            )
            instance = __class__.py2hw(
                core_dict,
                # Note, any of the arguments below can have their values overridden by
                # the core_dict
                **kwargs,
            )
        elif file_ext == ".json":
            instance = __class__.read_py2hw_json(
                os.path.join(core_dir, f"{core_name}.json"),
                # Note, any of the arguments below can have their values overridden by
                # the json data
                **kwargs,
            )
        return instance


def find_common_deep(path1, path2):
    """Find common files (recursively) inside two given directories
    Taken from: https://stackoverflow.com/a/51625515
    :param str path1: Directory path 1
    :param str path2: Directory path 2
    """
    return set.intersection(
        *(
            set(
                os.path.relpath(os.path.join(root, file), path)
                for root, _, files in os.walk(path)
                for file in files
            )
            for path in (path1, path2)
        )
    )


def find_module_setup_dir(core_name):
    """Searches for a core's setup directory
    param core_name: The core_name object
    returns: The path to the setup directory
    returns: The file extension
    """
    file_path = find_file(iob_core.global_project_root, core_name, [".py", ".json"])
    if not file_path:
        fail_with_msg(
            f"Setup directory of {core_name} not found in {iob_core.global_project_root}!"
        )

    file_ext = os.path.splitext(file_path)[1]
    # print("Found setup dir based on location of: " + file_path, file=sys.stderr)
    if file_ext == ".py" or file_ext == ".json":
        return os.path.dirname(file_path), file_ext
