#!/usr/bin/python3
#
#    Build configured REGFILEIF registers and signals
#

import sys
import os

mkregs_dir = ''

if __name__ == "__main__" :
    #parse command line to get mkregs_dir
    if len(sys.argv) != 4:
        print("Usage: {} COREsw_reg.v [HW|SW] [mkregs.py dir]".format(sys.argv[0]))
        print(" REGFILEIFsw_reg.v:the software accessible registers definitions file")
        print(" [HW|SW]: use HW to generate the hardware files or SW to generate the software files")
        print(" [mkregs.py dir]: directory of mkregs.py")
        quit()
    else:
        mkregs_dir = sys.argv[3]

# Add folder to path that contains python scripts to be imported
sys.path.append(mkregs_dir)
import mkregs
from mkregs import *

# Change <infile>sw_reg_gen.v to connect to external native bus
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

    fin = open (infile, 'r')
    defsfile = fin.readlines()
    fin.close()

    infile = infile.split('/')[-1].split('.')[0]

    # Create normal sw_reg
    mkregs.infile=infile
    swreg_parse (defsfile, hwsw)

    # Only create inverted files for Hardware
    if(hwsw == "HW"):
        # Make connections between read and write registers
        connect_wires_between_regs(infile+"_wire_connections.v", defsfile)

        # Change <infile>sw_reg_gen.v to connect to external native bus
        connect_to_external_native(infile+"_gen.v")

        # Create sw_reg with read and write registers inverted
        infile = infile + "_inverted"
        mkregs.infile=infile
        # invert registers type
        for i in range(len(defsfile)):
            if 'SWREG_W' in defsfile[i]:
                defsfile[i] = re.sub('SWREG_W\(([^,]+),','SWREG_R(\g<1>_INVERTED,', defsfile[i])
            else:
                defsfile[i] = re.sub('SWREG_R\(([^,]+),','SWREG_W(\g<1>_INVERTED,', defsfile[i])

        # write REGFILEIFsw_reg_inverted.v file
        fout = open (infile+".v", 'w')
        fout.writelines(defsfile)
        fout.close()

        # create generated inverted files
        swreg_parse (defsfile, hwsw)
