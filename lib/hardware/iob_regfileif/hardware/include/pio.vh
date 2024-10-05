// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

   // REGFILEIF
   input                           /*<InstanceName>*/_valid,
   input [`iob_regfileif_csrs_ADDR_W-1:0]   /*<InstanceName>*/_address,
   input [`DATA_W-1:0]   /*<InstanceName>*/_wdata,
   input [`DATA_W/8-1:0] /*<InstanceName>*/_wstrb,
   output [`DATA_W-1:0]  /*<InstanceName>*/_rdata,
   output                          /*<InstanceName>*/_ready,
