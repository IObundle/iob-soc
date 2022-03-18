   // NATIVEBRIDGEIF
   output                           /*<InstanceName>*/_valid,
   output [`NATIVEBRIDGEIF_ADDR_W-1:0]   /*<InstanceName>*/_address,
   output [`NATIVEBRIDGEIF_DATA_W-1:0]   /*<InstanceName>*/_wdata,
   output [`NATIVEBRIDGEIF_DATA_W/8-1:0] /*<InstanceName>*/_wstrb,
   input [`NATIVEBRIDGEIF_DATA_W-1:0]  /*<InstanceName>*/_rdata,
   input                          /*<InstanceName>*/_ready,
