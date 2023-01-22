# This file contains three important variables:
# - possible revisions of this board (5A-75E)
# - special place&route arguments for each revision
# - pin constraints for each revision of this board (5A-75E)

set POSSIBLE_REVISIONS { "6.0" "7.1" "8.0" }

set EXTRA_PNR_ARGUMENTS [dict create \
    6.0 "--ignore-loops --25k --package CABGA256 --speed 6" \
    7.1 "--ignore-loops --25k --package CABGA256 --speed 6" \
    8.0 "--ignore-loops --25k --package CABGA256 --speed 6" \
]
# FIXME: does '--ignore-loops' break the system?

set PIN_MAP_DICT [dict create 6.0 {
    {LOCATE COMP "clk" SITE "P6"}
    {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
    {FREQUENCY PORT "clk" 25 MHZ}
    {LOCATE COMP "uart_rxd" SITE "R7"}
    {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
    {LOCATE COMP "uart_txd" SITE "T6"}
    {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
} 7.1 {
    {LOCATE COMP "clk" SITE "P6"}
    {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
    {FREQUENCY PORT "clk" 25 MHZ}
    {LOCATE COMP "uart_rxd" SITE "R13"}
    {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
    {LOCATE COMP "uart_txd" SITE "P11"}
    {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
} 8.0 {
    {LOCATE COMP "clk" SITE "P6"}
    {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
    {FREQUENCY PORT "clk" 25 MHZ}
    {LOCATE COMP "uart_rxd" SITE "R7"}
    {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
    {LOCATE COMP "uart_txd" SITE "T6"}
    {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
}
]