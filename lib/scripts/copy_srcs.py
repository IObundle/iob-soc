# This module copies sources to the build directory

import os
import sys
import subprocess
from pathlib import Path
import shutil
import importlib.util

# IObundle scripts imported:
import if_gen
import iob_colors


def get_lib_dir():
    return os.path.join(os.path.dirname(__file__), "..")


# This function sets up the flows for this core
def flows_setup(python_module):
    # Setup simulation
    sim_setup(python_module)

    # Setup fpga
    fpga_setup(python_module)

    # Setup harware
    hw_setup(python_module)

    lint_setup(python_module)

    syn_setup(python_module)

    # Setup software
    sw_setup(python_module)

    # Setup documentation if it is top module
    doc_setup(python_module)


def hw_setup(python_module):
    # Create module's version TeX file. Also create *_version.vh Verilog Header if we do not have csrs.
    if python_module.is_top_module:
        version_file(python_module)


# Setup simulation related files/modules
# module: python module representing a *_setup.py file of the root directory of the core/system.
def sim_setup(python_module):
    build_dir = python_module.build_dir

    sim_dir = "hardware/simulation"

    # Copy LIB sim files
    shutil.copytree(
        f"{get_lib_dir()}/{sim_dir}",
        f"{build_dir}/{sim_dir}",
        dirs_exist_ok=True,
        ignore=shutil.ignore_patterns("*.pdf"),
    )


# Setup fpga files, but only the ones in the board_list
def fpga_setup(python_module):
    # If board_list is empty, then do nothing
    if not python_module.board_list:
        return

    build_dir = python_module.build_dir
    fpga_dir = "hardware/fpga"
    src_dir = f"{get_lib_dir()}/{fpga_dir}"
    dst_dir = f"{build_dir}/{fpga_dir}"
    tools_list = ["quartus", "vivado"]

    # Copy common fpga files in the fpga_dir (except for the directories in the tools list)
    shutil.copytree(
        src_dir,
        dst_dir,
        dirs_exist_ok=True,
        ignore=shutil.ignore_patterns("*.pdf", *tools_list),
    )

    # Copy LIB fpga directories only if their name is present in the board_list
    for fpga in python_module.board_list:
        for tool in tools_list:
            setup_fpga_dir = os.path.join(src_dir, tool, fpga)
            if os.path.isdir(setup_fpga_dir):
                # if the tool does not exist in the build directory, then create it
                # and copy only files (not directories) in tool directory
                if not os.path.isdir(os.path.join(dst_dir, tool)):
                    os.makedirs(os.path.join(dst_dir, tool))
                    setup_tool_dir = os.path.join(src_dir, tool)
                    # copy files in tool directory
                    for file in os.listdir(setup_tool_dir):
                        setup_tool_file = os.path.join(setup_tool_dir, file)
                        if os.path.isfile(setup_tool_file):
                            shutil.copy2(
                                setup_tool_file, os.path.join(dst_dir, tool, file)
                            )
                # then copy the fpga directory (excluding any .pdf)
                shutil.copytree(
                    setup_fpga_dir,
                    os.path.join(dst_dir, tool, fpga),
                    dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns("*.pdf"),
                )


def lint_setup(python_module):
    build_dir = python_module.build_dir
    lint_dir = "hardware/lint"

    # Copy LIB lint files
    shutil.copytree(
        f"{get_lib_dir()}/{lint_dir}",
        f"{build_dir}/{lint_dir}",
        dirs_exist_ok=True,
    )


# synthesis
def syn_setup(python_module):
    build_dir = python_module.build_dir
    syn_dir = "hardware/syn"

    for file in Path(f"{get_lib_dir()}/{syn_dir}").rglob("*"):
        src_file = file.as_posix()
        dest_file = os.path.join(
            build_dir, src_file.replace(get_lib_dir(), "").strip("/")
        )
        if os.path.isfile(src_file):
            os.makedirs(os.path.dirname(dest_file), exist_ok=True)
            shutil.copyfile(f"{src_file}", f"{dest_file}")


