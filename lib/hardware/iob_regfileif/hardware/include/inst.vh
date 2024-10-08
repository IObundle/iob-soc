// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

   //
   // /*<InstanceName>*/
   //

   iob_regfileif /*<InstanceName>*/
     (
      .clk     (clk),
      .rst     (reset),

      // Register file interface
      .valid_ext   (/*<InstanceName>*/_valid),
      .address_ext (/*<InstanceName>*/_address),
      .wdata_ext   (/*<InstanceName>*/_wdata),
      .wstrb_ext   (/*<InstanceName>*/_wstrb),
      .rdata_ext   (/*<InstanceName>*/_rdata),
      .ready_ext   (/*<InstanceName>*/_ready),

      // CPU interface
      .valid       (slaves_req[`valid(`/*<InstanceName>*/)]),
      .address     (slaves_req[`address(`/*<InstanceName>*/,`iob_regfileif_csrs_ADDR_W+2)-2]),
      .wdata       (slaves_req[`wdata(`/*<InstanceName>*/)]),
      .wstrb       (slaves_req[`wstrb(`/*<InstanceName>*/)]),
      .rdata       (slaves_resp[`rdata(`/*<InstanceName>*/)]),
      .ready       (slaves_resp[`ready(`/*<InstanceName>*/)])
      );
