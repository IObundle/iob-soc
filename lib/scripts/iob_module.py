import os
import shutil
from dataclasses import dataclass, field

import iob_colors

import copy_srcs

import config_gen
import param_gen
import verilog_gen
import reg_gen
import io_gen
import doc_gen
import ipxact_gen

from iob_verilog_instance import iob_verilog_instance


@dataclass
class iob_module:
    """Generic class to describe how to generate a base IOb IP core / module"""

    name: str = None
    csr_if: str = "iob"
    version: str = "1.0"  # Module version
    description: str = "default description"  # Module description
    previous_version: str = version  # Module previous version
    setup_dir: str = ""  # Setup directory for this module
    build_dir: str = ""  # Build directory for this module
    rw_overlap: bool = False  # overlap Read and Write register addresses
    is_top_module: bool = False  # Select if this module is the top module
    use_netlist: bool = False  # use module netlist
    is_system: bool = False  # create software files in build directory
    board_list: list = None  # List of fpga files to copy to build directory
    purpose: str = "hardware"
    confs: tuple = ()
    regs: tuple = ()
    ios: tuple = ()
    block_groups: tuple = ()
    submodule_list: tuple = ()
    ignore_snippets: tuple = ()  # List of snippets to ignore during replace

    # Read-only dictionary with relation between the setup_purpose and the corresponding source folder
    PURPOSE_DIRS: dict = field(
        default_factory=lambda: {
            "hardware": "hardware/src",
            "simulation": "hardware/simulation/src",
            "fpga": "hardware/fpga/src",
        }
    )

    def __post_init__(self, is_top=True, purpose="hardware", topdir="."):
        """
        Finish attribute initialization and init setup process for this module
        """
        self.is_top_module = is_top
        # TODO: Check if name is being set corretly
        self.name = self.name or self.__class__.__name__

        if is_top:
            self.set_default_build_dir()
            topdir = self.build_dir
        else:
            self.build_dir = topdir
        self.setup_dir = find_module_setup_dir(self, os.getcwd())
        self.purpose = purpose

        # Create build directory this is the top module class, and is the first time setup
        if is_top:
            self.__create_build_dir()

        # Setup submodules placed in `submodule_list` list
        for submodule in self.submodule_list:
            if type(submodule) is tuple:
                if "purpose" not in submodule[1]:
                    submodule[0]._setup(False, "hardware", topdir)
                else:
                    submodule[0]._setup(False, submodule[1]["purpose"], topdir)
            else:
                submodule._setup(False, purpose, topdir)

        # Copy files from LIB to setup various flows
        # (should run before copy of files from module's setup dir)
        if is_top:
            copy_srcs.flows_setup(self)

        # Copy files from the module's setup dir
        copy_srcs.copy_rename_setup_directory(self)

        # Generate config_build.mk
        config_gen.config_build_mk(self)

        # Generate configuration files
        config_gen.generate_confs(self)

        # Generate parameters
        param_gen.generate_params(self)

        # Generate ios
        io_gen.generate_ports(self)

        # Generate csr interface
        csr_gen_obj, reg_table = reg_gen.generate_csr(self)

        if is_top:
            # Replace Verilog snippet includes
            self._replace_snippet_includes()
            # Clean duplicate sources in `hardware/src` and its subfolders (like `hardware/simulation/src`)
            self._remove_duplicate_sources()
            # Generate docs
            doc_gen.generate_docs(self, csr_gen_obj, reg_table)
            # Generate ipxact file
            # if self.generate_ipxact: #TODO: When should this be generated?
            #    ipxact_gen.generate_ipxact_xml(self, reg_table, self.build_dir + "/ipxact")

    # by default, set build_dir for all modules as top module
    def set_default_build_dir(self):
        self.build_dir = f"../{self.name}_{self.version}/build"

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

        os.makedirs(f"{self.build_dir}/doc", exist_ok=True)
        os.makedirs(f"{self.build_dir}/doc/tsrc", exist_ok=True)

        shutil.copyfile(
            f"{copy_srcs.get_lib_dir()}/build.mk", f"{self.build_dir}/Makefile"
        )

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

    def instance(self, name="", *args, **kwargs):
        """Create a verilog instance for the current ip core/verilog module."""

        if not name:
            name = f"{self.name}_0"

        # Return a new iob_verilog_instance object with these attributes that describe the Verilog instance
        return iob_verilog_instance(name, *args, module=self, **kwargs)


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


def find_module_setup_dir(core, search_path):
    """Searches for a core's setup directory, and updates `core.setup_dir` attribute.
    param core: The core object
    param search_path: The directory to search
    """
    # Use os.walk() to traverse the directory tree
    for root, directories, files in os.walk(search_path):
        for file in files:
            # Check if file name matches '<core_class_name>.py'
            if file.split(".")[0] == core.__class__.__name__:
                # print(os.path.join(root, file)) # DEBUG
                return root

    raise Exception(
        f"{iob_colors.FAIL}Setup dir of {core.name} not found in {search_path}!{iob_colors.ENDC}"
    )
