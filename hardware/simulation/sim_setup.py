# This script is called during setup.
# You can use 'setup_module' to access the contents of the iob_soc_tester_setup.py python module
import os
import shutil

# If we are using the tester by itself (no UUT), then copy the Tester's test.expected files
if setup_module.build_dir==f"../{setup_module.name}_{setup_module.version}":
    # Delete all test*.expected files from build_dir
    dirpath=os.path.join(setup_module.build_dir, "hardware/simulation/src")
    for file in os.listdir(dirpath):
        if file.startswith("test") and file.endswith(".expected"):
            os.remove(os.path.join(dirpath,file))

    # Find out correct test.expected filename
    test_file_name='test'
    #Check if setup with INIT_MEM (check if macro exists)
    macro = next((i for i in setup_module.confs if i['name']=='INIT_MEM'), False)
    if macro and macro['val'] != 'NA':
        test_file_name+='_initmem'
    #Check if setup with USE_EXTMEM (check if macro exists)
    macro = next((i for i in setup_module.confs if i['name']=='USE_EXTMEM'), False)
    if macro and macro['val'] != 'NA':
        test_file_name+='_extmem'
    test_file_name+='.expected'

    # Copy correct test.expected file to build dir
    shutil.copyfile(os.path.join(setup_module.setup_dir, "hardware/simulation/src", test_file_name),os.path.join(dirpath,"test.expected"))

######### Append tester sim_build.mk to UUT's sim_build.mk #########
import filecmp

src_file = setup_module.setup_dir+"/hardware/simulation/sim_build.mk"
dst_file = setup_module.build_dir+"/hardware/simulation/sim_build.mk"

# Make sure files are not equal
# They may be equal if the python scripts already copied it
if not filecmp.cmp(src_file, dst_file):
    # Append the Tester's sim_build.mk to the top system/core's sim_build.mk
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
