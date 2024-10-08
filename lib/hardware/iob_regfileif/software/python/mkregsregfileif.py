#!/usr/bin/python3

# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

#
#    Build configured REGFILEIF/NATIVEBRIDGEIF registers and signals
#

import sys
import os
import re

mkregs_dir = ""

if __name__ == "__main__":
    # parse command line to get mkregs_dir
    if len(sys.argv) != 5:
        print(
            "Usage: {} iob_corename_csrs.vh [HW|SW] [mkregs.py dir] [top_module_name]".format(
                sys.argv[0]
            )
        )
        print(
            " iob_regfileif_csrs.vh:the software accessible registers definitions file"
        )
        print(
            " [HW|SW]: use HW to generate the hardware files or SW to generate the software files"
        )
        print(" [mkregs.py dir]: directory of mkregs.py")
        print(" [top_module_name]: Top/core module name")
        quit()
    else:
        mkregs_dir = sys.argv[3]

# Add folder to path that contains python scripts to be imported
sys.path.append(mkregs_dir)
from mkregs import *


# Change <infile>_gen.vh to connect to external native bus
def connect_to_external_native(filename):
    fin = open(filename, "r")
    file_contents = fin.readlines()
    fin.close()

    for i in range(len(file_contents)):
        file_contents[i] = re.sub(
            "valid",
            "valid_ext",
            re.sub(
                "wstrb",
                "wstrb_ext",
                re.sub(
                    "wdata",
                    "wdata_ext",
                    re.sub(
                        "rdata",
                        "rdata_ext",
                        re.sub(
                            "address",
                            "address_ext",
                            re.sub(
                                "ready",
                                "ready_ext",
                                re.sub("addr_reg", "addr_ext_reg", file_contents[i]),
                            ),
                        ),
                    ),
                ),
            ),
        )

    fout = open(filename, "w")
    fout.writelines(file_contents)
    fout.close()


# Create file with registers and connect wires from internal native and external native interfaces
def create_regs(filename, program):
    file_contents = []

    for line in program:
        if line.startswith("//"):
            continue  # commented line

        subline = re.sub("\[|\]|:|,|//|\;", " ", line)
        subline = re.sub("\(", " ", subline, 1)
        subline = re.sub("\)", " ", subline, 1)

        flds = subline.split()
        if not flds:
            continue  # empty line
        # print flds[0]
        if "csrs_" in flds[0]:  # software accessible registers
            reg_name = flds[1]  # register name
            reg_size_bits = int(flds[2]) * 8  # register size
            reg_rst_val = flds[3]  # register name

            file_contents.append("`IOB_WIRE({}, {})\n".format(reg_name, reg_size_bits))
            file_contents.append(
                "iob_reg #(.DATA_W({}),.RST_VAL({}))\n".format(
                    reg_size_bits, reg_rst_val
                )
            )
            file_contents.append("{} (\n".format(reg_name.lower()))
            file_contents.append(
                ".clk        (clk),\n\
                    .arst       (rst),\n\
                    .rst        (rst),\n"
            )
            # register type
            if "_W" in flds[0]:  # write register
                file_contents.append(
                    ".en         ({reg_name}_en),\n\
                        .data_in    ({reg_name}_wdata_ext),\n\
                        .data_out   ({reg_name}_INVERTED_rdata)\n".format(
                        reg_name=reg_name
                    )
                )
            else:  # read register
                file_contents.append(
                    ".en         ({reg_name}_INVERTED_en),\n\
                        .data_in    ({reg_name}_INVERTED_wdata),\n\
                        .data_out   ({reg_name}_rdata_ext)\n".format(
                        reg_name=reg_name
                    )
                )
            file_contents.append(");\n")

        else:
            continue  # not a recognized macro

    fout = open(filename, "w")
    fout.writelines(file_contents)
    fout.close()


# Main function
if __name__ == "__main__":
    infile = sys.argv[1]
    hwsw = sys.argv[2]
    corename = sys.argv[4]

    fin = open(infile, "r")
    defsfile = fin.readlines()
    fin.close()

    # Create normal csrs
    csrs_parse(defsfile, hwsw, corename)

    if hwsw == "HW":
        # Create regs
        create_regs(corename + "_csrs_regs.vh", defsfile)

        # Change <corename>_gen.vh to connect to external native bus
        connect_to_external_native(corename + "_csrs_gen.vh")

    # Create csrs with read and write registers inverted
    corename = corename + "_inverted"
    # invert registers type
    for i in range(len(defsfile)):
        if "csrs_W" in defsfile[i]:
            defsfile[i] = re.sub(
                "csrs_W\(([^,]+),", "csrs_R(\g<1>_INVERTED,", defsfile[i]
            )
        else:
            defsfile[i] = re.sub(
                "csrs_R\(([^,]+),", "csrs_W(\g<1>_INVERTED,", defsfile[i]
            )

    if hwsw == "HW":
        # write iob_COREPREFIX_inverted.vh file
        fout = open(corename + ".vh", "w")
        fout.writelines(defsfile)
        fout.close()

    # create generated inverted files
    csrs_parse(defsfile, hwsw, corename)

    # Hack to rename 'write_reg' and 'read_reg' inside iob_COREPREFIX_inverted_csrs_gen.vh, because it would cause duplicates if inverted and non inverted csrs_gen.vh files were included
    if hwsw == "HW":
        fin = open(corename + "_csrs_gen.vh", "r")
        file_contents = fin.readlines()
        fin.close()

        for i in range(len(file_contents)):
            file_contents[i] = re.sub(
                "write_reg", "write_reg_inverted", file_contents[i]
            )
            file_contents[i] = re.sub("read_reg", "read_reg_inverted", file_contents[i])

        fout = open(corename + "_csrs_gen.vh", "w")
        fout.writelines(file_contents)
        fout.close()
