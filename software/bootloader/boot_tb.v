//receive program load start msg
cpu_getline();
      
//receive start addr msg 
cpu_getline();
     
`ifdef USE_DDR
      cpu_loadfirmware(2**(`RAM_ADDR_W-2));
`elsif USE_RAM
      cpu_loadfirmware(2**(`RAM_ADDR_W-2));
`endif
      