# Check if any *_setup.py modules exist (like sim_setup.py, fpga_setup.py, ...).
# If so, get a function to execute them and run them
# This will allow these modules to be executed during setup
#    python_module: python module of *_setup.py of the core/system, should contain setup_dir
#    **kwargs: set of objects that will be accessible from inside the modules when they are executed
def run_setup_functions(python_module, module_type, **kwargs):
    # Check if any *_setup.py modules exist. If so, get a function to execute them and add them to the 'modules' list
    module_path = {
        "sim_setup": "hardware/simulation/sim_setup.py",
        "fpga_setup": "hardware/fpga/fpga_setup.py",
        "sw_setup": "software/sw_setup.py",
        "doc_setup": "document/doc_setup.py",
    }[module_type]
    full_module_path = os.path.join(python_module.setup_dir, module_path)
    if os.path.isfile(full_module_path):
        # Get and run function of this file
        get_module_function(full_module_path, **kwargs)()


# Get an executable function to run a given python module
#    module_path: python module path
#    **kwargs: set of objects that will be accessible from inside the module when it is executed
# Example: get_module_function("sim_setup.py",setup_module=python_module)
def get_module_function(module_path, **kwargs):
    # Create function to execute module if it exists
    def module_function():
        if os.path.isfile(module_path):
            module_name = os.path.basename(module_path).split(".")[0]
            spec = importlib.util.spec_from_file_location(module_name, module_path)
            module = importlib.util.module_from_spec(spec)
            sys.modules[module_name] = module
            # Define module objects given via kwargs
            for key, value in kwargs.items():
                vars(module)[key] = value
            spec.loader.exec_module(module)

    return module_function


# Setup simulation related files/modules
# module: python module representing a *_setup.py file of the root directory of the core/system.
def sw_setup(python_module):
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir

    os.makedirs(build_dir + "/software/src", exist_ok=True)
    # Copy LIB software Makefile
    shutil.copy(f"{get_lib_dir()}/software/Makefile", f"{build_dir}/software/Makefile")

    # Create 'scripts/' directory
    python_setup(build_dir)


def python_setup(build_dir):
    dest_dir = f"{build_dir}/scripts"
    if not os.path.exists(dest_dir):
        os.mkdir(dest_dir)
    copy_files(get_lib_dir(), dest_dir, ["iob_colors.py"], "*.py")


def doc_setup(python_module):
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir

    # Copy LIB tex files if not present
    os.makedirs(f"{build_dir}/document/tsrc", exist_ok=True)
    for file in os.listdir(f"{get_lib_dir()}/document/tsrc"):
        shutil.copy2(
            f"{get_lib_dir()}/document/tsrc/{file}", f"{build_dir}/document/tsrc/{file}"
        )

    # Copy LIB figures
    os.makedirs(f"{build_dir}/document/figures", exist_ok=True)
    for file in os.listdir(f"{get_lib_dir()}/document/figures"):
        shutil.copy2(
            f"{get_lib_dir()}/document/figures/{file}",
            f"{build_dir}/document/figures/{file}",
        )

    # Copy document Makefile
    shutil.copy2(f"{get_lib_dir()}/document/Makefile", f"{build_dir}/document/Makefile")

    # General documentation
    write_git_revision_short_hash(f"{build_dir}/document/tsrc")


def write_git_revision_short_hash(dst_dir):
    file_name = "shortHash.tex"
    text = (
        subprocess.check_output(["git", "rev-parse", "--short", "HEAD"])
        .decode("ascii")
        .strip()
    )

    if not (os.path.exists(dst_dir)):
        os.makedirs(dst_dir)
    file = open(f"{dst_dir}/{file_name}", "w")
    file.write(text)


