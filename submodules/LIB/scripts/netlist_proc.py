#!/usr/bin/env python3

"""
Usage:
- From a shell:
    ./netlist_proc.py input_netlist.v output_netlist.v iob_top_module

- From another python script:
    import netlist_proc

    netlist_proc.process_netlist(
        input="input_netlist.v",
        output="output_netlist.v",
        top_module="iob_top_module",
        prefix="_prefix_",
    )
"""

import argparse
import re
import sys


def process_netlist(input, output, top_module, prefix="_"):
    print("Netlist processing:")
    print(f"\t\tInput: {input}")
    print(f"\t\tOutput: {output}")
    print(f"\t\tTop module: {top_module}")
    print(f"\t\tPrefix: {prefix}")

    # search pattern: "module <name>"
    pattern = r"module\s+(\w+)"

    # Read input netlist
    with open(input, "r") as file:
        content = file.read()

    netlist_modules = []
    # Iterate through the lines and look for the pattern
    for line in content.splitlines():
        match = re.search(pattern, line)
        if match:
            module_name = match.group(1)
            netlist_modules.append(module_name)

    # Remove top module
    netlist_modules = [line for line in netlist_modules if line != top_module]

    # replace all instances of <module name> with {prefix}<module_name>
    for module_name in netlist_modules:
        replacement_string = f"{prefix}{module_name}"
        content = content.replace(module_name, replacement_string)

    # write processed netlist
    with open(output, "w") as f:
        f.write(content)


def parse_args():
    parser = argparse.ArgumentParser(
        description="IObundle Netlist Processing Script. Adds prefixes to all module names (except top module) to avoid module name collisions with other verilog sources."
    )
    parser.add_argument("input", help="Input netlist file.")
    parser.add_argument("output", help="Output netlist file.")
    parser.add_argument("-t", help="Netlist top level module.")
    parser.add_argument("-p", default="_", help="Prefix to add to module names.")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    process_netlist(args.input, args.output, args.t, args.p)
