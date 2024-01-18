import os
import shutil
import sys
import json
import re
import importlib





if len(sys.argv) >= 2:
    build_dir = sys.argv[1]
    print(build_dir)
else:
    print("Please provide two arguments.")
    sys.exit(1)  # Exiting with a non-zero code signifies an error condition



build_dir = os.path.abspath(build_dir)

source_path = os.path.join(os.getcwd(), "hardware", "caravel", "src")

if os.path.exists(source_path) and os.path.isdir(source_path):
    # List all files in the directory with a .v extension (assuming Verilog files have .v extension)
    verilog_files = [os.path.join(source_path, file) for file in os.listdir(source_path) if file.endswith(".v")]
else:
    print(f"The directory '{source_path}' does not exist or is not a directory.")


target_path = os.path.join(build_dir, "caravel_project","verilog", "rtl")
if os.path.exists(source_path) and os.path.isdir(source_path) and os.path.exists(target_path) and os.path.isdir(target_path):
    # List Verilog files in the target directory
    target_verilog_files = [file for file in os.listdir(target_path) if file.endswith(".v")]

    # Verify if each Verilog file in the target directory exists in the source directory
    for target_file in target_verilog_files:
        source_file = os.path.join(source_path, target_file)
        target_file = os.path.join(target_path, target_file)

        # If the file exists in the source directory, overwrite it with the one from the target directory
        if os.path.exists(source_file) and os.path.isfile(source_file):
            shutil.copy(target_file, source_file)
            print(f"Overwritten: {source_file} with {target_file}")

    print("Verification and copying complete.")
else:
    print("Source or target directory does not exist or is not a directory.")