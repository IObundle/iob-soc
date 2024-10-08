#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

import os, sys

sys.path.insert(0, os.getcwd() + "/submodules/LIB/scripts")
import setup
from submodule_utils import import_setup

name = "iob_nativebridgeif"
flows = ""
setup_dir = os.path.dirname(__file__)
submodules = {}

regfileif_core_module = import_setup(f"{setup_dir}/..")
# Copy some fields from the regfileif core
version = regfileif_core_module.version
flows = regfileif_core_module.flows
if setup.is_top_module(sys.modules[__name__]):
    build_dir = f"../{name}_{version}"

confs = regfileif_core_module.confs

ios = [
    {"name": "iob_s_port", "descr": "Slave CPU native interface", "ports": []},
    {"name": "iob_m_port", "descr": "Master CPU native interface", "ports": []},
]

regs = [
    {
        "name": "dummy",
        "descr": "Dummy registers to run register setup functions",
        "regs": [
            {
                "name": "DUMMY",
                "type": "R",
                "n_bits": 1,
                "rst_val": 0,
                "addr": -1,
                "log2n_items": 0,
                "autologic": False,
                "descr": "Dummy Register",
            },
        ],
    }
]

blocks = []


# Main function to setup this core and its components
def main():
    setup.setup(sys.modules[__name__])

    # Remove csrs_gen and csrs_inst files
    os.remove(f"{build_dir}/hardware/src/{name}_csrs_inst.vs")
    os.remove(f"{build_dir}/hardware/src/{name}_csrs_gen.v")

    # Modify iob_nativebridgeif_csrs_def.vh
    with open(f"{build_dir}/hardware/src/{name}_csrs_def.vh", "w") as file:
        file.write('`include "iob_regfileif_csrs_def.vh"\n')
        file.write(
            "`define IOB_NATIVEBRIDGEIF_csrs_ADDR_W `IOB_REGFILEIF_csrs_ADDR_W\n"
        )


if __name__ == "__main__":
    main()
