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

from pathlib import Path


class iob_module_meta(type):
    """Function to copy class attributes to subclasses,
    instead of passing them by reference. https://stackoverflow.com/a/2488610
    """

    def __init__(self, *args):
        super(iob_module_meta, self).__init__(*args)
        for superclass in self.__mro__:
            for k, v in vars(superclass).items():
                if isinstance(
                    v,
                    (
                        list,
                        dict,
                    ),
                ):
                    setattr(self, k, type(v)(v))


class iob_module:
    """Generic class to describe a base iob-module"""

    __metaclass__ = iob_module_meta
    name = "iob_module"  # Verilog module name (not instance name)
    csr_if = "iob"
    version = "1.0"  # Module version
    description = "default description"  # Module description
    previous_version = None  # Module version
    setup_dir = ""  # Setup directory for this module
    build_dir = ""  # Build directory for this module
    rw_overlap = False  # overlap Read and Write register addresses
    is_top_module = False  # Select if this module is the top module
    use_netlist = False  # use module netlist
    is_system = False  # create software files in build directory
    board_list = None  # List of fpga files to copy to build directory
    confs = []
    regs = []
    ios = []
    block_groups = []
    submodule_list = []

    # Read-only dictionary with relation between the setup_purpose and the corresponding source folder
    purpose_dirs = {
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

    @classmethod
    def _setup(cls, is_top=True, purpose="hardware", topdir="."):
        print(topdir)
        """
        Initialize the setup process for the top module.
        """
        cls.is_top_module = is_top

        if is_top:
            topdir = f"../{cls.name}_{cls.version}"
            LIB_DIR = os.environ.get("LIB_DIR")
        cls.build_dir = topdir + "/build"

        # Create build directory this is the top module class, and is the first time setup
        if cls.is_top_module:
            cls.__create_build_dir()

        # check if directory ../{cls.name}_{cls.version} exists

        directory = Path(cls.build_dir)

        if directory.exists():
            print("Directory exists")
        else:
            print("Directory does not exist")

        # Setup submodules placed in `submodule_list` list
        for submodule in cls.submodule_list:
            if type(submodule) == tuple:
                if "purpose" not in submodule[1]:
                    submodule[0]._setup(False, "hardware", topdir)
                else:
                    submodule[0]._setup(False, submodule[1], topdir)
            else:
                submodule._setup(False, purpose, topdir)

        # Copy sources from the module's setup dir (and from its superclasses)
        cls._copy_srcs(purpose)

        # Generate configuration files
        config_gen.generate_confs(cls)

        # Generate parameters
        param_gen.generate_params(cls)

        # Generate ios
        io_gen.generate_ports(cls)

        # Generate csr interface
        csr_gen.generate_csr(cls)

        if is_top:
            # Replace Verilog snippet includes
            cls.replace_snippet_includes()
            # Clean duplicate sources in `hardware/src` and its subfolders (like `hardware/simulation/src`)
            cls.remove_duplicate_sources()
            # Generate ipxact file
            ipxact_gen.generate_ipxact_xml(cls, reg_table, cls.build_dir + "/ipxact")

    @classmethod
    def __create_build_dir(cls):
        """Create build directory. Must be called from the top module."""
        assert (
            cls.is_top_module
        ), f"{iob_colors.FAIL}Module {cls.name} is not a top module!{iob_colors.ENDC}"
        os.makedirs(cls.build_dir, exist_ok=True)
        # Create hardware directories
        os.makedirs(f"{cls.build_dir}/hardware/src", exist_ok=True)
        os.makedirs(f"{cls.build_dir}/hardware/simulation/src", exist_ok=True)
        os.makedirs(f"{cls.build_dir}/hardware/fpga/src", exist_ok=True)

        shutil.copyfile(f"{copy_srcs.LIB_DIR}/build.mk", f"{cls.build_dir}/Makefile")

    @classmethod
    def clean_build_dir(cls):
        """Clean build directory. Must be called from the top module."""
        cls.build_dir = f"../{cls.name}_{cls.version}"
        print(
            f"{iob_colors.ENDC}Cleaning build directory: {cls.build_dir}{iob_colors.ENDC}"
        )
        # if build_dir exists run make clean in it
        if os.path.exists(cls.build_dir):
            os.system(f"make -C {cls.build_dir} clean")
        shutil.rmtree(cls.build_dir, ignore_errors=True)

    @classmethod
    def print_build_dir(cls):
        """Print build directory."""
        cls.build_dir = f"../{cls.name}_{cls.version}"
        print(cls.build_dir)

    @classmethod
    def _copy_srcs(cls, exclude_file_list=[], highest_superclass=None):
        """Copy sources from the module's setup dir"""
        # find modules' setup dir
        current_directory = os.getcwd()
        # Use os.walk() to traverse the directory tree
        for root, directories, files in os.walk(current_directory):
            for directory in directories:
                # Print the absolute path of each directory found
                if directory == cls.name:
                    print(os.path.join(root, directory))
                    cls.setup_dir = os.path.join(root, directory)
                    break

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

            module_name = os.path.basename(filepath).split(".")[0]
            spec = importlib.util.spec_from_file_location(module_name, filepath)
            module = importlib.util.module_from_spec(spec)
            sys.modules[module_name] = module
            # Define setup_module object, corresponding to this class
            vars(module)["setup_module"] = cls
            # Execute setup file
            spec.loader.exec_module(module)
