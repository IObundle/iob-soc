#!/usr/bin/env -S python3 -B

import sys
import os

import iob_core
from iob_base import find_obj_in_list, fail_with_msg, find_file, import_python_module


def from_dict(core_dict):
    """Generate a core from a py2hwsw dictionary"""
    iob_core.iob_core.py2hw(core_dict)


def from_json(json_filepath):
    """Generate a core from a given json file"""
    iob_core.iob_core.read_py2hw_json(json_filepath)


if __name__ == "__main__":
    print(f"Py2hwsw args: {sys.argv}")  # DEBUG
    core_name = sys.argv[1]
    core_dir, file_ext = iob_core.find_module_setup_dir(core_name)

    if file_ext == ".py":
        import_python_module(
            os.path.join(core_dir, f"{core_name}.py"),
        )
        core_module = sys.modules[core_name]
        core_dict = core_module.setup({"core_name": core_name})
        from_dict(core_dict)
    elif file_ext == ".json":
        from_json(os.path.join(core_dir, f"{core_name}.json"))
