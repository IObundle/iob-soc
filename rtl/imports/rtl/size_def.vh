   // 4096 32bit words = 16kB memory - ProgRom
   // 8 bits for mem
   //parameter MEM_ADDR_W = 12; 
   
   
   // Main Memory address width (uses AXI interfac) = width (depth) + 2 (dos dois bits retirados referentes dos 4 bytes = 32 bits)
   parameter MAIN_MEM_ADDR_W = 14; // 14 = 32 bits (4) * 2**12 (4096) depth


   parameter DDR_ADDR_W = 14;
