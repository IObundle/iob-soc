//receive program load start msg
do begin 
   cpu_getchar(cpu_char);
   $write("%c", cpu_char);
end while (cpu_char != "\n");
      
//receive start addr msg 
do begin 
   cpu_getchar(cpu_char);
   $write("%c", cpu_char);
end while (cpu_char != "\n");
     
`ifdef USE_DDR
      cpu_loadfirmware(2**(`RAM_ADDR_W-2));
`elsif USE_RAM
      cpu_loadfirmware(2**(`RAM_ADDR_W-2));
`endif
      
