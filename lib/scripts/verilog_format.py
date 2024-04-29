#!/usr/bin/env python3

import sys
import subprocess


def format_files(
    files_list, format_rules_file="./submodules/LIB/scripts/verible-format.rules"
):
    """Run Verible formatter on given list of files.
    :param files_list: list of files to format.
    :param format_rules_file: rules file to use.
    """
    # Read format rules
    with open(format_rules_file) as f:
        format_rules = f.read().replace("\n", " ")

    format_cmd = (
        f'verible-verilog-format --inplace {format_rules} {" ".join(files_list)}'
    )
    print(format_cmd)
    result = subprocess.run(format_cmd, shell=True)
    if result.returncode != 0:
        exit(result.returncode)


if __name__ == "__main__":
    files_list = sys.argv[1:]
    format_files(files_list)
