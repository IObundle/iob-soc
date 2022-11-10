`timescale 1ns / 1ps
`include "system.vh"
`include "functions.vh"
`include "riffa.vh"
`include "altera.vh"

module top_system   
  #(// Number of RIFFA Channels
    parameter C_NUM_CHNL = 1,
    // Number of PCIe Lanes
    parameter C_NUM_LANES =  8,
    // Settings from Quartus IP Library
    parameter C_PCI_DATA_WIDTH = 64,
    parameter C_MAX_PAYLOAD_BYTES = 256,
    parameter C_LOG_NUM_TAGS = 5
    )
   (
   input 		    clk,
   input 		    resetn,
   input 		    uart_rxd,
   output 		    uart_txd,
   output reg 		    rs422_re_n,
   output reg 		    rs422_de,
   output reg 		    rs422_te,
		  
   //output [0:0] led_bracket
   //output [0:0] led_board
   output [7:0] 	    LED,
   
   // ----------PCIE----------
   input 		    PCIE_RESET_N,
   input 		    PCIE_REFCLK,
   
   // ----------PCIE Serial RX----------
   input [C_NUM_LANES-1:0]  PCIE_RX_IN,
   
   // ----------PCIE Serial TX----------
   output [C_NUM_LANES-1:0] PCIE_TX_OUT
   
   
  );

   
    wire                     npor;
    wire                     pin_perst;

    // ----------TL Config interface----------
    wire [3:0]               tl_cfg_add;
    wire [31:0]              tl_cfg_ctl;
    wire [52:0]              tl_cfg_sts;

    // ----------Rx/TX Interfaces----------
    wire [0:0]               rx_st_sop;
    wire [0:0]               rx_st_eop;
    wire [0:0]               rx_st_err;
    wire [0:0]               rx_st_valid;
    wire                     rx_st_ready;
    wire [C_PCI_DATA_WIDTH-1:0] rx_st_data;
    wire [0:0]                  rx_st_empty;
    
    wire [0:0]                  tx_st_sop;
    wire [0:0]                  tx_st_eop;
    wire [0:0]                  tx_st_err;
    wire [0:0]                  tx_st_valid;
    wire                        tx_st_ready;
    wire [C_PCI_DATA_WIDTH-1:0] tx_st_data;
    wire [0:0]                  tx_st_empty;
    
    // ----------Clocks & Locks----------
    wire                        pld_clk;
    wire                        coreclkout_hip;
    wire                        refclk;
    wire                        pld_core_ready;
    wire                        reset_status;
    wire                        serdes_pll_locked;

    // ----------Interrupt Interfaces----------
    wire                        app_msi_req;
    wire                        app_msi_ack;
    
    // ----------Reconfiguration Controller signals----------
    wire                        mgmt_clk_clk;
    wire                        mgmt_rst_reset;

    // ----------Reconfiguration Driver Signals----------
    wire                        reconfig_xcvr_clk;
    wire                        reconfig_xcvr_rst;

    wire [7:0]                  rx_in;
    wire [7:0]                  tx_out;
    
    // ------------Status Interface------------
    wire                        derr_cor_ext_rcv;
    wire                        derr_cor_ext_rpl;
    wire                        derr_rpl;
    wire                        dlup;
    wire                        dlup_exit;
    wire                        ev128ns;
    wire                        ev1us;
    wire                        hotrst_exit;
    wire [3:0]                  int_status;
    wire                        l2_exit;
    wire [3:0]                  lane_act;
    wire [4:0]                  ltssmstate;
    wire                        rx_par_err;
    wire [1:0]                  tx_par_err;
    wire                        cfg_par_err;
    wire [7:0]                  ko_cpl_spc_header;
    wire [11:0]                 ko_cpl_spc_data;

    // ----------Clocks----------
   assign pld_clk = coreclkout_hip;
   assign mgmt_clk_clk = PCIE_REFCLK;
   assign reconfig_xcvr_clk = PCIE_REFCLK;
   assign refclk = PCIE_REFCLK;
   assign pld_core_ready = serdes_pll_locked;

   
    // ----------Resets----------
    assign reconfig_xcvr_rst = 1'b0;
    assign mgmt_rst_reset = 1'b0;
    assign pin_perst = PCIE_RESET_N;
    assign npor = PCIE_RESET_N;

    // ----------LED's----------
    assign LED[7:0] = 8'hff;
    QSysDE5QGen1x8If64
        pcie_system_inst
            (
             // Outputs
             .rx_st_startofpacket              (rx_st_sop[0:0]),
             .rx_st_endofpacket                (rx_st_eop[0:0]),
             .rx_st_valid                      (rx_st_valid[0:0]),
             .rx_st_data                       (rx_st_data[63:0]),
             .tx_st_ready                      (tx_st_ready),
             .pciehip_reset_status             (reset_status),
             .pciehip_serdes_pll_locked        (serdes_pll_locked),
             .pciecfg_tl_cfg_add               (tl_cfg_add[3:0]),
             .pciecfg_tl_cfg_ctl               (tl_cfg_ctl[31:0]),
             .pciecfg_tl_cfg_sts               (tl_cfg_sts[52:0]),
             .pciecoreclk_clk                  (coreclkout_hip),
             .pcieserial_tx_out0               (PCIE_TX_OUT[0]),
             .pcieserial_tx_out1               (PCIE_TX_OUT[1]),
             .pcieserial_tx_out2               (PCIE_TX_OUT[2]),
             .pcieserial_tx_out3               (PCIE_TX_OUT[3]),
             .pcieserial_tx_out4               (PCIE_TX_OUT[4]),
             .pcieserial_tx_out5               (PCIE_TX_OUT[5]),
             .pcieserial_tx_out6               (PCIE_TX_OUT[6]),
             .pcieserial_tx_out7               (PCIE_TX_OUT[7]),
             .pciemsi_app_int_ack              (app_int_ack),
             .pciemsi_app_msi_ack              (app_msi_ack),
             .pciestat_derr_cor_ext_rcv        (derr_cor_ext_rcv),
             .pciestat_derr_cor_ext_rpl        (derr_cor_ext_rpl),
             .pciestat_derr_rpl                (derr_rpl),
             .pciestat_dlup                    (dlup),
             .pciestat_dlup_exit               (dlup_exit),
             .pciestat_ev128ns                 (ev128ns),
             .pciestat_ev1us                   (ev1us),
             .pciestat_hotrst_exit             (hotrst_exit),
             .pciestat_int_status              (int_status),
             .pciestat_l2_exit                 (l2_exit),
             .pciestat_lane_act                (lane_act),
             .pciestat_ltssmstate              (ltssmstate),
             .pciestat_rx_par_err              (rx_par_err),
             .pciestat_tx_par_err              (tx_par_err),
             .pciestat_cfg_par_err             (cfg_par_err),
             .pciestat_ko_cpl_spc_header       (ko_cpl_spc_header),
             .pciestat_ko_cpl_spc_data         (ko_cpl_spc_data),
             // Inputs
             .rx_st_ready                      (rx_st_ready),
             .tx_st_startofpacket              (tx_st_sop[0:0]),
             .tx_st_endofpacket                (tx_st_eop[0:0]),
             .tx_st_valid                      (tx_st_valid[0:0]),
             .tx_st_data                       (tx_st_data[63:0]),
             .pciehip_pld_core_ready           (pld_core_ready),
             .pcienpor_npor                    (npor),
             .pcienpor_pin_perst               (pin_perst),
             .pcierefclk_clk                   (refclk),
             .reconfigrefclk_clk               (reconfig_xcvr_clk),
             .pciepld_clk                      (pld_clk),
             .reconfigrst_reset                (reconfig_xcvr_rst),
             .mgmtrst_reset                    (mgmt_rst_reset),
             .mgmtclk_clk                      (mgmt_clk_clk),
             .reconfigpldclk_clk               (pld_clk),
             .pcieserial_rx_in0                (PCIE_RX_IN[0]),
             .pcieserial_rx_in1                (PCIE_RX_IN[1]),
             .pcieserial_rx_in2                (PCIE_RX_IN[2]),
             .pcieserial_rx_in3                (PCIE_RX_IN[3]),
             .pcieserial_rx_in4                (PCIE_RX_IN[4]),
             .pcieserial_rx_in5                (PCIE_RX_IN[5]),
             .pcieserial_rx_in6                (PCIE_RX_IN[6]),
             .pcieserial_rx_in7                (PCIE_RX_IN[7]),
             .pciemsi_app_msi_req              (app_msi_req),
             .drvstat_derr_cor_ext_rcv         (derr_cor_ext_rcv),
             .drvstat_derr_cor_ext_rpl         (derr_cor_ext_rpl),
             .drvstat_derr_rpl                 (derr_rpl),
             .drvstat_dlup                     (dlup),
             .drvstat_dlup_exit                (dlup_exit),
             .drvstat_ev128ns                  (ev128ns),
             .drvstat_ev1us                    (ev1us),
             .drvstat_hotrst_exit              (hotrst_exit),
             .drvstat_int_status               (int_status),
             .drvstat_l2_exit                  (l2_exit),
             .drvstat_lane_act                 (lane_act),
             .drvstat_ltssmstate               (ltssmstate),
             .drvstat_rx_par_err               (rx_par_err),
             .drvstat_tx_par_err               (tx_par_err),
             .drvstat_cfg_par_err              (cfg_par_err),
             .drvstat_ko_cpl_spc_header        (ko_cpl_spc_header),
             .drvstat_ko_cpl_spc_data          (ko_cpl_spc_data));

   
    // RIFFA channel interface
    wire                        rst_out;
    wire [C_NUM_CHNL-1:0]       chnl_rx_clk;
    wire [C_NUM_CHNL-1:0]       chnl_rx;
    wire [C_NUM_CHNL-1:0]       chnl_rx_ack;
    wire [C_NUM_CHNL-1:0]       chnl_rx_last;
    wire [(C_NUM_CHNL*32)-1:0]  chnl_rx_len;
    wire [(C_NUM_CHNL*31)-1:0]  chnl_rx_off;
    wire [(C_NUM_CHNL*C_PCI_DATA_WIDTH)-1:0] chnl_rx_data;
    wire [C_NUM_CHNL-1:0]                    chnl_rx_data_valid;
    wire [C_NUM_CHNL-1:0]                    chnl_rx_data_ren;
    
    wire [C_NUM_CHNL-1:0]                    chnl_tx_clk;
    wire [C_NUM_CHNL-1:0]                    chnl_tx;
    wire [C_NUM_CHNL-1:0]                    chnl_tx_ack;
    wire [C_NUM_CHNL-1:0]                    chnl_tx_last;
    wire [(C_NUM_CHNL*32)-1:0]               chnl_tx_len;
    wire [(C_NUM_CHNL*31)-1:0]               chnl_tx_off;
    wire [(C_NUM_CHNL*C_PCI_DATA_WIDTH)-1:0] chnl_tx_data;
    wire [C_NUM_CHNL-1:0]                    chnl_tx_data_valid;
    wire [C_NUM_CHNL-1:0]                    chnl_tx_data_ren;

    wire                                     chnl_reset;
    wire                                     chnl_clk;
    wire                                     riffa_reset;
    wire                                     riffa_clk;
    assign riffa_reset = reset_status;
    assign riffa_clk = pld_clk;
    assign chnl_clk = pld_clk;
    assign chnl_reset = rst_out;

       riffa_wrapper_de5
        #(/*AUTOINSTPARAM*/
          // Parameters
          .C_LOG_NUM_TAGS               (C_LOG_NUM_TAGS),
          .C_NUM_CHNL                   (C_NUM_CHNL),
          .C_PCI_DATA_WIDTH             (C_PCI_DATA_WIDTH),
          .C_MAX_PAYLOAD_BYTES          (C_MAX_PAYLOAD_BYTES))
    riffa
        (
         // Outputs
         .RX_ST_READY                   (rx_st_ready),
         .TX_ST_DATA                    (tx_st_data[C_PCI_DATA_WIDTH-1:0]),
         .TX_ST_VALID                   (tx_st_valid[0:0]),
         .TX_ST_EOP                     (tx_st_eop[0:0]),
         .TX_ST_SOP                     (tx_st_sop[0:0]),
         .TX_ST_EMPTY                   (tx_st_empty[0:0]),
         .APP_MSI_REQ                   (app_msi_req),
         .RST_OUT                       (rst_out),
         .CHNL_RX                       (chnl_rx[C_NUM_CHNL-1:0]),
         .CHNL_RX_LAST                  (chnl_rx_last[C_NUM_CHNL-1:0]),
         .CHNL_RX_LEN                   (chnl_rx_len[(C_NUM_CHNL*`SIG_CHNL_LENGTH_W)-1:0]),
         .CHNL_RX_OFF                   (chnl_rx_off[(C_NUM_CHNL*`SIG_CHNL_OFFSET_W)-1:0]),
         .CHNL_RX_DATA                  (chnl_rx_data[(C_NUM_CHNL*C_PCI_DATA_WIDTH)-1:0]),
         .CHNL_RX_DATA_VALID            (chnl_rx_data_valid[C_NUM_CHNL-1:0]),
         .CHNL_TX_ACK                   (chnl_tx_ack[C_NUM_CHNL-1:0]),
         .CHNL_TX_DATA_REN              (chnl_tx_data_ren[C_NUM_CHNL-1:0]),
         // Inputs
         .RX_ST_DATA                    (rx_st_data[C_PCI_DATA_WIDTH-1:0]),
         .RX_ST_EOP                     (rx_st_eop[0:0]),
         .RX_ST_SOP                     (rx_st_sop[0:0]),
         .RX_ST_VALID                   (rx_st_valid[0:0]),
         .RX_ST_EMPTY                   (rx_st_empty[0:0]),
         .TX_ST_READY                   (tx_st_ready),
         .TL_CFG_CTL                    (tl_cfg_ctl[`SIG_CFG_CTL_W-1:0]),
         .TL_CFG_ADD                    (tl_cfg_add[`SIG_CFG_ADD_W-1:0]),
         .TL_CFG_STS                    (tl_cfg_sts[`SIG_CFG_STS_W-1:0]),
         .KO_CPL_SPC_HEADER             (ko_cpl_spc_header[`SIG_KO_CPLH_W-1:0]),
         .KO_CPL_SPC_DATA               (ko_cpl_spc_data[`SIG_KO_CPLD_W-1:0]),
         .APP_MSI_ACK                   (app_msi_ack),
         .PLD_CLK                       (pld_clk),
         .RESET_STATUS                  (reset_status),
         .CHNL_RX_CLK                   (chnl_rx_clk[C_NUM_CHNL-1:0]),
         .CHNL_RX_ACK                   (chnl_rx_ack[C_NUM_CHNL-1:0]),
         .CHNL_RX_DATA_REN              (chnl_rx_data_ren[C_NUM_CHNL-1:0]),
         .CHNL_TX_CLK                   (chnl_tx_clk[C_NUM_CHNL-1:0]),
         .CHNL_TX                       (chnl_tx[C_NUM_CHNL-1:0]),
         .CHNL_TX_LAST                  (chnl_tx_last[C_NUM_CHNL-1:0]),
         .CHNL_TX_LEN                   (chnl_tx_len[(C_NUM_CHNL*`SIG_CHNL_LENGTH_W)-1:0]),
         .CHNL_TX_OFF                   (chnl_tx_off[(C_NUM_CHNL*`SIG_CHNL_OFFSET_W)-1:0]),
         .CHNL_TX_DATA                  (chnl_tx_data[(C_NUM_CHNL*C_PCI_DATA_WIDTH)-1:0]),
         .CHNL_TX_DATA_VALID            (chnl_tx_data_valid[C_NUM_CHNL-1:0])
	 );


   wire 				     uart_rts;
   
   
   always @* begin
      rs422_te = 0;
      rs422_de = 1;
      rs422_re_n = 0;
   end

   //
   // CLOCK MANAGEMENT
   //

   //system clock
   wire 			sys_clk = clk;

   //
   // RESET MANAGEMENT
   //


   //system reset

   wire                         sys_rst;

   reg [15:0] 			rst_cnt;

   always @(posedge sys_clk, negedge resetn)
     if(!resetn)
       rst_cnt <= 16'hFFFF;
     else if (rst_cnt != 16'h0)
       rst_cnt <= rst_cnt - 1'b1;

   assign sys_rst  = (rst_cnt != 16'h0);

   //
   // SYSTEM
   //
   assign chnl_rx_clk[0] = chnl_clk;
   assign chnl_tx_clk[0] = chnl_clk;
   
   // Instantiate and assign modules to RIFFA channels. Users should
   // replace the chnl_tester instantiation with their own core.
   system system
     (
      .clk           (sys_clk),
      .rst         (sys_rst),
      .trap          (),
      //UART
      .uart_txd      (uart_txd),
      .uart_rxd      (uart_rxd),
      .uart_rts      (uart_rts),
      .uart_cts      (1'b1),
      .PLD_CLK_IF(chnl_clk),
      .PLD_RST_IF(chnl_reset),
      .PCIE_CHNL_RX_IF(chnl_rx[0]),
//      .PCIE_CHNL_RX_CLK_IF(chnl_rx_clk[0]),
      .PCIE_CHNL_RX_ACK_IF(chnl_rx_ack[0]),
      .PCIE_CHNL_RX_LAST_IF(chnl_rx_last[0]),
      .PCIE_CHNL_RX_LEN_IF(chnl_rx_len[`SIG_CHNL_LENGTH_W*0 +:`SIG_CHNL_LENGTH_W]),
      .PCIE_CHNL_RX_OFF_IF(chnl_rx_off[`SIG_CHNL_OFFSET_W*0 +:`SIG_CHNL_OFFSET_W]),
      .PCIE_CHNL_RX_DATA_IF(chnl_rx_data[C_PCI_DATA_WIDTH*0 +:C_PCI_DATA_WIDTH]),
      .PCIE_CHNL_RX_DATA_VALID_IF(chnl_rx_data_valid[0]),
      .PCIE_CHNL_RX_DATA_REN_IF(chnl_rx_data_ren[0]),
  //    .PCIE_CHNL_TX_CLK_IF(chnl_tx_clk[0]),
      .PCIE_CHNL_TX_IF(chnl_tx[0]),
      .PCIE_CHNL_TX_ACK_IF(chnl_tx_ack[0]),
      .PCIE_CHNL_TX_LAST_IF(chnl_tx_last[0]),
      .PCIE_CHNL_TX_LEN_IF(chnl_tx_len[`SIG_CHNL_LENGTH_W*0 +:`SIG_CHNL_LENGTH_W]),
      .PCIE_CHNL_TX_OFF_IF(chnl_tx_off[`SIG_CHNL_OFFSET_W*0 +:`SIG_CHNL_OFFSET_W]),
      .PCIE_CHNL_TX_DATA_IF(chnl_tx_data[C_PCI_DATA_WIDTH*0 +:C_PCI_DATA_WIDTH]),
      .PCIE_CHNL_TX_DATA_VALID_IF(chnl_tx_data_valid[0]),
      .PCIE_CHNL_TX_DATA_REN_IF(chnl_tx_data_ren[0])
      );



endmodule
