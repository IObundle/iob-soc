from copy_srcs import (
    lib_module_setup,
    create_if_gen_headers,
    copy_files,
)
import sys


def lib_sim_setup(module_name, dest_srcs_dir):
    hardware_srcs = []
    Vheaders = []
    lib_dir = "."
    lib_module_setup(
        Vheaders, hardware_srcs, module_name, lib_dir=lib_dir, add_sim_srcs=True
    )
    # func_and_include_setup(hardware_srcs, Vheaders, flow="sim", lib_dir=lib_dir)

    # Copy Hw
    if Vheaders:
        create_if_gen_headers(dest_srcs_dir, Vheaders)
        copy_files(lib_dir, dest_srcs_dir, Vheaders, "*.vh")
    if hardware_srcs:
        copy_files(lib_dir, dest_srcs_dir, hardware_srcs, "*.v")

    # Copy TB
    copy_files(lib_dir, dest_srcs_dir, [], f"{module_name}_tb.v", copy_all=True)
    # Copy LIB hw files
    copy_files("hardware/modules", dest_srcs_dir, [], "iob_utils.vh", copy_all=True)
    copy_files("hardware/modules", dest_srcs_dir, [], "iob_tasks.vs", copy_all=True)


if __name__ == "__main__":
    lib_sim_setup(sys.argv[1], sys.argv[2])
