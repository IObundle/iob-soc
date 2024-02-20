#!/usr/bin/env python3

import argparse
import subprocess


def submodule_exceptions(path):
    # get repository submodules
    submodules = subprocess.run(
        "git submodule",
        shell=True,
        check=True,
        capture_output=True,
        text=True,
        cwd=path,
    ).stdout

    # parse submodule info to get submodule path
    submodule_exceptions = ""
    for submodule in submodules.split("\n"):
        try:
            submodule_dir = submodule.strip().split(" ")[1]
            submodule_exceptions = (
                f"{submodule_exceptions} -not -path './{submodule_dir}/*'"
            )
        except IndexError:
            pass
    return submodule_exceptions


def build_find_cmd(path, file_extentions):
    # 1. check if path is git repository:
    # 1.A. Is git repo: exclude submodule paths in find command
    # 1.B. Not git repo: search all subdirectories
    # 2. Add pattern to search for file_extentions

    # check if path is git repository
    is_git_repo = subprocess.run(
        "git rev-parse --is-inside-work-tree",
        shell=True,
        capture_output=True,
        text=True,
        cwd=path,
    ).stdout.strip()

    find_flags = ""
    if is_git_repo == "true":
        find_flags = submodule_exceptions(path)

    find_cmd = f"find {path} {find_flags} -type f \("
    first_extention = 1
    for extention in file_extentions.split(" "):
        if first_extention:
            find_cmd = f"{find_cmd} -name '{extention}'"
            first_extention = 0
        else:
            find_cmd = f"{find_cmd} -o -name '{extention}'"
    find_cmd = f"{find_cmd} \)"
    return find_cmd


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="sw_format.py",
        description="""Software format script.
        Format all software files in directory or repository (except submodules).
        Currently supports black (python) and clang (C/C++).""",
    )
    parser.add_argument(
        "formater", choices=["black", "clang"], help="Formater program to run."
    )
    parser.add_argument(
        "path",
        type=str,
        nargs="?",
        default=".",
        help="path to format. Formats all subdirs, except for git submodules",
    )
    args = parser.parse_args()

    match args.formater:
        case "black":
            cmd = "black"
            flags = ""
            file_extentions = "*.py"
        case "clang":
            cmd = "clang-format"
            flags = "-i -style=file -fallback-style=none -Werror"
            file_extentions = "*.c *.h *.cpp *.hpp"
        case _:
            cmd = ""
            flags = ""
            file_extentions = ""

    # find all files and format
    format_cmd = (
        f"{build_find_cmd(args.path, file_extentions)} | xargs -r {cmd} {flags}"
    )
    subprocess.run(format_cmd, shell=True, check=True)
    print(format_cmd)
