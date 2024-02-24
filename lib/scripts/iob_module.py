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

    def __init__(self):
        self.name = "iob_module"  # Verilog module name (not instance name)
        self.csr_if = "iob"
        self.version = "1.0"  # Module version
        self.description = "default description"  # Module description
        self.previous_version = None  # Module version
        self.setup_dir = ""  # Setup directory for this module
        self.build_dir = ""  # Build directory for this module
        self.rw_overlap = False  # overlap Read and Write register addresses
        self.is_top_module = False  # Select if this module is the top module
        self.use_netlist = False  # use module netlist
        self.is_system = False  # create software files in build directory
        self.board_list = None  # List of fpga files to copy to build directory
        self.confs = []
        self.regs = []
        self.ios = []
        self.block_groups = []
        self.submodule_list = []

        # Read-only dictionary with relation between the setup_purpose and the corresponding source folder
        self.purpose_dirs = {
            "hardware": "hardware/src",
            "simulation": "hardware/simulation/src",
            "fpga": "hardware/fpga/src",
        }

    def _setup(self, is_top=True, purpose="hardware", topdir="."):
        print(topdir)
        """
        Initialize the setup process for the top module.
        """
        self.is_top_module = is_top

        if is_top:
            topdir = f"../{self.name}_{self.version}"
            LIB_DIR = os.environ.get("LIB_DIR")
        self.build_dir = topdir + "/build"

        # Create build directory this is the top module class, and is the first time setup
        if self.is_top_module:
            self.__create_build_dir()

        # check if directory ../{self.name}_{self.version} exists

        directory = Path(self.build_dir)

        if directory.exists():
            print("Directory exists")
        else:
            print("Directory does not exist")

        # Setup submodules placed in `submodule_list` list
        for submodule in self.submodule_list:
            if type(submodule) == tuple:
                if "purpose" not in submodule[1]:
                    submodule[0]._setup(False, "hardware", topdir)
                else:
                    submodule[0]._setup(False, submodule[1], topdir)
            else:
                submodule._setup(False, purpose, topdir)

        # Copy sources from the module's setup dir (and from its superclasses)
        self._copy_srcs(purpose)

        # Generate configuration files
        config_gen.generate_confs(self)

        # Generate parameters
        param_gen.generate_params(self)

        # Generate ios
        io_gen.generate_ports(self)

        # Generate csr interface
        csr_gen.generate_csr(self)

        if is_top:
            # Replace Verilog snippet includes
            self.replace_snippet_includes()
            # Clean duplicate sources in `hardware/src` and its subfolders (like `hardware/simulation/src`)
            self.remove_duplicate_sources()
            # Generate ipxact file
            ipxact_gen.generate_ipxact_xml(self, reg_table, self.build_dir + "/ipxact")

    def __create_build_dir(self):
        """Create build directory. Must be called from the top module."""
        assert (
            self.is_top_module
        ), f"{iob_colors.FAIL}Module {self.name} is not a top module!{iob_colors.ENDC}"
        os.makedirs(self.build_dir, exist_ok=True)
        # Create hardware directories
        os.makedirs(f"{self.build_dir}/hardware/src", exist_ok=True)
        os.makedirs(f"{self.build_dir}/hardware/simulation/src", exist_ok=True)
        os.makedirs(f"{self.build_dir}/hardware/fpga/src", exist_ok=True)

        shutil.copyfile(f"{copy_srcs.LIB_DIR}/build.mk", f"{self.build_dir}/Makefile")

    def clean_build_dir(self):
        """Clean build directory. Must be called from the top module."""
        self.build_dir = f"../{self.name}_{self.version}"
        print(
            f"{iob_colors.ENDC}Cleaning build directory: {self.build_dir}{iob_colors.ENDC}"
        )
        # if build_dir exists run make clean in it
        if os.path.exists(self.build_dir):
            os.system(f"make -C {self.build_dir} clean")
        shutil.rmtree(self.build_dir, ignore_errors=True)

    def print_build_dir(self):
        """Print build directory."""
        self.build_dir = f"../{self.name}_{self.version}"
        print(self.build_dir)

    def _copy_srcs(self, exclude_file_list=[], highest_superclass=None):
        """Copy sources from the module's setup dir"""
        # find modules' setup dir
        current_directory = os.getcwd()
        # Use os.walk() to traverse the directory tree
        for root, directories, files in os.walk(current_directory):
            for directory in directories:
                # Print the absolute path of each directory found
                if directory == self.name:
                    print(os.path.join(root, directory))
                    self.setup_dir = os.path.join(root, directory)
                    break

    def _remove_duplicate_sources(self):
        """Remove sources in the build directory from subfolders that exist in `hardware/src`"""
        # Go through all subfolders defined in PURPOSE_DIRS
        for subfolder in self.PURPOSE_DIRS.values():
            # Skip hardware folder
            if subfolder == "hardware/src":
                continue

            # Get common srcs between `hardware/src` and current subfolder
            common_srcs = self.find_common_deep(
                os.path.join(self.build_dir, "hardware/src"),
                os.path.join(self.build_dir, subfolder),
            )
            # Remove common sources
            for src in common_srcs:
                os.remove(os.path.join(self.build_dir, subfolder, src))
                # print(f'{iob_colors.INFO}Removed duplicate source: {os.path.join(subfolder, src)}{iob_colors.ENDC}')

    def _replace_snippet_includes(self):
        verilog_gen.replace_includes(self.setup_dir, self.build_dir)
