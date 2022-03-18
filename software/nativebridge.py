#!/usr/bin/python3
#
#   Create NATIVEBRIDGEIF in directory specified
#   The NATIVEBRIDGEIF is a peripheral that only contains wires. It bridges the peripheral bus with an external interface.
#   It allows the peripheral bus signals to be accessed externally.
#

import sys
import os
import re

def create_nativebridgeif(directory):
    nativebridgeif_dir = os.path.join(directory, "NATIVEBRIDGEIF")

    # ~~~~~~~~~~~~ Create NATIVEBRIDGEIF folder ~~~~~~~~~~~~
    os.mkdir(nativebridgeif_dir)

    # ~~~~~~~~~~~~ Create harware and software dirs ~~~~~~~~~~~~
    os.mkdir(os.path.join(nativebridgeif_dir,"hardware"))
    os.mkdir(os.path.join(nativebridgeif_dir,"software"))

    # ~~~~~~~~~~~~ Create Makefile ~~~~~~~~~~~~
    makefile_str = """
corename:
	@echo "NATIVEBRIDGEIF"

.PHONY: corename
    """
    fout = open (os.path.join(nativebridgeif_dir,"Makefile"), 'w')
    fout.write(makefile_str)
    fout.close()

    # ~~~~~~~~~~~~ Create hardware.mk ~~~~~~~~~~~~
    harware_mk_str = """
# Library
ifneq (LIB,$(filter LIB, $(SUBMODULES)))
SUBMODULES+=LIB
INCLUDE+=$(incdir)$(LIB_DIR)/hardware/include
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
endif

# hardware include dirs
INCLUDE+=$(incdir)$(NATIVEBRIDGEIF_DIR)/hardware/include

# includes
VHDR+=$(wildcard $(NATIVEBRIDGEIF_DIR)/hardware/include/*.vh)

# sources
VSRC+=$(NATIVEBRIDGEIF_DIR)/hardware/src/iob_nativebridgeif.v
    """
    fout = open (os.path.join(nativebridgeif_dir,"hardware","hardware.mk"), 'w')
    fout.write(harware_mk_str)
    fout.close()

    # ~~~~~~~~~~~~ Create include, iob_nativebridgeif.vh, inst.v and pio.v ~~~~~~~~~~~~
    os.mkdir(os.path.join(nativebridgeif_dir,"hardware/include"))
    # iob_nativebridgeif.vh
    fin = open (os.path.join(os.path.dirname(__file__), '../hardware/include/iob_regfileif.vh'), 'r')
    verilogheader_content=fin.readlines()
    fin.close()
    for i in range(len(verilogheader_content)):
        verilogheader_content[i] = re.sub('REGFILE','NATIVEBRIDGE', verilogheader_content[i])
    fout = open (os.path.join(nativebridgeif_dir,"hardware/include","iob_nativebridgeif.vh"), 'w')
    fout.writelines(verilogheader_content)
    fout.close()
    # inst.v
    fin = open (os.path.join(os.path.dirname(__file__), '../hardware/include/inst.v'), 'r')
    instv_content=fin.readlines()
    fin.close()
    for i in range(len(instv_content)):
        instv_content[i] = re.sub('regfileif','nativebridgeif', 
                           re.sub('REGFILEIF','NATIVEBRIDGEIF', instv_content[i]))
    fout = open (os.path.join(nativebridgeif_dir,"hardware/include","inst.v"), 'w')
    fout.writelines(instv_content)
    fout.close()
    # pio.v
    fin = open (os.path.join(os.path.dirname(__file__), '../hardware/include/pio.v'), 'r')
    pio_content=fin.readlines()
    fin.close()
    for i in range(len(pio_content)):
        if 'input' in pio_content[i]:
            pio_content[i] = re.sub('REGFILEIF','NATIVEBRIDGEIF', 
                             re.sub('input','output', pio_content[i]))
        else:
            pio_content[i] = re.sub('REGFILEIF','NATIVEBRIDGEIF', 
                             re.sub('output','input', pio_content[i]))
    fout = open (os.path.join(nativebridgeif_dir,"hardware/include","pio.v"), 'w')
    fout.writelines(pio_content)
    fout.close()

    # ~~~~~~~~~~~~ Create verilog source ~~~~~~~~~~~~
    os.mkdir(os.path.join(nativebridgeif_dir,"hardware/src"))
    verilog_source_str = """
`timescale 1ns/1ps

`include "iob_lib.vh"
`include "iob_nativebridgeif.vh"

module iob_nativebridgeif
  # (
     parameter ADDR_W = `NATIVEBRIDGEIF_ADDR_W,
     parameter DATA_W = `NATIVEBRIDGEIF_DATA_W,
     parameter WDATA_W = `NATIVEBRIDGEIF_DATA_W
     )
   (

    // CPU interface
    `INPUT(valid,   1),
    `INPUT(address, ADDR_W),
    `INPUT(wdata,   WDATA_W),
    `INPUT(wstrb,   WDATA_W/8),
    `OUTPUT(rdata,  DATA_W),
    `OUTPUT(ready,  1),

    // External interface
    `OUTPUT(valid_ext,   1),
    `OUTPUT(address_ext, ADDR_W),
    `OUTPUT(wdata_ext,   WDATA_W),
    `OUTPUT(wstrb_ext,   WDATA_W/8),
    `INPUT(rdata_ext,  DATA_W),
    `INPUT(ready_ext,  1),


    `INPUT(clk,  1),
    `INPUT(rst,  1)
    );

    // Connect interfaces
    assign valid_ext = valid;
    assign address_ext = address;
    assign wdata_ext = wdata;
    assign wstrb_ext = wstrb;
    assign rdata = rdata_ext;
    assign ready = ready_ext;

endmodule
    """
    fout = open (os.path.join(nativebridgeif_dir,"hardware/src","iob_nativebridgeif.v"), 'w')
    fout.write(verilog_source_str)
    fout.close()

    # ~~~~~~~~~~~~ Create software.mk ~~~~~~~~~~~~
    software_str = """
defmacro:=-D
incdir:=-I

#include
INCLUDE+=-I$(NATIVEBRIDGEIF_DIR)/software

#headers
HDR+=$(NATIVEBRIDGEIF_DIR)/software/*.h

#sources
SRC+=
    """
    fout = open (os.path.join(nativebridgeif_dir,"software","software.mk"), 'w')
    fout.write(software_str)
    fout.close()
    # iob-nativebridgeif.h 
    fin = open (os.path.join(os.path.dirname(__file__), 'iob-regfileif.h'), 'r')
    src_content=fin.readlines()
    fin.close()
    for i in range(len(src_content)):
        src_content[i] = re.sub('regfile','nativebridge', src_content[i])
    fout = open (os.path.join(nativebridgeif_dir,"software","iob-nativebridgeif.h"), 'w')
    fout.writelines(src_content)
    fout.close()

    # ~~~~~~~~~~~~ Create embedded.mk ~~~~~~~~~~~~
    os.mkdir(os.path.join(nativebridgeif_dir,"software/embedded"))
    embedded_str = """
#nativebridge common parameters
include $(NATIVEBRIDGEIF_DIR)/software/software.mk

#embeded sources
SRC+=$(NATIVEBRIDGEIF_DIR)/software/embedded/iob-nativebridgeif.c
    """
    fout = open (os.path.join(nativebridgeif_dir,"software/embedded","embedded.mk"), 'w')
    fout.write(embedded_str)
    fout.close()
    # iob-nativebridgeif.c
    fin = open (os.path.join(os.path.dirname(__file__), 'embedded/iob-regfileif.c'), 'r')
    src_content=fin.readlines()
    fin.close()
    for i in range(len(src_content)):
        src_content[i] = re.sub('regfileif','nativebridgeif', src_content[i])
    fout = open (os.path.join(nativebridgeif_dir,"software/embedded","iob-nativebridgeif.c"), 'w')
    fout.writelines(src_content)
    fout.close()

    # ~~~~~~~~~~~~ Create pc.mk ~~~~~~~~~~~~
    os.mkdir(os.path.join(nativebridgeif_dir,"software/pc-emul"))
    pc_emul_str = """
#nativebridge common parameters
include $(NATIVEBRIDGEIF_DIR)/software/software.mk

#pc sources
SRC+=$(NATIVEBRIDGEIF_SW_DIR)/pc-emul/iob-nativebridgeif.c
    """
    fout = open (os.path.join(nativebridgeif_dir,"software/pc-emul","pc.mk"), 'w')
    fout.write(pc_emul_str)
    fout.close()
    # iob-nativebridgeif.c for pc-emul
    fin = open (os.path.join(os.path.dirname(__file__), 'pc-emul/iob-regfileif.c'), 'r')
    src_content=fin.readlines()
    fin.close()
    for i in range(len(src_content)):
        src_content[i] = re.sub('regfile','nativebridge', 
                         re.sub('REGFILE','NATIVEBRIDGE', src_content[i]))
    fout = open (os.path.join(nativebridgeif_dir,"software/pc-emul","iob-nativebridgeif.c"), 'w')
    fout.writelines(src_content)
    fout.close()

# Main function
if __name__ == "__main__" :
    if len(sys.argv) != 2:
        print("Usage: {} <path>".format(sys.argv[0]))
        print(" <path>: Create NATIVEBRIDGEIF in given path.")
        quit()
    else:
        create_nativebridgeif(sys.argv[1])
