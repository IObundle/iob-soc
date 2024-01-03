import os
import shutil
import sys
import json
import importlib


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

if os.path.exists(source_path):
    v_top_modules = [file for file in os.listdir(source_path) if file.endswith(".v")]
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
            file
            for file in os.listdir(iob_bp)
            if file.endswith((".v", ".vh")) and file != "iob_soc_tb.v"
        ]
        for file_name in v_files_sim:
            source_file_path = os.path.join(iob_bp, file_name)
            destination_file_path = os.path.join(iob_soc_src_path, file_name)
            # Copy the file from source to destination
            shutil.copy(source_file_path, destination_file_path)
        v_files = [
            file
            for file in os.listdir(iob_soc_src_path)
            if file.endswith((".v", ".vh"))
            and "ram" not in file
            and file != "iob_soc.v"
            and file != "iob_cache_onehot_to_bin.v"
            and file != "iob_cache_replacement_policy.v"
            and file != "axi_interconnect.v"
            and file != "iob_soc_int_mem.v"
            and file != "iob_soc_ext_mem.v"
        ]
        # now it is made just for two directoried, but this can be done as the bootstrap, and import everithing

        if not os.path.exists(temporary_dir):
            os.makedirs(temporary_dir)
            print(f"Directory '{temporary_dir}' created.")
            # Copy contents of user_proj_example to temporary_dir
            for item in os.listdir(user_proj_dir):
                s = os.path.join(user_proj_dir, item)
                d = os.path.join(temporary_dir, item)
                if os.path.isdir(s):
                    shutil.copytree(s, d, symlinks=True)
                else:
                    shutil.copy2(s, d)
            json_temp = os.path.join(temporary_dir, "config.json")
            if os.path.exists(json_temp):
                with open(json_temp, "r") as json_file:
                    data = json.load(json_file)
                    data["DESIGN_NAME"] = module_name
                    data["VERILOG_FILES"] = [
                        file
                        for file in data["VERILOG_FILES"]
                        if "user_proj_example.v" not in file
                    ]
                    data["VERILOG_FILES"].append(target_file)
                    for verig in v_files:
                        temp = os.path.join(iob_soc_src_path, verig)
                        data["VERILOG_FILES"].append(temp)
                with open(json_temp, "w") as json_file:
                    json.dump(data, json_file, indent=4)
        else:
            print("Temporary directory already exists.")
