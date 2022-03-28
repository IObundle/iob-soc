   // IOBNATIVEBRIDGEIF
   output                           /*<InstanceName>*/_valid,
   output [`iob_nativebridgeif_swreg_ADDR_W-1:0]   /*<InstanceName>*/_address,
   output [`DATA_W-1:0]   /*<InstanceName>*/_wdata,
   output [`DATA_W/8-1:0] /*<InstanceName>*/_wstrb,
   input [`DATA_W-1:0]  /*<InstanceName>*/_rdata,
   input                          /*<InstanceName>*/_ready,
