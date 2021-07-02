// START_TABLE sw_reg
`SWREG_W(GPIO_R0, DATA_W, 0)   //Bit duration in system clock cycles.
`SWREG_W(GPIO_R1, DATA_W/2, 0) //Bit duration in system clock cycles.
`SWREG_W(GPIO_R2, DATA_W/4, 0) //TX data
`SWREG_W(GPIO_R4, 1, 0)        //TX enable.
