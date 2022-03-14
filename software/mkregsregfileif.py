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
sys.path.append(os.path.join(os.path.dirname(__file__), mkregs_dir))
import mkregs
from mkregs import *

# Main function
if __name__ == "__main__" :
    infile = sys.argv[1]
    hwsw = sys.argv[2]

    fin = open (infile, 'r')
    defsfile = fin.readlines()
    fin.close()

    infile = infile.split('/')[-1].split('.')[0]

    # Create normal sw_reg
    infile_part = infile + "_1"
    mkregs.infile=infile_part
    swreg_parse (defsfile, hwsw)

    # Create sw_reg with read and write registers inverted
    infile_part = infile + "_2"
    mkregs.infile=infile_part
    # invert registers type
    for i in range(len(defsfile)):
        if 'SWREG_W' in defsfile[i]:
            defsfile[i] = re.sub('SWREG_W','SWREG_R', defsfile[i])
        else:
            defsfile[i] = re.sub('SWREG_R','SWREG_W', defsfile[i])
    swreg_parse (defsfile, hwsw)
