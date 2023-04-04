import filecmp

src_file = setup_module.setup_dir+"/software/sw_build.mk"
dst_file = setup_module.build_dir+"/software/sw_build.mk"

# Make sure files are not equal
# They may be equal if the python scripts already copied it
if not filecmp.cmp(src_file, dst_file):
    # Append the Tester's sw_build.mk to the top system/core's sw_build.mk
    f1 = open(src_file, 'r')
    f2 = open(dst_file, 'a+')    

    f2.write(f1.read())

    f1.close()
    f2.close()
