// START_TABLE sw_reg
`SWREG_R(GPIO_RD, DATA_W, 0)      // General purpose IO reads
`SWREG_W(GPIO_WR, DATA_W, 0)      // General purpose IO writes
`SWREG_W(GPIO_RD_MASK, DATA_W, 0) // Mask for enable/disable IO reads
`SWREG_W(GPIO_WR_MASK, DATA_W, 0) // Mask for enable/disable IO writes
