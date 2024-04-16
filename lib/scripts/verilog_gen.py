#!/usr/bin/env python3
import os
import iob_colors
import re

from param_gen import has_params


# Find include statements inside a list of lines and replace them by the contents of the included file and return the new list of lines
def replace_includes_in_lines(lines, VSnippetFiles, ignore_snippets):
    for line in lines:
        if re.search(r'`include ".*\.vs"', line):
            # retrieve the name of the file to be included
            tail = line.split('"')[1]
            if tail in ignore_snippets:
                continue
            found_vs = False
            for VSnippetFile in VSnippetFiles:
                if tail == os.path.basename(VSnippetFile):
                    found_vs = True
                    # open the file to be included
                    with open(f"{VSnippetFile}", "r") as include:
                        include_lines = include.readlines()
                    # replace the include statement with the content of the file
                    # if the file to be included is *_portmap.vs or *_port.vs and has a ");" in the next line, remove the last comma
                    if re.search(r'`include ".*_portmap\.vs"', line) or re.search(
                        r'`include ".*_port\.vs"', line
                    ):
                        if re.search(r"\s*\);\s*", lines[lines.index(line) + 1]):
                            # find and remove the first comma in the last line of the include_lines ignoring white spaces
                            include_lines[-1] = re.sub(
                                r"\s*,\s*", "", include_lines[-1], count=1
                            )
                    # if the include_lines has an include statement, recursively replace the include statements
                    for include_line in include_lines:
                        if re.search(r'`include ".*\.vs"', include_line):
                            include_lines = replace_includes_in_lines(
                                include_lines, VSnippetFiles, ignore_snippets
                            )
                    # replace the include statement with the content of the file
                    lines[lines.index(line)] = "".join(include_lines)
                    break
            # if the file to be included is not found in the VSnippetFiles, raise an error
            if not found_vs:
                raise FileNotFoundError(
                    f"{iob_colors.FAIL}File {tail} not found! {iob_colors.ENDC}"
                )
    return lines


# Function to search recursively for every verilog file inside the search_path
def replace_includes(setup_dir="", build_dir="", ignore_snippets=[]):
    VSnippetFiles = []
    VerilogFiles = []
    SearchPaths = f"{build_dir}/hardware"
    ExcludeDirs = ["hardware/fpga/db", "hardware/fpga/ip"]

    for root, dirs, files in os.walk(SearchPaths):
        # Skip directories from ExcludeDirs
        if any(exclude_dir in root for exclude_dir in ExcludeDirs):
            continue

        for file in files:
            if file.endswith(".vs"):
                VSnippetFiles.append(f"{root}/{file}")
                VerilogFiles.append(f"{root}/{file}")
            elif file.endswith(".v") or file.endswith(".sv") or file.endswith(".vh"):
                VerilogFiles.append(f"{root}/{file}")

    for VerilogFile in VerilogFiles:
        print(f"Replacing includes in {VerilogFile}")
        with open(VerilogFile, "r") as source:
            try:
                lines = source.readlines()
            except UnicodeDecodeError:
                print(
                    f"{iob_colors.FAIL}Error occured when opening '{VerilogFile}'. That file is not utf-8 encoded.{iob_colors.ENDC}."
                )
                exit(1)
            # replace the include statements with the content of the file
            new_lines = replace_includes_in_lines(lines, VSnippetFiles, ignore_snippets)
        # write the new file
        with open(VerilogFile, "w") as source:
            source.writelines(new_lines)

    # Remove .vs files from current directory
    for VSnippetFile in VSnippetFiles:
        os.remove(VSnippetFile)

    print(
        f"{iob_colors.INFO}Replaced Verilog Snippet includes with respective content and deleted the files.{iob_colors.ENDC}"
    )


# Insert given verilog code into module defined inside the given verilog source file
# If `after_line` is provided, the code will be inserted just after that line.
# Otherwise, the code will be inserted just before the `endmodule` statement.
def insert_verilog_in_module(verilog_code, verilog_file_path, after_line=""):
    with open(verilog_file_path, "r") as system_source:
        lines = system_source.readlines()
    if after_line:
        # Find line index
        for idx, line in enumerate(lines):
            if after_line in line:
                insertion_idx = idx + 1
                break
        else:
            raise Exception(
                f"{iob_colors.FAIL}verilog_tools.py: Could not find '{after_line}' declaration in '{verilog_file_path}'!{iob_colors.ENDC}"
            )
    else:
        # Find `endmodule`
        for idx, line in enumerate(lines):
            if line.startswith("endmodule"):
                insertion_idx = idx
                break
        else:
            raise Exception(
                f"{iob_colors.FAIL}verilog_tools.py: Could not find 'endmodule' declaration in '{verilog_file_path}'!{iob_colors.ENDC}"
            )

    # Insert Verilog code
    lines.insert(insertion_idx, verilog_code + "\n")

    # Write new system source file
    with open(verilog_file_path, "w") as system_source:
        system_source.writelines(lines)


# Remove given verilog line of code from the given verilog source file
def remove_verilog_line_from_source(verilog_code, verilog_file_path):
    with open(verilog_file_path, "r") as system_source:
        lines = system_source.readlines()
    # Find Verilog line that contains given verilog_code
    line_idx = 0
    while line_idx < len(lines):
        # Remove line if contains verilog_code
        if verilog_code in lines[line_idx]:
            lines.pop(line_idx)
            break
        line_idx += 1

    # Write new system source file
    with open(verilog_file_path, "w") as system_source:
        system_source.writelines(lines)


# Replace string in file
def inplace_change(filename, old_string, new_string):
    # Safely read the input filename using 'with'
    with open(filename) as f:
        s = f.read()
        if old_string not in s:
            print('"{old_string}" not found in {filename}.'.format(**locals()))
            return

    # Safely write the changed content, if found in the file
    with open(filename, "w") as f:
        print(
            'Changing "{old_string}" to "{new_string}" in {filename}'.format(**locals())
        )
        s = s.replace(old_string, new_string)
        f.write(s)


def generate_verilog(core):
    """Generate main Verilog module of given core
    if it does not exist yet (may be defined manually or generated previously).
    """
    out_dir = core.build_dir + "/hardware/src"
    file_path = os.path.join(out_dir, f"{core.name}.v")

    if os.path.exists(file_path):
        print(
            f"Note: Not generating '{core.name}.v'. Module already exists (probably created manually or generated previously)."
        )
        return

    f_module = open(file_path, "w+")

    if has_params(core.confs):
        params_line = f'#(\n    `include "{core.name}_params.vs"\n) ('
    else:
        params_line = "("

    module_body_lines = ""
    if core.wires:
        module_body_lines += f'    `include "{core.name}_wires.vs"\n\n'

    if core.csrs:
        module_body_lines += f'    `include "{core.name}_swreg_inst.vs"\n\n'

    if core.blocks:
        module_body_lines += f'    `include "{core.name}_blocks.vs"\n\n'

    if core.snippets:
        module_body_lines += f'    `include "{core.name}_snippets.vs"\n\n'

    f_module.write(
        f"""`timescale 1ns / 1ps
`include "{core.name}_conf.vh"

module {core.name} {params_line}
    `include "{core.name}_io.vs"
);
{module_body_lines}
endmodule
"""
    )
    f_module.close()
