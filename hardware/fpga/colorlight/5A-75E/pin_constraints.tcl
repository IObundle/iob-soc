# This script contains two important variables:
# - possible revisions of this board (5A-75E).
# - pin constraints for each revision of this board (5A-75E).

set POSSIBLE_REVISIONS { "6.0" "7.1" "8.0" }

set PIN_MAP_DICT [dict create 6.0 {
        {LOCATE COMP "clk" SITE "P6"}
        {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
        {FREQUENCY PORT "clk" 25 MHZ}
        {LOCATE COMP "uart_rxd" SITE "R7"}
        {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
        {LOCATE COMP "uart_txd" SITE "T6"}
        {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
    } 7.1 {
    } 8.0 {
        {LOCATE COMP "clk" SITE "P6"}
        {IOBUF PORT "clk" IO_TYPE=LVCMOS33}
        {FREQUENCY PORT "clk" 25 MHZ}
        {LOCATE COMP "uart_rxd" SITE "R7"}
        {IOBUF PORT "uart_rxd" IO_TYPE=LVCMOS33}
        {LOCATE COMP "uart_txd" SITE "T6"}
        {IOBUF PORT "uart_txd" IO_TYPE=LVCMOS33}
    }]