# Include headers and srcs from given python module (module_name)
# headers: List of headers that will be appedend by the list of headers in the .py module.
# srcs: List of srcs that will be appedend by the list of srcs in the .py module.
# module_name: name of the python module to include. Can also be the name of a src module (with the same extension as passed in the module_extension parameter).
# lib_dir: root directory of the LIB
# add_sim_srcs: If True, then the list of simulation sources will be appended to the srcs list
# add_fpga_srcs: If True, then the list of FPGA sources will be appended to the srcs list
# module_parameters: optional argument. Allows passing an optional object with parameters to a hardware module.
# module_extension: Select module file extension (.v for hardware, .c for software)
def lib_module_setup(
    headers,
    srcs,
    module_name,
    lib_dir=get_lib_dir(),
    add_sim_srcs=False,
    add_fpga_srcs=False,
    module_parameters=None,
    module_extension=".v",
):
    module_path = None

    # Search for module_name.py
    for mod_path in Path(lib_dir).rglob(f"{module_name}.py"):
        module_path = mod_path
        break
    # If module_name.py is not found, search for module_name.module_extension
    if not module_path:
        for mod_path in Path(lib_dir).rglob(f"{module_name}{module_extension}"):
            module_path = mod_path
            break
    # Exit if module is not found
    if not module_path:
        sys.exit(
            f"{iob_colors.FAIL} {module_name} is not a LIB module.{iob_colors.ENDC}"
        )

    extension = os.path.splitext(module_path)[1]
    # If module_name.py is found, import the headers and srcs lists from it
    if extension == ".py":
        lib_module_name = os.path.basename(module_path).split(".")[0]
        spec = importlib.util.spec_from_file_location(lib_module_name, module_path)
        lib_module = importlib.util.module_from_spec(spec)
        sys.modules[lib_module_name] = lib_module
        if module_parameters:
            lib_module.module_parameters = module_parameters
        spec.loader.exec_module(lib_module)
        headers.extend(lib_module.headers)
        srcs.extend(lib_module.modules)
        if add_sim_srcs and (
            hasattr(lib_module, "sim_headers") and hasattr(lib_module, "sim_modules")
        ):
            headers.extend(lib_module.sim_headers)
            srcs.extend(lib_module.sim_modules)
        if add_fpga_srcs and (
            hasattr(lib_module, "fpga_headers") and hasattr(lib_module, "fpga_modules")
        ):
            headers.extend(lib_module.fpga_headers)
            srcs.extend(lib_module.fpga_modules)
    # If module_name.module_extension is found, add it to the srcs list
    elif extension == module_extension:
        srcs.append(f"{module_name}{module_extension}")


def copy_files(src_dir, dest_dir, sources=[], pattern="*", copy_all=False):
    files_copied = []
    print(src_dir)
    if (sources != []) or copy_all:
        os.makedirs(dest_dir, exist_ok=True)
        for path in Path(src_dir).rglob(pattern):
            file = path.name
            if (file in sources) or copy_all:
                src_file = path.resolve()
                dest_file = f"{dest_dir}/{file}"
                if os.path.isfile(src_file) and (
                    not (os.path.isfile(dest_file))
                    or (os.stat(src_file).st_mtime < os.stat(dest_file).st_mtime)
                ):
                    shutil.copy(src_file, dest_file)
                    files_copied.append(file)
                elif not (os.path.isfile(src_file)):
                    print(
                        f"{iob_colors.WARNING}{src_file} is not a file.{iob_colors.ENDC}"
                    )
                else:
                    print(
                        f"{iob_colors.INFO}Not copying file. File in build directory is newer than the one in the source directory.{iob_colors.ENDC}"
                    )
    else:
        print(
            f"{iob_colors.WARNING}'copy_files' function did nothing.{iob_colors.ENDC}"
        )
    return files_copied


