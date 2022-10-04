#!/usr/bin/env python3
#Script created by iobnativebridge.py
# Call this script with ROOT_DIR to create the iob_nativebridge_swreg.vh
import os
import sys
import re

fin = open (os.path.join(sys.argv[1], 'sut_swreg.vh'), 'r')
swreg_content=fin.readlines()
fin.close()
for i in range(len(swreg_content)):
    swreg_content[i] = re.sub('REGFILEIF','PCIE', swreg_content[i])
fout = open (os.path.join(os.path.dirname(__file__),"../../","mkregs.conf"), 'w')
fout.writelines(swreg_content)
fout.close()
    
