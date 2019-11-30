//receive program load start msg
cpu_getline();

//receive start addr msg 
cpu_getline();

//load firmware     
cpu_loadfirmware(2**(`RAM_ADDR_W-2));

