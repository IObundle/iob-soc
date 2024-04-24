#!/usr/bin/env -S python3 -B

import sys

from iob_core import iob_core


def from_dict(core_dict):
    """Generate a core from a py2hwsw dictionary"""
    iob_core.py2hw(core_dict)


def from_json(json_filepath):
    """Generate a core from a given json file"""
    iob_core.read_py2hw_json(json_filepath)


if __name__ == "__main__":
    print(f"Py2hwsw args: {sys.argv}")  # DEBUG
    core_name = sys.argv[1]
    instance = iob_core.get_core_obj(core_name)
