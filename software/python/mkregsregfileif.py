#!/usr/bin/python3
#
#    Build configured REGFILEIF/NATIVEBRIDGEIF registers and signals
#

import sys
import os
import re

mkregs_dir = ''

if __name__ == "__main__" :
    #parse command line to get mkregs_dir
    if len(sys.argv) != 5:
        print("Usage: {} iob_corename_swreg.vh [HW|SW] [mkregs.py dir] [top_module_name]".format(sys.argv[0]))
        print(" iob_regfileif_swreg.vh:the software accessible registers definitions file")
        print(" [HW|SW]: use HW to generate the hardware files or SW to generate the software files")
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
    fin = open (filename, 'r')
    file_contents = fin.readlines()
    fin.close()

    for i in range(len(file_contents)):
        file_contents[i] = re.sub('valid','valid_ext', 
                re.sub('wstrb','wstrb_ext', 
                re.sub('wdata','wdata_ext', 
                re.sub('rdata','rdata_ext', 
                re.sub('address','address_ext', 
                re.sub('ready','ready_ext', 
                file_contents[i]
                ))))))

    fout = open (filename, 'w')
    fout.writelines(file_contents)
    fout.close()

# Make connections between read and write registers
def connect_wires_between_regs(filename, program):
    file_contents = []

    for line in program :
        if line.startswith("//"): continue #commented line

        subline = re.sub('\[|\]|:|,|//|\;',' ', line)
        subline = re.sub('\(',' ',subline, 1)
        subline = re.sub('\)',' ', subline, 1)

        flds = subline.split()
        if not flds : continue #empty line
        #print flds[0]
        if ('SWREG_' in flds[0]): #software accessible registers
            reg_name = flds[1] #register name

            #register type
            if '_W' in flds[0]: #write register
                file_contents.append("assign {}{} = {};\n".format(flds[1],"_INVERTED",flds[1]))
            else: #read register
                file_contents.append("assign {} = {}{};\n".format(flds[1],flds[1],"_INVERTED"))

        else: continue #not a recognized macro

    fout = open (filename, 'w')
    fout.writelines(file_contents)
    fout.close()

# Main function
if __name__ == "__main__" :
    infile = sys.argv[1]
    hwsw = sys.argv[2]
    corename = sys.argv[4]

    fin = open (infile, 'r')
    defsfile = fin.readlines()
    fin.close()

    # Create normal swreg
    swreg_parse (defsfile, hwsw, corename)

    if(hwsw == "HW"):
        # Make connections between read and write registers
        connect_wires_between_regs(corename+"_swreg_wire_connections.vh", defsfile)

        # Change <corename>_gen.vh to connect to external native bus
        connect_to_external_native(corename+"_swreg_gen.vh")

    # Create swreg with read and write registers inverted
    corename = corename + "_inverted"
    # invert registers type
    for i in range(len(defsfile)):
        if 'SWREG_W' in defsfile[i]:
            defsfile[i] = re.sub('SWREG_W\(([^,]+),','SWREG_R(\g<1>_INVERTED,', defsfile[i])
        else:
            defsfile[i] = re.sub('SWREG_R\(([^,]+),','SWREG_W(\g<1>_INVERTED,', defsfile[i])

    if(hwsw == "HW"):
        # write iob_COREPREFIX_inverted_swreg.vh file
        fout = open (corename+".vh", 'w')
        fout.writelines(defsfile)
        fout.close()

    # create generated inverted files
    swreg_parse (defsfile, hwsw, corename)
