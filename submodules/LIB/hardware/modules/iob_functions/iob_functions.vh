`define IOB_MAX(a, b) (((a) > (b)) ? (a) : (b))
`define IOB_MIN(a, b) (((a) < (b)) ? (a) : (b))

`define IOB_CSHIFT_LEFT(DATA_W, DATA, SHIFT) ((DATA << SHIFT) | (DATA >> (DATA_W - SHIFT)))
`define IOB_CSHIFT_RIGHT(DATA_W, DATA, SHIFT) ((DATA >> SHIFT) | (DATA << (DATA_W - SHIFT)))
