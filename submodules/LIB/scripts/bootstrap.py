#!/usr/bin/env -S python3 -B
# Python script to search and add python modules under the given directory to the search path.
# It also instatiates the top module, assuming that it is a class with the same name as the file that contains it.
import os
import sys
import datetime


# Search for files under the given directory using a breadth-first search
def bfs_search_files(search_path):
    dirs = [search_path]
    return_values = []
    # while there are dirs to search
    while len(dirs):
        nextDirs = []
        for parent in dirs:
            # Create a tuple for this directory containing the path and a list of files in it
            dir_tuple = (parent, [])
            return_values.append(dir_tuple)
            # Scan this dir
            for f in os.listdir(parent):
                # if there is a dir, then save for next ittr
                # if it is a file then save it in dir_tuple
                ff = os.path.join(parent, f)
                if os.path.isdir(ff):
                    nextDirs.append(ff)
                else:
                    dir_tuple[1].append(f)
        # once we've done all the current dirs then
        # we set up the next itter as the child dirs
        # from the current itter.
        dirs = nextDirs
    return return_values


def init_top_module():
    """ "
    Initialize the top module and return it.
    """
    top_module = vars(sys.modules[top_module_name])[top_module_name]
    top_module.is_top_module = True
    top_module.init_attributes()

    return top_module


# Insert header in source files
def insert_header():
    # invoked from the command line as:
    # python3 bootstrap.py <top_module_name> -f insert_header -h <header_file> <comment> <file1> <file2> <file3> ...
    # where
    # <header_file> is the name of the header file to be inserted.
    # <comment> is the comment character to be used
    # <file1> <file2> <file3> ... are the files to be processed

    # get the current year
    year = datetime.datetime.now().year

    top_module = init_top_module()

    # get the name and version of the top module
    core_name = top_module.name
    core_version = top_module.version

    h_arg_index = sys.argv.index("-h")

    # header is in the file whose name is given in the first argument after `-h`
    f = open(sys.argv[h_arg_index + 1], "r")
    header = f.readlines()
    f.close()

    # replace the following strings in the header:
    # $NAME with the core name
    # $VERSION with the core version
    # $YEAR with the current year
    for i in range(len(header)):
        header[i] = header[i].replace("$NAME", core_name)
        header[i] = header[i].replace("$VERSION", core_version)
        header[i] = header[i].replace("$YEAR", str(year))

    # insert the header in the files given in the command line
    files_list = sys.argv[h_arg_index + 3 :]
    comment_string = sys.argv[h_arg_index + 2]
    for filename in files_list:
        f = open(filename, "r+")
        content = f.read()
        f.seek(0, 0)
        for line in header:
            f.write(comment_string + "  " + f"{line}")
        f.write("\n\n\n" + content)


# Given a version string, return a 4 digit representation of that version.
def version_from_str(version_str):
    major, minor = version_str.replace("V", "").split(".")
    version_str = f"{int(major):02d}{int(minor):02d}"
    return version_str


# function to return the top module name
def get_top_module_name():
    top_module = init_top_module()
    print(f"{top_module.name}", end="")


# function to return the top module version
def get_top_module_version():
    top_module = init_top_module()
    print(f"{top_module.version}", end="")


# Print build directory attribute of the top module
def get_build_dir():
    try:
        top_module = init_top_module()
        print(top_module.build_dir)
    except:
        print("ERROR: No build directory found for the top module")
        raise


# Instantiate top module to start setup process
def instantiate_top_module():
    top_module = init_top_module()
    top_module.setup_as_top_module()


##########################################################################################
########   Main script    ################################################################
##########################################################################################
if __name__ == "__main__":

    if len(sys.argv) < 2:
        print(
            "Usage: %s <top_module_name> [setup_args] [-s <search_path>] [-f <func_name>]"
            % sys.argv[0]
        )
        print(
            "<top_module_name>: Name of top module class and file (they must have the same name)."
        )
        print(
            "-s <search_path>: Optional root of search path for python modules. Defaults to current directory."
        )
        print("-f <func_name>: Optional function name to execute")
        print(
            "setup_args: Optional project-defined arguments that may be using during setup process of the current project."
        )
        exit(0)

    search_path = "."
    if "-s" in sys.argv:
        search_path = sys.argv[sys.argv.index("-s") + 1]

    # Add python modules search paths for every module
    print(f"Searching for modules under '{search_path}'...", file=sys.stderr)
    found_modules = []
    for filepath, files in bfs_search_files(search_path):
        for filename in files:
            if filename.endswith(".py") and filename not in found_modules:
                sys.path.append(filepath)
                found_modules.append(filename)

    # Import top module
    top_module_name = sys.argv[1].split(".")[0]
    exec("import " + top_module_name)

    # Set a custom LIB directory
    for arg in sys.argv:
        if "LIB_DIR" in arg:
            import copy_srcs

            copy_srcs.LIB_DIR = arg.split("=")[1]
            break

    # Call either the default function or the one given by the user
    function_2_call = "instantiate_top_module"
    if "-f" in sys.argv:
        function_2_call = sys.argv[sys.argv.index("-f") + 1]
    print(f"Calling '{function_2_call}'...", file=sys.stderr)
    vars()[function_2_call]()
