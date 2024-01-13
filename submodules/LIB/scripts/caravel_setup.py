import os
import shutil
import sys
import json
import re
import importlib


def find_module_instantiations(verilog_file_path):
    module_names = []
    module_pattern = r"^(?!module).*\b\w+\s*#\s*\([\s\S]*?;\s*$"
    with open(verilog_file_path, "r") as file:
        verilog_code = file.read()
        # Search for module instantiations using regex
        matches = re.findall(module_pattern, verilog_code, re.MULTILINE)
        # Extract module names from the matches
        for match in matches:
            # Capture the module name pattern
            module_name = match.split()[0] + ".v"
            module_names.append(module_name)
    return module_names


def find_includes(file_path):
    with open(file_path, "r") as file:
        verilog_code = file.read()
        include_pattern = re.compile(r'`include\s+"([^"]+)"')
        matches = include_pattern.findall(verilog_code)
        return matches


if len(sys.argv) >= 2:
    build_dir = sys.argv[1]
    print(build_dir)
else:
    print("Please provide two arguments.")
    sys.exit(1)  # Exiting with a non-zero code signifies an error condition

build_dir = os.path.abspath(build_dir)
source_path = os.path.join(os.getcwd(), "submodules", "caravel_project")
target_path = os.path.join(build_dir, "caravel_project")


try:
    # Ensure that the source directory exists
    if os.path.exists(source_path):
        # Check if the target directory already exists
        if not os.path.exists(target_path):
            shutil.copytree(source_path, target_path)
            print(f"Directory '{source_path}' copied to '{target_path}'")
        else:
            print(f"Directory '{target_path}' already exists.")
    else:
        print(f"Source directory '{source_path}' does not exist.")
except shutil.Error as e:
    print(f"Error: {e}")
except OSError as e:
    print(f"Error: {e}")

source_path = os.path.join(os.getcwd(), "hardware", "caravel", "src")
target_path = os.path.join(target_path, "verilog", "rtl")
open_lane_dir = os.path.join(build_dir, "caravel_project", "openlane")
user_proj_dir = os.path.join(open_lane_dir, "user_proj_example")


required_modules = []
temporary_models = []
temporary_models2 = []
temporary_models3 = []


if os.path.exists(source_path):
    v_top_modules = [file for file in os.listdir(source_path) if file.endswith(".v")]
    print("hamburgues")
    # Copy each '.v' file from source_path to target_path
    for file_name in v_top_modules:

        source_file = os.path.join(source_path, file_name)
        target_file = os.path.join(target_path, file_name)
        shutil.copyfile(source_file, target_file)
        module_name = os.path.splitext(file_name)[0]

        temporary_dir = os.path.join(open_lane_dir, module_name)
        iob_soc_src_path = os.path.join(build_dir, "hardware", "src")
        iob_bp = os.path.join(build_dir, "hardware", "simulation", "src")

        v_files_sim = [
            file for file in os.listdir(iob_bp) if file.endswith((".v", ".vh"))
        ]

        for file_name in v_files_sim:
            source_file_path = os.path.join(iob_bp, file_name)
            destination_file_path = os.path.join(iob_soc_src_path, file_name)
            # Copy the file from source to destination
            shutil.copy(source_file_path, destination_file_path)

        temporary_models = find_module_instantiations(target_file)
        required_modules = temporary_models + find_includes(target_file)

        while temporary_models != []:
            temporary_models3 = []
            for verilog_names in temporary_models:
                destination_file_path = os.path.join(iob_soc_src_path, verilog_names)

                # search any new instatiated module in the verilog file
                temporary_models2 = find_module_instantiations(
                    destination_file_path
                ) + find_includes(destination_file_path)
                # verify if there is any repeated modules
                for verilog_names2 in temporary_models2:
                    for verilog_names3 in required_modules:
                        if verilog_names2 == verilog_names3:
                            temporary_models2.remove(verilog_names2)

                temporary_models3 = temporary_models3 + temporary_models2
                required_modules = required_modules + temporary_models2

            temporary_models = temporary_models3

            print(required_modules)
