# Check if the Tester is not the top system
if meta['build_dir'] != f"../{meta['name']+'_'+meta['version']}":
    # Append the Tester's embed_build.mk to the top system/core's embed_build.mk
    f1 = open(meta['setup_dir']+"/software/embedded/embed_build.mk", 'r')
    f2 = open(meta['build_dir']+"/software/embedded/embed_build.mk", 'a+')    

    f2.write(f1.read())

    f1.close()
    f2.close()
