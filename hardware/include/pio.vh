   // REGFILEIF
   input                           /*<InstanceName>*/_valid,
   input [`REGFILEIF_ADDR_W-1:0]   /*<InstanceName>*/_address,
   input [`REGFILEIF_DATA_W-1:0]   /*<InstanceName>*/_wdata,
   input [`REGFILEIF_DATA_W/8-1:0] /*<InstanceName>*/_wstrb,
   output [`REGFILEIF_DATA_W-1:0]  /*<InstanceName>*/_rdata,
   output                          /*<InstanceName>*/_ready,
