import os
import shutil
import sys
import importlib

import iob_colors

import copy_srcs

import if_gen
import config_gen
import verilog_gen
import csr_gen
import block_gen
import io_gen
import ipxact_gen

from typing import List


class iob_module:
    """Generic class to describe a base iob-module"""

    ###############################################################
    # IOb module attributes: common to all iob-modules (subclasses)
    ###############################################################

    # Standard attributes common to all iob-modules
    name = "iob_module"  # Verilog module name (not instance name)
    csr_if = "iob"
    version = "1.0"  # Module version
    description = "default description"  # Module description
    previous_version = ""  # Module version
    setup_dir = ""  # Setup directory for this module
    build_dir = ""  # Build directory for this module
    confs = None  # List of configuration macros/parameters for this module
    autoaddr = True  # register address mode: True: automatic; False: manual
    rw_overlap = False  # overlap Read and Write register addresses
    regs = None  # List of registers for this module
    ios = None  # List of I/O for this module
    block_groups = None  # List of block groups for this module. Used for documentation.
    wire_list = None  # List of internal wires of the Verilog module. Used to interconnect module components.
    is_top_module = False  # Select if this module is the top module
    use_netlist = False  # use module netlist
    generate_ipxact = False  # generate IP-XACT XML file
    is_system = False  # create software files in build directory
    board_list: List = []  # List of fpga files to copy to build directory

    _initialized_attributes = (
        False  # Store if attributes have been initialized for this class
    )

    submodule_list = None  # List of submodules to setup

    # List of setup purposes for this module. Also used to check if module has already been setup.
    _setup_purpose = None

    # Read-only dictionary with relation between the setup_purpose and the corresponding source folder
    PURPOSE_DIRS = {
        "hardware": "hardware/src",
        "simulation": "hardware/simulation/src",
        "fpga": "hardware/fpga/src",
    }

    def __init__(
        self,
        name="",
        description="default description",
        parameters={},
    ):
        """Constructor to build verilog instances.
        :param str name: Verilog instance name
        :param str description: Verilog instance description
        :param dict parameters: Verilog parameters
        """
        if not name:
            name = f"{self.name}_0"
        self.name = name
        self.description = description
        self.parameters = parameters

    ###############################################################
    # Methods NOT to be overriden by subclasses
    ###############################################################

    # DEPRECATED METHOD
    @classmethod
    def setup(cls, purpose="hardware", is_top_module=False):
        """Deprecated method for setup.
        Raises exception if called.
        """
        raise Exception(
            f"{iob_colors.FAIL}The `setup()` method is deprecated. Use the `_create_submodules_list()` method to setup the `submodule_list`.{iob_colors.ENDC}"
        )

    @classmethod
    def setup_as_top_module(cls):
        """Initialize the setup process for the top module.
        This method should only be called once, and only for the top module class.
        It is typically called by the `bootstrap.py` script.
        """
        cls.__setup(is_top_module=True)

    @classmethod
    def __setup(cls, purpose="hardware", is_top_module=False):
        """Private setup method for this module.
        purpose: Reason for setting up the module. Used to select between the standard destination locations.
        is_top_module: Select if this is the top module. This should only be enabled on the top module class.
        """
        # print(f'DEBUG: Setup: {cls.name}, purpose: {purpose}') # DEBUG

        # Initialize empty list for purpose
        if cls._setup_purpose == None:
            cls._setup_purpose = []

        # Don't setup if module has already been setup for this purpose or for the "hardware" purpose.
        if purpose in cls._setup_purpose or "hardware" in cls._setup_purpose:
            return

        # Only init attributes if this is the first time we run setup
        if not cls._setup_purpose:
            cls.is_top_module = is_top_module
            cls.init_attributes()

        # Create build directory this is the top module class, and is the first time setup
        if is_top_module and not cls._setup_purpose:
            cls.__create_build_dir()

        # Add current setup purpose to list
        cls._setup_purpose.append(purpose)

        cls.__pre_specific_setup()
        cls._specific_setup()
        cls._post_setup()

    # DEPRECATED METHOD
    @classmethod
    def instance(cls, name="", *args, **kwargs):
        """Deprecated method to create Verilog instances.
        Raises exception if called.
        """
        raise Exception(
            f"{iob_colors.FAIL}The `instance()` method is deprecated. Use the class constructor inherited from `iob_module` to create Verilog instances.{iob_colors.ENDC}"
        )

        # Return None, since iob_verilog_instance class/objects do not exist
        return None

    @classmethod
    def init_attributes(cls):
        """Public method to initialize attributes of the class
        This method is automatically called by the `setup` method.
        """
        # Only run this method if attributes have not yet been initialized
        if cls._initialized_attributes:
            return
        cls._initialized_attributes = True

        # Set the build directory in the `iob_module` superclass, so everyone has access to it
        if cls.is_top_module:
            if "BUILD_DIR" in os.environ:
                # Use directory from 'BUILD_DIR' environment variable
                iob_module.build_dir = os.environ["BUILD_DIR"]
            elif cls.build_dir:
                # Use build directory defined in module
                iob_module.build_dir = cls.build_dir
            else:
                # Auto-fill build directory
                iob_module.build_dir = f"../{cls.name}_{cls.version}"

            # Use directory from 'BUILD_DIR' argument (if any)
            for arg in sys.argv:
                if arg.startswith("BUILD_DIR="):
                    iob_module.build_dir = arg.split("=")[1]
                    break

        # Copy build directory from the `iob_module` superclass
        cls.build_dir = iob_module.build_dir

        # Copy current version to previous version if it is not set
        if not cls.previous_version:
            cls.previous_version = cls.version
        # try to open file document/tsrc/intro.tex and read it into cls.description
        try:
            with open(f"document/tsrc/intro.tex", "r") as file:
                cls.description = file.read()
        except:
            print("Error reading document/tsrc/intro.tex")

        # Initialize empty lists for attributes (We can't initialize in the attribute declaration because it would cause every subclass to reference the same list)
        cls.confs = []
        cls.regs = []
        cls.ios = []
        cls.block_groups = []
        cls.submodule_list = []
        cls.wire_list = []

        cls._init_attributes()

        cls._create_submodules_list()

        # Call _setup_* function for attributes (these may be overriden by subclasses)
        cls._setup_confs()
        cls._setup_ios()
        cls._setup_regs()

    @classmethod
    def __pre_specific_setup(cls):
        """Private method to setup and instantiate submodules before specific setup"""
        # Setup submodules placed in `submodule_list` list
        cls._setup_submodules(cls.submodule_list)
        # Create instances of submodules (previously setup)
        cls._create_instances()
        # Setup block groups (not called from init_attributes() because
        # this function has instances of modules that are only created by this function)
        cls._setup_block_groups()

    ###############################################################
    # Methods commonly overriden by subclasses
    ###############################################################

    @classmethod
    def _init_attributes(cls):
        """Default method to init attributes does nothing"""
        pass

    @classmethod
    def _create_submodules_list(cls, submodule_list=[]):
        """Default method to create list of submodules just appends the list of submodules given, to the class list.
        This method does not do any sanity checking on the list of submodules.
        :param list submodule_list: List of submodules to append to the class `submodule_list` attribute.
        """
        cls.submodule_list += submodule_list

    @classmethod
    def _create_instances(cls):
        """Default method to instantiate modules does nothing"""
        pass

    @classmethod
    def _specific_setup(cls):
        """Default _specific_setup does nothing.
        This function should be overriden by its subclasses to
        implement their specific setup functionality.
        If they create sources in the build dir, they should be aware of the
        latest setup purpose, using: `cls.get_setup_purpose()`
        """
        pass

    @classmethod
    def _setup_confs(cls, confs=[]):
        """Append confs to the current confs class list, overriding existing ones
        :param list confs: List of confs to append/override in class attribute
        """
        cls.update_dict_list(cls.confs, confs)

    @classmethod
    def _setup_ios(cls, ios=[]):
        """Append ios to the current ios class list, overriding existing ones
        :param list ios: List of ios to append/override in class attribute
        """
        cls.update_dict_list(cls.ios, ios)

    @classmethod
    def _setup_regs(cls, regs=[]):
        """Append regs to the current regs class list, overriding existing ones
        :param list regs: List of regs to append/override in class attribute
        """
        cls.update_dict_list(cls.regs, regs)

    @classmethod
    def _setup_block_groups(cls, block_groups=[]):
        """Append block_groups to the current block_groups class list, overriding existing ones
        :param list block_groups: List of block_groups to append/override in class attribute
        """
        cls.update_dict_list(cls.block_groups, block_groups)

    ###############################################################
    # Methods optionally overriden by subclasses
    ###############################################################

    @classmethod
    def _post_setup(cls):
        """Launch post(-specific)-setup tasks"""
        # Auto-add common module macros and submodules
        cls._auto_add_settings()

        if cls.is_top_module:
            # Setup flows (copy LIB files)
            copy_srcs.flows_setup(cls)

        # Copy sources from the module's setup dir (and from its superclasses)
        cls._copy_srcs()

        # Generate hw, sw and doc files
        cls._generate_files()

        # Run `*_setup.py` python scripts
        cls._run_setup_files()

        if cls.is_top_module:
            # Replace Verilog snippet includes
            cls._replace_snippet_includes()
            # Clean duplicate sources in `hardware/src` and its subfolders (like `hardware/simulation/src`)
            cls._remove_duplicate_sources()

    @classmethod
    def _generate_files(cls):
        """Generate hw, sw and doc files"""
        csr_gen_obj, reg_table = cls._build_regs_table()
        cls._generate_hw(csr_gen_obj, reg_table)
        cls._generate_sw(csr_gen_obj, reg_table)
        cls._generate_doc(csr_gen_obj, reg_table)
        cls._generate_ipxact(reg_table)

    @classmethod
    def _auto_add_settings(cls):
        """Auto-add settings like macros and submodules to the module"""

        # Auto-add VERSION macro if there are software registers
        if cls.regs:
            found_version_macro = False
            if cls.confs:
                for macro in cls.confs:
                    if macro["name"] == "VERSION":
                        found_version_macro = True
            if not found_version_macro:
                cls.confs.append(
                    {
                        "name": "VERSION",
                        "type": "M",
                        "val": "16'h" + copy_srcs.version_str_to_digits(cls.version),
                        "min": "NA",
                        "max": "NA",
                        "descr": "Product version. This 16-bit macro uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234.",
                    }
                )

        if cls.regs:
            # Auto-add iob_ctls module, except if use_netlist
            if cls.name != "iob_ctls" and not cls.use_netlist:
                from iob_ctls import iob_ctls

                iob_ctls.__setup(purpose=cls.get_setup_purpose())
            ## Auto-add iob_s_port.vh
            cls.__generate({"interface": "iob_s_port"}, purpose=cls.get_setup_purpose())
            ## Auto-add iob_s_portmap.vh
            cls.__generate(
                {"interface": "iob_s_s_portmap"}, purpose=cls.get_setup_purpose()
            )

    @classmethod
    def _build_regs_table(cls):
        """Build registers table.
        :returns csr_gen csr_gen_obj: Instance of csr_gen class
        :returns list reg_table: Register table generated by `get_reg_table` method of `csr_gen_obj`
        """
        # Don't create regs table if module does not have regs
        if not cls.regs:
            return None, None

        # Make sure 'general' registers table exists
        general_regs_table = next((i for i in cls.regs if i["name"] == "general"), None)
        if not general_regs_table:
            general_regs_table = {
                "name": "general",
                "descr": "General Registers.",
                "regs": [],
            }
            cls.regs.append(general_regs_table)

        # Add 'VERSION' register if this is the first time we are setting up this core
        # (The register will already be present on subsequent setups)
        if len(cls._setup_purpose) < 2:
            # Auto add 'VERSION' register in 'general' registers table if it doesn't exist
            # If it does exist, give an error
            for reg in general_regs_table["regs"]:
                if reg["name"] == "VERSION":
                    raise Exception(
                        cls.name + ": Register 'VERSION' is reserved. Please remove it."
                    )
            else:
                general_regs_table["regs"].append(
                    {
                        "name": "VERSION",
                        "type": "R",
                        "n_bits": 16,
                        "rst_val": copy_srcs.version_str_to_digits(cls.version),
                        "addr": -1,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Product version.  This 16-bit register uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234.",
                    }
                )

        # Create an instance of the csr_gen class inside the csr_gen module
        # This instance is only used locally, not affecting status of csr_gen imported in other functions/modules
        csr_gen_obj = csr_gen.csr_gen()
        csr_gen_obj.config = cls.confs
        # Get register table
        reg_table = csr_gen_obj.get_reg_table(cls.regs, cls.rw_overlap, cls.autoaddr)

        return csr_gen_obj, reg_table

    @classmethod
    def _generate_hw(cls, csr_gen_obj, reg_table):
        """Generate common hardware files"""
        if cls.regs:
            csr_gen_obj.write_hwheader(
                reg_table, cls.build_dir + "/hardware/src", cls.name
            )
            csr_gen_obj.write_lparam_header(
                reg_table, cls.build_dir + "/hardware/simulation/src", cls.name
            )
            if not cls.use_netlist:
                csr_gen_obj.write_hwcode(
                    reg_table,
                    cls.build_dir + "/hardware/src",
                    cls.name,
                    cls.csr_if,
                )

        if cls.confs:
            config_gen.params_vh(cls.confs, cls.name, cls.build_dir + "/hardware/src")

            config_gen.conf_vh(cls.confs, cls.name, cls.build_dir + "/hardware/src")

        if cls.ios:
            io_gen.generate_ios_header(
                cls.ios, cls.name, cls.build_dir + "/hardware/src"
            )

    @classmethod
    def _generate_sw(cls, csr_gen_obj, reg_table):
        """Generate common software files"""
        if cls.is_system or cls.regs:
            os.makedirs(cls.build_dir + "/software/src", exist_ok=True)
            if cls.regs:
                csr_gen_obj.write_swheader(
                    reg_table, cls.build_dir + "/software/src", cls.name
                )
                csr_gen_obj.write_swcode(
                    reg_table, cls.build_dir + "/software/src", cls.name
                )
                csr_gen_obj.write_swheader(
                    reg_table, cls.build_dir + "/software/src", cls.name
                )
            config_gen.conf_h(cls.confs, cls.name, cls.build_dir + "/software/src")

    @classmethod
    def _generate_doc(cls, csr_gen_obj, reg_table):
        """Generate common documentation files"""
        if cls.is_top_module:
            config_gen.generate_confs_tex(cls.confs, cls.build_dir + "/document/tsrc")
            io_gen.generate_ios_tex(cls.ios, cls.build_dir + "/document/tsrc")
            if cls.regs:
                csr_gen_obj.generate_regs_tex(
                    cls.regs, reg_table, cls.build_dir + "/document/tsrc"
                )
            block_gen.generate_blocks_tex(
                cls.block_groups, cls.build_dir + "/document/tsrc"
            )

    @classmethod
    def _generate_ipxact(cls, reg_table):
        if cls.generate_ipxact:
            # Generate IP-XACT XML file
            ipxact_gen.generate_ipxact_xml(cls, reg_table, cls.build_dir + "/ipxact")

    @classmethod
    def _remove_duplicate_sources(cls):
        """Remove sources in the build directory from subfolders that exist in `hardware/src`"""
        # Go through all subfolders defined in PURPOSE_DIRS
        for subfolder in cls.PURPOSE_DIRS.values():
            # Skip hardware folder
            if subfolder == "hardware/src":
                continue

            # Get common srcs between `hardware/src` and current subfolder
            common_srcs = cls.find_common_deep(
                os.path.join(cls.build_dir, "hardware/src"),
                os.path.join(cls.build_dir, subfolder),
            )
            # Remove common sources
            for src in common_srcs:
                os.remove(os.path.join(cls.build_dir, subfolder, src))
                # print(f'{iob_colors.INFO}Removed duplicate source: {os.path.join(subfolder, src)}{iob_colors.ENDC}')

    @classmethod
    def _replace_snippet_includes(cls):
        verilog_gen.replace_includes(cls.setup_dir, cls.build_dir)

    @classmethod
    def _run_setup_files(cls):
        flows_setup_files = {
            "sim": cls.setup_dir + "/hardware/simulation/sim_setup.py",
            "fpga": cls.setup_dir + "/hardware/fpga/fpga_setup.py",
            "emb": cls.setup_dir + "/software/sw_setup.py",
            "doc": cls.setup_dir + "/document/doc_setup.py",
        }
        for flow, filepath in flows_setup_files.items():
            # Skip if file does not exist
            if not os.path.isfile(filepath):
                continue
            
            # Import the module 
            setup_module = importlib.import_module(
                os.path.splitext(os.path.basename(filepath))[0]
            )
            # Run the setup function
            setup_module.setup(cls)            

    @classmethod
    def _setup_submodules(cls, submodule_list):
        """Generate or run setup functions for the interfaces/submodules in the given submodules list.
        :param list submodule_list: List of interfaces/submodules to generate/setup.

        Example submodule_list:
            [
            # Generate interfaces with if_gen. Check out the `__generate()` method for details.
            # Generate an `axi_m_portmap` interface (using a simple dictionary):
            {"interface": "axi_m_portmap"},
            # Generate an `axi_s_portmap` interface for the `simulation` purpose (using a tuple with a simple dictionary):
            ({"interface": "axi_s_portmap"}, {"purpose": "simulation"}),
            # Generate an `iob_s_port` interface with custom prefixes (using a dictionary):
            {
                "file_prefix": "example_file_prefix_",
                "interface": "iob_s_port",
                "wire_prefix": "example_wire_prefix_",
                "port_prefix": "example_port_prefix_",
            },
            # Set up a submodule
            iob_picorv32,
            # Set up a submodule for the `simulation` purpose (using a tuple):
            (axi_ram, {"purpose": "simulation"}),
        """
        for submodule in submodule_list:
            _submodule = submodule
            setup_options = {}

            # Split submodule from its setup options (if it is a tuple)
            if type(submodule) == tuple:
                _submodule = submodule[0]
                setup_options = submodule[1]

            # Add 'hardware' purpose by default
            if "purpose" not in setup_options:
                setup_options["purpose"] = "hardware"

            # Don't setup submodules that have a purpose different than
            # "hardware" when this class is not the top module
            if not cls.is_top_module and setup_options["purpose"] != "hardware":
                continue

            # If the submodule purpose is hardware, change that purpose to match the purpose of the current class.
            # (If we setup the current class for simulation, then we want the submodules for simulation aswell)
            if setup_options["purpose"] == "hardware":
                setup_options["purpose"] = cls.get_setup_purpose()

            # Check if should generate with if_gen or setup a submodule.
            if type(_submodule) == dict:
                # Dictionary: generate interface with if_gen
                cls.__generate(_submodule, **setup_options)
            elif issubclass(_submodule, iob_module):
                # Subclass of iob_module: setup the module
                # Skip if module uses netlist and purpose is hardware
                if not cls.use_netlist or setup_options["purpose"] != "hardware":
                    _submodule.__setup(**setup_options)
            else:
                # Unknown type
                raise Exception(
                    f"{iob_colors.FAIL}Unknown type in submodule_list of {cls.name}: {_submodule}{iob_colors.ENDC}"
                )

    # DEPRECATED METHOD
    @classmethod
    def generate(cls, vs_name, purpose="hardware"):
        """Deprecated method for generate.
        Raises exception if called.
        """
        raise Exception(
            f"{iob_colors.FAIL}The `generate()` method is deprecated. Use the `_create_submodules_list()` method to setup the `submodule_list`.{iob_colors.ENDC}"
        )

    @classmethod
    def __generate(cls, vs_name, purpose="hardware"):
        """Generate a Verilog header with `if_gen.py`.
        vs_name: A dictionary describing the interface to generate.
                 Example simple dictionary: {"interface": "iob_wire"}
                 Example full dictionary:
                       {
                           "file_prefix": "iob_bus_0_2_", # Prefix to include in the generated file name
                           "interface": "axi_m_portmap",  # Type of interface/wires to generate. Will also be part of the filename.
                           "wire_prefix": "",             # Prefix to include in the generated wire names
                           "port_prefix": "",             # Prefix to include in the generated port names
                           "bus_start": 0,                # Optional. Starting index of the bus of wires that we are connecting.
                           "bus_size": 2,                 # Optional. Size of the bus of wires that we are creating/connecting.
                       }
        purpose: [Optional] Reason for generating the header. Used to select between the standard destination locations.

        Example function calls:
        To generate a simple `iob_s_port.vh` file, use: `iob_module.generate("iob_s_port")`
        To generate an iob_s_port file with a custom prefix in its ports, wires, and filename, use:
            iob_module.generate(
                       {
                           "file_prefix": "example_file_prefix_",
                           "interface": "iob_s_port",
                           "wire_prefix": "example_wire_prefix_",
                           "port_prefix": "example_port_prefix_",
                       })
        """
        dest_dir = os.path.join(cls.build_dir, cls.get_purpose_dir(purpose))

        if_gen.default_interface_fields(vs_name)

        if (type(vs_name) is dict) and (vs_name["interface"] in if_gen.interfaces):
            f_out = open(
                os.path.join(
                    dest_dir, vs_name["file_prefix"] + vs_name["interface"] + ".vs"
                ),
                "w",
            )
            if_gen.create_signal_table(vs_name["interface"])
            if_gen.write_vs_contents(
                vs_name["interface"],
                vs_name["port_prefix"],
                vs_name["wire_prefix"],
                f_out,
                bus_size=vs_name["bus_size"] if "bus_size" in vs_name.keys() else 1,
                bus_start=vs_name["bus_start"] if "bus_start" in vs_name.keys() else 0,
            )
        else:
            raise Exception(
                f"{iob_colors.FAIL} Can't generate '{vs_name}'. Type not recognized.{iob_colors.ENDC}"
            )

    @classmethod
    def get_setup_purpose(cls):
        """Get the purpose of the latest setup.
        :returns str setup_purpose: The latest setup purpose
        """
        if len(cls._setup_purpose) < 1:
            raise Exception(
                f"{iob_colors.FAIL}Module has not been setup!{iob_colors.ENDC}"
            )
        # Return the latest purpose
        return cls._setup_purpose[-1]

    @classmethod
    def get_purpose_dir(cls, purpose):
        """Get output directory based on the purpose given."""
        assert (
            purpose in cls.PURPOSE_DIRS
        ), f"{iob_colors.FAIL}Unknown purpose {purpose}{iob_colors.ENDC}"
        return cls.PURPOSE_DIRS[purpose]

    @classmethod
    def __create_build_dir(cls):
        """Create build directory. Must be called from the top module."""
        assert (
            cls.is_top_module
        ), f"{iob_colors.FAIL}Module {cls.name} is not a top module!{iob_colors.ENDC}"
        os.makedirs(cls.build_dir, exist_ok=True)
        config_gen.config_build_mk(cls)
        # Create hardware directories
        os.makedirs(f"{cls.build_dir}/hardware/src", exist_ok=True)
        os.makedirs(f"{cls.build_dir}/hardware/simulation/src", exist_ok=True)
        os.makedirs(f"{cls.build_dir}/hardware/fpga/src", exist_ok=True)

        shutil.copyfile(
            f"{copy_srcs.LIB_DIR}/build.mk", f"{cls.build_dir}/Makefile"
        )  # Copy generic MAKEFILE

    @classmethod
    def _copy_srcs(cls, exclude_file_list=[], highest_superclass=None):
        """Copy module sources to the build directory from every subclass in between `iob_module` and `cls`, inclusive.
        The function will not copy sources from classes that have no setup_dir (empty string)
        cls: Lowest subclass
        (implicit: iob_module: highest subclass)
        :param list exclude_file_list: list of strings, each string representing an ignore pattern for the source files.
                                       For example, using the ignore pattern '*.v' would prevent from copying every Verilog source file.
                                       Note, if want to ignore a file that is going to be renamed with the new core name,
                                       we would still use the old core name in the ignore patterns.
                                       For example, if we dont want it to generate the 'new_name_firmware.c' based on the 'old_name_firmware.c',
                                       then we should add 'old_name_firmware.c' to the ignore list.
        :param class highest_superclass: If specified, only copy sources from this subclass and up to specified class. By default, highest_superclass=iob_module.
        """
        previously_setup_dirs = []
        # Select between specified highest_superclass or this one (iob_module)
        highest_superclass = highest_superclass or __class__

        # List of classes, starting from highest superclass (iob_module), down to lowest subclass (cls)
        classes = cls.__mro__[cls.__mro__.index(highest_superclass) :: -1]

        # Go through every subclass, starting for highest superclass to the lowest subclass
        for module_class in classes:
            # Skip classes without setup_dir
            if not module_class.setup_dir:
                continue

            # Skip class if we already setup its directory (it may have inherited the same dir from the superclass)
            if module_class.setup_dir in previously_setup_dirs:
                continue

            previously_setup_dirs.append(module_class.setup_dir)

            # Files that should always be copied
            dir_list = [
                "hardware/src",
                "software",
            ]
            # Files that should only be copied if it is top module
            if cls.is_top_module:
                dir_list += [
                    "hardware/simulation",
                    "hardware/common_src",
                    "hardware/fpga",
                    "hardware/syn",
                    "hardware/lint",
                ]
            # Copy sources
            for directory in dir_list:
                # Skip this directory if it does not exist
                if not os.path.isdir(os.path.join(module_class.setup_dir, directory)):
                    continue

                # If we are handling the `hardware/src` directory,
                # copy to the correct destination based on `_setup_purpose`.
                if directory == "hardware/src":
                    dst_directory = cls.get_purpose_dir(cls.get_setup_purpose())
                    if cls.use_netlist:
                        # copy SETUP_DIR/CORE.v netlist instead of
                        # SETUP_DIR/hardware/src
                        shutil.copyfile(
                            os.path.join(module_class.setup_dir, f"{cls.name}.v"),
                            os.path.join(
                                cls.build_dir, f"{dst_directory}/{cls.name}.v"
                            ),
                        )
                        continue
                elif directory == "hardware/fpga":
                    # Skip if board_list is empty
                    if cls.board_list is None:
                        continue

                    tools_list = ["quartus", "vivado"]

                    # Copy everything except the tools directories
                    shutil.copytree(
                        os.path.join(module_class.setup_dir, directory),
                        os.path.join(cls.build_dir, directory),
                        dirs_exist_ok=True,
                        copy_function=cls.copy_with_rename(module_class.name, cls.name),
                        ignore=shutil.ignore_patterns(*exclude_file_list, *tools_list),
                    )

                    # if it is the fpga directory, only copy the directories in the cores board_list
                    for fpga in cls.board_list:
                        # search for the fpga directory in the cores setup_dir/hardware/fpga
                        # in both quartus and vivado directories
                        for tools_dir in tools_list:
                            setup_tools_dir = os.path.join(
                                module_class.setup_dir, directory, tools_dir
                            )
                            build_tools_dir = os.path.join(
                                cls.build_dir, directory, tools_dir
                            )
                            setup_fpga_dir = os.path.join(setup_tools_dir, fpga)
                            build_fpga_dir = os.path.join(build_tools_dir, fpga)

                            # if the fpga directory is found, copy it to the build_dir
                            if os.path.isdir(setup_fpga_dir):
                                # Copy the tools directory files only
                                for file in os.listdir(setup_tools_dir):
                                    setup_file = os.path.join(setup_tools_dir, file)
                                    if os.path.isfile(setup_file):
                                        cls.copy_with_rename(
                                            module_class.name, cls.name
                                        )(
                                            setup_file,
                                            os.path.join(build_tools_dir, file),
                                        )
                                # Copy the fpga directory
                                shutil.copytree(
                                    setup_fpga_dir,
                                    build_fpga_dir,
                                    dirs_exist_ok=True,
                                    copy_function=cls.copy_with_rename(
                                        module_class.name, cls.name
                                    ),
                                    ignore=shutil.ignore_patterns(*exclude_file_list),
                                )
                                break
                        else:
                            raise Exception(
                                f"{iob_colors.FAIL}FPGA directory {fpga} not found in {module_class.setup_dir}/hardware/fpga/{iob_colors.ENDC}"
                            )

                    # No need to copy any more files in this directory
                    continue

                else:
                    dst_directory = directory

                # Copy tree of this directory, renaming files, and overriding destination ones.
                shutil.copytree(
                    os.path.join(module_class.setup_dir, directory),
                    os.path.join(cls.build_dir, dst_directory),
                    dirs_exist_ok=True,
                    copy_function=cls.copy_with_rename(module_class.name, cls.name),
                    ignore=shutil.ignore_patterns(*exclude_file_list),
                )

            # Copy document directory if cls is the top module and it has documentation
            if cls.is_top_module and os.path.isdir(
                os.path.join(module_class.setup_dir, "document")
            ):
                shutil.copytree(
                    os.path.join(module_class.setup_dir, "document"),
                    os.path.join(cls.build_dir, "document"),
                    dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns(*exclude_file_list),
                )

    ###############################################################
    # Utility methods
    ###############################################################

    @staticmethod
    def update_dict_list(dict_list, new_items):
        """Update a list of dictionaries with new items given in a list

        :param list dict_list: List of dictionaries, where each item is a dictionary that has a "name" key
        :param list new_items: List of dictionaries, where each item is a dictionary that has a "name" key and should be inserted into the dict_list
        """
        for item in new_items:
            for _item in dict_list:
                if _item["name"] == item["name"]:
                    _item.update(item)
                    break
            else:
                dict_list.append(item)

    @staticmethod
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

    @staticmethod
    def copy_with_rename(old_core_name, new_core_name):
        """Creates a function that:
        - Renames any '<old_core_name>' string inside the src file and in its filename, to the given '<new_core_name>' string argument.
        """

        def copy_func(src, dst):
            dst = os.path.join(
                os.path.dirname(dst),
                os.path.basename(
                    dst.replace(old_core_name, new_core_name).replace(
                        old_core_name.upper(), new_core_name.upper()
                    )
                ),
            )
            # print(f"### DEBUG: {src} {dst}")
            try:
                file_perms = os.stat(src).st_mode
                with open(src, "r") as file:
                    lines = file.readlines()
                for idx in range(len(lines)):
                    lines[idx] = (
                        lines[idx]
                        .replace(old_core_name, new_core_name)
                        .replace(old_core_name.upper(), new_core_name.upper())
                    )
                with open(dst, "w") as file:
                    file.writelines(lines)
            except:
                shutil.copyfile(src, dst)
            # Set file permissions equal to source file
            os.chmod(dst, file_perms)

        return copy_func