# Create verilog headers for the interfaces in Vheaders list, using if_gen.py
# This function will remove all if_gen entries from the Vheaders list. It will leave the .vh files in that list.
def create_if_gen_headers(dest_dir, Vheaders):
    non_if_gen_interfaces = []
    for vh_name in Vheaders:
        if type(vh_name) == str and vh_name.endswith(".vh"):
            # Save this entry as a .vh file.
            non_if_gen_interfaces.append(vh_name)
            continue  # Skip if_gen for this entry
        elif (type(vh_name) is str) and (vh_name in if_gen.interfaces):
            if "iob_" in vh_name:
                file_prefix = ""
            else:
                file_prefix = "iob_"
            f_out = open(f"{dest_dir}/{file_prefix}{vh_name}.vh", "w")
            if_gen.create_signal_table(vh_name)
            if_gen.write_vh_contents(vh_name, "", "", f_out)
        elif (type(vh_name) is dict) and (vh_name["interface"] in if_gen.interfaces):
            f_out = open(
                f"{dest_dir}/{vh_name['file_prefix']}{vh_name['interface']}.vh", "w"
            )
            if_gen.create_signal_table(vh_name["interface"])
            if_gen.write_vh_contents(
                vh_name["interface"],
                vh_name["port_prefix"],
                vh_name["wire_prefix"],
                f_out,
                bus_size=vh_name["bus_size"] if "bus_size" in vh_name.keys() else 1,
                bus_start=vh_name["bus_start"] if "bus_start" in vh_name.keys() else 0,
            )
        else:
            sys.exit(
                f"{iob_colors.FAIL} {vh_name} is not an available header.{iob_colors.ENDC}"
            )
    # Save the list of non if_gen interfaces (will only contain .vh files)
    Vheaders = non_if_gen_interfaces


# Create TeX and optionally Verilog header files with the version of the system
def version_file(
    python_module,
    create_version_header=True,
):
    core_name = python_module.name
    core_version = python_module.version
    core_previous_version = python_module.previous_version
    build_dir = python_module.build_dir

    tex_dir = f"{build_dir}/document/tsrc"
    verilog_dir = f"{build_dir}/hardware/src"

    os.makedirs(tex_dir, exist_ok=True)
    tex_file = f"{tex_dir}/{core_name}_version.tex"
    with open(tex_file, "w") as tex_f:
        tex_f.write(core_version)
    tex_file = f"{tex_dir}/{core_name}_previous_version.tex"
    with open(tex_file, "w") as tex_f:
        tex_f.write(core_previous_version)

    # Don't create version.vh if module has csrs (because it already has the VERSION register)
    if python_module.csrs:
        return

    vh_file = f"{verilog_dir}/{core_name}_version.vh"
    vh_version_string = "0"
    for c in core_version:
        if c.isdigit():
            vh_version_string += c
    with open(vh_file, "w") as vh_f:
        vh_f.write(f"`define VERSION {vh_version_string}")


# Given a version string (like "V0.12"), return a 4 digit string representing the version (like "0012")
def version_str_to_digits(version_str):
    version_str = version_str.replace("V", "")
    major_ver, minor_ver = version_str.split(".")
    return f"{int(major_ver):02d}{int(minor_ver):02d}"


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


