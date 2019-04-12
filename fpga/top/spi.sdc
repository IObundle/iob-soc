####################################################################
#
#
#   Description: SPI Constraints File
#
#   Copyright (C) 2018 IObundle, Lda  All rights reserved
#
#####################################################################


create_clock -name "clk" -add -period 10.0 [get_ports clk]
create_clock -name "sclk" -add -period 25.0 [get_ports sclk]
