//receive program load start msg
cpu_getline();

//load firmware
cpu_loadfirmware(`PROG_SIZE/4);

//receive prog loaded msg 
cpu_getline();
