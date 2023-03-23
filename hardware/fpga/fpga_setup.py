# This script is called during setup.
# You can use 'setup_module' to access the contents of the iob_soc_tester_setup.py python module
import shutil

# Override premap.tcl from build dir, with Tester's premap.tcl 
shutil.copyfile(setup_module.setup_dir+"/hardware/fpga/vivado/premap.tcl", setup_module.build_dir+"/hardware/fpga/vivado/premap.tcl")

######### Append tester fpga_build.mk to UUT's fpga_build.mk #########
import filecmp

src_file = setup_module.setup_dir+"/hardware/fpga/fpga_build.mk"
dst_file = setup_module.build_dir+"/hardware/fpga/fpga_build.mk"

# Make sure files are not equal
# They may be equal if the python scripts already copied it
if not filecmp.cmp(src_file, dst_file):
    # Append the Tester's fpga_build.mk to the top system/core's fpga_build.mk
    f1 = open(src_file, 'r')
    f2 = open(dst_file, 'a+')    

    f2.write(f1.read())

    f1.close()
    f2.close()

#Override 'NAME' makefile variable with tester name
#This is useful when we are building the tester with another core that may have set NAME variable.
with open(dst_file, 'a+') as file:
    file.write("\n#Override 'NAME' variable with Tester's name\n")
    file.write(f"NAME:={setup_module.name}\n")
