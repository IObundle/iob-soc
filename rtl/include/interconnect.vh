//
// INTERCONNECT MACROS
//

//uncomment to parse independently


//`define DATA_W 32

//BUS TYPES
`define I 0
`define D 1

//TODO: insert type argument in macros after name 

//CONCAT BUS WIDTHS

`define BUS_REQ_W(TYPE, ADDR_W) 1+ADDR_W+TYPE*(`DATA_W+`DATA_W/8)

`define BUS_RESP_W              `DATA_W+1

`define BUS_W(TYPE, ADDR_W)     `BUS_REQ_W(TYPE, ADDR_W)+`BUS_RESP_W

//UNCAT BUS SUFFIXES
//signals
`define valid _valid
`define addr  _addr
`define wdata _wdata
`define wstrb _wstrb
`define rdata _rdata
`define ready _ready
//type instruction, data or resized
`define i     _i
`define d     _d
`define r     _r



///////////////////////////////////////////////////////////////////
//DECLARE
//

//IBUS
`define bus_cat(TYPE, NAME, ADDR_W, N) wire [N*`BUS_W(TYPE, ADDR_W)-1:0] NAME;

`define ibus_uncat(NAME, ADDR_W)\
wire  NAME`valid;\
wire [ADDR_W-1:0] NAME`addr;\
wire [`DATA_W-1:0] NAME`rdata;\
wire NAME`ready;

`define dbus_uncat(NAME, ADDR_W)\
wire  NAME`valid;\
wire [ADDR_W-1:0] NAME`addr;\
wire [`DATA_W-1:0] NAME`wdata;\
wire [`DATA_W/8-1:0] NAME`wstrb;\
wire [`DATA_W-1:0] NAME`rdata;\
wire NAME`ready;


////////////////////////////////////////////////////////////////
// CONNECT
//

`define connect_m(TYPE, UNCAT, CAT, ADDR_W, N, I)\
assign CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-1]                    = UNCAT`valid;\
assign CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-1 -: ADDR_W]          = UNCAT`addr;\
assign CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-1-ADDR_W -: `DATA_W]  = UNCAT`wdata;\
assign CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDRW)-1-ADDR_W -: `DATA_W/8] = UNCAT`wstrb;\
assign UNCAT`rdata                                                            = CAT[I*`BUS_RESP_W+`DATA_W -: `DATA_W];\
assign UNCAT`ready                                                            = CAT[I*`BUS_RESP_W];

`define connect_s(TYPE, UNCAT, CAT, ADDR_W, N, I)\
assign UNCAT`valid                           = CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-1];\
assign UNCAT`addr                            = CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-2 -: ADDR_W];\
assign UNCAT`wdata                           = CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-2-ADDR_W -: `DATA_W];\
assign UNCAT`wstrb                           = CAT[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-2-ADDR_W-`DATA_W -: `DATA_W/8];\
assign CAT[I*`BUS_RESP_W+`DATA_W -: `DATA_W] = UNCAT`rdata;\ 
assign CAT[I*`BUS_RESP_W]                    = UNCAT`ready;

///////////////////////////////////////////////////////////////////////////////////
//GET REQ AND RESP SLICES

`define get_req (TYPE, NAME, ADDR_W, N, I)\
NAME[N*`BUS_RESP_W+(I+1)*`BUS_REQ_W(TYPE, ADDR_W)-1 -: `BUS_REQ_W(TYPE, ADDR_W)] 

`define get_resp(NAME, I) NAME[(I+1)*`BUS_RESP_W-1 -: `BUS_RESP_W]


///////////////////////////////////////////////////////////////////////////////////
//RESIZE
`define resize (SRC, SRC_ADDR_W, DEST, DEST_ADDR_W);\
wire [SRC_ADDR_W-1:0] SRC`addr = SRC[`BUS_W(`D, SRC_ADDR_W)-2 -: SRC_ADDR_W];\
wire [DEST_ADDR_W-1:0] DEST`addr = {{DEST_ADDR_W-SRC_ADDR_W{1'b0}}, SRC`addr};\
wire [`BUS_W(`D, DEST_ADDR_W)-1 : 0] DEST`r = {SRC[1+`DATA/8+2*`DATA_W+SRC_ADDR_W], DEST`addr, SRC[`DATA/8+2*`DATA_W : 0]};

`define i2d (NAME, ADDR_W) wire [BUS_W(`D, ADDR_W)-1:0] NAME`d;


                                                                           
