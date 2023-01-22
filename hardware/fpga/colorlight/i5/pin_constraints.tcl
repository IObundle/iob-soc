# This file contains:
# - pin constraints for of this board (Colorlight i5).

# not needed! i5 has no revisions like other color light obards
# set POSSIBLE_REVISIONS { ... }

# TODO: fix this for i5
set PIN_MAP {
    {LOCATE COMP "clk" SITE "P6"}
    {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
    {FREQUENCY PORT "clk" 25 MHZ}
    {LOCATE COMP "uart_rxd" SITE "R7"}
    {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
    {LOCATE COMP "uart_txd" SITE "T6"}
    {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
}