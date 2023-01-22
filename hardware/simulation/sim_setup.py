import filecmp

src_file = meta['setup_dir']+"/hardware/simulation/sim_build.mk"
dst_file = meta['build_dir']+"/hardware/simulation/sim_build.mk"

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
    file.write(f"NAME:={meta['name']}\n")
