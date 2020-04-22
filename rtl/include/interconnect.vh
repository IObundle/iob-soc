//
// INTERCONNECT MACROS
//

//uncomment to parse independently
//`define DATA_W 32
//`define ADDR_W 32

//CONCAT BUS WIDTHS
`define IBUS_REQ_W (1+`ADDR_W)
`define DBUS_REQ_W(N) (1+`ADDR_W-$clog2(N)+`DATA_W+`DATA_W/8)
`define BUS_RESP_W (1+`DATA_W)

`define PBUS_REQ_W(N) N*(`ADDR_W-$clog2(N)+`DATA_W+`DATA_W/8)
`define PBUS_RESP_W(N) N*(1+`DATA_W)

//UNCAT BUS SUFFIXES
//signals
`define valid _valid
`define addr _addr
`define wdata _wdata
`define wstrb _wstrb
`define rdata _rdata
`define ready _ready

//CAT BUS SUFFIXES
//instruction, data, peripheral
`define i _i
`define d _d
`define p _p
//request or response
`define req _req
`define resp _resp

//DECLARE BUS

// IBUS
`define ibusreq_cat(NAME) wire [IBUS_REQ_W-1:0] NAME`d`req;

`define ibusresp_cat(NAME) wire [BUS_RESP_W-1:0] NAME`d`resp;

`define ibusreq_uncat(NAME)\
wire  NAME`i`valid;\
wire [`ADDR_W-1:0] NAME`i`addr;\
wire [`DATA_W-1:0] NAME`i`wdata;\
wire [`DATA_W/8-1:0] NAME`i`wstrb;

`define ibusresp_uncat(NAME)\
wire [`DATA_W-1:0] NAME`i`rdata;\
wire NAME`i`ready;

// DBUS
`define dbusreq_cat(NAME,N) wire [DBUS_REQ_W(N)-1:0] NAME`d`req;

`define dbusresp_cat(NAME) wire [BUS_RESP_W-1:0] NAME`d`resp;

`define dbusreq_uncat(NAME,N)\
wire  NAME`d`valid;\
wire [`ADDR_W-$clog2(N)-1:0] NAME`d`addr;\
wire [`DATA_W-1:0] NAME`d`wdata;\
wire [`DATA_W/8-1:0] NAME`d`wstrb;

`define dbusresp_uncat(NAME)\
wire [`DATA_W-1:0] NAME`d`rdata;\
wire NAME`d`ready;

// PBUS
`define pbusreq_cat(NAME) wire [DBUS_REQ_W(N)-1:0] NAME`p`req;
`define pbusreq_cat(NAME,N) wire [PBUS_REQ_W(N)-1:0] NAME`p`req;

`define pbusresp_cat(NAME) wire [BUS_RESP_W-1:0] NAME`p`resp;
`define pbusresp_cat(NAME,N) wire [PBUS_RESP_W(N)-1:0] NAME`p`resp;


//PACK AND PACK

//FROM MASTER PERSPECTIVE
`define pack_ireqbus(NAME)\
assign NAME[`ADDR_W] = NAME`valid;\
assign NAME[`ADDR_W-1:0] = NAME`addr;

`define pack_dreqbus(NAME,N)\
assign NAME[DBUS_REQ_W(N)-1] = NAME`valid;\
assign NAME[DBUS_REQ_W(N)-1 -: `ADDR_W-$clog2(N)] = NAME`addr;\
assign NAME[DBUS_REQ_W(N)-1-`ADDR_W-$clog2(N) -: `DATA_W] = NAME`wdata;\
assign NAME[DBUS_REQ_W(N)-1-`ADDR_W-$clog2(N) -: `DATA_W/8] = NAME`wdata;

`define unpack_respbus(NAME)\
assign NAME`rdata = NAME[`DATA_W:1];\
assign NAME`ready = NAME[0];

//FROM SLAVE PERSPECTIVE
`define unpack_ireqbus(NAME)\
assign NAME`valid = NAME[`IBUS_REQ_W-1];\
assign NAME`addr = NAME[`IBUS_REQ_W(N)-1-1 -: `ADDR_W];

`define unpack_dreqbus(NAME,N)\
assign NAME`valid = NAME[`DBUS_REQ_W(N)-1];\
assign NAME`addr = NAME[`DBUS_REQ_W(N)-1-1 -: `ADDR_W-$clog2(N)];\
assign NAME`wdata = NAME[`DBUS_REQ_W(N)-1-1-`ADDR_W-$clog2(N) -: `DATA_W];\
assign NAME`wdata = NAME[`DBUS_REQ_W(N)-1-1-`ADDR_W-$clog2(N)-`DATA_W -: `DATA_W/8];

`define pack_respbus(NAME)\
assign NAME[`DATA_W:1] = NAME`rdata;\
assign NAME[0] = NAME`ready;

//PERIPHERAL BUS
`define pack_prespbus(PERIPH_NAME, N, BUS_NAME)\
`pack_respbus(PERIPH_NAME`p`resp)\
`mux_prespbus(PERIPH_NAME`p`resp, N, BUS_NAME)

`define mux_prespbus(PERIPH_NAME, N, BUS_NAME)\
assign BUS_NAME`resp[(N+1)*`DBUS_REQ_W(2*N)-1 -: `DBUS_REQ_W(2*N)] = PERIPH_NAME`p`resp;

`define demux_preqbus(BUS_NAME, N, PERIPH_NAME)\
assign PERIPH_NAME = BUS_NAME[(N+1)*`DBUS_REQ_W(2*N)-1 -: `DBUS_REQ_W(2*N)];

`define unpack_preqbus(BUS_NAME, N, PERIPH_NAME)\
`demux_preqbus(BUS_NAME`req, N, PERIPH_NAME`p`req)\
`unpack_dreqbus(PERIPH_NAME`p`req, 1)


