//
// INTERCONNECT MACROS
//

//uncomment to parse independently


//`define DATA_W 32

//CONCAT BUS WIDTHS
`define IBUS_W(ADDR_W)   1+ADDR_W+`DATA_W+1
`define DBUS_W(ADDR_W)   1+ADDR_W+2*`DATA_W+`DATA_W/8+1

`define IBUS_REQ_W(ADDR_W)   1+ADDR_W
`define DBUS_REQ_W(ADDR_W)   1+ADDR_W+`DATA_W+`DATA_W/8

`define BUS_RESP_W           `DATA_W+1


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
`define ibus_cat(NAME, ADDR_W, N) wire [N*`IBUS_W(N)-1:0] NAME`i;

`define ibus_uncat(NAME, ADDR_W)\
wire  NAME`valid;\
wire [ADDR_W-1:0] NAME`addr;\
wire [`DATA_W-1:0] NAME`rdata;\
wire NAME`ready;

//DBUS
`define dbus_cat(NAME, ADDR_W, N) wire [N*`DBUS_W(N)-1:0] NAME`d;

`define dbus_uncat(NAME, ADDR_W)\
wire  NAMEvalid;\
wire [ADDR_W-1:0] NAME`addr;\
wire [`DATA_W-1:0] NAME`wdata;\
wire [`DATA_W/8-1:0] NAME`wstrb;\
wire [`DATA_W-1:0] NAME`rdata;\
wire NAME`ready;


////////////////////////////////////////////////////////////////
// CONNECT
//

`define connect_m2s_i(UNCAT, CAT, ADDR_W, N, I)\
assign CAT`i[N*`BUS_RESP_W+(I+1)*`IBUS_REQ_W(ADDR_W)-1]           = UNCAT`valid;\
assign CAT`i[N*`BUS_RESP_W+(I+1)*`IBUS_REQ_W(ADDR_W)-1 -: ADDR_W] = UNCAT`addr;\
assign UNCAT`rdata                                                = CAT`i[I*`BUS_RESP_W+`DATA_W -: `DATA_W];\
assign UNCAT`ready                                                = CAT`i[I*`BUS_RESP_W];

`define connect_s2m_i(UNCAT, CAT, ADDR_W, N, I)\
assign UNCAT`valid                                                = CAT`i[N*`BUS_RESP_W+(I+1)*`IBUS_REQ_W(ADDR_W)-1];\
assign UNCAT`addr                                                 = CAT`i[N*`BUS_RESP_W+(I+1)*`IBUS_REQ_W(ADDR_W)-2 -: ADDR_W];\
assign CAT`i[I*`BUS_RESP_W+`DATA_W -: `DATA_W]                    = UNCAT`rdata;\ 
assign CAT`i[I*`BUS_RESP_W]                                       = UNCAT`ready;


`define connect_m2s_d(UNCAT, CAT, ADDR_W, N, I)\
assign CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_W)-1]                    = UNCAT`valid;\
assign CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_W)-1 -: ADDR_W]          = UNCAT`addr;\
assign CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_W)-1-ADDR_W -: `DATA_W]  = UNCAT`wdata;\
assign CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDRW)-1-ADDR_W -: `DATA_W/8] = UNCAT`wstrb;\
assign UNCAT`rdata                                                         = CAT`d[I*`BUS_RESP_W+`DATA_W -: `DATA_W];\
assign UNCAT`ready                                                         = CAT`d[I*`BUS_RESP_W];

`define connect_s2m_d(UNCAT, CAT, ADDR_W, N, I)\
assign UNCAT`valid                              = CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_W)-1];\
assign UNCAT`addr                               = CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_w)-2 -: ADDR_W];\
assign UNCAT`wdata                              = CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_w)-2-ADDR_W -: `DATA_W];\
assign UNCAT`wstrb                              = CAT`d[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_w)-2-ADDR_W-`DATA_W -: `DATA_W/8];\
assign CAT`d[I*`BUS_RESP_W+`DATA_W -: `DATA_W] = UNCAT`rdata;\ 
assign CAT`d[I*`BUS_RESP_W]                    = UNCAT`ready;

///////////////////////////////////////////////////////////////////////////////////
//GET REQ AND RESP SLICES
                                                        
`define get_req_i (NAME, ADDR_W, N, I)\
NAME[N*`BUS_RESP_W+(I+1)* `IBUS_REQ_W(ADDR_W)-1 -: `IBUS_REQ_W(ADDR_W)]\

`define get_req_d (NAME, ADDR_W, N, I)\
NAME[N*`BUS_RESP_W+(I+1)*`DBUS_REQ_W(ADDR_W)-1 -: `DBUS_REQ_W(ADDR_W)] 

//`define get_resp(NAME, I) NAME[(I+1)*`IBUS_RESP_W-1 -: `IBUS_RESP_W]


///////////////////////////////////////////////////////////////////////////////////
//RESIZE
`define resize (SRC, SRC_ADDR_W, DEST, DEST_ADDR_W);\
wire [SRC_ADDR_W-1:0] SRC`addr = SRC[`DBUS_W(SRC_ADDR_W)-2 -: SRC_ADDR_W];\
wire [DEST_ADDR_W-1:0] DEST`addr = {{DEST_ADDR_W-SRC_ADDR_W{1'b0}}, SRC`addr};\
wire [`DBUS_W(DEST_ADDR_W)-1 : 0] DEST`r = {SRC[1+`DATA/8+2*`DATA_W+SRC_ADDR_W], DEST`addr, SRC[`DATA/8+2*`DATA_W : 0]};

                                                                           