def copy_rename_setup_subdir(core, directory, exclude_file_list=[]):
    """Copy and rename files from a given setup subdirectory to the build directory
    :param core: The core object
    :param directory: The directory to copy
    :param exclude_file_list: List of wildcards for files to exclude
    """
    # Skip this directory if it does not exist
    if not os.path.isdir(os.path.join(core.setup_dir, directory)):
        return

    # If we are handling the `hardware/src` directory,
    # copy to the correct destination based on setup_purpose.
    if directory == "hardware/src":
        dst_directory = core.PURPOSE_DIRS[core.purpose]
        if core.use_netlist:
            # copy SETUP_DIR/CORE.v netlist instead of
            # SETUP_DIR/hardware/src
            shutil.copyfile(
                os.path.join(core.setup_dir, f"{core.name}.v"),
                os.path.join(core.build_dir, f"{dst_directory}/{core.name}.v"),
            )
            return
    elif directory == "hardware/fpga":
        # Skip if board_list is empty
        if not core.board_list:
            return

        tools_list = ["quartus", "vivado"]

        # Copy everything except the tools directories
        shutil.copytree(
            os.path.join(core.setup_dir, directory),
            os.path.join(core.build_dir, directory),
            dirs_exist_ok=True,
            copy_function=copy_with_rename(core.original_name, core.name),
            ignore=shutil.ignore_patterns(*exclude_file_list, *tools_list),
        )

        # if it is the fpga directory, only copy the directories in the cores board_list
        for fpga in core.board_list:
            # search for the fpga directory in the cores setup_dir/hardware/fpga
            # in both quartus and vivado directories
            for tools_dir in tools_list:
                setup_tools_dir = os.path.join(core.setup_dir, directory, tools_dir)
                build_tools_dir = os.path.join(core.build_dir, directory, tools_dir)
                setup_fpga_dir = os.path.join(setup_tools_dir, fpga)
                build_fpga_dir = os.path.join(build_tools_dir, fpga)

                # if the fpga directory is found, copy it to the build_dir
                if os.path.isdir(setup_fpga_dir):
                    # Copy the tools directory files only
                    for file in os.listdir(setup_tools_dir):
                        setup_file = os.path.join(setup_tools_dir, file)
                        if os.path.isfile(setup_file):
                            copy_with_rename(core.name, core.name)(
                                setup_file,
                                os.path.join(build_tools_dir, file),
                            )
                    # Copy the fpga directory
                    shutil.copytree(
                        setup_fpga_dir,
                        build_fpga_dir,
                        dirs_exist_ok=True,
                        copy_function=copy_with_rename(core.original_name, core.name),
                        ignore=shutil.ignore_patterns(*exclude_file_list),
                    )
                    break
            else:
                raise Exception(
                    f"{iob_colors.FAIL}FPGA directory {fpga} not found in {core.setup_dir}/hardware/fpga/{iob_colors.ENDC}"
                )

        # No need to copy any more files in this directory
        return

    else:
        dst_directory = directory

    # Copy tree of this directory, renaming files, and overriding destination ones.
    # Note: The `copy_with_rename` may throw errors when
    #       trying to rename binary files from the doc dir.
    #       The main branch used a dedicated script to copy doc files
    #       without renaming them. Maybe here we should try to
    #       implement it with a try catch block.
    shutil.copytree(
        os.path.join(core.setup_dir, directory),
        os.path.join(core.build_dir, dst_directory),
        dirs_exist_ok=True,
        copy_function=copy_with_rename(core.original_name, core.name),
        ignore=shutil.ignore_patterns(*exclude_file_list),
    )


def copy_rename_setup_directory(core, exclude_file_list=[]):
    """Copy and rename files from the module's setup dir.
    Any string from the files in the setup dir that matches the
    module's class name (core.original_name) will be replaced by the
    module's name (core.name).
    For example, if we create a new IOb-SoC module with
    `iob_soc(name="iob_soc_sut")` then the `iob_soc.v` file from
    the iob-soc setup dir will have all instances of the string 'iob_soc'
    replaced with the new string 'iob_soc_sut'.

    :param list exclude_file_list: list of strings, each string representing an ignore pattern for the source files.
                                   For example, using the ignore pattern '*.v' would prevent from copying every Verilog source file.
                                   Note, if want to ignore a file that is going to be renamed with the new core name,
                                   we would still use the old core name in the ignore patterns.
                                   For example, if we dont want it to generate the 'new_name_firmware.c' based on the 'old_name_firmware.c',
                                   then we should add 'old_name_firmware.c' to the ignore list.
    """

    # Files that should always be copied
    dir_list = [
        "hardware/src",
        "software",
    ]
    # Files that should only be copied if it is top module
    if core.is_top_module:
        dir_list += [
            "hardware/simulation",
            "hardware/common_src",
            "hardware/fpga",
            "hardware/syn",
            "hardware/lint",
            "doc",
        ]

    # Copy sources
    for directory in dir_list:
        copy_rename_setup_subdir(core, directory, exclude_file_list)
