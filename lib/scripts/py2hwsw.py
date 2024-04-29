#!/usr/bin/env -S python3 -B

import argparse

from iob_base import fail_with_msg
from iob_core import iob_core


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
        "--build_dir",
        dest="build_dir",
        type=str,
        default="",
        help="The core's build directory",
    )
    parser.add_argument(
        "--project_root",
        dest="project_root",
        type=str,
        default=".",
        help="The project root directory",
    )

    parser.add_argument(
        "--no_verilog_format",
        dest="verilog_format",
        action="store_false",
        help="Disable verilog formatter",
    )
    parser.add_argument(
        "--no_verilog_lint",
        dest="verilog_lint",
        action="store_false",
        help="Disable verilog linter",
    )
    args = parser.parse_args()

    # print(f"Args: {args}", file=sys.stderr)  # DEBUG

    iob_core.global_build_dir = args.build_dir
    iob_core.global_project_root = args.project_root
    iob_core.global_project_vformat = args.verilog_format
    iob_core.global_project_vlint = args.verilog_lint

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
