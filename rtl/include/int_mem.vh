//internal memory address space (log2 of byte size)
`ifdef USE_DDR
 `define BOOTRAM_ADDR_W (`BOOTROM_ADDR_W+1)
`else
 `define BOOTRAM_ADDR_W `MAINRAM_ADDR_W
`endif
