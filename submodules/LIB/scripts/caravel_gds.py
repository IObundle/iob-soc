import os
import sys
import re


current_directory = os.getcwd() # get current directory
to_verilog_source = "hardware/caravel/src" #path to caravel verilog source
Full_Path_to_verilog_source = os.path.join(current_directory, to_verilog_source) #full caravel path