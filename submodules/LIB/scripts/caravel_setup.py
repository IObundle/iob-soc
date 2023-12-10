import os
import sys
import re


to_caravel_make = "submodules/caravel_user_project/Makefile" #path to caravel MAKEFILE
to_caravel= "submodules/caravel_user_project" #path to caravel
current_directory = os.getcwd() # get current directory

Full_Path_to_caravel = os.path.join(current_directory, to_caravel) #full caravel path
Full_path_to_caravel_Make = os.path.join(current_directory, to_caravel_make) #full makefile caravel path


line_to_add = "export PWD := " + Full_Path_to_caravel + "\n" #For some reason the PWD is not exported in my makefile


#part that exports the PWD in the make file
with open(Full_path_to_caravel_Make, 'r') as file:
    content = file.read()
pattern = r'(?m)^SIM\?\=RTL\n(.*)$'
updated_content = re.sub(pattern, r'SIM?=RTL\n' + line_to_add, content)
with open(Full_path_to_caravel_Make, 'w') as file:
    file.write(updated_content)



with open(Full_path_to_caravel_Make, 'r') as file:
    content = file.read()
# Replace CARAVEL_LITE?=1 with CARAVEL_LITE?=0
content = re.sub(r'CARAVEL_LITE\?=1', r'CARAVEL_LITE=0', content)
with open(Full_path_to_caravel_Make, 'w') as file:
    file.write(content)