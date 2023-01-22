# This file contains three important variables:
# - possible revisions of this board (i5)
# - special place&route arguments for each revision
# - pin constraints for each revision of this board (i5)

set POSSIBLE_REVISIONS { "7.0" }

set EXTRA_PNR_ARGUMENTS [dict create \
    7.0 "--ignore-loops --25k --package CABGA381 --speed 6"
]
# FIXME: does '--ignore-loops' break the system?

set PIN_MAP_DICT [dict create 7.0 {
    {LOCATE COMP "clk" SITE "P3"}
    {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
    {FREQUENCY PORT "clk" 25 MHZ}
    {LOCATE COMP "resetn" SITE "K18"}
    {IOBUF PORT "resetn" IO_TYPE=LVCMOS33}
    {IOBUF PORT "resetn" PULLMODE=UP}
    {LOCATE COMP "uart_rxd" SITE "H18"}
    {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
    {LOCATE COMP "uart_txd" SITE "J17"}
    {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
}
]