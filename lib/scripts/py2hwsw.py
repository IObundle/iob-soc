#!/usr/bin/env -S python3 -B

import sys
import argparse

from iob_base import fail_with_msg
from iob_core import iob_core


# TODO: Do we still need these functions?
# They were supposed to be imported by the user script (<core_name>.py)
# But since the entire setup process can be managed from the command line,
# I'm not sure if these are needed anymore.
def from_dict(core_dict):
    """Generate a core from a py2hwsw dictionary"""
    iob_core.py2hw(core_dict)


def from_json(json_filepath):
    """Generate a core from a given json file"""
    iob_core.read_py2hw_json(json_filepath)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Python to hardware/software generator"
    )
    parser.add_argument("core_name", type=str, help="The name of the core to generate.")
    parser.add_argument(
        "target",
        type=str,
        default="setup",
        help="The target action to perform. "
        "Options: setup, clean, print_build_dir, print_py2hwsw_attributes.",
    )
    parser.add_argument(
        "--project_root", type=str, default=".", help="The project root directory"
    )
    args = parser.parse_args()

    print(f"Args: {args}")  # DEBUG

    if args.target == "setup":
        iob_core.get_core_obj(args.core_name)
    elif args.target == "clean":
        iob_core.clean_build_dir(args.core_name)
    elif args.target == "print_build_dir":
        iob_core.print_build_dir(args.core_name)
    elif args.target == "print_py2hwsw_attributes":
        iob_core.print_py2hwsw_attributes(args.core_name)
    else:
        fail_with_msg(f"Unknown target: {args.target}")
