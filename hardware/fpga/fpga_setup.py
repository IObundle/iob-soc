# This script is called during setup.
# You can use 'setup_module' to access the contents of the iob_soc_setup.py python module
import os
import shutil

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


board_dirs = ['hardware/fpga/quartus/DE10-LITE/','hardware/fpga/quartus/CYCLONEV-GT-DK','hardware/fpga/vivado/AES-KU040-DB-G','hardware/fpga/vivado/BASYS3']
# Remove all test*.expected files from boards, copy only the correct one
for board_dir in board_dirs:
    # Delete all test*.expected files from build_dir
    dirpath=os.path.join(setup_module.build_dir, board_dir)
    for file in os.listdir(dirpath):
        if file.startswith("test") and file.endswith(".expected"):
            os.remove(os.path.join(dirpath,file))

    # Copy correct test.expected file to build dir
    src_file = os.path.join(setup_module.setup_dir, board_dir, test_file_name)
    if os.path.isfile(src_file):
        shutil.copyfile(src_file,os.path.join(dirpath,"test.expected"))

