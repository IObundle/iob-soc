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


class iob_module:
    """Generic class to describe a base iob-module"""

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
    def _setup(cls, is_top=False, purpose="hardware", topdir=""):
        print(topdir)
        """
        Initialize the setup process for the top module.
        """
        cls.is_top_module = is_top

        if is_top:
            topdir = f"../{cls.name}_{cls.version}"

        cls.build_dir = topdir

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
        cls._copy_srcs()

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
                                        cls.copy_with_rename(module_class.name, cls.name)(
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
